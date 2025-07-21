import Foundation
import CoreLocation

/// A service that handles location permission, coordinates, and reverse geocoding into city name.
final class LocationService: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    /// Used to resume the async call after location is fetched or fails
    private var continuation: CheckedContinuation<(CLLocationCoordinate2D, String?), Error>?

    override init() {
        super.init()
        manager.delegate = self
    }

    /// Requests location permission and returns user's coordinate and city name asynchronously.
    func requestLocation() async throws -> (coordinate: CLLocationCoordinate2D, city: String?) {
        manager.requestWhenInUseAuthorization()  // Ask for permission

        // Wait for user to respond (small delay to give time for system to update status)
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3s

        let status = manager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw LocationError.permissionDenied
        }

        manager.startUpdatingLocation()  // Begin location updates

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }


    /// Delegate method: Called when a location is successfully retrieved
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first, let continuation = continuation else { return }
            
        self.continuation = nil     // Prevent multiple resumes

        manager.stopUpdatingLocation()  // Stop updates after first successful result

        // Perform reverse geocoding asynchronously
        Task {
            let city = await reverseGeocode(location)
            continuation.resume(returning: (location.coordinate, city))
        }
    }

    /// Delegate method: Called if location retrieval fails
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let continuation = continuation else { return }
        self.continuation = nil
        continuation.resume(throwing: error)
    }


    /// Uses CLGeocoder to resolve a CLLocation into a city name asynchronously.
    private func reverseGeocode(_ location: CLLocation) async -> String? {
        let geocoder = CLGeocoder()
        return await withCheckedContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                let city = placemarks?.first?.locality
                continuation.resume(returning: city)
            }
        }
    }

    /// Custom error for location failures
    enum LocationError: Error {
        case noLocation
        case permissionDenied

    }
}
