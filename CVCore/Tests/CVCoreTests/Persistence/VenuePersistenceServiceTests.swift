import XCTest

@testable import CVCore

final class VenuePersistenceServiceTests: XCTestCase {

    private var venuePersistenceService:
        VenuePersistenceServiceImpl<
            MockPersistenceService<FoursqareDTO.Venue>,
            MockPersistenceService<[String: [FoursqareDTO.Venue]]>
        >!
    private var favoritesPersistence: MockPersistenceService<FoursqareDTO.Venue>!
    private var searchResultsPersistence: MockPersistenceService<[String: [FoursqareDTO.Venue]]>!

    override func setUp() {
        super.setUp()
        favoritesPersistence = MockPersistenceService<FoursqareDTO.Venue>()
        searchResultsPersistence = MockPersistenceService<[String: [FoursqareDTO.Venue]]>()
        venuePersistenceService = VenuePersistenceServiceImpl(
            favoritesPersistence: favoritesPersistence,
            searchResultsPersistence: searchResultsPersistence)
    }

    override func tearDown() {
        favoritesPersistence = nil
        searchResultsPersistence = nil
        venuePersistenceService = nil
        super.tearDown()
    }

    func testSaveFavorite() async throws {
        // Arrange
        let venue = FoursqareDTO.Venue(
            id: "1", name: "Test Venue",
            location: FoursqareDTO.Location(
                address: "123 Test St",
                formatted_address: "123 Test St, Test City",
                locality: "Test City",
                postcode: "12345",
                region: "Test Region",
                country: "Test Country"
            )
        )
        
        // Act
        try await venuePersistenceService.saveFavorite(venue)
        let favorites = try await favoritesPersistence.fetchAll()
        
        // Assert
        XCTAssertEqual(favorites, [venue])
    }

    func testFetchFavorites() async throws {
        // Arrange
        let venue1 = FoursqareDTO.Venue(
            id: "1", name: "Test Venue 1",
            location: FoursqareDTO.Location(
                address: "123 Test St",
                formatted_address: "123 Test St, Test City",
                locality: "Test City",
                postcode: "12345",
                region: "Test Region",
                country: "Test Country"
            )
        )
        let venue2 = FoursqareDTO.Venue(
            id: "2", name: "Test Venue 2",
            location: FoursqareDTO.Location(
                address: "456 Test St",
                formatted_address: "456 Test St, Test City",
                locality: "Test City",
                postcode: "67890",
                region: "Test Region",
                country: "Test Country"
            )
        )
        try await favoritesPersistence.save(entity: venue1)
        try await favoritesPersistence.save(entity: venue2)
        
        // Act
        let favorites = try await venuePersistenceService.fetchFavorites()
        
        // Assert
        XCTAssertEqual(favorites, [venue1, venue2])
    }

    func testRemoveFavorite() async throws {
        // Arrange
        let venue = FoursqareDTO.Venue(
            id: "1", name: "Test Venue",
            location: FoursqareDTO.Location(
                address: "123 Test St",
                formatted_address: "123 Test St, Test City",
                locality: "Test City",
                postcode: "12345",
                region: "Test Region",
                country: "Test Country"
            )
        )
        try await favoritesPersistence.save(entity: venue)
        
        // Act
        try await venuePersistenceService.removeFavorite(venue)
        let favorites = try await favoritesPersistence.fetchAll()
        
        // Assert
        XCTAssertTrue(favorites.isEmpty)
    }

    func testIsFavorite() async throws {
        // Arrange
        let venue = FoursqareDTO.Venue(
            id: "1", name: "Test Venue",
            location: FoursqareDTO.Location(
                address: "123 Test St",
                formatted_address: "123 Test St, Test City",
                locality: "Test City",
                postcode: "12345",
                region: "Test Region",
                country: "Test Country"
            )
        )
        try await favoritesPersistence.save(entity: venue)
        
        // Act
        let isFavorite = try await venuePersistenceService.isFavorite(venue)
        
        // Assert
        XCTAssertTrue(isFavorite)
    }

    func testSaveSearchResults() async throws {
        // Arrange
        let venue = FoursqareDTO.Venue(
            id: "1", name: "Test Venue",
            location: FoursqareDTO.Location(
                address: "123 Test St",
                formatted_address: "123 Test St, Test City",
                locality: "Test City",
                postcode: "12345",
                region: "Test Region",
                country: "Test Country"
            )
        )
        let query = "Test Query"
        let searchRequest = SearchVenuesRequest(query: query, location: (latitude: 0, longitude: 0))
        
        // Act
        try await venuePersistenceService.saveSearchResults(for: searchRequest, venues: [venue])
        let searchResults = try await searchResultsPersistence.fetchAll().first
        
        // Assert
        XCTAssertEqual(searchResults?[query], [venue])
    }

    func testFetchSearchResults() async throws {
        // Arrange
        let venue = FoursqareDTO.Venue(
            id: "1", name: "Test Venue",
            location: FoursqareDTO.Location(
                address: "123 Test St",
                formatted_address: "123 Test St, Test City",
                locality: "Test City",
                postcode: "12345",
                region: "Test Region",
                country: "Test Country"
            )
        )
        let query = "Test Query"
        let searchRequest = SearchVenuesRequest(query: query, location: (latitude: 0, longitude: 0))
        
        try await searchResultsPersistence.save(entity: [query: [venue]])
        
        // Act
        let searchResults = try await venuePersistenceService.fetchSearchResults(for: searchRequest)
        
        // Assert
        XCTAssertEqual(searchResults, [venue])
    }

    func testClearSearchResults() async throws {
        // Arrange
        let venue = FoursqareDTO.Venue(
            id: "1", name: "Test Venue",
            location: FoursqareDTO.Location(
                address: "123 Test St",
                formatted_address: "123 Test St, Test City",
                locality: "Test City",
                postcode: "12345",
                region: "Test Region",
                country: "Test Country"
            )
        )
        let query = "Test Query"
        try await searchResultsPersistence.save(entity: [query: [venue]])
        
        // Act
        try await venuePersistenceService.clearSearchResults()
        let searchResults = try await searchResultsPersistence.fetchAll()
        
        // Assert
        XCTAssertTrue(searchResults.isEmpty)
    }
}
