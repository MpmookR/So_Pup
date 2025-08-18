import SwiftUI

struct ReviewSection: View {
    let reviews: [Review]
    let dogName: String
    let ownerId: String  // Add owner ID parameter
    @StateObject private var reviewVM = ReviewViewModel()
    
    private var averageRating: Double {
        reviewVM.averageRating
    }
    
    private var totalReviews: Int {
        reviewVM.totalReviews
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reviews")
                .font(.headline)
                .foregroundColor(Color.socialText)
            
            if !reviews.isEmpty {
                // Review Summary Bar
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16))
                        
                        if reviewVM.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text(String(format: "%.1f", averageRating))
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    if reviewVM.isLoading {
                        Text("Loading...")
                            .font(.body)
                            .foregroundColor(.gray)
                    } else {
                        Text("Total: \(totalReviews) review\(totalReviews == 1 ? "" : "s")")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
                
                // Individual Review Cards
                ForEach(reviews) { review in
                    ReviewCard(review: review)
                }
            } else {
                // Empty State
                VStack(alignment: .leading, spacing: 8) {
                    Text("No reviews just yet. Once \(dogName) has a few successful meetups, you'll see what others think!")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 16)
                }
            }
        }
        .onAppear {
            Task {
                await reviewVM.loadReviewStats(userId: ownerId)
            }
        }
    }
}
    
    
