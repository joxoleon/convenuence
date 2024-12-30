import XCTest
@testable import CVCore

final class VenueRepositoryServiceTests: XCTestCase {

    var venueRepositoryService: VenueRepositoryService!
    var mockApiClient: MockVenueAPIClient!
    var mockPersistenceService: MockVenuePersistenceService!

    override func setUp() {
        super.setUp()
        mockApiClient = MockVenueAPIClient()
        mockPersistenceService = MockVenuePersistenceService()
        venueRepositoryService = VenueRepositoryServiceImpl(apiClient: mockApiClient, persistenceService: mockPersistenceService)
    }

    override func tearDown() {
        venueRepositoryService = nil
        mockApiClient = nil
        mockPersistenceService = nil
        super.tearDown()
    }

    func testSearchVenuesSuccess() async throws {
        // Arrange
        let request = SearchVenuesRequest(query: "coffee", location: (latitude: 40.7128, longitude: -74.0060))
        let expectedVenues = [Venue(id: "1", name: "Coffee Shop", isFavorite: false, categoryIconUrl: nil)]
        mockApiClient.searchVenuesResult = SearchVenuesResponse(results: expectedVenues.map { FoursqareDTO.Venue(id: $0.id, name: $0.name, location: FoursqareDTO.Location(address: "", formatted_address: "", locality: "", postcode: "", region: "", country: ""), categories: [] ) })
        mockPersistenceService.fetchFavoriteIdsResult = []

        // Act
        let venues = try await venueRepositoryService.searchVenues(request: request)

        // Assert
        XCTAssertEqual(venues, expectedVenues)
        XCTAssertEqual(mockPersistenceService.savedVenues, expectedVenues)
    }

    func testSearchVenuesNetworkFailure() async throws {
        // Arrange
        let request = SearchVenuesRequest(query: "coffee", location: (latitude: 40.7128, longitude: -74.0060))
        mockApiClient.searchVenuesResult = nil
        mockPersistenceService.fetchSearchResultsResult = ["1"]
        let expectedVenues = [Venue(id: "1", name: "Coffee Shop", isFavorite: false, categoryIconUrl: nil)]
        mockPersistenceService.fetchVenuesResult = expectedVenues

        // Act
        let venues = try await venueRepositoryService.searchVenues(request: request)

        // Assert
        XCTAssertEqual(venues, expectedVenues)
    }

    func testGetVenueDetailsSuccess() async throws {
        // Arrange
        let venueId = "1"
        let expectedVenueDetail = VenueDetail(id: venueId, name: "Coffee Shop", description: "A nice place", isFavorite: false, photoUrls: [])
        mockApiClient.fetchVenueDetailsResult = FoursqareDTO.VenueDetails(id: venueId, name: "Coffee Shop", description: "A nice place", location: FoursqareDTO.Location(address: "", formatted_address: "", locality: "", postcode: "", region: "", country: ""), categories: [], geocodes: FoursqareDTO.Geocodes(main: FoursqareDTO.Coordinate(latitude: 0, longitude: 0)))
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
        let expectedVenueDetail = VenueDetail(id: venueId, name: "Coffee Shop", description: "A nice place", isFavorite: false, photoUrls: [])
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
        let expectedFavorites = [Venue(id: "1", name: "Coffee Shop", isFavorite: true, categoryIconUrl: nil)]
        mockPersistenceService.fetchFavoriteVenuesResult = expectedFavorites

        // Act
        let favorites = try await venueRepositoryService.getFavorites()

        // Assert
        XCTAssertEqual(favorites, expectedFavorites)
    }
}