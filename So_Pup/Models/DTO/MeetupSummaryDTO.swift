import Foundation

struct MeetupSummaryDTO: Identifiable, Codable, Hashable {
    let id: String
    let chatRoomId: String
    let proposedTime: Date
    let locationName: String
    let status: MeetupStatus
    let otherUserId: String
    let otherUserName: String
    let otherDogId: String
    let otherDogName: String
    let otherDogImageUrl: String
}


