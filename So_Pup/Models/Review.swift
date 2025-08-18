import Foundation

struct Review: Identifiable, Codable {
    var id: String
    var meetupId: String
    var reviewerId: String         // The user who left the review
    var revieweeId: String         // The user being reviewed
    var rating: Int                // Rating from 1-5 stars
    var comment: String?           // Optional comment
    var createdAt: Date            // When the review was created
    
    // Enhanced fields (optional)
    let reviewerDogName: String?
    let revieweeDogName: String?
    let reviewerDogImage: String?
    let revieweeDogImage: String?
}

// it’s “used” automatically during decode/encode
enum CodingKeys: String, CodingKey {
    case id, meetupId, reviewerId, revieweeId, rating, comment, createdAt
    case reviewerDogName, revieweeDogName, reviewerDogImage, revieweeDogImage
}

/// Review statistics for a user
struct ReviewStats: Codable {
    let averageRating: Double
    let reviewCount: Int
}
