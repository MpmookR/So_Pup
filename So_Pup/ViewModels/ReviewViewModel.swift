import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
final class ReviewViewModel: ObservableObject {
    @Published var userReviews: [Review] = []
    @Published var enhancedReviews: [Review] = []
    @Published var reviewStats: ReviewStats?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var successMessage: String?
    @Published var showSuccess = false
    
    private let reviewService = ReviewService.shared
    private let authVM = AuthViewModel()
    
    // MARK: - Public Methods
    
    /// Submit a review for a meetup
    func submitReview(
        meetupId: String,
        revieweeId: String,
        rating: Int,
        comment: String?
    ) async {
        guard let currentUser = Auth.auth().currentUser else {
            await showError("Failed to get current user information")
            return
        }
        
        isLoading = true
        
        do {
            let token = try await authVM.fetchIDToken()
            
            try await reviewService.submitReview(
                meetupId: meetupId,
                revieweeId: revieweeId,
                rating: rating,
                comment: comment,
                authToken: token
            )
            
            await showSuccess("Review submitted successfully!")
            
            // Refresh reviews after submission
            await loadUserReviews(userId: currentUser.uid)
            
        } catch {
            await showError("Failed to submit review: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    /// Load review statistics for a user
    func loadReviewStats(userId: String) async {
        isLoading = true
        
        do {
            let stats = try await reviewService.fetchReviewStats(userId: userId)
            reviewStats = stats
        } catch {
            await showError("Failed to load review statistics: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    /// Load all reviews for a user
    func loadUserReviews(userId: String) async {
        isLoading = true
        
        do {
            let reviews = try await reviewService.fetchUserReviews(userId: userId)
            userReviews = reviews
        } catch {
            await showError("Failed to load user reviews: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    /// Load enhanced reviews for a user with dog information
    func loadEnhancedUserReviews(userId: String) async {
        isLoading = true
        
        do {
            let reviews = try await reviewService.fetchUserReviewsWithDogInfo(userId: userId)
            enhancedReviews = reviews
        } catch {
            await showError("Failed to load enhanced reviews: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    /// Load all review data for a user
    func loadAllReviewData(userId: String) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadReviewStats(userId: userId) }
            group.addTask { await self.loadUserReviews(userId: userId) }
            group.addTask { await self.loadEnhancedUserReviews(userId: userId) }
        }
    }
    
    // MARK: - Helper Methods
    
    private func showError(_ message: String) async {
        errorMessage = message
        showError = true
    }
    
    private func showSuccess(_ message: String) async {
        successMessage = message
        showSuccess = true
    }
    
    /// Get average rating for a user
    var averageRating: Double {
        reviewStats?.averageRating ?? 0.0
    }
    
    /// Get total number of reviews for a user
    var totalReviews: Int {
        reviewStats?.totalReviews ?? 0
    }
    
    /// Get rating distribution for a user
    var ratingDistribution: [Int: Int] {
        reviewStats?.ratingDistribution ?? [:]
    }
    
    /// Check if user has any reviews
    var hasReviews: Bool {
        !userReviews.isEmpty
    }
    
    /// Check if user has any enhanced reviews
    var hasEnhancedReviews: Bool {
        !enhancedReviews.isEmpty
    }
}
