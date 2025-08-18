import SwiftUI

struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Reviewer Info
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "pawprint.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray.opacity(0.4))
                    .padding(10)
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(99)

                VStack(alignment: .leading, spacing: 2) {
                    Text("User")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(review.createdAt.formattedLong())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // Review Text
            Text(review.comment ?? "")
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
