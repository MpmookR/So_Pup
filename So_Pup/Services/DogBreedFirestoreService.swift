import FirebaseFirestore

struct DogBreedFirestoreService {
    static func fetchBreeds() async throws -> [String] {
        let snapshot = try await Firestore.firestore().collection("dogBreeds").getDocuments()
        let breeds = snapshot.documents.compactMap { $0.data()["name"] as? String }
        return breeds.sorted()
    }
}

