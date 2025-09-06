//
//  Lightweight global navigation coordinator.
//  Exposes published properties that views can observe to trigger navigation
//  events (e.g. deep-links, push notifications).
//
//  Key Responsibilities:
//  - Store the ID of a chat room that should be navigated to
//  - Allow views such as ChatView to observe and respond to navigation requests
//  - Decouple navigation triggers from the view hierarchy
//
//  Published Properties:
//  - pendingChatRoomId: Optional chat room ID; when set, views can navigate
//    into that chat and then clear the value
//
//  Usage:
//  Inject as an @EnvironmentObject throughout the app. Update
//  `pendingChatRoomId` when an external event (like a push notification)
//  should open a specific chat.
//
//  Note:
//  pendingChatRoomId: a chat room the app should open automatically, but can’t be opened yet.
//
import Foundation

final class GlobalRouter: ObservableObject {
    @Published var pendingChatRoomId: String? = nil
}


