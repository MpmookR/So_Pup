import Foundation

// for chat profile card
struct ChatRoomCardData: Identifiable, Equatable, Hashable {
    var id: String {room.id}
    let room: ChatRoom
    let dog: DogModel
    let owner: UserModel
}


