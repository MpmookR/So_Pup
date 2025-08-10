import Foundation

struct ChatRoom: Hashable, Codable {
    var id: String
    var dogIds: [String]; // e.g., ["dog123", "dog456"]
    var userIds: [String]; // e.g., ["user123", "user456"]
    var createdAt: String;
    var isPuppyMode: Bool;
    var lastMessage: LastMessagePreview?; // stores the last message preview like WhatsApp or Telegram
}

struct LastMessagePreview: Hashable, Codable{
    var text: String;
    var timestamp: String;
    var senderId: String;
    var messageType: MessageType;
}

// for decode backend sent data
struct ChatRoomCreation: Codable {
    var chatroomId: String
}

import Foundation

extension ChatRoom {
    func otherUserId(currentUserId: String) -> String? {
        userIds.first { $0 != currentUserId }
    }

    func otherDogId(myDogId: String) -> String? {
        dogIds.first { $0 != myDogId }
    }

    /// Freshest ISO8601 string for this room (last message if present, else createdAt)
    var newestISOTimeString: String {
        lastMessage?.timestamp ?? createdAt
    }
}



