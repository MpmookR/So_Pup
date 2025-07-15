import Foundation

struct DogReview: Identifiable, Codable {
    let id: String
    let meetupId: String
    
    let reviewedDogId: String      // The dog being reviewed

    let reviewerDogId: String      // The dog who left the review
    let reviewerDogName: String
    let reviewerDogImageURL: String
    
    let date: Date
    let reviewText: String
}


