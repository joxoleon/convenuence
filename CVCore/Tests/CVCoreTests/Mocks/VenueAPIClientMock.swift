import XCTest
@testable import CVCore

class MockVenueAPIClient: VenueAPIClient {
    var searchVenuesResult: SearchVenuesResponse?
    var fetchVenueDetailsResult: FetchVenueDetailsResponse?

    func searchVenues(request: SearchVenuesRequest) async throws -> SearchVenuesResponse {
        if let result = searchVenuesResult {
            return result
        } else {
            throw APIClientError.networkError(NSError(domain: "", code: -1, userInfo: nil))
        }
    }

    func fetchVenueDetails(request: FetchVenueDetailsRequest) async throws -> FetchVenueDetailsResponse {
        if let result = fetchVenueDetailsResult {
            return result
        } else {
            throw APIClientError.networkError(NSError(domain: "", code: -1, userInfo: nil))
        }
    }
}