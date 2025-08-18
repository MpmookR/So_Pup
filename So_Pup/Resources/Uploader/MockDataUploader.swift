import FirebaseFirestore
import FirebaseAuth
import Foundation


struct MockDataUploader{
    static func uploadMockData() async {
        let db = Firestore.firestore()
        
        // Upload dogs
        for dog in MockDogData.all {
            let dogRef = db.collection("dogs").document(dog.id)
            do {
                try await dogRef.setData(from: dog)
                print("✅ Uploaded dog: \(dog.name)")
            } catch {
                print("❌ Failed to upload dog: \(dog.name), \(error.localizedDescription)")
            }
        }
        
        // Upload users
        for user in MockUserData.all {
            let userRef = db.collection("users").document(user.id)
            do {
                try await userRef.setData(from: user)
                print("✅ Uploaded user: \(user.name)")
            } catch {
                print("❌ Failed to upload user: \(user.name), \(error.localizedDescription)")
            }
        }
        
        // Upload reviews
//        for review in MockDogReviewData.all {
//            let reviewRef = db.collection("dogReviews").document(review.id)
//            do {
//                try await reviewRef.setData(from: review)
//                print("✅ Uploaded review by: \(review.reviewerDogName) for dogId: \(review.reviewedDogId)")
//            } catch {
//                print("❌ Failed to upload review \(review.id), \(error.localizedDescription)")
//            }
//        }
    }
}

