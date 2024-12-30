import SwiftUI
import CoreLocation
import Combine
import CVCore

protocol SearchVenuesViewModelProtocol: ObservableObject {
    var searchQuery: String { get set }
    var venues: [Venue] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var currentLocation: CLLocation { get }
    func fetchVenues()
}

class SearchVenuesViewModel: SearchVenuesViewModelProtocol {

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
        debounceInterval: TimeInterval = 0.75
    ) {
        self.venueRepositoryService = venueRepositoryService
        self.userLocationService = userLocationService
        self.debouncer = Debouncer(delay: debounceInterval)
        self.currentLocation = userLocationService.currentLocation
        bindSearchQuery()
    }

    // MARK: - Public Methods

    func fetchVenues() {
        guard !searchQuery.isEmpty else {
            DispatchQueue.main.async {
                self.venues = []
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        Task(priority: .background) { [weak self] in
            guard let self = self else { return }
            do {
                let location = self.userLocationService.currentLocation
                let fetchedVenues = try await self.venueRepositoryService.searchVenues(at: location, query: self.searchQuery)

                // Update venues and isLoading state on the main thread
                DispatchQueue.main.async {
                    self.venues = fetchedVenues
                    self.isLoading = false
                }
            } catch {
                print("Error fetching venues: \(error)")

                // Handle error and update the state on the main thread
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
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
}
