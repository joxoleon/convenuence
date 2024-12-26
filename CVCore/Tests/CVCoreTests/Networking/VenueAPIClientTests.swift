import XCTest
@testable import CVCore

class VenueAPIClientTests: XCTestCase {
    private var apiClient: VenueAPIClientImpl!
    private let authorizationHeader = "fsq3YmUUOIyJI8dOKxZfTtnlkYSJZ1LIAahConcvUZnKS5I="

    override func setUp() {
        super.setUp()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)
        
        apiClient = VenueAPIClientImpl(authorizationHeader: authorizationHeader, session: session)
    }

    override func tearDown() {
        apiClient = nil
        URLProtocolMock.testURLs = [:]
        super.tearDown()
    }

    func testSearchVenuesSuccess() async throws {
        let url = URL(string: "https://api.foursquare.com/v3/places/search")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = """
        {
            "results": [
                {
                    "fsq_id": "123",
                    "name": "Coffee Shop",
                    "location": {
                        "address": "123 Main St",
                        "formatted_address": "123 Main St, New York, NY 10001",
                        "locality": "New York",
                        "postcode": "10001",
                        "region": "NY",
                        "country": "US"
                    }
                }
            ]
        }
        """.data(using: .utf8)
        
        URLProtocolMock.testURLs[url] = (response, data, nil)
        
        let request = SearchVenuesRequest(query: "coffee", location: (latitude: 40.748817, longitude: -73.985428))
        let result = try await apiClient.searchVenues(request: request)
        
        XCTAssertEqual(result.results.count, 1)
        XCTAssertEqual(result.results.first?.id, "123")
        XCTAssertEqual(result.results.first?.name, "Coffee Shop")
    }

    func testFetchVenueDetailsSuccess() async throws {
        let url = URL(string: "https://api.foursquare.com/v3/places/598ee2aa2955134db1635b30")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = """
        {
            "fsq_id": "598ee2aa2955134db1635b30",
            "name": "Venue Name",
            "location": {
                "address": "123 Main St",
                "formatted_address": "123 Main St, New York, NY 10001",
                "locality": "New York",
                "postcode": "10001",
                "region": "NY",
                "country": "US"
            },
            "description": "A great place to visit",
            "categories": [
                {
                    "id": 1,
                    "name": "Category Name",
                    "short_name": "Category",
                    "icon": {
                        "prefix": "https://example.com/",
                        "suffix": ".png"
                    }
                }
            ],
            "geocodes": {
                "main": {
                    "latitude": 40.748817,
                    "longitude": -73.985428
                }
            }
        }
        """.data(using: .utf8)
        
        URLProtocolMock.testURLs[url] = (response, data, nil)
        
        let request = FetchVenueDetailsRequest(id: "598ee2aa2955134db1635b30")
        let result = try await apiClient.fetchVenueDetails(request: request)
        
        XCTAssertEqual(result.id, "598ee2aa2955134db1635b30")
        XCTAssertEqual(result.name, "Venue Name")
        XCTAssertEqual(result.location.address, "123 Main St")
        XCTAssertEqual(result.description, "A great place to visit")
        XCTAssertEqual(result.categories.first?.name, "Category Name")
        XCTAssertEqual(result.geocodes.main.latitude, 40.748817)
        XCTAssertEqual(result.geocodes.main.longitude, -73.985428)
    }

    func testSearchVenuesNetworkError() async throws {
        let url = URL(string: "https://api.foursquare.com/v3/places/search")!
        let error = URLError(.notConnectedToInternet)
        
        URLProtocolMock.testURLs[url] = (nil, nil, error)
        
        let request = SearchVenuesRequest(query: "coffee", location: (latitude: 40.748817, longitude: -73.985428))
        
        do {
            _ = try await apiClient.searchVenues(request: request)
            XCTFail("Expected network error")
        } catch let error as APIClientError {
            switch error {
            case .networkError(let networkError):
                XCTAssertEqual((networkError as? URLError)?.code, URLError(.notConnectedToInternet).code)
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testFetchVenueDetailsInvalidResponse() async throws {
        let url = URL(string: "https://api.foursquare.com/v3/places/598ee2aa2955134db1635b30")!
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        
        URLProtocolMock.testURLs[url] = (response, nil, nil)
        
        let request = FetchVenueDetailsRequest(id: "598ee2aa2955134db1635b30")
        
        do {
            _ = try await apiClient.fetchVenueDetails(request: request)
            XCTFail("Expected invalid response error")
        } catch let error as APIClientError {
            switch error {
            case .invalidResponse:
                // Expected error
                break
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}
