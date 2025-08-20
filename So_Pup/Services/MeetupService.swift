import Foundation
import FirebaseAuth

final class MeetupService {
    static let shared = MeetupService()
    private init() {}
    
    private let baseURL = "https://api-2z4snw37ba-uc.a.run.app/meetups"
    
    // MARK: - API Methods
    /// Create a new meetup request
    func createMeetupRequest(
        chatRoomId: String,
        meetup: MeetupRequest,
        senderId: String,
        receiverId: String,
        senderDogId: String,
        receiverDogId: String,
        authToken: String
    ) async throws {
        guard let url = URL(string: "\(baseURL)/\(chatRoomId)/create") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let dto = CreateMeetupRequestDTO(
            meetup: meetup,
            senderId: senderId,
            receiverId: receiverId,
            senderDogId: senderDogId,
            receiverDogId: receiverDogId
        )
        request.httpBody = try JSONCoder.encoder().encode(dto)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            // Try to surface backend error if present
            if let http = response as? HTTPURLResponse {
                if let err = try? JSONCoder.decoder().decode(ErrorResponse.self, from: data) {
                    throw NSError(domain: "MeetupService", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: err.error])
                }
            }
            throw URLError(.badServerResponse)
        }
        
        print("✅ Meetup request created successfully")
        
    }
    
    /// Update meetup status (accept/reject)
    func updateMeetupStatus(
        chatRoomId: String,
        meetupId: String,
        status: MeetupStatus,
        receiverId: String,
        authToken: String
    ) async throws {
        guard let url = URL(string: "\(baseURL)/\(chatRoomId)/\(meetupId)/status") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: String] = [
            "status": status.rawValue,
            "receiverId": receiverId
        ]
        
        request.httpBody = try JSONCoder.encoder().encode(body)
        print("📦 Updating meetup status:", body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            if let http = response as? HTTPURLResponse,
               let err = try? JSONCoder.decoder().decode(ErrorResponse.self, from: data) {
                throw NSError(domain: "MeetupService", code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: err.error])
            }
            throw URLError(.badServerResponse)
        }
        print("✅ Meetup status updated to \(status.rawValue)")
    }
    
    /// Cancel a meetup request
    func cancelMeetupRequest(
        chatRoomId: String,
        meetupId: String,
        receiverId: String,
        authToken: String
    ) async throws {
        guard let url = URL(string: "\(baseURL)/\(chatRoomId)/\(meetupId)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: String] = ["receiverId": receiverId]
        request.httpBody = try JSONCoder.encoder().encode(body)
        print("📦 Cancelling meetup request:", body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            if let http = response as? HTTPURLResponse,
               let err = try? JSONCoder.decoder().decode(ErrorResponse.self, from: data) {
                throw NSError(domain: "MeetupService", code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: err.error])
            }
            throw URLError(.badServerResponse)
        }
        print("✅ Meetup request cancelled successfully")
    }
    
    /// Mark a meetup as complete
    func markMeetupComplete(
        chatRoomId: String,
        meetupId: String,
        authToken: String
    ) async throws {
        guard let url = URL(string: "\(baseURL)/\(chatRoomId)/\(meetupId)/complete") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            if let http = response as? HTTPURLResponse,
               let err = try? JSONCoder.decoder().decode(ErrorResponse.self, from: data) {
                throw NSError(domain: "MeetupService", code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: err.error])
            }
            throw URLError(.badServerResponse)
        }
        print("✅ Meetup marked as complete")
    }
    
    /// Fetch meetups for a user with optional filters
    func fetchUserMeetups(
        userId: String,
        type: String? = nil,       // Optional: "incoming" or "outgoing"
        status: MeetupStatus? = nil, // Optional: .pending, .accepted, etc.
        authToken: String
    ) async throws -> [MeetupSummaryDTO] {
        
        // 1. Start building the base URL with the user ID
        var components = URLComponents(string: "\(baseURL)/user/\(userId)")
        
        // 2. Prepare query parameters (only if provided)
        var queryItems: [URLQueryItem] = []
        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status.rawValue))
        }
        
        // 3. Assign query items to URL components (nil if no filters provided)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        
        // 4. Ensure we have a valid final URL
        guard let url = components?.url else { throw URLError(.badURL) }
        
        // 5. Build the GET request with authentication
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        // Debug log: Show which query parameters are being sent
        print("📦 Fetching meetups for user: \(userId) — Query: \(queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&"))")
        
        // 6. Send the request and get the response
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 7. Ensure the response status code is in the success range (200-299)
        guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    if let http = response as? HTTPURLResponse,
                       let err = try? JSONCoder.decoder().decode(ErrorResponse.self, from: data) {
                        throw NSError(domain: "MeetupService", code: http.statusCode,
                                      userInfo: [NSLocalizedDescriptionKey: err.error])
                    }
                    throw URLError(.badServerResponse)
                }
        
        // 8. Decode JSON into our model
        let result = try JSONCoder.decoder().decode(FetchMeetupsResponse.self, from: data)
         print("✅ Fetched \(result.meetups.count) meetups for user")
         return result.meetups
     
    }
    
    // MARK: - DTOs (request-only)
    private struct CoordinateDTO: Codable {
        let latitude: Double
        let longitude: Double
    }
    
    private struct MeetupPayloadDTO: Codable {
        let proposedTime: Date
        let locationName: String
        let locationCoordinate: CoordinateDTO
        let meetUpMessage: String
    }
    
    private struct CreateMeetupRequestDTO: Codable {
        let meetup: MeetupPayloadDTO
        let senderId: String
        let receiverId: String
        let senderDogId: String
        let receiverDogId: String
        
        init(meetup: MeetupRequest,
             senderId: String,
             receiverId: String,
             senderDogId: String,
             receiverDogId: String) {
            self.meetup = .init(
                proposedTime: meetup.proposedTime,
                locationName: meetup.locationName,
                locationCoordinate: .init(
                    latitude: meetup.locationCoordinate.latitude,
                    longitude: meetup.locationCoordinate.longitude
                ),
                meetUpMessage: meetup.meetUpMessage
            )
            self.senderId = senderId
            self.receiverId = receiverId
            self.senderDogId = senderDogId
            self.receiverDogId = receiverDogId
        }
    }
    
}
