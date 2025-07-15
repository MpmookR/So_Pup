import Foundation
import CoreLocation

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
}

extension Coordinate {
    
    //convert a CLLocationCoordinate2D into custom Coordinate 
    init(from clLocation: CLLocationCoordinate2D) {
            self.latitude = clLocation.latitude
            self.longitude = clLocation.longitude
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


