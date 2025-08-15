import SwiftUI
import FirebaseAuth

struct ChatDestination: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let card: ChatRoomCardData
    var onBack: () -> Void

    @StateObject private var sendVM: SendMessageViewModel

    init(card: ChatRoomCardData, onBack: @escaping () -> Void, authVM: AuthViewModel? = nil) {
        self.card = card
        self.onBack = onBack
        // create with the *shared* AuthViewModel passed in from the parent
        _sendVM = StateObject(wrappedValue: SendMessageViewModel(authVM: authVM ?? AuthViewModel()))
    }

    var body: some View {
        let uid = Auth.auth().currentUser?.uid ?? ""
        ChatScreen(
            dog: card.dog,
            room: card.room,
            currentUserId: uid,
            onBack: onBack,
            sendMessage: sendVM,
            authVM: authViewModel
        )
    }
}
