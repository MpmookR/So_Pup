/// --------------------
/// Compose-box view model for sending chat messages (main actor).
///
/// Responsibilities
/// - Holds draft text, sending/error flags, and the addressable context (room/user/dog IDs).
/// - Configures sending context from a `ChatRoom` or via explicit IDs.
/// - Validates readiness via `canSend` and serialises sends with `isSending`.
/// - Obtains a fresh Firebase ID token from `AuthViewModel` and calls `ChatService.sendMessage(...)`.
///
/// Key collaborators
/// - `AuthViewModel` --> `fetchIDToken()` for backend auth.
/// - `ChatService` --> message delivery to the backend.
/// - `ChatRoom` -->  convenience for resolving the other user/dog IDs.
///
/// Usage
/// 1) Initialise with `AuthViewModel`.
/// 2) Call `setContext(...)` (from room or explicit IDs).
/// 3) Bind `draft` to the input field; call `await send()` on submit.
/// --------------------
import Foundation

@MainActor
final class SendMessageViewModel: ObservableObject {
    @Published var draft: String = ""
    @Published var isSending = false
    @Published var errorMessage: String?

    private let authVM: AuthViewModel
    private let chatService: ChatService

    // Context required to send
    private var chatRoomId: String = ""
    private var senderUserId: String = ""
    private var senderDogId: String = ""
    private var receiverUserId: String = ""
    private var receiverDogId: String = ""

    init(authVM: AuthViewModel, chatService: ChatService = .shared) {
        self.authVM = authVM
        self.chatService = chatService
    }

    // Configure using a ChatRoom
    @discardableResult
    func setContext(room: ChatRoom, currentUserId: String, myDogId: String) -> Bool {
        guard
            let otherUser = room.otherUserId(currentUserId: currentUserId),
            let otherDog  = room.otherDogId(myDogId: myDogId)
        else {
            errorMessage = "Couldn’t resolve receiver IDs."
            return false
        }
        chatRoomId     = room.id
        senderUserId   = currentUserId
        senderDogId    = myDogId
        receiverUserId = otherUser
        receiverDogId  = otherDog
        return true
    }

    // Or configure explicitly if you already have IDs
    func setContext(chatRoomId: String,
                    senderUserId: String,
                    senderDogId: String,
                    receiverUserId: String,
                    receiverDogId: String) {
        self.chatRoomId     = chatRoomId
        self.senderUserId   = senderUserId
        self.senderDogId    = senderDogId
        self.receiverUserId = receiverUserId
        self.receiverDogId  = receiverDogId
    }

    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !chatRoomId.isEmpty &&
        !receiverUserId.isEmpty &&
        !receiverDogId.isEmpty &&
        !isSending
    }

    func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        print("➡️ send(): room=\(chatRoomId) text='\(text)' toUser=\(receiverUserId) toDog=\(receiverDogId) fromDog=\(senderDogId)")

        guard canSend else {
            if chatRoomId.isEmpty { errorMessage = "Missing chat room." }
            else { errorMessage = "Missing receiver IDs." }
            return
        }

        isSending = true
        defer { isSending = false }

        do {
            let token = try await authVM.fetchIDToken()
            try await chatService.sendMessage(
                chatRoomId: chatRoomId,
                text: text,
                receiverId: receiverUserId,
                senderDogId: senderDogId,
                receiverDogId: receiverDogId,
                authToken: token
            )
            draft = "" // update the field text - clear bar
            print("✅ send() completed")

        } catch {
            errorMessage = error.localizedDescription
            print("❌ send() failed: \(error)")

        }
    }
}

