import Foundation

// used for encoding filter settings to backend
struct DogFilterSettingsDTO: Codable {
    let maxDistanceInKm: Int
    let selectedGender: String?
    let selectedSizes: [String]
    let selectedPlayStyleTags: [String]
    let selectedEnvironmentTags: [String]
    let selectedTriggerTags: [String]
    let selectedHealthStatus: String?
    let neuteredOnly: Bool?
    let preferredAgeRange: [Double]?
}

