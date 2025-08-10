import Foundation

// MARK: - ISO helper
enum ISO {
    static let shared: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
}

// MARK: - Card builder (ChatRoom -> ChatRoomCardData)
// Builds ChatRoomCardData arrays from rooms
struct ChatCardBuilder {
    static func build(from rooms: [ChatRoom],
                      currentDogId: String,
                      profileService: ProfileDataService) async -> [ChatRoomCardData] {

        var dogCache:  [String: DogModel] = [:]
        var userCache: [String: UserModel] = [:]
        var results: [ChatRoomCardData] = []

        await withTaskGroup(of: ChatRoomCardData?.self) { group in
            for room in rooms {
                group.addTask {
                    // Pick the "other" dog id in this room
                    guard let otherDogId = room.dogIds.first(where: { $0 != currentDogId }) else { return nil }

                    // DOG (inline cache)
                    let dog: DogModel
                    if let cached = dogCache[otherDogId] {
                        dog = cached
                    } else if let fetched = try? await profileService.fetchDog(by: otherDogId) {
                        dogCache[otherDogId] = fetched
                        dog = fetched
                    } else { return nil }

                    // OWNER from dog's ownerId (don’t trust room.userIds)
                    let ownerId = dog.ownerId
                    let owner: UserModel
                    if let cached = userCache[ownerId] {
                        owner = cached
                    } else if let fetched = try? await profileService.fetchUser(by: ownerId) {
                        userCache[ownerId] = fetched
                        owner = fetched
                    } else { return nil }

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

