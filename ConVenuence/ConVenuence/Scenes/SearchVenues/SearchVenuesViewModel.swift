import SwiftUI
import CoreLocation
import Combine
import CVCore

// MARK: - SearchVenuesViewModelProtocol
protocol SearchVenuesViewModelProtocol: ObservableObject {
    var searchQuery: String { get set }
    var venues: [Venue] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var currentLocation: CLLocation { get }
    func fetchVenues()
}

// MARK: - SearchVenuesViewModel
class SearchVenuesViewModel: SearchVenuesViewModelProtocol {

    // MARK: - Bindable Properties

    @Published var searchQuery: String = ""
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
        self.currentLocation = CLLocation(latitude: 44.8191, longitude: 20.4154) // Default to New Belgrade
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

        Task(priority: .background) { // Perform the network task on a background thread
            do {
                let location = userLocationService.currentLocation
                let fetchedVenues = try await venueRepositoryService.searchVenues(at: location, query: self.searchQuery)

                // Update venues and isLoading state on the main thread
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.currentLocation = userLocationService.currentLocation
                    self.venues = fetchedVenues
                    self.isLoading = false
                }
            } catch {
                print("Error fetching venues: \(error)")

                // Handle error and update the state on the main thread
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.currentLocation = self.userLocationService.currentLocation
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }


    // MARK: - Private Methods

    private func bindSearchQuery() {
        $searchQuery
            .removeDuplicates() // Trigger only when the query actually changes
            .filter { !$0.isEmpty } // Only act when there's a non-empty search query
            .receive(on: DispatchQueue.main) // Ensure updates are on the main thread
            .sink { [weak self] _ in
                self?.debouncer.run {
                    self?.fetchVenues()
                }
            }
            .store(in: &cancellables)
    }
}
