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
        let venue1 = Venue(venue: Venue.sample1, isFavorite: false)
        let venue2 = Venue(venue: Venue.sample2, isFavorite: false)
        let venue3 = Venue(venue: Venue.sample3, isFavorite: false)

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
        let venue1 = Venue(venue: Venue.sample1, isFavorite: false)
        let venue2 = Venue(venue: Venue.sample2, isFavorite: false)
        
        try await venuePersistenceService.saveVenue(venue1)
        try await venuePersistenceService.saveVenue(venue2)
        try await venuePersistenceService.saveFavorite(venueId: venue1.id)
        try await venuePersistenceService.saveFavorite(venueId: venue2.id)
        
        // Act
        let favoriteVenues = try await venuePersistenceService.fetchFavoriteVenues()
        print("Favorite venues: \(favoriteVenues)")
        
        // Assert
        XCTAssertEqual(favoriteVenues.count, 2)
        let favoriteVenueIds = favoriteVenues.map { $0.id }
        XCTAssertTrue(favoriteVenueIds.contains(venue1.id))
        XCTAssertTrue(favoriteVenueIds.contains(venue2.id))
    }
    
    func testSaveAndFetchVenueDetail() async throws {
        // Arrange
        let venueDetail = VenueDetail.sample1
        
        // Act
        try await venuePersistenceService.saveVenueDetail(venueDetail)
        let fetchedDetail = try await venuePersistenceService.fetchVenueDetail(by: venueDetail.id)
        
        // Assert
        XCTAssertEqual(fetchedDetail, venueDetail)
    }
    
    func testFetchVenueDetails() async throws {
        // Arrange
        let venueDetail1 = VenueDetail.sample1
        let venueDetail2 = VenueDetail.sample2
        
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
        let venue = Venue.sample1
        
        // Act
        try await venuePersistenceService.saveVenue(venue)
        let fetchedVenue = try await venuePersistenceService.fetchVenue(by: venue.id)
        
        // Assert
        XCTAssertEqual(fetchedVenue, venue)
    }
    
    func testFetchVenues() async throws {
        // Arrange
        let venue1 = Venue.sample1
        let venue2 = Venue.sample2
        
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
        let venue1 = Venue.sample1
        let venue2 = Venue.sample2
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
