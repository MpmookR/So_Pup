import Foundation

//MARK: read from local Json file

//struct BreedService {
//    static func loadDogBreeds() -> [String] {
//        guard let url = Bundle.main.url(forResource: "DogBreed", withExtension: "json") else {
//            print("❌ JSON file not found")
//            return []
//        }
//        
//        do {
//            let data = try Data(contentsOf: url)
//            let decoded = try JSONDecoder().decode(DogBreedResponse.self, from: data)
//            let breeds = decoded.flattenedBreeds
//            print("✅ Loaded breeds: \(breeds)")
//            return breeds
//        } catch {
//            print("❌ Decoding error: \(error)")
//            return []
//        }
//    }
//}
//
//extension DogBreedResponse {
//    /// Flattens the nested dog breed structure into a list of displayable strings
//    var flattenedBreeds: [String] {
//        message.flatMap { (breed, subBreeds) -> [String] in
//            if subBreeds.isEmpty {
//                return [breed.capitalized]
//            } else {
//                return subBreeds.map { "\(breed) \($0)".capitalized }
//            }
//        }.sorted()
//    }
//}


