import Foundation

// MARK: - VenueService Protocol

public protocol VenueService {
    func searchVenues(request: SearchVenuesRequest) async throws -> [Venue]
    func getVenueDetails(id: VenueId) async throws -> VenueDetail
    func getFavorites() async throws -> [Venue]
    func saveFavorite(venueId: VenueId) async throws
    func removeFavorite(venueId: VenueId) async throws
    func isFavorite(id: VenueId) async throws -> Bool
}

// MARK: - VenueService Implementation

public final class VenueServiceImpl: VenueService {

    // MARK: - Dependencies
    
    private let apiClient: VenueAPIClient
    private let persistenceService: VenuePersistenceService

    // MARK: - Initializers

    public init(apiClient: VenueAPIClient, persistenceService: VenuePersistenceService) {
        self.apiClient = apiClient
        self.persistenceService = persistenceService
    }

    // MARK: - VenueService Methods
    
    public func searchVenues(request: SearchVenuesRequest) async throws -> [Venue] {
        let favoriteIds = try await persistenceService.fetchFavoriteIds()

        do {
            // Try fetching from the network
            let response: SearchVenuesResponse = try await apiClient.searchVenues(request: request)
            let venues = response.results.map { Venue(fsdto: $0, isFavorite: favoriteIds.contains($0.id)) }
            try await persistenceService.saveSearchResults(for: request, venueIds: venues.map { $0.id })
            return venues
        } catch {
            // If network fetch fails or it isn't available, try fetching from the persistence layer
            if let venueIds = try await persistenceService.fetchSearchResults(for: request) {
                let venues = try await persistenceService.fetchVenues(by: venueIds)
                return venues.map { Venue(id: $0.id, name: $0.name, isFavorite: favoriteIds.contains($0.id)) }
            } else {
                throw error
            }
        }
    }

    public func getVenueDetails(id: VenueId) async throws -> VenueDetail {
        let favoriteIds = try await persistenceService.fetchFavoriteIds()
        do {
            // Try fetching from the network
            let response: FetchVenueDetailsResponse = try await apiClient.fetchVenueDetails(request: FetchVenueDetailsRequest(id: id))
            let isFavorite = favoriteIds.contains(response.id)
            // TODO: Handle fetch photo URLs
            let photoUrls: [URL] = []
            let venueDetail = VenueDetail(fsdto: response, isFavorite: isFavorite, photoUrls: photoUrls)
            try await persistenceService.saveVenueDetail(venueDetail)
            return venueDetail
        } catch {
            // If network fetch fails for any reason, try fetching from persistence layer
            if let venueDetail = try await persistenceService.fetchVenueDetail(by: id) {
                return venueDetail
            } else {
                throw error
            }
        }
    }

    public func getFavorites() async throws -> [Venue] {
        return try await persistenceService.fetchFavoriteVenues()
    }

    public func saveFavorite(venueId: VenueId) async throws {
        try await persistenceService.saveFavorite(venueId: venueId)
    }

    public func removeFavorite(venueId: VenueId) async throws {
        try await persistenceService.removeFavorite(venueId: venueId)
    }

    public func isFavorite(id: VenueId) async throws -> Bool {
        let favoriteIds = try await persistenceService.fetchFavoriteIds()
        return favoriteIds.contains(id)
    }
}
