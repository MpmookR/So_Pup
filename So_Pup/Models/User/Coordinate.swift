import Foundation
import CoreLocation

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
    var geohash: String?
}

extension Coordinate {
    
    //convert a CLLocationCoordinate2D into custom Coordinate 
    init(from clLocation: CLLocationCoordinate2D) {
        let lat = clLocation.latitude
        let lon = clLocation.longitude
        self.latitude = lat
        self.longitude = lon
        self.geohash = GeoHash.encode(latitude: lat, longitude: lon) // generating the geohash 
    }
    
    func distance(from other: Coordinate) -> CLLocationDistance {
        let selfLoc = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let otherLoc = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return selfLoc.distance(from: otherLoc)
    }

    func formattedDistance(from other: Coordinate) -> String {
        let meters = self.distance(from: other)
        if meters < 1000 {
            return "\(Int(meters)) m away"
        } else {
            return "\(Int(meters / 1000)) km away"
        }
    }
}


