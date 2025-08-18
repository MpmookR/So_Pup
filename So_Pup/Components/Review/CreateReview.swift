import SwiftUI

struct CreateReview: View {
    // Inputs
    let meetupId: String
    let revieweeId: String
    let revieweeDogName: String
    let revieweeDogImageURL: String?

    @EnvironmentObject var reviewVM: ReviewViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var rating: Int = 0
    @State private var comment: String = ""
    @State private var isSubmitting = false
    @State private var localError: String?

    private let commentLimit = 300
    private var canSubmit: Bool { rating > 0 && !isSubmitting }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    // Use AvatarView; fallback shown if nil
                    AvatarView(urlString: revieweeDogImageURL, size: 54)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Review \(revieweeDogName)")
                            .font(.headline)
                        Text("How was your meetup?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.top, 4)

                // Rating
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rating")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    StarRatingPicker(rating: $rating)
                        .accessibilityLabel(Text("Rating: \(rating) out of 5"))
                }

                // Comment
                VStack(alignment: .leading, spacing: 8) {
                    Text("Comment (optional)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $comment)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color.gray.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                            )

                        if comment.isEmpty {
                            Text("Share a few details about the meetup…")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .allowsHitTesting(false)
                        }
                    }

                    HStack {
                        Spacer()
                        Text("\(comment.count)/\(commentLimit)")
                            .font(.caption2)
                            .foregroundStyle(comment.count > commentLimit ? .red : .secondary)
                    }
                }
            }
            .padding(16)
            .onChange(of: comment) { _, newValue in
                if newValue.count > commentLimit {
                    comment = String(newValue.prefix(commentLimit))
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSubmitting)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSubmitting ? "Submitting…" : "Submit") {
                        Task { await handleSubmit() }
                    }
                    .disabled(!canSubmit)
                }
            }
            .alert("Review Error", isPresented: .constant(localError != nil)) {
                Button("OK") { localError = nil }
            } message: {
                Text(localError ?? "")
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(isSubmitting)
    }

    private func handleSubmit() async {
        isSubmitting = true
        localError = nil
        await reviewVM.submitReview(
            meetupId: meetupId,
            revieweeId: revieweeId,
            rating: rating,
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )
        // Refresh stats + lists for this profile
        await reviewVM.loadAllReviewData(userId: revieweeId)
        isSubmitting = false

        // If your VM sets error state, optionally read it here and keep sheet open.
        if let err = reviewVM.errorMessage, reviewVM.showError {
            localError = err
            return
        }
        dismiss()
    }
}

// Simple 1–5 star picker
struct StarRatingPicker: View {
    @Binding var rating: Int
    private let max = 5

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...max, id: \.self) { i in
                Button {
                    rating = i
                } label: {
                    Image(systemName: i <= rating ? "star.fill" : "star")
                        .font(.system(size: 28))
                        .foregroundColor(.yellow)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("\(i) star\(i == 1 ? "" : "s")"))
                .accessibilityAddTraits(i == rating ? .isSelected : [])
            }
        }
    }
}
// Helper to tidy comment handling
extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}


