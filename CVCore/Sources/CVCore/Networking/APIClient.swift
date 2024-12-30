import Foundation

protocol APIClient {
    /**
     Performs a network request and decodes the response.
     
     This method sends an HTTP request to the specified URL, including query items and an authorization API key. It expects a JSON response that can be decoded into the provided `Decodable` type.
     
     - Parameters:
       - url: The URL for the request.
       - queryItems: Optional query items to include in the request URL.
       - authorizationHeader: The API key used for authorization, sent as a value in the `Authorization` header.
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
        authorizationHeader: String,
        responseType: T.Type
    ) async throws -> T
}

enum APIClientError: Error {
    case networkError(Error)
    case invalidResponse(statusCode: Int, responseBody: String?)
    case decodingError(Error)
    case maxRetriesExceeded
}

class APIClientImpl: APIClient {

    // MARK: - Properties

    private let session: URLSession
    private let maxRetries: Int
    private let retryableErrorCodes: [URLError.Code] = [.networkConnectionLost, .timedOut]

    // MARK: - Initializers

    init(session: URLSession = .shared, maxRetries: Int = 3) {
        self.session = session
        self.maxRetries = maxRetries
    }

    // MARK: - APIClient

    func performRequest<T: Decodable>(
        url: URL,
        queryItems: [URLQueryItem]?,
        authorizationHeader: String,
        responseType: T.Type
    ) async throws -> T {
        // Construct URL with query items
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems

        // Prepare the URLRequest
        var request = URLRequest(url: components.url!)
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET" // Default method, modify if necessary

        // Print the raw request
        logRawRequest(request: request, queryItems: queryItems)

        var attempt = 0
        while attempt <= maxRetries {
            attempt += 1
            print("[APIClient] Attempt \(attempt): Sending request to \(request.url?.absoluteString ?? "unknown URL")")

            do {
                // Execute the network request
                let (data, urlResponse) = try await session.data(for: request)

                // Validate the HTTP response
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("[APIClient] Invalid response: URLResponse is not an HTTPURLResponse.")
                    throw APIClientError.invalidResponse(statusCode: -1, responseBody: nil)
                }

                print("[APIClient] Response status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    do {
                        // Decode the response into the specified type
                        let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                        print("[APIClient] Decoding successful.")
                        return decodedResponse
                    } catch let decodingError as DecodingError {
                        let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                        print("[APIClient] Failed to decode JSON: \(responseBody)")
                        throw APIClientError.decodingError(decodingError)
                    }
                } else {
                    // Handle invalid status codes
                    let responseBody = String(data: data, encoding: .utf8)
                    print("[APIClient] Invalid response with status code \(httpResponse.statusCode): \(responseBody ?? "No response body")")
                    throw APIClientError.invalidResponse(statusCode: httpResponse.statusCode, responseBody: responseBody)
                }
            } catch let urlError as URLError {
                if retryableErrorCodes.contains(urlError.code), attempt <= maxRetries {
                    print("[APIClient] Retrying request due to transient error: \(urlError.localizedDescription)")
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                    continue
                } else {
                    print("[APIClient] URL error occurred: \(urlError.localizedDescription)")
                    throw APIClientError.networkError(urlError)
                }
            } catch {
                print("[APIClient] Unexpected error occurred: \(error.localizedDescription)")
                throw error
            }
        }

        print("[APIClient] Max retries exceeded. Failing request.")
        throw APIClientError.maxRetriesExceeded
    }

    // MARK: - Private Methods

    private func logRawRequest(request: URLRequest, queryItems: [URLQueryItem]?) {
        print("---- RAW REQUEST ----")
        
        // Log the full URL (already includes query items after the fix)
        if let url = request.url {
            print("Full URL: \(url.absoluteString)")
        } else {
            print("URL: unknown")
        }
        
        // Log HTTP method
        print("HTTP Method: \(request.httpMethod ?? "unknown")")
        
        // Log headers
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Query items are no longer necessary to log separately since they are part of the full URL
        if let queryItems = queryItems, !queryItems.isEmpty {
            print("Query Items (sent in URL):")
            for queryItem in queryItems {
                print(" - \(queryItem.name): \(queryItem.value ?? "nil")")
            }
        } else {
            print("Query Items: None")
        }
        
        // Log HTTP body
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("HTTP Body: \(bodyString)")
        } else {
            print("HTTP Body: None")
        }
        
        print("--------------------")
    }


}
