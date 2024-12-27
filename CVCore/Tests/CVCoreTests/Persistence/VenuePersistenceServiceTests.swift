import XCTest
@testable import CVCore

final class VenuePersistenceServiceTests: XCTestCase {
    
    var venuePersistenceService: UserDefaultsVenuePersistenceService!
    let userDefaults = UserDefaults(suiteName: "TestDefaults")!
    
    override func setUp() {
        super.setUp()
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        venuePersistenceService = UserDefaultsVenuePersistenceService()
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        venuePersistenceService = nil
        super.tearDown()
    }
    
    func testSaveAndFetchFavorite() async throws {
        let venueId = "venue1"
        
        try await venuePersistenceService.saveFavorite(venueId: venueId)
        let favoriteIds = try await venuePersistenceService.fetchFavoriteIds()
        
        XCTAssertTrue(favoriteIds.contains(venueId))
    }
    
    func testRemoveFavorite() async throws {
        let venueId = "venue1"
        
        try await venuePersistenceService.saveFavorite(venueId: venueId)
        try await venuePersistenceService.removeFavorite(venueId: venueId)
        let favoriteIds = try await venuePersistenceService.fetchFavoriteIds()
        
        XCTAssertFalse(favoriteIds.contains(venueId))
    }
    
    func testFetchFavoriteVenues() async throws {
        let venue1 = Venue(id: "venue1", name: "Venue 1", isFavorite: true)
        let venue2 = Venue(id: "venue2", name: "Venue 2", isFavorite: true)
        
        try await venuePersistenceService.saveVenue(venue1)
        try await venuePersistenceService.saveVenue(venue2)
        try await venuePersistenceService.saveFavorite(venueId: venue1.id)
        try await venuePersistenceService.saveFavorite(venueId: venue2.id)
        
        let favoriteVenues = try await venuePersistenceService.fetchFavoriteVenues()
        
        XCTAssertEqual(favoriteVenues.count, 2)
        XCTAssertTrue(favoriteVenues.contains(venue1))
        XCTAssertTrue(favoriteVenues.contains(venue2))
    }
    
    func testSaveAndFetchVenueDetail() async throws {
        let venueDetail = VenueDetail(id: "venue1", name: "Venue 1", description: "Description", isFavorite: true, photoUrls: [])
        
        try await venuePersistenceService.saveVenueDetail(venueDetail)
        let fetchedDetail = try await venuePersistenceService.fetchVenueDetail(by: venueDetail.id)
        
        XCTAssertEqual(fetchedDetail, venueDetail)
    }
    
    func testFetchVenueDetails() async throws {
        let venueDetail1 = VenueDetail(id: "venue1", name: "Venue 1", description: "Description 1", isFavorite: true, photoUrls: [])
        let venueDetail2 = VenueDetail(id: "venue2", name: "Venue 2", description: "Description 2", isFavorite: true, photoUrls: [])
        
        try await venuePersistenceService.saveVenueDetail(venueDetail1)
        try await venuePersistenceService.saveVenueDetail(venueDetail2)
        
        let fetchedDetails = try await venuePersistenceService.fetchVenueDetails(by: [venueDetail1.id, venueDetail2.id])
        
        XCTAssertEqual(fetchedDetails.count, 2)
        XCTAssertTrue(fetchedDetails.contains(venueDetail1))
        XCTAssertTrue(fetchedDetails.contains(venueDetail2))
    }
    
    func testSaveAndFetchVenue() async throws {
        let venue = Venue(id: "venue1", name: "Venue 1", isFavorite: true)
        
        try await venuePersistenceService.saveVenue(venue)
        let fetchedVenue = try await venuePersistenceService.fetchVenue(by: venue.id)
        
        XCTAssertEqual(fetchedVenue, venue)
    }
    
    func testFetchVenues() async throws {
        let venue1 = Venue(id: "venue1", name: "Venue 1", isFavorite: true)
        let venue2 = Venue(id: "venue2", name: "Venue 2", isFavorite: true)
        
        try await venuePersistenceService.saveVenue(venue1)
        try await venuePersistenceService.saveVenue(venue2)
        
        let fetchedVenues = try await venuePersistenceService.fetchVenues(by: [venue1.id, venue2.id])
        
        XCTAssertEqual(fetchedVenues.count, 2)
        XCTAssertTrue(fetchedVenues.contains(venue1))
        XCTAssertTrue(fetchedVenues.contains(venue2))
    }
    
    func testSaveAndFetchSearchResults() async throws {
        let request = SearchVenuesRequest(query: "venue2", location: (latitude: 0, longitude: 0))
        let venueIds = ["venue1", "venue2"]
        
        try await venuePersistenceService.saveSearchResults(for: request, venueIds: venueIds)
        let fetchedResults = try await venuePersistenceService.fetchSearchResults(for: request)
        
        XCTAssertEqual(fetchedResults, venueIds)
    }

    func testSaveAndFetchMultipleVenues() async throws {
        let venue1 = Venue(id: "venue1", name: "Venue 1", isFavorite: true)
        let venue2 = Venue(id: "venue2", name: "Venue 2", isFavorite: true)
        let venues = [venue1, venue2]
        
        try await venuePersistenceService.saveVenues(venues)
        let fetchedVenues = try await venuePersistenceService.fetchVenues(by: [venue1.id, venue2.id])
        
        XCTAssertEqual(fetchedVenues.count, 2)
        XCTAssertTrue(fetchedVenues.contains(venue1))
        XCTAssertTrue(fetchedVenues.contains(venue2))
    }
}
