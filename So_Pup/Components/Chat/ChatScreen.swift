import SwiftUI

struct ChatScreen: View {
    let dog: DogModel
    let room: ChatRoom
    let currentUserId: String
    var onBack: (() -> Void)? = nil
        
    @StateObject private var messageService = FirestoreMessageService()
    @ObservedObject var sendMessage: SendMessageViewModel
    @StateObject private var meetupVM: MeetupViewModel
    
    @State private var scrollTarget: String?
    @State private var showCreateMeetup = false


    init(dog: DogModel, room: ChatRoom, currentUserId: String, onBack: (() -> Void)? = nil, sendMessage: SendMessageViewModel, authVM: AuthViewModel) {
        self.dog = dog
        self.room = room
        self.currentUserId = currentUserId
        self.onBack = onBack
        self.sendMessage = sendMessage
        self._meetupVM = StateObject(wrappedValue: MeetupViewModel(authVM: authVM))
    }

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
                onCreateMeetup: { showCreateMeetup = true },
                isMeetupAllowed: canCreateMeetup
            )
            .disabled(sendMessage.isSending)
        }
        .padding(.horizontal)
        .background(.white)
        .sheet(isPresented: $showCreateMeetup) {
            CreateMeetup(
                meetupVM: meetupVM,
                onBack: { showCreateMeetup = false },
                chatRoomId: room.id,
                receiverId: room.otherUserId(currentUserId: currentUserId) ?? "",
                receiverDogId: dog.id,
                receiverDogName: dog.displayName
            )
        }
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
        // Check if meetups are allowed (both dogs must be in social mode)
    private var isMeetupAllowed: Bool {
        return dog.mode == .social
    }
    
    // Check if meetups are available (both dogs must be in social mode)
    private var canCreateMeetup: Bool {
        return dog.mode == .social
    }
}
