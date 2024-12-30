import Foundation
import CoreLocation

// MARK: - VenueRepositoryService Protocol

public protocol VenueRepositoryService {
    func searchVenues(at location: CLLocation, query: String) async throws -> [Venue]
    func getVenueDetails(id: VenueId) async throws -> VenueDetail
    func getFavorites() async throws -> [Venue]
    func saveFavorite(venueId: VenueId) async throws
    func removeFavorite(venueId: VenueId) async throws
    func isFavorite(id: VenueId) async throws -> Bool
}

// MARK: - VenueRepositoryService Implementation

public final class VenueRepositoryServiceImpl: VenueRepositoryService {

    // MARK: - Dependencies
    
    private let apiClient: VenueAPIClient
    private let persistenceService: VenuePersistenceService

    // MARK: - Initializers

    public init(apiClient: VenueAPIClient, persistenceService: VenuePersistenceService) {
        self.apiClient = apiClient
        self.persistenceService = persistenceService
    }

    // MARK: - VenueRepositoryService Methods
    
    public func searchVenues(at location: CLLocation, query: String) async throws -> [Venue] {
        let request = SearchVenuesRequest(query: query, location: location)
        let favoriteIds = try await persistenceService.fetchFavoriteIds()

        do {
            // Try fetching from the network
            let response: SearchVenuesResponse = try await apiClient.searchVenues(request: request)
            let venues = response.results.map { Venue(fsdto: $0, isFavorite: favoriteIds.contains($0.id)) }
            // Persist venue instances and search results
            try await persistenceService.saveVenues(venues)
            try await persistenceService.saveSearchResults(for: request, venueIds: venues.map { $0.id })
            // Return the fetched venues
            return venues
        } catch {
            // If network fetch fails or it isn't available, try fetching from the persistence layer
            if let venueIds = try await persistenceService.fetchSearchResults(for: request) {
                let venues = try await persistenceService.fetchVenues(by: venueIds)
                return venues.map { Venue(venue: $0, isFavorite: favoriteIds.contains($0.id)) }
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
            // TODO: Handle fetch photo URLs if I'm going to use them at all!
            let venueDetail = VenueDetail(fsdto: response, isFavorite: isFavorite)
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