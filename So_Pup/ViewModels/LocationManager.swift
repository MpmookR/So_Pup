import Foundation
import CoreLocation

/// VM handles location updates and reverse geocoding for the current city
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    /// user's current geographic coordinate (latitude & longitude)
    @Published var currentLocation: CLLocationCoordinate2D?
    
    @Published var cityName: String = ""

    /// Initializes the location manager, requests permission, and starts updating location
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization() // Ask for location permission
        manager.startUpdatingLocation()         // Begin retrieving location updates
    }

    /// Delegate method triggered when new location data is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentLocation = location.coordinate  // Update published location
            fetchCityName(from: location)               // Perform reverse geocoding
            manager.stopUpdatingLocation()              // Stop after first successful update
        }
    }

    /// Uses CLGeocoder to reverse geocode the CLLocation into a readable city name.
    private func fetchCityName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let city = placemarks?.first?.locality {
                self.cityName = city // Publish the resolved city name
            }
        }
    }
}

// MARK: keyword
//CLLocationManager: The object uses to start and stop the delivery of location-related events to app.
//CLGeocoder: reverse geocide to readable city name

