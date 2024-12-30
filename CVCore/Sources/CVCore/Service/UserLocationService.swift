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
    private var isUpdating: Bool = false
    private var updateTimer: Timer?

    // MARK: - Initializer
    public override init() {
        self.locationManager = CLLocationManager()
        self.currentLocation = CLLocation(latitude: 44.8191, longitude: 20.4154) // Default to New Belgrade
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.startUpdatingLocation() // Perform initial location fetch
    }
    
    // MARK: - UserLocationService Methods
    public func startUpdatingLocation() {
        guard !isUpdating else { return }
        isUpdating = true
        handleAuthorization()
        
        // Start timer to fetch location every 10 minutes
        updateTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { [weak self] _ in
            self?.fetchLocationPeriodically()
        }
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        updateTimer?.invalidate()
        updateTimer = nil
        isUpdating = false
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location // Cache the latest location
            print("Updated location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
        locationManager.stopUpdatingLocation() // Stop location updates after receiving
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error)")
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorization()
    }
    
    // MARK: - Private Methods
    private func handleAuthorization() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("Location access denied or restricted, using default location.")
            currentLocation = defaultLocation
        @unknown default:
            print("Unknown authorization status, using default location.")
            currentLocation = defaultLocation
        }
    }
    
    private func fetchLocationPeriodically() {
        // Ensure authorization before fetching location
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Periodic update fallback to default location.")
            currentLocation = defaultLocation
        default:
            break
        }
    }
}
