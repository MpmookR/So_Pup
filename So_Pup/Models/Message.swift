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
    let meetupRequest: MeetupRequest? // Only for .meetupRequest messages
}

enum MessageType: String, Codable {
    case text
    case meetupRequest
    case system // eg; Meetups are disabled in Puppy Mode
}
