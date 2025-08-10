import SwiftUI
import FirebaseAuth

struct ChatView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var router: GlobalRouter
    
    @State private var selectedTab = "Chat"
    @State private var hasLoaded = false
    @State private var selectedCard: ChatRoomCardData?
    
    private let tabOptions = ["Chat", "Meet-Up"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CustomNavBar(title: "Chat")
                TopTabSwitcher(tabs: tabOptions, selectedTab: $selectedTab)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if selectedTab == "Chat" {
                            if chatVM.isLoading {
                                ProgressView("Loading chats...")
                            } else if chatVM.chatRoomProfiles.isEmpty {
                                Text("No conversations yet")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(chatVM.chatRoomProfiles) { card in
                                    ChatListCard(
                                        chatroom: card.room,
                                        dog: card.dog,
                                        owner: card.owner,
                                        userCoordinate: card.owner.coordinate,
                                        isNew: chatVM.isChatRoomNew(card.room)
                                    )
                                    .onTapGesture { selectedCard = card }
                                }
                            }
                        } else {
                            MeetupListSection() // To do
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)
                }
            }
            // Navigation destination when a card is selected
            .navigationDestination(item: $selectedCard) { (card: ChatRoomCardData) in
                ChatDestination(
                    card: card,
                    onBack: { selectedCard = nil },
                    authVM: authViewModel
                )
                .onAppear { chatVM.markChatRoomAsRead(card.room) }
                .onDisappear { chatVM.markChatRoomAsRead(card.room) }
            }
            // Initial load
            .task {
                guard !hasLoaded, chatVM.chatRoomProfiles.isEmpty else { return }
                hasLoaded = true
                await chatVM.initializeChatListener()
                if let id = router.pendingChatRoomId { tryNavigate(to: id) }
            }
            // Respond to router updates
            .onChange(of: router.pendingChatRoomId, initial: false) { _, newValue in
                if let id = newValue { tryNavigate(to: id) }
            }
            // Respond to VM profile updates (compare IDs only to reduce work)
            .onChange(of: chatVM.chatRoomProfiles.map(\.id), initial: false) { _, _ in
                if let id = router.pendingChatRoomId { tryNavigate(to: id) }
            }
            .background(.white)
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Navigation helper
    private func tryNavigate(to chatRoomId: String) {
        if let card = chatVM.chatRoomProfiles.first(where: { $0.room.id == chatRoomId }) {
            selectedCard = card
            router.pendingChatRoomId = nil
        }
    }
}
