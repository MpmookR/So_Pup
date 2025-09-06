// -------------------
//  SwiftUI view that hosts a single chat conversation. Wraps `ChatScreen`
//  with the necessary data (dog, owner, room) and manages a local
//  SendMessageViewModel instance.
//
//  Key Responsibilities:
//  - Serve as the entry point to an active chat from a ChatRoomCardData
//  - Pass user, dog, and room details to `ChatScreen`
//  - Provide back-navigation closure (`onBack`) to return to the chat list
//  - Initialise and own a `SendMessageViewModel` scoped to this chat
//
//  State / Environment:
//  - authViewModel (EnvironmentObject): Injected authentication state
//  - sendVM (StateObject): Handles sending messages for this chat
//  - viewerCoordinate (State): Optional location of the viewing user
//
//  Usage:
//  Instantiate with `ChatRoomCardData` and an `onBack` closure. Requires
//  `AuthViewModel` to be present in the environment for user context.
// -------------------
import SwiftUI
import FirebaseAuth

struct ChatDestination: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let card: ChatRoomCardData
    var onBack: () -> Void
    
    @State private var viewerCoordinate: Coordinate? = nil
    @StateObject private var sendVM: SendMessageViewModel
    
    /// Custom init is needed to pass AuthViewModel into @StateObject
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
            owner: card.owner,
            room: card.room,
            currentUserId: uid,
            onBack: onBack,
            sendMessage: sendVM
        )
    }
}
 
