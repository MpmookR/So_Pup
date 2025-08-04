import Foundation

// for MatchRequest card UI on the Match tabview
struct MatchRequestCardData: Identifiable {
    let id: String
    let dog: DogModel
    let owner: UserModel
    let message: String
    let requestId: String
    let direction: MatchDirection

    enum MatchDirection {
        case incoming
        case outgoing
    }
}


