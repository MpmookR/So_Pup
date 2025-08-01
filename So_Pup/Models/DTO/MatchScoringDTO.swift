// struct that mirrors the backend's MatchScoringDTO, and is fully Encodable.

import Foundation

struct MatchScoringDTO: Codable {
    let currentDogId: DogModel
    let filteredDogIds: [String] // IDs of dogs to be considered for matching
    let userLocation: Coordinate
    let filters: DogFilterSettingsDTO?
}

