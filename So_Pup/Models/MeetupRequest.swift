import Foundation

struct MeetupRequest: Hashable, Codable {
    let proposedTime: Date
    let locationName: String // it should use the CoreLocation/map kit to pin the location
    let locationCoordinate: Coordinate
    let meetUpMessage: String
    let status: MeetupStatus // pending, accepted, declined
}

enum MeetupStatus: String, Codable {
    case pending
    case upcoming
    case declined
    case completed

    var isActive: Bool {
        return self == .pending || self == .upcoming
    }

    var isCompleted: Bool {
        return self == .declined || self == .completed
    }

    var allowsComment: Bool {
        return self == .completed
    }
}




