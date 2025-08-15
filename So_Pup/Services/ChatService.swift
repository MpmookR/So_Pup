import Foundation

final class ChatService {
    static let shared = ChatService()
    private init() {}
    
    private let baseURL = "https://api-2z4snw37ba-uc.a.run.app/chat"
    
    // create chatroom
    func createChatroom(
        fromDogId: String,
        toUserId: String,
        toDogId: String,
        authToken: String
    )async throws -> String {
        // Build the target URL for the match request endpoint
        guard let url = URL(string: "\(baseURL)/createRoom") else {
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
        ]
        
        // Encode the body as JSON
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("📦 Request:", body)
        
        // Send the HTTP request and wait for the response
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(ChatRoomCreation.self, from: data)
        print("✅ Chatroom created with ID:", decoded.chatroomId)
        return decoded.chatroomId
    }
    
    // send message in the chatroom
    func sendMessage(
        chatRoomId: String,
        text: String,
        receiverId: String,
        senderDogId: String,
        receiverDogId: String,
        authToken: String
    ) async throws {
        guard let url = URL(string: "\(baseURL)/sendMessage") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "chatRoomId": chatRoomId,
            "text": text,
            "receiverId": receiverId,
            "senderDogId": senderDogId,
            "receiverDogId": receiverDogId
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("📦 message to send:", body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200..<300).contains(http.statusCode) {
            let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("❌ sendMessage HTTP \(http.statusCode). Body:\n\(raw)")
            throw URLError(.badServerResponse)
        }

        // No decode needed — Firestore listener will bring the new message in.
        if let raw = String(data: data, encoding: .utf8) {
            print("✅ sendMessage accepted. Raw response:\n\(raw)")
        } else {
            print("✅ sendMessage accepted (non-UTF8 body).")
        }
    }

    
    // fetch all messages belongs to the chatroom
    func fetchMessages(
        for chatRoomId: String,
        authToken: String
    ) async throws -> [Message] {
        guard let url = URL(string: "\(baseURL)/\(chatRoomId)/messages") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let messages = try JSONDecoder().decode([Message].self, from: data)
        print("📥 \(messages.count) messages fetched for chatRoom \(chatRoomId)")
        return messages
    }

    // fectch all chatroom for the user
    func fetchChatRooms(authToken: String) async throws -> [ChatRoom] {
        guard let url = URL(string: "\(baseURL)/rooms") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let chatRooms = try JSONDecoder().decode([ChatRoom].self, from: data)
        print("📥 \(chatRooms.count) chat rooms fetched")
        print("Raw chat room JSON:", String(data: data, encoding: .utf8) ?? "nil")
        return chatRooms
    }
    
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

}


