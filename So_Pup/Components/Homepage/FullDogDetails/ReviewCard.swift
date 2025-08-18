import SwiftUI

struct ReviewCard: View {
    let review: Review

    // On a reviewee’s profile, show the *reviewer* dog avatar.
    private var avatarURL: String? { review.reviewerDogImage }
    private var displayName: String { review.reviewerDogName ?? "User" }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Reviewer Info
            HStack(alignment: .center, spacing: 12) {
                AvatarView(urlString: avatarURL, size: 50)

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(review.createdAt.formattedLong())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // Review Text
            if let txt = review.comment, !txt.isEmpty {
                Text(txt)
                    .font(.body)
                    .foregroundColor(Color.socialText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 21))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct AvatarView: View {
    let urlString: String?
    let size: CGFloat

    var body: some View {
        ZStack {
            // Neutral background so layout doesn’t jump
            Circle()
                .fill(Color.gray.opacity(0.1))

            if let s = urlString, let url = URL(string: s) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().scaleEffect(0.8)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(.gray.opacity(0.4))
                    @unknown default:
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(.gray.opacity(0.4))
                    }
                }
                .clipShape(Circle())
            } else {
                Image(systemName: "pawprint.fill")
                    .foregroundColor(.gray.opacity(0.4))
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .accessibilityHidden(true)
    }
}
