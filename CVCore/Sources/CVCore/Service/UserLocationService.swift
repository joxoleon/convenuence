import Foundation
import CoreLocation

// MARK: - UserLocationService Protocol
public protocol UserLocationService {
    var currentLocation: CLLocation { get }
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

// MARK: - UserLocationService Implementation
public final class UserLocationServiceImpl: NSObject, UserLocationService, CLLocationManagerDelegate {
    
    // MARK: - Properties
    public private(set) var currentLocation: CLLocation
    private let locationManager: CLLocationManager
    private let defaultLocation = CLLocation(latitude: 44.8191, longitude: 20.4154) // New Belgrade
    private var updateTimer: Timer?

    // MARK: - Initializer
    public override init() {
        self.locationManager = CLLocationManager()
        self.currentLocation = CLLocation(latitude: 44.8191, longitude: 20.4154) // Default to New Belgrade
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestAuthorization()
    }
    
    // MARK: - UserLocationService Methods
    public func startUpdatingLocation() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { [weak self] _ in
            self?.updateLocation()
        }
        updateLocation() // Immediate update on start
    }
    
    public func stopUpdatingLocation() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            print("Updated location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
        locationManager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch location: \(error.localizedDescription)")
        currentLocation = defaultLocation
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocation()
    }
    
    // MARK: - Private Methods
    private func requestAuthorization() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func updateLocation() {
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Location access not authorized. Falling back to default location.")
            currentLocation = defaultLocation
        }
    }
}
