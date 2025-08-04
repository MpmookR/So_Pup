import Foundation

// A singleton service to handle match request-related API calls.
final class MatchRequestService {
    static let shared = MatchRequestService()
    private init() {}
    
    private let baseURL = "https://api-2z4snw37ba-uc.a.run.app/matchRequest"

    func sendMatchRequest(
        fromDogId: String,
        toUserId: String,
        toDogId: String,
        message: String,
        authToken: String
    ) async throws {
        // Build the target URL for the match request endpoint
        guard let url = URL(string: "\(baseURL)/send") else {
            throw URLError(.badURL)
        }
        // Prepare the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        // Construct the request body using dictionary encoding
        let body: [String: Any] = [
            "fromDogId": fromDogId,
            "toUserId": toUserId,
            "toDogId": toDogId,
            "message": message
        ]
        
        // Encode the body as JSON
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("📦 Request:", body)
        
        // Send the HTTP request and wait for the response
        let (_, response) = try await URLSession.shared.data(for: request)

        // Validate the HTTP response
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        print("✅ Match request sent successfully")
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
    
    // Checks if a pending match request exists between two dogs
    func checkIfRequestExists(
        fromDogId: String,
        toDogId: String,
        authToken: String
    ) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/status?fromDogId=\(fromDogId)&toDogId=\(toDogId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        // Execute request
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Decode response JSON format >> exists: true/false
        let result = try JSONDecoder().decode([String: Bool].self, from: data)
        return result["exists"] ?? false
    }
    
    func fetchMatchRequests(
        dogId: String,
        type: String, // should be "incoming" or "outgoing"
        authToken: String
    ) async throws -> [MatchRequest] {
        guard let url = URL(string: "\(baseURL)/\(dogId)?type=\(type)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([MatchRequest].self, from: data)
    }


}


