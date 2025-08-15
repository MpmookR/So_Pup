import FirebaseFirestore

// for real time message updating
class FirestoreMessageService: ObservableObject {
    private var listener: ListenerRegistration?
    
    @Published var messages: [Message] = []

    func listenToMessages(chatRoomId: String) {
        let db = Firestore.firestore()
        let messagesRef = db.collection("chatRooms").document(chatRoomId).collection("messages")
            .order(by: "timestamp", descending: false)

        listener = messagesRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Error listening to messages: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("❌ No documents in messages snapshot")
                return
            }

            do {
                self.messages = try documents.map { try $0.data(as: Message.self) }
                print("🔄 Updated messages: \(self.messages.count)")
            } catch {
                print("❌ Failed to decode messages: \(error)")
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        print("🛑 Message listener removed")
    }
}

