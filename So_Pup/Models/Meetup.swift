import Foundation

struct Meetup: Identifiable, Codable {
    let id: String
    let requesterDogId: String
    let receiverDogId: String
    let date: Date
    var isCompleted: Bool
}


