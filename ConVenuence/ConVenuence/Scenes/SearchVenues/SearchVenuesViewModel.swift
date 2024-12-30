import SwiftUI
import Combine
import CVCore

protocol SearchVenuesViewModelProtocol: ObservableObject {
    var searchQuery: String { get set }
    var venues: [Venue] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    func fetchVenues()
}

// MARK: - SearchVenuesViewModel
class SearchVenuesViewModel: SearchVenuesViewModelProtocol {
    
    // MARK: - Bindable Properties
    
    @Published var searchQuery: String = ""
    @Published private(set) var venues: [Venue] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Properties
    
    private let venueRepositoryService: VenueRepositoryService
    private var cancellables: Set<AnyCancellable> = []
    private let debouncer: Debouncer
    
    // MARK: - Initializers

    init(venueRepositoryService: VenueRepositoryService, debounceInterval: TimeInterval = 0.5) {
        self.venueRepositoryService = venueRepositoryService
        self.debouncer = Debouncer(delay: debounceInterval)
        bindSearchQuery()
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
                let request = SearchVenuesRequest(query: searchQuery, location: (latitude: 40.7128, longitude: -74.0060)) // Example location
                venues = try await venueRepositoryService.searchVenues(request: request)
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func bindSearchQuery() {
        $searchQuery
            .sink { [weak self] query in
                self?.debouncer.run { self?.fetchVenues() }
            }
            .store(in: &cancellables)
    }
}

class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func run(action: @escaping () -> Void) {
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
}
