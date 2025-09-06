/// ----------------
///
/// Responsibilities
/// - Submit a review for a meetup via `ReviewService`.
/// - Load review stats, plain reviews, and “enhanced” reviews (with dog info).
/// - Cache per-owner `ReviewStats` and track per-owner loads to avoid duplicate requests.
/// - Expose UI state (lists, stats, banners, loading).
///
/// Key collaborators
/// - `AuthViewModel` --> fresh Firebase ID token for secure calls.
/// - `ReviewService` (.shared) --> submit/fetch reviews and stats.
/// - Firebase `Auth` --> current user presence (UID check).
///
/// Notes
/// - `loadAllReviewData(userId:)` fetches stats, reviews, and enhanced reviews in parallel
///   via a task group. `loadStatsIfNeeded` is safe for list contexts (no global spinner).
/// ----------------
import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
final class ReviewViewModel: ObservableObject {
    
    private let reviewService = ReviewService.shared
    private let authVM: AuthViewModel
    
    @Published var userReviews: [Review] = []
    @Published var enhancedReviews: [Review] = []
    @Published var reviewStats: ReviewStats?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var successMessage: String?
    @Published var showSuccess = false
    
    @Published private var statsCache: [String: ReviewStats] = [:]
    @Published private var loadingIds: Set<String> = []
    
    init(authVM: AuthViewModel) {
        self.authVM = authVM
    }
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
            
            // Refresh the profile you're viewing
            await loadAllReviewData(userId: revieweeId)
            
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
            print("📊 ReviewViewModel: Received stats - averageRating=\(stats.averageRating), reviewCount=\(stats.reviewCount)")
        } catch {
            print("❌ ReviewViewModel: Failed to load stats - \(error.localizedDescription)")
            await showError("Failed to load review statistics: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func stats(for ownerId: String) -> ReviewStats? { statsCache[ownerId] }
    
    /// Fetches once per owner and caches in statsCache[ownerId]
    /// Skips network if already present (unless force == true)
    /// Tracks loading per owner (no global spinner), so it’s safe for lists/cards
    // use when multiple owner visible
    func loadStatsIfNeeded(ownerId: String, force: Bool = false) async {
        if !force, statsCache[ownerId] != nil || loadingIds.contains(ownerId) { return }
        loadingIds.insert(ownerId)
        defer { loadingIds.remove(ownerId) }
        do {
            let s = try await reviewService.fetchReviewStats(userId: ownerId)
            statsCache[ownerId] = s
        } catch {
            print("⚠️ stats load failed for \(ownerId):", error.localizedDescription)
        }
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
        reviewStats?.reviewCount ?? 0
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
