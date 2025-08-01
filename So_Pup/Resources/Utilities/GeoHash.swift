import Foundation
import CoreLocation

class GeoHash {
    private static let base32 = Array("0123456789bcdefghjkmnpqrstuvwxyz")
    
    static func encode(latitude: Double, longitude: Double, precision: Int = 9) -> String {
        var latInterval = (-90.0, 90.0)
        var lonInterval = (-180.0, 180.0)
        var hash = ""
        var bits = [Bool]()
        var even = true
        
        while hash.count < precision {
            let mid: Double
            if even {
                mid = (lonInterval.0 + lonInterval.1) / 2
                if longitude > mid {
                    bits.append(true)
                    lonInterval.0 = mid
                } else {
                    bits.append(false)
                    lonInterval.1 = mid
                }
            } else {
                mid = (latInterval.0 + latInterval.1) / 2
                if latitude > mid {
                    bits.append(true)
                    latInterval.0 = mid
                } else {
                    bits.append(false)
                    latInterval.1 = mid
                }
            }
            even.toggle()
            
            if bits.count == 5 {
                var index = 0
                for (i, bit) in bits.enumerated() {
                    if bit {
                        index += 1 << (4 - i)
                    }
                }
                hash.append(base32[index])
                bits.removeAll()
            }
        }
        return hash
    }
}


