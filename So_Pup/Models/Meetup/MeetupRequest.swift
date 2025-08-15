import Foundation

struct MeetupRequest: Hashable, Codable {
    let id: String
    let chatRoomId: String
    let senderId: String
    let senderDogId: String // Added missing field
    let receiverId: String
    let receiverDogId: String
    let proposedTime: Date
    let locationName: String // it should use the CoreLocation/map kit to pin the location
    let locationCoordinate: Coordinate
    let meetUpMessage: String
    let status: MeetupStatus // pending, accepted, declined
    let createdAt: Date
    let updatedAt: Date
}

enum MeetupStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted" // Backend uses "accepted"
    case rejected = "rejected" // Backend uses "rejected"
    case completed = "completed"
    case cancelled = "cancelled" // Backend also supports cancelled

    var isActive: Bool {
        return self == .pending || self == .accepted
    }

    var isCompleted: Bool {
        return self == .rejected || self == .completed || self == .cancelled
    }

    var allowsComment: Bool {
        return self == .completed
    }
}




