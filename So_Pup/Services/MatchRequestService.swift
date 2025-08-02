import Foundation

// A singleton service to handle match request-related API calls.
final class MatchRequestService {
    static let shared = MatchRequestService()
    private init() {}
    
    private let baseURL = "https://api-2z4snw37ba-uc.a.run.app/matchRequest"
    /// Sends a new match request to the backend.
    /// - Parameters:
    ///   - fromDogId: The ID of the current user's dog
    ///   - toUserId: The user ID of the recipient
    ///   - toDogId: The dog ID of the recipient
    ///   - authToken: Firebase ID token for authorization
    /// - Returns: The newly created `MatchRequest` object
    func sendMatchRequest(
        fromDogId: String,
        toUserId: String,
        toDogId: String,
        message: String,
        authToken: String
    ) async throws -> MatchRequest {
        guard let url = URL(string: "\(baseURL)/send") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "fromDogId": fromDogId,
            "toUserId": toUserId,
            "toDogId": toDogId,
            "message": message
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("📦 Request:", body)
        
        // Send the request and decode the response
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        print("✅ Response status: \(httpResponse.statusCode)")

        let decoded = try JSONDecoder().decode(MatchRequest.self, from: data)
        
        print("✅ Match request sent successfully:", decoded)
        return decoded
    }
    
    /// Updates the status of an existing match request.
    /// - Parameters:
    ///   - requestId: The match request ID to update
    ///   - status: New status to set (`accepted` or `rejected`)
    ///   - authToken: Firebase ID token for authorization
    func updateMatchStatus(
        requestId: String,
        status: MatchRequestStatus,
        authToken: String
    ) async throws {
        guard let url = URL(string: "\(baseURL)/\(requestId)/status") else {
            throw URLError(.badURL)
        }
        print("📝 Updating status of matchRequest \(requestId) to \(status.rawValue)")

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["status": status.rawValue]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("📦 Request:", body)

        // Send the request and validate the response
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        print("✅ Status updated successfully.")

    }
}


