import SwiftUI
import CoreLocation
import Combine
import CVCore

@MainActor
class SearchVenuesViewModel: ObservableObject, FavoriteRepositoryDelegate {
    
    // MARK: - Bindable Properties
    
    @Published var searchQuery: String = "" {
        didSet {
            if searchQuery.isEmpty {
                venues = []
            }
        }
    }
    @Published private(set) var venues: [Venue] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Properties
    public var currentLocation: CLLocation {
        userLocationService.currentLocation
    }
    
    private let venueRepositoryService: VenueRepositoryService
    private let userLocationService: UserLocationService
    private var cancellables: Set<AnyCancellable> = []
    private let debouncer: Debouncer

    // MARK: - Initializers
    
    init(
        venueRepositoryService: VenueRepositoryService,
        userLocationService: UserLocationService,
        debounceInterval: TimeInterval = 0.5
    ) {
        print("Current Location in SearchVenuesViewModel: \(userLocationService.currentLocation)")
        
        self.venueRepositoryService = venueRepositoryService
        self.userLocationService = userLocationService
        self.debouncer = Debouncer(delay: debounceInterval)
        bindSearchQuery()
        bindFavoriteChanges()
    }
    
    // MARK: - Public Methods

    func fetchVenues() {
        guard !searchQuery.isEmpty else {
            venues = []
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedVenues = try await venueRepositoryService.searchVenues(at: currentLocation, query: searchQuery)
                venues = fetchedVenues
                isLoading = false
            } catch let error as APIClientError {
                errorMessage = error.userFriendlyMessage
                isLoading = false
            } catch {
                errorMessage = "An unexpected error occurred. Please try again later."
                isLoading = false
            }
        }
    }

    func setFavorite(for venueId: VenueId, to isFavorite: Bool) {
        Task {
            do {
                if isFavorite {
                    try await venueRepositoryService.saveFavorite(venueId: venueId)
                } else {
                    try await venueRepositoryService.removeFavorite(venueId: venueId)
                }
                await refreshVenuesFromCache()
            } catch let error as APIClientError {
                errorMessage = error.userFriendlyMessage
            } catch {
                errorMessage = "An unexpected error occurred. Please try again later."
            }
        }
    }
    
    // MARK: - Private utility methods

    private func bindSearchQuery() {
        $searchQuery
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.debouncer.run {
                    self?.fetchVenues()
                }
            }
            .store(in: &cancellables)
    }

    private func bindFavoriteChanges() {
        venueRepositoryService.favoriteChangesPublisher
            .sink { [weak self] in
                Task { await self?.refreshVenuesFromCache() }
            }
            .store(in: &cancellables)
    }

    private func refreshVenuesFromCache() async {
        do {
            let cachedVenues = try await venueRepositoryService.searchVenuesFromCache(at: currentLocation, query: searchQuery)
            venues = cachedVenues
        } catch let error as APIClientError {
            errorMessage = error.userFriendlyMessage
        } catch {
            errorMessage = "An unexpected error occurred while refreshing cached data."
        }
    }
}

