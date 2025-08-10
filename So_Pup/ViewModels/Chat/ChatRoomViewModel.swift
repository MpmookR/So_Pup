import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class ChatRoomViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var draft: String = ""
    @Published var isSending = false
    @Published var error: String?

    private let chatRoomId: String
    private let currentUserId: String
    private let receiverUserId: String
    private let senderDogId: String
    private let receiverDogId: String
    private let authVM: AuthViewModel

    // Your existing realtime listener (reuse if you already have one)
    private let messageListener = FirestoreMessageService()

    init(
        chatRoomId: String,
        currentUserId: String,
        receiverUserId: String,
        senderDogId: String,
        receiverDogId: String,
        authVM: AuthViewModel
    ) {
        self.chatRoomId = chatRoomId
        self.currentUserId = currentUserId
        self.receiverUserId = receiverUserId
        self.senderDogId = senderDogId
        self.receiverDogId = receiverDogId
        self.authVM = authVM
    }

    func start() {
        messageListener.listenToMessages(chatRoomId: chatRoomId)
        // Bridge listener into this VM’s published array
        Task { @MainActor [weak self] in
            guard let self else { return }
            for await msgs in messageListener.stream() { // add a `stream()` async sequence in your service, or poll via delegate/callback
                self.messages = msgs
            }
        }
    }

    func stop() {
        messageListener.stopListening()
    }

    func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        isSending = true; error = nil
        do {
            let token = try await authVM.fetchIDToken()
            _ = try await ChatService.shared.sendMessage(
                chatRoomId: chatRoomId,
                text: text,
                receiverId: receiverUserId,
                senderDogId: senderDogId,
                receiverDogId: receiverDogId,
                authToken: token
            )
            draft = "" // clear on success; listener will bring in the new message
        } catch {
            self.error = error.localizedDescription
        }
        isSending = false
    }
}


