import Foundation

struct UserModel: Identifiable, Codable{
    var id: String //firebase UID
    var name: String
    var gender: UserGenderOption
    var profilePictureURL: String?
    var location: String //city
    var coordinate: Coordinate  // latitude + longitude
    var bio: String?
    var languages: [String]
    var customLanguage: String? 
    var dogId: String
}


struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
}
