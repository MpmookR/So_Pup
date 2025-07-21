import Foundation
import FirebaseFirestore

final class ProfileDataService {
    private let db = Firestore.firestore()
    
    // MARK: - Fetch Dogs
    
    func fetchAllDogs() async throws -> [DogModel] {
        let snapshot = try await db.collection("dogs").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: DogModel.self) }
    }
    
    func fetchDog(by id: String) async throws -> DogModel? {
        let doc = try await db.collection("dogs").document(id).getDocument()
        return try doc.data(as: DogModel.self)
    }

    // MARK: - Fetch Users

    func fetchAllUsers() async throws -> [UserModel] {
        let snapshot = try await db.collection("users").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: UserModel.self) }
    }

    func fetchUser(by id: String) async throws -> UserModel? {
        let doc = try await db.collection("users").document(id).getDocument()
        return try doc.data(as: UserModel.self)
    }
    
    // MARK: - Fetch Dog Reviews
    func fetchReviews(for dogId: String) async throws -> [DogReview] {
        let snapshot = try await db.collection("dogReviews")
            .whereField("reviewedDogId", isEqualTo: dogId)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: DogReview.self) }
    }
}


