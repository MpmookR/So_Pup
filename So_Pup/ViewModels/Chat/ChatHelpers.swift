/// -------------------
//  Provides utility components for chat functionality in the SoPup app,
//  including ISO date handling, chat room card construction, and read state
//  management.
//
//  Components:
///  - ISO: Helper for parsing and formatting ISO8601 date strings, including
///          fractional seconds support.
///  - ChatCardBuilder: Asynchronously builds ChatRoomCardData objects from
///          ChatRoom models by resolving related Dog and User information.
///          Uses an actor-based cache to ensure thread-safe reuse of fetched
///          dogs and users.
///  - ChatReadState: Persists and checks message "read" state per chat room
///          using UserDefaults. Determines if a room has new/unread messages
///          and marks rooms as read.
//
//  Key Features:
///  - Thread-safe caching for dogs and users when building chat cards
///  - Sorting of chat rooms by latest activity (last message or creation date)
///  - ISO8601 parsing that gracefully handles fractional and non-fractional
///    timestamps
///  - Lightweight persistence of last seen timestamps for "NEW" dot indicators
/// -------------------
import Foundation

// MARK: - Card builder (ChatRoom -> ChatRoomCardData)
// Builds ChatRoomCardData arrays from rooms
struct ChatCardBuilder {

    // Thread-safe caches guarded by an actor
    private actor Cache {
        var dogs: [String: DogModel] = [:]
        var users: [String: UserModel] = [:]

        func dog(for id: String) -> DogModel? { dogs[id] }
        func putDog(_ dog: DogModel, for id: String) { dogs[id] = dog }

        func user(for id: String) -> UserModel? { users[id] }
        func putUser(_ user: UserModel, for id: String) { users[id] = user }
    }

    static func build(
        from rooms: [ChatRoom],
        currentDogId: String,
        profileService: ProfileDataService
    ) async -> [ChatRoomCardData] {

        let cache = Cache()                  // <- shared, but synchronized
        var results: [ChatRoomCardData] = []

        await withTaskGroup(of: ChatRoomCardData?.self) { group in
            for room in rooms {
                group.addTask {
                    // 1) find the "other" dog id
                    guard let otherDogId = room.dogIds.first(where: { $0 != currentDogId }) else {
                        return nil
                    }

                    // 2) DOG (use cache first)
                    let dog: DogModel
                    if let c = await cache.dog(for: otherDogId) {
                        dog = c
                    } else if let fetched = try? await profileService.fetchDog(by: otherDogId) {
                        await cache.putDog(fetched, for: otherDogId)
                        dog = fetched
                    } else {
                        return nil
                    }

                    // 3) OWNER (use dog's ownerId, not room.userIds)
                    let ownerId = dog.ownerId
                    let owner: UserModel
                    if let c = await cache.user(for: ownerId) {
                        owner = c
                    } else if let fetched = try? await profileService.fetchUser(by: ownerId) {
                        await cache.putUser(fetched, for: ownerId)
                        owner = fetched
                    } else {
                        return nil
                    }

                    // 4) Build card
                    return ChatRoomCardData(room: room, dog: dog, owner: owner)
                }
            }

            for await card in group {
                if let card { results.append(card) }   // single-threaded append here
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
