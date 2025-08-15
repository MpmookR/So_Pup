import Foundation

// match filtering and display on the client side
struct MatchProfile : Hashable {
    let dog: DogModel
    let owner: UserModel
    let distanceInMeters: Double?
}

