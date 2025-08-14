import Foundation

// MARK: - ISO helper
// MARK: - ISO (fractional seconds) formatter
enum ISO {
    static let shared: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    /// Parse ISO8601 string (with/without fractional seconds)
    static func parse(_ s: String) -> Date? {
        guard !s.isEmpty else { return nil }
        if let d = shared.date(from: s) { return d }
        return ISO8601DateFormatter().date(from: s)
    }
}

// MARK: - Card builder (ChatRoom -> ChatRoomCardData)
// Builds ChatRoomCardData arrays from rooms
struct ChatCardBuilder {
    static func build(from rooms: [ChatRoom],
                      currentDogId: String,
                      profileService: ProfileDataService) async -> [ChatRoomCardData] {

        var results: [ChatRoomCardData] = []

        await withTaskGroup(of: ChatRoomCardData?.self) { group in
            for room in rooms {
                group.addTask {
                    // Pick the "other" dog id in this room
                    guard let otherDogId = room.dogIds.first(where: { $0 != currentDogId }) else { return nil }

                    // Fetch dog data
                    guard let dog = try? await profileService.fetchDog(by: otherDogId) else { return nil }

                    // Fetch owner data from dog's ownerId
                    guard let owner = try? await profileService.fetchUser(by: dog.ownerId) else { return nil }

                    return ChatRoomCardData(room: room, dog: dog, owner: owner)
                }
            }
            for await card in group {
                if let card { results.append(card) }
            }
        }

        // Sort newest first by lastMessage.timestamp (fallback to createdAt)
        results.sort {
            let a = ISO.shared.date(from: $0.room.lastMessage?.timestamp ?? $0.room.createdAt) ?? .distantPast
            let b = ISO.shared.date(from: $1.room.lastMessage?.timestamp ?? $1.room.createdAt) ?? .distantPast
            return a > b
        }
        return results
    }
}

// MARK: - Read state (NEW dot) helper
enum ChatReadState {
    private static func key(for roomId: String) -> String { "lastSeen_\(roomId)" }
    
    static func lastSeen(for roomId: String) -> Date {
        (UserDefaults.standard.object(forKey: key(for: roomId)) as? Date) ?? .distantPast
    }
    
    /// True if room has a message newer than last seen.
    static func isNew(room: ChatRoom) -> Bool {
        let lastSeen = lastSeen(for: room.id)
        guard let latest = ISO.parse(room.newestISOTimeString) else { return false }
        return latest > lastSeen
    }
    
    /// Persist that the user has seen up to the room's latest timestamp.
    static func markAsRead(room: ChatRoom) {
        let k = key(for: room.id)
        let currentStored = (UserDefaults.standard.object(forKey: k) as? Date) ?? .distantPast
        if let latest = ISO.parse(room.newestISOTimeString) {
            UserDefaults.standard.set(max(currentStored, latest), forKey: k)
        } else {
            // No messages; store now so it won't appear NEW.
            UserDefaults.standard.set(Date(), forKey: k)
        }
    }
}

