import XCTest
import CoreLocation

@testable import CVCore

final class VenueRepositoryServiceTests: XCTestCase {

    var venueRepositoryService: VenueRepositoryService!
    var mockApiClient: MockVenueAPIClient!
    var mockPersistenceService: MockVenuePersistenceService!

    override func setUp() {
        super.setUp()
        mockApiClient = MockVenueAPIClient()
        mockPersistenceService = MockVenuePersistenceService()
        venueRepositoryService = VenueRepositoryServiceImpl(
            apiClient: mockApiClient, persistenceService: mockPersistenceService)
    }

    override func tearDown() {
        venueRepositoryService = nil
        mockApiClient = nil
        mockPersistenceService = nil
        super.tearDown()
    }

    func testSearchVenuesSuccess() async throws {
        // Arrange
        let location = CLLocation(latitude: 40.7128, longitude: -74.0060)
        let query = "coffee"
        let expectedVenues = [
            Venue.sample1
        ]
        mockApiClient.searchVenuesResult = SearchVenuesResponse(
            results: [FoursquareDTO.Venue.sample1])
        mockPersistenceService.fetchFavoriteIdsResult = []

        // Act
        let venues = try await venueRepositoryService.searchVenues(at: location, query: query)

        // Assert
        XCTAssertEqual(venues, expectedVenues)
        XCTAssertEqual(mockPersistenceService.savedVenues, expectedVenues)
    }

    func testSearchVenuesNetworkFailure() async throws {
        // Arrange
        let location = CLLocation(latitude: 40.7128, longitude: -74.0060)
        let query = "coffee"
        mockApiClient.searchVenuesResult = nil
        mockPersistenceService.fetchSearchResultsResult = ["1"]
        let expectedVenues = [
            Venue.sample1
        ]
        mockPersistenceService.fetchVenuesResult = expectedVenues

        // Act
        let venues = try await venueRepositoryService.searchVenues(at: location, query: query)

        // Assert
        XCTAssertEqual(venues, expectedVenues)
    }

    func testGetVenueDetailsSuccess() async throws {
        // Arrange
        let venueId = "1"
        let expectedVenueDetail = VenueDetail.sample1
        mockApiClient.fetchVenueDetailsResult = FoursquareDTO.VenueDetails.sample1
        mockApiClient.fetchVenuePhotosResult = FoursquareDTO.Photo.samplePhotos
        mockPersistenceService.fetchFavoriteIdsResult = []

        // Act
        let venueDetail = try await venueRepositoryService.getVenueDetails(id: venueId)

        // Assert
        XCTAssertEqual(venueDetail, expectedVenueDetail)
        XCTAssertEqual(mockPersistenceService.savedVenueDetail, expectedVenueDetail)
    }

    func testGetVenueDetailsNetworkFailure() async throws {
        // Arrange
        let venueId = "1"
        mockApiClient.fetchVenueDetailsResult = nil
        let expectedVenueDetail = VenueDetail.sample1
        mockPersistenceService.fetchVenueDetailResult = expectedVenueDetail

        // Act
        let venueDetail = try await venueRepositoryService.getVenueDetails(id: venueId)

        // Assert
        XCTAssertEqual(venueDetail, expectedVenueDetail)
    }

    func testSaveFavorite() async throws {
        // Arrange
        let venueId = "1"

        // Act
        try await venueRepositoryService.saveFavorite(venueId: venueId)

        // Assert
        XCTAssertTrue(mockPersistenceService.savedFavoriteIds.contains(venueId))
    }

    func testRemoveFavorite() async throws {
        // Arrange
        let venueId = "1"
        mockPersistenceService.fetchFavoriteIdsResult = [venueId]

        // Act
        try await venueRepositoryService.removeFavorite(venueId: venueId)

        // Assert
        XCTAssertFalse(mockPersistenceService.savedFavoriteIds.contains(venueId))
    }

    func testIsFavorite() async throws {
        // Arrange
        let venueId = "1"
        mockPersistenceService.fetchFavoriteIdsResult = [venueId]

        // Act
        let isFavorite = try await venueRepositoryService.isFavorite(id: venueId)

        // Assert
        XCTAssertTrue(isFavorite)
    }

    func testGetFavorites() async throws {
        // Arrange
        let expectedFavorites = [
            Venue.sample2
        ]
        mockPersistenceService.fetchFavoriteVenuesResult = expectedFavorites

        // Act
        let favorites = try await venueRepositoryService.getFavorites()

        // Assert
        XCTAssertEqual(favorites, expectedFavorites)
    }
}
