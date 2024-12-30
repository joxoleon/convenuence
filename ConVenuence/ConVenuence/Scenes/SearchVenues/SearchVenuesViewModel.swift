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
                venues = [] // Reset venues immediately when the query is empty
            }
        }
    }
    @Published private(set) var venues: [Venue] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var currentLocation: CLLocation

    // MARK: - Properties

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
        self.venueRepositoryService = venueRepositoryService
        self.userLocationService = userLocationService
        self.debouncer = Debouncer(delay: debounceInterval)
        self.currentLocation = userLocationService.currentLocation
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
                let location = currentLocation
                let fetchedVenues = try await venueRepositoryService.searchVenues(at: location, query: searchQuery)
                venues = fetchedVenues
                isLoading = false
            } catch {
                print("Error fetching venues: \(error)")
                errorMessage = error.localizedDescription
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
            } catch {
                print("Error setting favorite: \(error)")
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Private Methods

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
        } catch {
            print("Error refreshing venues from cache: \(error)")
        }
    }
}
