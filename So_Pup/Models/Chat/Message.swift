import Foundation

struct Message: Identifiable, Hashable, Codable {
    let id: String // Firestore doc ID
    let text: String
    let senderId: String
    let receiverId: String
    let senderDogId: String
    let receiverDogId: String
    let timestamp: Date
    let messageType: MessageType
    let meetupId: String? // Optional for non-meetup messages
}

