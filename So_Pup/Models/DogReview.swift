import Foundation

struct DogReview: Identifiable, Codable {
    var id: String
    var meetupId: String
    
    var reviewedDogId: String      // The dog being reviewed

    var reviewerDogId: String      // The dog who left the review
    var reviewerDogName: String
    var reviewerDogImageURL: String
    
    var date: Date
    var reviewText: String
    
    var isMock: Bool = false
}


