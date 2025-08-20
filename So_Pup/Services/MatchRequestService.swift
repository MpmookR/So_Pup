import Foundation

// A singleton service to handle match request-related API calls.
final class MatchRequestService {
    static let shared = MatchRequestService()
    private init() {}
    
    private let baseURL = "https://api-2z4snw37ba-uc.a.run.app/matchRequest"

    // MARK: Send match request
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
        let body: [String: String] = [
            "fromDogId": fromDogId,
            "toUserId": toUserId,
            "toDogId": toDogId,
            "message": message
        ]
        
        request.httpBody = try JSONCoder.encoder().encode(body)
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

    
    /// Updates the status of an existing match request and build the chatroom
    struct UpdateMatchStatusResponse: Codable {
        let message: String
        let chatRoomId: String?
    }

    func updateMatchStatus(
        requestId: String,
        status: MatchRequestStatus,
        authToken: String
    ) async throws -> UpdateMatchStatusResponse {
        guard let url = URL(string: "\(baseURL)/\(requestId)/status") else {
            throw URLError(.badURL)
        }
        print("📝 Updating status of matchRequest \(requestId) to \(status.rawValue)")

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: String] = ["status": status.rawValue]
        
        request.httpBody = try JSONCoder.encoder().encode(body)
        print("📦 Request:", body)

        // Send the request and validate the response
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONCoder.decoder().decode(UpdateMatchStatusResponse.self, from: data)
        print("✅ Status updated: \(decoded.message), chatRoomId: \(decoded.chatRoomId ?? "nil")")
        return decoded
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
        let result = try JSONCoder.decoder().decode([String: Bool].self, from: data)
        return result["exists"] ?? false
    }
    
    func fetchMatchRequests(
        dogId: String,
        type: String, // "incoming" or "outgoing"
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

        return try JSONCoder.decoder().decode([MatchRequest].self, from: data)
    }


}


