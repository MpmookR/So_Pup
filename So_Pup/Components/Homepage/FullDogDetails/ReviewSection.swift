import SwiftUI

struct ReviewSection: View {
    let dogName: String
    let owner: UserModel

    @EnvironmentObject var reviewVM: ReviewViewModel

    private var averageRating: Double { reviewVM.averageRating }
    private var totalReviews: Int { reviewVM.totalReviews }
    private var enhanced: [Review] { reviewVM.enhancedReviews }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reviews")
                .font(.headline)
                .foregroundColor(Color.socialText)

            // Show summary as soon as stats exist
            if totalReviews > 0 {
                HStack {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text(String(format: "%.1f", averageRating)).font(.headline)
                    Spacer()
                    Text("Total: \(totalReviews) review\(totalReviews == 1 ? "" : "s")")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.socialLight)
                .cornerRadius(21)
            }

            if !enhanced.isEmpty {
                ForEach(enhanced) { ReviewCard(review: $0) }
            } else if totalReviews == 0 {
                Text("No reviews just yet. Once \(dogName) has a few successful meetups, you'll see what others think!")
                    .foregroundColor(.gray)
                    .padding(.top, 16)
            }
        }
        .task(id: owner.id) {
            await reviewVM.loadAllReviewData(userId: owner.id) // loads stats + basic + enhanced
        }
    }
}


    
