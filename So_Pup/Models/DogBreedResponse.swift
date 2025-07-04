import Foundation

/// Model to decode dog breed data from Dog CEO API-style JSON
/// The `message` dictionary contains:
/// - Key: main breed (e.g., "australian")
/// - Value: array of sub-breeds (e.g., ["kelpie", "shepherd"])
///
/// This matches the structure of the API response:
/// {
///   "message": {
///     "australian": ["kelpie", "shepherd"],
///     "beagle": []
///   },
///   "status": "success"
/// }
struct DogBreedResponse: Decodable {
    let message: [String: [String]]
}

/// This extension flattens the nested breed/sub-breed structure into a displayable list of strings.
/// Examples:
/// - "australian shepherd"
/// - "beagle"
/// The result is a flat, sorted array like:
/// ["Australian Kelpie", "Australian Shepherd", "Beagle", ...]
extension DogBreedResponse {
    var flattenedBreeds: [String] {
        message.flatMap { (breed, subBreeds) -> [String] in
            if subBreeds.isEmpty {
                return [breed.capitalized]
            } else {
                return subBreeds.map { "\(breed) \($0)".capitalized }
            }
        }.sorted()
    }
}






//MARK: local json file version
/// Model to decode dog breed data from Dog CEO API-style JSON
/// The `message` dictionary contains:
/// - Key: main breed (e.g., "australian")
/// - Value: array of sub-breeds (e.g., ["kelpie", "shepherd"])
///

//struct DogBreedResponse: Decodable {
//    let message: [String: [String]]
//}
