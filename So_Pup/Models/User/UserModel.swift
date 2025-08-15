import Foundation

struct UserModel: Identifiable, Codable, Hashable {
    // Identity
    var id: String
    var name: String
    var gender: UserGenderOption
    var profilePictureURL: String?
    
    // Location
    var location: String
    var coordinate: Coordinate
    var locationPermissionDenied: Bool?

    // Personalisation
    var bio: String?
    var languages: [String]
    var customLanguage: String?

    // Dog Link
    var primaryDogId: String

    var isMock: Bool?
    var pushToken: String? // FCM token
}

// MARK: In Firestore, use whereField("isMock", isEqualTo: false) to exclude them in production fetch

