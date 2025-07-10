import FirebaseFirestore
import Foundation

//MARK: ⚠️ uploadBreeds() run this once during development

struct BreedUploader {
    static func uploadBreeds() {
        guard let url = Bundle.main.url(forResource: "DogBreed", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(DogBreedResponse.self, from: data) else {
            print("❌ Failed to load or decode breed data")
            return
        }

        let db = Firestore.firestore()
        let breeds = decoded.flattenedBreeds

        for breed in breeds {
            let docId = breed.lowercased().replacingOccurrences(of: " ", with: "-")
            db.collection("dogBreeds").document(docId).setData(["name": breed]) { error in
                if let error = error {
                    print("❌ Error uploading \(breed): \(error.localizedDescription)")
                } else {
                    print("✅ Uploaded: \(breed)")
                }
            }
        }
    }
}






