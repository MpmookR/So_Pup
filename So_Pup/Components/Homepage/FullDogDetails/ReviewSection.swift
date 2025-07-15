import SwiftUI

struct ReviewSection: View {
    let review: DogReview

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Reviewer Info
            HStack(alignment: .center, spacing: 12) {
                AsyncImage(url: URL(string: review.reviewerDogImageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Image(systemName: "pawprint.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray.opacity(0.4))
                            .padding(10)
                    }
                }
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(99)

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.reviewerDogName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(review.date.formattedLong())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // Review Text
            Text(review.reviewText)
                .font(.body)
                .foregroundColor(Color.socialText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity) 
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 21))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ReviewSection(review: MockDogReviewData.review2)
        .padding()
        .background(Color(.systemGroupedBackground))
}
