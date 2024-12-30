import Foundation
import CoreLocation

// MARK: - UserLocationService Protocol

public protocol UserLocationService {
    func getCurrentLocation() async throws -> CLLocation
}

// MARK: - UserLocationService Implementation

public final class UserLocationServiceImpl: NSObject, UserLocationService, CLLocationManagerDelegate {

    // MARK: - Dependencies
    
    private let locationManager: CLLocationManager
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    // MARK: - Initializers

    public override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }

    // MARK: - UserLocationService Methods
    
    public func getCurrentLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        }
    }

    // MARK: - CLLocationManagerDelegate Methods

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationContinuation?.resume(returning: location)
            locationManager.stopUpdatingLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
    }
}
