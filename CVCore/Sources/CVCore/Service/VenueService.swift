import Foundation

// MARK: - VenueService Protocol

public protocol VenueService {
    func searchVenues(request: SearchVenuesRequest) async throws -> [FoursqareDTO.Venue]
    func getVenueDetails(id: String) async throws -> FoursqareDTO.VenueDetails
    func getFavorites() async throws -> [FoursqareDTO.Venue]
    func saveFavorite(_ venue: FoursqareDTO.Venue) async throws
    func removeFavorite(_ venue: FoursqareDTO.Venue) async throws
    func isFavorite(_ venue: FoursqareDTO.Venue) async throws -> Bool
}

// MARK: - Domain Models


// MARK: - VenueService Implementation

public final class VenueServiceImpl: VenueService {

    // Dependencies
    private let apiClient: VenueAPIClient
    private let persistenceService: VenuePersistenceService

    // Initializer
    public init(apiClient: VenueAPIClient, persistenceService: VenuePersistenceService) {
        self.apiClient = apiClient
        self.persistenceService = persistenceService
    }

    // MARK: - VenueService Methods

    public func searchVenues(request: SearchVenuesRequest) async throws -> [FoursqareDTO.Venue] {
        // Try and fetch data from the cache - a cache invalidation strategy should be implemented in a real-world scenario to avoid stale data
        // Also this should be paginated, but I'll skip it as it outside of the project scope
        if let cachedResults = try await persistenceService.fetchSearchResults(for: request) {
            return cachedResults
        } else {
            let response = try await apiClient.searchVenues(request: request)
            try await persistenceService.saveSearchResults(for: request, venues: response.results)
            return response.results
        }
    }

    public func getVenueDetails(id: String) async throws -> FoursqareDTO.VenueDetails {
        // Fetch details from the API
        // In my opinion, these should be cached as well, but I'll skip it as it outside of the project scope
        let request = FetchVenueDetailsRequest(id: id)
        return try await apiClient.fetchVenueDetails(request: request)
    }

    public func getFavorites() async throws -> [FoursqareDTO.Venue] {
        return try await persistenceService.fetchFavorites()
    }

    public func saveFavorite(_ venue: FoursqareDTO.Venue) async throws {
        try await persistenceService.saveFavorite(venue)
    }

    public func removeFavorite(_ venue: FoursqareDTO.Venue) async throws {
        try await persistenceService.removeFavorite(venue)
    }

    public func isFavorite(_ venue: FoursqareDTO.Venue) async throws -> Bool {
        return try await persistenceService.isFavorite(venue)
    }
}
