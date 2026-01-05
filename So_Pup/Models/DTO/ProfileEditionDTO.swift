import Foundation

// MARK: - Request DTOs (Encodable, omit nils)
struct CoordinateDTO: Codable {
    let latitude: Double
    let longitude: Double
}

struct UserUpdateDTO: Codable {
    var name: String?
    var bio: String?
    var location: String?
    var coordinate: CoordinateDTO?
    var languages: [String]?
    var customLanguage: String?
    var imageURL: String?
}

struct DogBasicUpdateDTO: Codable {
    var name: String?
    var dob: Date?
    var breed: String?
    var weight: Double?
    var gender: String?
    var size: String?
    var bio: String?
    var coordinate: CoordinateDTO?
}

struct DogBehaviorUpdateDTO: Codable {
    var isNeutered: Bool?
    var behavior: DogBehavior?
}

struct DogImagesUpdateDTO: Codable {
    let imageURLs: [String]
}

struct DogHealthUpdateDTO: Codable {
    var fleaTreatmentDate: Date?
    var wormingTreatmentDate: Date?
}

// MARK: - Response Models (unchanged)
struct UserProfileUpdateResponse: Codable {
    let message: String
    let user: UserModel
}

struct DogProfileUpdateResponse: Codable {
    let message: String
    let dog: DogModel
}

struct DogBehaviorUpdateResponse: Codable {
    let message: String
    let dog: DogModel
}

struct DogImagesUpdateResponse: Codable {
    let message: String
    let dog: DogModel
}

struct DogHealthUpdateResponse: Codable {
    let message: String
    let dog: DogModel
}

// MARK: - Errors

enum ProfileEditionError: Error, LocalizedError {
    case notAuthenticated
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "User not authenticated"
        case .invalidResponse:  return "Invalid response from server"
        case .apiError(let m):  return m
        }
    }
}


