import Foundation

// MARK: - Meetup API Response Models

struct UpdateMeetupStatusResponse: Codable {
    let message: String
    let success: Bool
}

struct CancelMeetupResponse: Codable {
    let message: String
    let success: Bool
}

struct FetchMeetupsResponse: Codable {
    let message: String
    let meetups: [MeetupSummaryDTO]
}


