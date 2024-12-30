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

    func loadJSONFromFile(named fileName: String) -> Data {
        guard let url = Bundle.module.url(forResource: fileName, withExtension: "json") else {
            fatalError("Unable to find \(fileName).json in the test bundle.")
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            fatalError("Unable to load \(fileName).json from the test bundle: \(error)")
        }
    }

    func testSearchVenuesSuccess() async throws {
        let url = URL(string: "https://api.foursquare.com/v3/places/search")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = loadJSONFromFile(named: "SearchVenuesResponse")
        
        URLProtocolMock.testURLs[url] = (response, data, nil)
        
        let request = SearchVenuesRequest(query: "pizza", location: (latitude: 44.8196, longitude: 20.4251))
        let result = try await apiClient.searchVenues(request: request)
        
        XCTAssertEqual(result.results.count, 1)
        XCTAssertEqual(result.results.first?.id, "4ea1ad6fd3e32e6867a62ed9")
        XCTAssertEqual(result.results.first?.name, "Pizza Bar")
        XCTAssertEqual(result.results.first?.location.address, "Bulevar Mihajla Pupina 165v")
        XCTAssertEqual(result.results.first?.location.formatted_address, "Bulevar Mihajla Pupina 165v (Bulevar umetnosti), 11070 Београд")
        XCTAssertEqual(result.results.first?.location.locality, "Београд")
        XCTAssertEqual(result.results.first?.location.postcode, "11070")
        XCTAssertEqual(result.results.first?.location.region, "Central Serbia")
        XCTAssertEqual(result.results.first?.location.country, "RS")
        XCTAssertEqual(result.results.first?.categories.first?.id, 13064)
        XCTAssertEqual(result.results.first?.categories.first?.name, "Pizzeria")
        XCTAssertEqual(result.results.first?.categories.first?.short_name, "Pizza")
        XCTAssertEqual(result.results.first?.categories.first?.icon.prefix, "https://ss3.4sqi.net/img/categories_v2/food/pizza_")
        XCTAssertEqual(result.results.first?.categories.first?.icon.suffix, ".png")
        XCTAssertEqual(result.results.first?.geocodes?.main.latitude, 44.821935)
        XCTAssertEqual(result.results.first?.geocodes?.main.longitude, 20.416514)
    }

    func testFetchVenueDetailsSuccess() async throws {
        let url = URL(string: "https://api.foursquare.com/v3/places/4ea1ad6fd3e32e6867a62ed9")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = loadJSONFromFile(named: "FetchVenueDetailsResponse")
        
        URLProtocolMock.testURLs[url] = (response, data, nil)
        
        let request = FetchVenueDetailsRequest(id: "4ea1ad6fd3e32e6867a62ed9")
        let result = try await apiClient.fetchVenueDetails(request: request)
        
        XCTAssertEqual(result.id, "4ea1ad6fd3e32e6867a62ed9")
        XCTAssertEqual(result.name, "Pizza Bar")
        XCTAssertEqual(result.location.address, "Bulevar Mihajla Pupina 165v")
        XCTAssertEqual(result.location.formatted_address, "Bulevar Mihajla Pupina 165v (Bulevar umetnosti), 11070 Београд")
        XCTAssertEqual(result.location.locality, "Београд")
        XCTAssertEqual(result.location.postcode, "11070")
        XCTAssertEqual(result.location.region, "Central Serbia")
        XCTAssertEqual(result.location.country, "RS")
        XCTAssertEqual(result.categories.first?.id, 13064)
        XCTAssertEqual(result.categories.first?.name, "Pizzeria")
        XCTAssertEqual(result.categories.first?.short_name, "Pizza")
        XCTAssertEqual(result.categories.first?.icon.prefix, "https://ss3.4sqi.net/img/categories_v2/food/pizza_")
        XCTAssertEqual(result.categories.first?.icon.suffix, ".png")
        XCTAssertEqual(result.geocodes.main.latitude, 44.821935)
        XCTAssertEqual(result.geocodes.main.longitude, 20.416514)
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
        let url = URL(string: "https://api.foursquare.com/v3/places/4ea1ad6fd3e32e6867a62ed9")!
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        
        URLProtocolMock.testURLs[url] = (response, nil, nil)
        
        let request = FetchVenueDetailsRequest(id: "4ea1ad6fd3e32e6867a62ed9")
        
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
