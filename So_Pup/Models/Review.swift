import Foundation

struct Review: Identifiable, Codable {
    var id: String
    var meetupId: String
    var reviewerId: String         // The user who left the review
    var revieweeId: String         // The user being reviewed
    var rating: Int                // Rating from 1-5 stars
    var comment: String?           // Optional comment
    var createdAt: Date            // When the review was created
}


