import Foundation
import SwiftUI
import FirebaseAuth

final class MatchScoringService {
    
    static let shared = MatchScoringService()
    private init() {}
    
    /// Sends a scoring request to the backend and returns scored matches
    func sendScoringRequest(
        currentDog: DogModel,
        candidateDogIds: [String],
        userLocation: Coordinate,
        filters: DogFilterSettings?,
        excludedDogIds: [String] = []
    
    ) async throws -> [ScoredDog] {
        // Construct the DTO payload
        let scoringDTO = MatchScoringDTO(
            currentDogId: currentDog,
            filteredDogIds: candidateDogIds,
            userLocation: userLocation,
            filters: filters?.toDTO(),
            excludedDogIds: excludedDogIds
        )
        
        guard let url = URL(string: "https://api-2z4snw37ba-uc.a.run.app/matchScoring/score") else {
            throw URLError(.badURL)
        }
        
        // Get Firebase ID token
        guard let user = Auth.auth().currentUser else {
            throw URLError(.userAuthenticationRequired)
        }
        let idToken = try await user.getIDToken()
        
        // Build the POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let jsonData = try JSONEncoder().encode(scoringDTO)
        request.httpBody = jsonData
        
#if DEBUG
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 Sending MatchScoringDTO:\n\(jsonString)")
        }
#endif
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
#if DEBUG
        if let rawResponse = String(data: data, encoding: .utf8) {
            print("📥 Raw response:\n\(rawResponse)")
        }
#endif
        
        // Decode response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let matches = try decoder.decode([ScoredDog].self, from: data)

        return matches
    }
}
