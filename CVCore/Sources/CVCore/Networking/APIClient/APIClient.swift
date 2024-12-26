import Foundation

protocol APIClient {
    /**
     Performs a network request and decodes the response.
     
     This method sends an HTTP request to the specified URL, including query items and an authorization API key. It expects a JSON response that can be decoded into the provided `Decodable` type.
     
     - Parameters:
       - url: The URL for the request.
       - queryItems: Optional query items to include in the request URL.
       - apiKey: The API key used for authorization, sent as a value in the `Authorization` header.
       - responseType: The type of the expected response, conforming to `Decodable`.
     
     - Returns: An instance of the specified `Decodable` type containing the response data.
     - Throws: 
       - `APIClientError.networkError` if a network error occurs.
       - `APIClientError.invalidResponse` if the server response is invalid (e.g., not a 200 HTTP status).
       - `APIClientError.decodingError` if the response cannot be decoded into the specified type.
     */
    func performRequest<T: Decodable>(
        url: URL,
        queryItems: [URLQueryItem]?,
        apiKey: String,
        responseType: T.Type
    ) async throws -> T
}

enum APIClientError: Error {
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
}

class APIClientImpl: APIClient {

    // MARK: - Properties

    private let session: URLSession

    // MARK: - Initializers

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - APIClient

    func performRequest<T: Decodable>(
        url: URL,
        queryItems: [URLQueryItem]?,
        apiKey: String,
        responseType: T.Type
    ) async throws -> T {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        do {
            let (data, urlResponse) = try await session.data(for: request)
            guard let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIClientError.invalidResponse
            }
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            if let urlError = error as? URLError {
                throw APIClientError.networkError(urlError)
            } else if let decodingError = error as? DecodingError {
                throw APIClientError.decodingError(decodingError)
            } else {
                throw error
            }
        }
    }
}
