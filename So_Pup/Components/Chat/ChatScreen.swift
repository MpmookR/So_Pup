import SwiftUI

struct ChatScreen: View {
    let dog: DogModel
    let room: ChatRoom
    let currentUserId: String
    var onBack: (() -> Void)? = nil
        
    @StateObject private var messageService = FirestoreMessageService()
    @ObservedObject var sendMessage: SendMessageViewModel
        
    @State private var scrollTarget: String?

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
            // keep scroll at bottom
            .task(id: messageService.messages.last?.id) {
                withAnimation { scrollTarget = messageService.messages.last?.id }
            }
            
            ChatInputBar(
                text: $sendMessage.draft,
                onSend: { _ in
                    print("🟢 ChatInputBar onSend fired")
                    Task { await sendMessage.send() } },
                onCreateMeetup: { /* open meet-up */ }
            )
            .disabled(sendMessage.isSending)
        }
        .padding(.horizontal)
        .background(.white)
        .onAppear { messageService.listenToMessages(chatRoomId: room.id) }
        .onDisappear { messageService.stopListening() }
        .onTapGesture { hideKeyboard() }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        // configure the SendMessage VM when the screen opens / room changes
                .task(id: room.id) {
                    // myDogId = the room dog that is NOT the other dog's id
                    let myDogId = room.dogIds.first { $0 != dog.id } ?? ""
                    let ok = sendMessage.setContext(
                        room: room,
                        currentUserId: currentUserId,
                        myDogId: myDogId
                    )
                    print("🧭 setContext ok=\(ok) room=\(room.id) myDogId=\(myDogId)")
                }
    }
}
