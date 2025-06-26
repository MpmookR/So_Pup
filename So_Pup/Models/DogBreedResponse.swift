import Foundation

struct DogBreedResponse: Codable {
    let message: [String: [String]]
}

/// Model to decode dog breed data from Dog CEO API-style JSON
/// The `message` dictionary contains:
/// - Key: main breed (e.g., "australian")
/// - Value: array of sub-breeds (e.g., ["kelpie", "shepherd"])


