import XCTest
@testable import CVCore

final class UserDefaultsVenuePersistenceServiceTests: XCTestCase {
    
    var venuePersistenceService: UserDefaultsVenuePersistenceService!
    let userDefaults = UserDefaults(suiteName: "TestDefaults")!
    
    override func setUp() {
        super.setUp()
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        venuePersistenceService = UserDefaultsVenuePersistenceService(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        venuePersistenceService = nil
        super.tearDown()
    }
    
    func testSaveAndFetchFavorite() async throws {
        // Arrange
        let venueId = "venue1"
        
        // Act
        try await venuePersistenceService.saveFavorite(venueId: venueId)
        let favoriteIds = try await venuePersistenceService.fetchFavoriteIds()
        
        // Assert
        XCTAssertTrue(favoriteIds.contains(venueId))
    }
    
    func testRemoveFavorite() async throws {
        // Arrange
        let venueId = "venue1"
        
        // Act
        try await venuePersistenceService.saveFavorite(venueId: venueId)
        try await venuePersistenceService.removeFavorite(venueId: venueId)
        let favoriteIds = try await venuePersistenceService.fetchFavoriteIds()
        
        // Assert
        XCTAssertFalse(favoriteIds.contains(venueId))
    }

    func testFavoritesComplex() async throws {
        // Arrange
        let venue1 = Venue(id: "venue1", name: "Venue 1", isFavorite: false, categoryIconUrl: nil)
        let venue2 = Venue(id: "venue2", name: "Venue 2", isFavorite: false, categoryIconUrl: nil)
        let venue3 = Venue(id: "venue3", name: "Venue 3", isFavorite: false, categoryIconUrl: nil)

        try await venuePersistenceService.saveVenues([venue1, venue2, venue3])

        // Set 1 and 3 as favorites
        try await venuePersistenceService.saveFavorite(venueId: venue1.id)
        try await venuePersistenceService.saveFavorite(venueId: venue3.id)

        // Assert that 1 and 3 are favorites and two isn't
        var v1 = try await venuePersistenceService.fetchVenue(by: venue1.id)
        var v2 = try await venuePersistenceService.fetchVenue(by: venue2.id)
        var v3 = try await venuePersistenceService.fetchVenue(by: venue3.id)
        XCTAssertTrue(v1?.isFavorite == true)
        XCTAssertTrue(v2?.isFavorite == false)
        XCTAssertTrue(v3?.isFavorite == true)

        // Remove 1 from favorites
        try await venuePersistenceService.removeFavorite(venueId: venue1.id)

        // Assert that 1 is no longer a favorite
        v1 = try await venuePersistenceService.fetchVenue(by: venue1.id)
        v2 = try await venuePersistenceService.fetchVenue(by: venue2.id)
        v3 = try await venuePersistenceService.fetchVenue(by: venue3.id)
        XCTAssertTrue(v1?.isFavorite == false)
        XCTAssertTrue(v2?.isFavorite == false)
        XCTAssertTrue(v3?.isFavorite == true)

    }
    
    func testFetchFavoriteVenues() async throws {
        // Arrange
        let venue1 = Venue(id: "venue1", name: "Venue 1", isFavorite: true, categoryIconUrl: nil)
        let venue2 = Venue(id: "venue2", name: "Venue 2", isFavorite: true, categoryIconUrl: nil)
        
        try await venuePersistenceService.saveVenue(venue1)
        try await venuePersistenceService.saveVenue(venue2)
        try await venuePersistenceService.saveFavorite(venueId: venue1.id)
        try await venuePersistenceService.saveFavorite(venueId: venue2.id)
        
        // Act
        let favoriteVenues = try await venuePersistenceService.fetchFavoriteVenues()
        print(favoriteVenues)
        
        // Assert
        XCTAssertEqual(favoriteVenues.count, 2)
        XCTAssertTrue(favoriteVenues.contains(venue1))
        XCTAssertTrue(favoriteVenues.contains(venue2))
    }
    
    func testSaveAndFetchVenueDetail() async throws {
        // Arrange
        let venueDetail = VenueDetail(id: "venue1", name: "Venue 1", description: "Description", isFavorite: true, photoUrls: [])
        
        // Act
        try await venuePersistenceService.saveVenueDetail(venueDetail)
        let fetchedDetail = try await venuePersistenceService.fetchVenueDetail(by: venueDetail.id)
        
        // Assert
        XCTAssertEqual(fetchedDetail, venueDetail)
    }
    
    func testFetchVenueDetails() async throws {
        // Arrange
        let venueDetail1 = VenueDetail(id: "venue1", name: "Venue 1", description: "Description 1", isFavorite: true, photoUrls: [])
        let venueDetail2 = VenueDetail(id: "venue2", name: "Venue 2", description: "Description 2", isFavorite: true, photoUrls: [])
        
        try await venuePersistenceService.saveVenueDetail(venueDetail1)
        try await venuePersistenceService.saveVenueDetail(venueDetail2)
        
        // Act
        let fetchedDetails = try await venuePersistenceService.fetchVenueDetails(by: [venueDetail1.id, venueDetail2.id])
        
        // Assert
        XCTAssertEqual(fetchedDetails.count, 2)
        XCTAssertTrue(fetchedDetails.contains(venueDetail1))
        XCTAssertTrue(fetchedDetails.contains(venueDetail2))
    }
    
    func testSaveAndFetchVenue() async throws {
        // Arrange
        let venue = Venue(id: "venue1", name: "Venue 1", isFavorite: true, categoryIconUrl: nil)
        
        // Act
        try await venuePersistenceService.saveVenue(venue)
        let fetchedVenue = try await venuePersistenceService.fetchVenue(by: venue.id)
        
        // Assert
        XCTAssertEqual(fetchedVenue, venue)
    }
    
    func testFetchVenues() async throws {
        // Arrange
        let venue1 = Venue(id: "venue1", name: "Venue 1", isFavorite: true, categoryIconUrl: nil)
        let venue2 = Venue(id: "venue2", name: "Venue 2", isFavorite: true, categoryIconUrl: nil)
        
        try await venuePersistenceService.saveVenue(venue1)
        try await venuePersistenceService.saveVenue(venue2)
        
        // Act
        let fetchedVenues = try await venuePersistenceService.fetchVenues(by: [venue1.id, venue2.id])
        
        // Assert
        XCTAssertEqual(fetchedVenues.count, 2)
        XCTAssertTrue(fetchedVenues.contains(venue1))
        XCTAssertTrue(fetchedVenues.contains(venue2))
    }
    
    func testSaveAndFetchSearchResults() async throws {
        // Arrange
        let request = SearchVenuesRequest(query: "venue2", location: (latitude: 0, longitude: 0))
        let venueIds = ["venue1", "venue2"]
        
        // Act
        try await venuePersistenceService.saveSearchResults(for: request, venueIds: venueIds)
        let fetchedResults = try await venuePersistenceService.fetchSearchResults(for: request)
        
        // Assert
        XCTAssertEqual(fetchedResults, venueIds)
    }

    func testSaveAndFetchMultipleVenues() async throws {
        // Arrange
        let venue1 = Venue(id: "venue1", name: "Venue 1", isFavorite: true, categoryIconUrl: nil)
        let venue2 = Venue(id: "venue2", name: "Venue 2", isFavorite: true, categoryIconUrl: nil)
        let venues = [venue1, venue2]
        
        // Act
        try await venuePersistenceService.saveVenues(venues)
        let fetchedVenues = try await venuePersistenceService.fetchVenues(by: [venue1.id, venue2.id])
        
        // Assert
        XCTAssertEqual(fetchedVenues.count, 2)
        XCTAssertTrue(fetchedVenues.contains(venue1))
        XCTAssertTrue(fetchedVenues.contains(venue2))
    }
}
