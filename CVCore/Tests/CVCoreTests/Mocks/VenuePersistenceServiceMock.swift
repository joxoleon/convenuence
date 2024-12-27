import XCTest
@testable import CVCore

class MockVenuePersistenceService: VenuePersistenceService {
    var fetchFavoriteIdsResult: [VenueId] = []
    var fetchFavoriteVenuesResult: [Venue] = []
    var fetchVenueDetailResult: VenueDetail?
    var fetchVenuesResult: [Venue] = []
    var fetchSearchResultsResult: [VenueId]?
    var savedFavoriteIds: [VenueId] = []
    var savedVenues: [Venue] = []
    var savedVenueDetail: VenueDetail?

    func saveFavorite(venueId: VenueId) async throws {
        savedFavoriteIds.append(venueId)
    }

    func removeFavorite(venueId: VenueId) async throws {
        savedFavoriteIds.removeAll { $0 == venueId }
    }

    func fetchFavoriteIds() async throws -> [VenueId] {
        return fetchFavoriteIdsResult
    }

    func fetchFavoriteVenues() async throws -> [Venue] {
        return fetchFavoriteVenuesResult
    }

    func saveVenueDetail(_ venueDetail: VenueDetail) async throws {
        savedVenueDetail = venueDetail
    }

    func fetchVenueDetail(by id: VenueId) async throws -> VenueDetail? {
        return fetchVenueDetailResult
    }

    func fetchVenueDetails(by ids: [VenueId]?) async throws -> [VenueDetail] {
        return []
    }

    func saveVenue(_ venue: Venue) async throws {
        savedVenues.append(venue)
    }

    func saveVenues(_ venues: [Venue]) async throws {
        savedVenues.append(contentsOf: venues)
    }

    func fetchVenue(by id: VenueId) async throws -> Venue? {
        return nil
    }

    func fetchVenues(by ids: [VenueId]?) async throws -> [Venue] {
        return fetchVenuesResult
    }

    func saveSearchResults(for request: SearchVenuesRequest, venueIds: [VenueId]) async throws {}

    func fetchSearchResults(for request: SearchVenuesRequest) async throws -> [VenueId]? {
        return fetchSearchResultsResult
    }
}
