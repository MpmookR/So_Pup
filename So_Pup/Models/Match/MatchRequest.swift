import Foundation
import FirebaseFirestore

struct MatchRequest: Identifiable, Codable {
    var id: String = UUID().uuidString // Will be overridden by Firestore doc ID
    let fromUserId: String
    let fromDogId: String
    let toDogId: String
    let message: String
    let createdAt: Date
    let status: MatchRequestStatus
}



