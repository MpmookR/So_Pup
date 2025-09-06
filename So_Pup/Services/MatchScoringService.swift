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

        // 1) Build DTO
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
        guard let user = Auth.auth().currentUser else {
            throw URLError(.userAuthenticationRequired)
        }

        // 2) Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONCoder.encoder()
        let body = try encoder.encode(scoringDTO)
        request.httpBody = body

        // Helpful debug prints (safe in TestFlight)
        if let jsonString = String(data: body, encoding: .utf8) {
            print("📤 MatchScoring request:\n\(jsonString)")
        }

        // Helper to execute with a specific token
        func perform(with token: String) async throws -> (Data, HTTPURLResponse) {
            var req = request
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            return (data, http)
        }

        // 3) First try with current token
        var token = try await user.getIDToken()
        var (data, http) = try await perform(with: token)

        // 4) Retry once on 401/403 (stale token / auth race)
        if http.statusCode == 401 || http.statusCode == 403 {
            token = try await user.getIDToken()
            (data, http) = try await perform(with: token)
        }

        // 5) Non-200 handling (surface message to UI layer if you want)
        guard (200..<300).contains(http.statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? "<no body>"
            print("❌ MatchScoring HTTP \(http.statusCode): \(bodyText)")
            throw URLError(.badServerResponse)
        }

        if let raw = String(data: data, encoding: .utf8) {
            print("📥 MatchScoring response:\n\(raw)")
        }

        // 6) Decode with tolerant ISO8601 strategy
        let decoder = JSONCoder.decoder()
        do {
            let matches = try decoder.decode([ScoredDog].self, from: data)
            return matches
        } catch {
            print("❌ MatchScoring decode failed: \(error.localizedDescription)")
            throw error
        }
    }
}
