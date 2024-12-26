import Foundation

class URLProtocolMock: URLProtocol {
    // Thread-safe storage for test URLs
    private static var queue = DispatchQueue(label: "URLProtocolMock.testURLs.queue")
    static private var _testURLs = [URL: (HTTPURLResponse?, Data?, Error?)]()
    static var testURLs: [URL: (HTTPURLResponse?, Data?, Error?)] {
        get {
            queue.sync { _testURLs }
        }
        set {
            queue.sync { _testURLs = newValue }
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url else {
            completeRequestWithError(URLError(.badURL))
            return
        }
        
        // Find a matching URL ignoring query parameter order
        if let (response, data, error) = URLProtocolMock.testURLs.first(where: { $0.key.matches(url) })?.value {
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = response {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            }
        } else {
            assertionFailure("Unexpected URL: \(url)")
            completeRequestWithError(URLError(.resourceUnavailable))
        }
    }

    override func stopLoading() {
        // No-op
    }

    private func completeRequestWithError(_ error: URLError) {
        DispatchQueue.global().async { [weak self] in
            self?.client?.urlProtocol(self!, didFailWithError: error)
        }
    }
}

// Extend URL to compare ignoring query parameter order
extension URL {
    func matches(_ other: URL) -> Bool {
        guard let components1 = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let components2 = URLComponents(url: other, resolvingAgainstBaseURL: false) else {
            return false
        }
        return components1.scheme == components2.scheme &&
               components1.host == components2.host &&
               components1.path == components2.path &&
               components1.queryItems?.sorted(by: { $0.name < $1.name }) == components2.queryItems?.sorted(by: { $0.name < $1.name })
    }
}
