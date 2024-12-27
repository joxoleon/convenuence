import Foundation

public protocol VenueAPIClient {
    /**
     Searches for venues based on a query and location.

     This method sends a request to the Foursquare Venue API to find venues matching the specified query and location criteria.

     - Parameter request: An instance of `SearchVenuesRequest` containing the search query, location, and other optional parameters.
     - Returns: An instance of `SearchVenuesResponse`, which includes a list of venues that match the search criteria.
     - Throws:
       - `VenueAPIClientError.networkError` if a network error occurs.
       - `VenueAPIClientError.invalidResponse` if the server response is invalid (e.g., not a 200 HTTP status).
       - `VenueAPIClientError.decodingError` if the response data cannot be decoded into the expected model.
       - `VenueAPIClientError.apiError` if the API returns an error response.
     */
    func searchVenues(request: SearchVenuesRequest) async throws -> SearchVenuesResponse

    /**
     Fetches details for a specific venue.

     This method sends a request to the Foursquare Venue API to retrieve detailed information about a venue identified by its ID.

     - Parameter request: An instance of `FetchVenueDetailsRequest` containing the ID of the venue whose details are being requested.
     - Returns: An instance of `FetchVenueDetailsResponse`, which includes detailed information about the specified venue.
     - Throws:
       - `VenueAPIClientError.networkError` if a network error occurs.
       - `VenueAPIClientError.invalidResponse` if the server response is invalid (e.g., not a 200 HTTP status).
       - `VenueAPIClientError.decodingError` if the response data cannot be decoded into the expected model.
       - `VenueAPIClientError.apiError` if the API returns an error response.
     */
    func fetchVenueDetails(request: FetchVenueDetailsRequest) async throws -> FetchVenueDetailsResponse
}

class VenueAPIClientImpl: VenueAPIClient {

    // MARK: - Properties

    private let apiClient: APIClient
    private let authorizationHeader: String

    // MARK: - Initializers

    init(authorizationHeader: String, session: URLSession = .shared) {
        self.apiClient = APIClientImpl(session: session)
        self.authorizationHeader = authorizationHeader
    }

    // MARK: - VenueAPIClient

    func searchVenues(request: SearchVenuesRequest) async throws -> SearchVenuesResponse {
        let url = request.url
        return try await apiClient.performRequest(
            url: url, queryItems: request.queryItems, authorizationHeader: authorizationHeader,
            responseType: SearchVenuesResponse.self
        )
    }

    func fetchVenueDetails(request: FetchVenueDetailsRequest) async throws -> FetchVenueDetailsResponse {
        let url = request.url
        return try await apiClient.performRequest(
            url: url, queryItems: request.queryItems, authorizationHeader: authorizationHeader,
            responseType: FetchVenueDetailsResponse.self
        )
    }
}

// MARK: - Search Venues

public struct SearchVenuesRequest {
    let query: String
    let location: (latitude: Double, longitude: Double)
    let radius: Int
    // Add limit and offset properties for pagination purposes
    // For now I won't implement that feature, but it can be added later
    let limit: Int
    let offset: Int

    public init(query: String, location: (latitude: Double, longitude: Double), radius: Int = 3000, limit: Int = 50, offset: Int = 0) {
        self.query = query
        self.location = location
        self.radius = radius
        self.limit = limit
        self.offset = offset
    }

    var url: URL {
        var components = URLComponents(string: "https://api.foursquare.com/v3/places/search")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "ll", value: "\(location.latitude),\(location.longitude)")
        ]
        return components.url!
    }

    var queryItems: [URLQueryItem]? {
        return nil
    }
}

public struct SearchVenuesResponse: Codable {
    public let results: [FoursqareDTO.Venue]
}

// MARK: - Fetch Venue Details

public struct FetchVenueDetailsRequest {
    let id: String

    public init(id: String) {
        self.id = id
    }

    var url: URL {
        return URL(string: "https://api.foursquare.com/v3/places/\(id)")!
    }

    var queryItems: [URLQueryItem]? {
        return nil
    }
}

public typealias FetchVenueDetailsResponse = FoursqareDTO.VenueDetails
