import Foundation

struct UserModel: Identifiable, Codable{
    var id: String
    var name: String
    var gender: UserGenderOption
    var profilePictureURL: String?
    var location: String
    var coordinate: Coordinate
    var bio: String?
    var languages: [String]
    var customLanguage: String?
    var dogId: String
    var locationPermissionDenied: Bool?
}


struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
}
