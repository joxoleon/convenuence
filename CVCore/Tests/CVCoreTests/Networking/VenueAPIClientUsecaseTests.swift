import XCTest
@testable import CVCore

class VenueAPIClientUsecaseTests: XCTestCase {
    private var apiClient: VenueAPIClientImpl!

    override func setUp() {
        super.setUp()
        // The authorization header should NEVER BE HARDCODED in a real app, it should also never be kept in a repo like this!
        // I'm just adding here for the sake of simplicity as I don't have the time to set up a proper environment.
        let authorizationHeader: String? = nil // Initialize this to a real foursquare authorization header to run these tests
        
        // Intentionally fail the test if the authorization header is nil, I'll add it while running the tests here, but will remove it from the repo before comitting.
        guard let authorizationHeader = authorizationHeader else {
            XCTFail("Authorization header is nil")
            return
        }
        apiClient = VenueAPIClientImpl(authorizationHeader: authorizationHeader, session: URLSession.shared)
    }

    override func tearDown() {
        apiClient = nil
        super.tearDown()
    }

    // These tests are intentionally commented out as they make real API calls and require a valid API key.
    // And because Apple/Swift doesn't allow "IGNORED" tests to exist in the codebase... Thank you Apple!
    
    // func testSearchVenuesRealAPI() async throws {
    //     // Perform the real API call
    //     let request = SearchVenuesRequest(query: "coffee", location: (latitude: 40.748817, longitude: -73.985428))
    //     let response = try await apiClient.searchVenues(request: request)

    //     // Assertions
    //     XCTAssertGreaterThan(response.results.count, 0)
    //     XCTAssertNotNil(response.results.first?.id)
    //     XCTAssertNotNil(response.results.first?.name)
    // }

    // func testFetchVenueDetailsRealAPI() async throws {
    //     // Perform the real API call
    //     let request = FetchVenueDetailsRequest(id: "598ee2aa2955134db1635b30")
    //     let response = try await apiClient.fetchVenueDetails(request: request)

    //     // Assertions
    //     XCTAssertNotNil(response.id)
    //     XCTAssertNotNil(response.name)
    //     XCTAssertNotNil(response.location.address)
    // }
}
