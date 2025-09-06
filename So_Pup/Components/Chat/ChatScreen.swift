import SwiftUI

struct ChatScreen: View {
    let dog: DogModel // other's dog
    let owner: UserModel
    let room: ChatRoom
    let currentUserId: String
//    let viewerCoordinate: Coordinate?
    var onBack: (() -> Void)? = nil
        
    @StateObject private var messageService = FirestoreMessageService()
    @ObservedObject var sendMessage: SendMessageViewModel
    
    @EnvironmentObject private var meetupVM: MeetupViewModel
    @EnvironmentObject private var matchingVM: MatchingViewModel
    
    @State private var scrollTarget: String?
    @State private var showCreateMeetup = false

    var body: some View {
        VStack(spacing: 0) {
            HStack{
                CustomNavBar(
                    title: "\(dog.displayName)'s Profile",
                    showBack: true,
                    onBackTap: onBack,
                    backgroundColor: .white
                )
                ViewProfileButton(
                    dog: dog,
                    owner: owner,
                    viewerCoordinate: matchingVM.userCoordinate.map(Coordinate.init),
                    title: nil
                )
                    .padding(.trailing, 12)
                    .padding(.top, 8)
            }

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
                onBack: { showCreateMeetup = false },
                chatRoomId: room.id,
                receiverId: room.otherUserId(currentUserId: currentUserId) ?? "",
                receiverDogId: dog.id,
                receiverDogName: dog.displayName
            )
        }
        // Start the Firestore snapshot listener for this room when the view appears
        // This streams new/edited messages in real time - pair with `.onDisappear { messageService.stopListening() }`
        // to detach the listener and avoid leaks/battery/network usage
        .onAppear { messageService.listenToMessages(chatRoomId: room.id) }
        .onDisappear { messageService.stopListening() }
        .onTapGesture { hideKeyboard() }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        // configure the SendMessage VM when the screen opens / room changes
                .task(id: room.id) {
                    let myDogId = room.dogIds.first { $0 != dog.id } ?? ""
                    let ok = sendMessage.setContext(
                        room: room,
                        currentUserId: currentUserId,
                        myDogId: myDogId
                    )
                    print("🧭 setContext ok=\(ok) room=\(room.id) myDogId=\(myDogId)")
                }
    }
    // MARK: - Meetup gating
    // Allowed only if BOTH dogs are in Social mode.
    private var canCreateMeetup: Bool {
        guard let myDog = matchingVM.currentDog else {
            // While loading your dog, be safe and disallow
            return false
        }
        return (myDog.mode == .social) && (dog.mode == .social)
    }
}
