import XCTest
@testable import CVCore

@available(iOS 15.0, macOS 12.0, *)
class VenueAPIClientTests: XCTestCase {
    // ...existing code...
    func testSearchVenuesSuccess() async throws {
        // Mock URLSession and test successful response
        // ...existing code...
    }
    
    func testFetchVenueDetailsSuccess() async throws {
        // Mock URLSession and test successful response
        // ...existing code...
    }
    
    func testNetworkError() async throws {
        // Mock URLSession and test network error handling
        // ...existing code...
    }
    
    func testDecodingError() async throws {
        // Mock URLSession and test decoding error handling
        // ...existing code...
    }
    
    func testVenueAPIRequests() async throws {
        let client = VenueAPIClientImpl(apiKey: apiKey)
        
        do {
            // Perform search venues request
            let venues = try await client.searchVenues(query: "coffee", location: (latitude: 40.748817, longitude: -73.985428))
            print("Search Venues Result: \(venues)")
            
            // Perform fetch venue details request for the first venue
            if let firstVenue = venues.first {
                let venueDetails = try await client.fetchVenueDetails(id: firstVenue.id)
                print("Venue Details Result: \(venueDetails)")
            } else {
                print("No venues found.")
            }
        } catch {
            XCTFail("Request failed with error: \(error)")
        }
    }
}
