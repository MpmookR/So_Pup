import Foundation
import FirebaseAuth
import FirebaseFirestore

final class ReviewService {
    static let shared = ReviewService()
    private init() {}
    
    private let baseURL = "https://api-2z4snw37ba-uc.a.run.app/reviews"
    private let db = Firestore.firestore()
    
    // MARK: - API Methods
    
    /// Submit a review for a meetup
    func submitReview(
        meetupId: String,
        revieweeId: String,
        rating: Int,
        comment: String?,
        authToken: String
    ) async throws {
        guard let url = URL(string: "\(baseURL)/submit") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        var body: [String: Any] = [
            "meetupId": meetupId,
            "revieweeId": revieweeId,
            "rating": rating
        ]
        
        if let comment = comment {
            body["comment"] = comment
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("📦 Submitting review:", body)
        
        //        let (_, response) = try await URLSession.shared.data(for: request)
        //
        //        guard let httpResponse = response as? HTTPURLResponse,
        //              (200..<300).contains(httpResponse.statusCode) else {
        //            throw URLError(.badServerResponse)
        //        }
        //
        //        print("✅ Review submitted successfully")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
            
            if !(200...299).contains(http.statusCode) {
                // Try to decode { error: "...", message: "..." }
                let payload = (try? JSONDecoder().decode(APIErrorPayload.self, from: data))
                let _ = String(data: data, encoding: .utf8) ?? ""
                let msg = payload?.message ?? payload?.error ?? "Unknown error"
                print("❌ Server \(http.statusCode): \(msg)")
                throw ReviewServiceError.server(message: msg, code: http.statusCode)
            }
            
            print("✅ Review submitted (status \(http.statusCode))")
        } catch let urlErr as URLError {
            print("❌ Transport error: \(urlErr)")
            throw ReviewServiceError.transport(urlErr)
        }
    }
    
    /// Fetch average review stats for a user
    func fetchReviewStats(userId: String) async throws -> ReviewStats {
        guard let url = URL(string: "\(baseURL)/average/\(userId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("📦 Fetching review stats for user:", userId)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Debug: Print raw response data
        if let responseString = String(data: data, encoding: .utf8) {
            print("🔍 Raw response data: \(responseString)")
        }
        
        let decoder = makeISODecoder()
        
        let result = try decoder.decode(ReviewStats.self, from: data)
        print("✅ Fetched review stats for user: averageRating=\(result.averageRating), reviewCount=\(result.reviewCount)")
        
        return result
    }
    
    /// Fetch all reviews for a user
    func fetchUserReviews(userId: String) async throws -> [Review] {
        guard let url = URL(string: "\(baseURL)/user/\(userId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("📦 Fetching reviews for user:", userId)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = makeISODecoder()
        
        let result = try decoder.decode([Review].self, from: data)
        print("✅ Fetched \(result.count) reviews for user")
        
        return result
    }
    
    /// Fetch enhanced reviews for a user with dog information
    func fetchUserReviewsWithDogInfo(userId: String) async throws -> [Review] {
        guard let url = URL(string: "\(baseURL)/user/\(userId)/enhanced") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("📦 Fetching enhanced reviews for user:", userId)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = makeISODecoder()
        
        let result = try decoder.decode([Review].self, from: data)
        print("✅ Fetched \(result.count) enhanced reviews for user")
        
        return result
    }
    
    /// Fetch reviews for a specific dog from Firestore
    func fetchReviews(for dogId: String) async throws -> [Review] {
        let snapshot = try await db.collection("dogReviews")
            .whereField("revieweeId", isEqualTo: dogId)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Review.self) }
    }
    
    // MARK: - Helper Methods
    
    private func makeISODecoder() -> JSONDecoder {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .custom { decoder in
            let s = try decoder.singleValueContainer().decode(String.self)
            if let d = ISO.parse(s) { return d }  // uses your ISO helper (withFractionalSeconds)
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Invalid ISO-8601 date: \(s)")
            )
        }
        return dec
    }
    // eror handling
    enum ReviewServiceError: LocalizedError {
        case server(message: String, code: Int)
        case transport(URLError)
        
        var errorDescription: String? {
            switch self {
            case .server(let message, let code):
                return "HTTP \(code): \(message)"
            case .transport(let e):
                return e.localizedDescription
            }
        }
    }
    
    struct APIErrorPayload: Decodable {
        let error: String?
        let message: String?
    }
    

}
