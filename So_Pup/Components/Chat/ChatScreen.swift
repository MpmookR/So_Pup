import SwiftUI

struct ChatScreen: View {
    let dog: DogModel
    let chatRoomId: String
    let currentUserId: String  // Injected from parent
    var onBack: (() -> Void)? = nil
    
    @State private var scrollTarget: String?
    
    @StateObject private var messageService = FirestoreMessageService()

    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(
                title: "\(dog.displayName)'s Profile",
                showBack: true,
                onBackTap: onBack,
                backgroundColor: .white
            )

            ScrollView {
                LazyVStack {
                    ForEach(messageService.messages) { message in
                        ChatBubble(
                            id: message.id,
                            text: message.text,
                            isCurrentUser: message.senderId == currentUserId
                        )
                    }
                }
            }
            // bind the scroll position to an ID
            .scrollPosition(id: $scrollTarget)

            ChatInputBar()
        }
        .padding(.horizontal)
        .background(Color(.systemGroupedBackground))
        .onAppear { messageService.listenToMessages(chatRoomId: chatRoomId) }
        .onDisappear { messageService.stopListening() }

        // Re-run when the last message ID changes
        .task(id: messageService.messages.last?.id) {
            withAnimation {
                scrollTarget = messageService.messages.last?.id
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
