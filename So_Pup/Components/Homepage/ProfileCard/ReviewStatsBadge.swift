import SwiftUI

struct ReviewStatsBadge: View {
    let ownerId: String
    @EnvironmentObject private var reviewVM: ReviewViewModel

    var body: some View {
        let s = reviewVM.stats(for: ownerId)
        Group {
            if let s, s.reviewCount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text(String(format: "%.1f", s.averageRating)).font(.footnote)
                    Text("(\(s.reviewCount))").font(.footnote).foregroundColor(.secondary)
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color.yellow.opacity(0.1))
                .clipShape(Capsule())
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text("No reviews yet").font(.footnote).foregroundColor(.secondary)
                }
            }
        }
        .task(id: ownerId) {
            await reviewVM.loadStatsIfNeeded(ownerId: ownerId)
        }
    }
}



