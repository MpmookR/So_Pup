// -------------------
//  Service for location permissions, current coordinate retrieval, reverse
//  geocoding, and POI search. Wraps Core Location, CLGeocoder, and MapKit
//  with async/await, exposing a clean API for SwiftUI.
//
//  Key Responsibilities:
//  - Request “When In Use” authorization and fetch the user’s location
//  - Reverse-geocode coordinates to city/address strings
//  - Build an MKMapItem for the current location
//  - Search places/POIs via MKLocalSearch
//
//  Implementation Notes:
//  - Uses a CheckedContinuation to resume the async request after the first
//    successful location update (then stops updates).
//  - Reverse geocoding is performed off the main thread with continuations.
//  - `authorizationStatus` is checked before starting updates.
//
//  Errors:
//  - LocationError.permissionDenied when authorization is not granted
//  - Propagates Core Location/MapKit errors from delegate/search paths
//
//  Usage:
//  - Call `requestLocation()` to get (coordinate, city).
//  - Call `getCurrentLocationMapItem()` for a ready-to-use MKMapItem.
//  - Call `searchLocations(query:)` for POI results.
//  - Call `coordinateToAddress(coordinate:)` for a formatted address.
// -------------------
import Foundation
import CoreLocation
import MapKit

/// A service that handles location permission, coordinates, reverse geocoding, and location search.
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

    /// Search for locations based on search query
    func searchLocations(query: String) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems
    }
    
    /// Get current location as MKMapItem
    func getCurrentLocationMapItem() async throws -> MKMapItem {
        let (coordinate, city) = try await requestLocation()
        
        // Create a map item for current location
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = city ?? "Current Location"
        
        return mapItem
    }
    
    /// Convert coordinate to address string
    func coordinateToAddress(coordinate: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        return await withCheckedContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                guard let placemark = placemarks?.first else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let address = [
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.postalCode,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
                
                continuation.resume(returning: address.isEmpty ? nil : address)
            }
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
