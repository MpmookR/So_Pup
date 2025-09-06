// -------------------
//  Container for the chat area with two tabs: Chats and Meet-Ups.
//  Wires together ChatViewModel, MeetupViewModel, and routing logic,
//  and navigates into a specific conversation when requested.
//
//  Key Responsibilities:
//  - Render top tab switcher and the corresponding tab content
//  - Listen for initial load and router updates to deep-link into a room
//  - Navigate to ChatDestination and mark rooms read on appear/disappear
//
//  Usage:
//  Provide AuthViewModel, ChatViewModel, MeetupViewModel, and GlobalRouter
//  in the environment. Pushes ChatDestinationWrapper on selection/deep-link.
// -------------------
import SwiftUI
import FirebaseAuth

private enum ChatTabs: String, CaseIterable {
    case chat = "Chat"
    case meetup = "Meet-Up"
}

struct ChatView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var meetupVM: MeetupViewModel
    @EnvironmentObject var router: GlobalRouter

    @State private var selectedTab: ChatTabs = .chat
    @State private var hasLoaded = false
    @State private var selectedCard: ChatRoomCardData?
    
    @Environment(\.dismiss) private var dismiss

    private let tabOptions: [String] = ChatTabs.allCases.map { $0.rawValue }

    var body: some View {
        NavigationStack {
            VStack {
                TopTabSwitcher(
                    tabs: tabOptions,
                    selectedTab: Binding(
                        get: { selectedTab.rawValue },
                        set: { newValue in selectedTab = ChatTabs(rawValue: newValue) ?? .chat }
                    )
                )
                .padding(.top, 16)

                ScrollView {
                    tabContent
                        .padding(.top)
                }
            }
            .padding(.top)
            .background(.white)
            // Navigation
            .navigationDestination(item: $selectedCard) { card in
                ChatDestinationWrapper(
                    card: card,
                    authVM: authViewModel,
                    markRead: { chatVM.markChatRoomAsRead(card.room) },
                    onBack: { selectedCard = nil }
                )
            }
            // Initial load: start Firestore listener once, then check for pending navigation
            .task {
                guard !hasLoaded else { return }
                hasLoaded = true
                await chatVM.initializeChatListener()
                if let id = router.pendingChatRoomId { tryNavigate(to: id) }
            }
            // Router updates: navigate if a push/deep-link sets a pending chat room ID
            .onChange(of: router.pendingChatRoomId) { _, newValue in
                if let id = newValue { tryNavigate(to: id) }
            }
            // VM profile updates: retry navigation when chatRoomProfiles refresh
            // (ensures navigation works once the required chat card is loaded)
            .onChange(of: chatVM.chatRoomProfiles.count) { _, _ in
                if let id = router.pendingChatRoomId { tryNavigate(to: id) }
            }
        }
    }

    // MARK: - Helpers
    private func tryNavigate(to chatRoomId: String) {
        if let card = chatVM.chatRoomProfiles.first(where: { $0.room.id == chatRoomId }) {
            selectedCard = card
            router.pendingChatRoomId = nil
        }
    }

    // MARK: - Tab content (keep inside ChatView so it can see state)
    @ViewBuilder
    private var tabContent: some View {
        if selectedTab == .chat {
            ChatTab(
                isLoading: chatVM.isLoading,
                cards: chatVM.chatRoomProfiles,
                isNew: { chatVM.isChatRoomNew($0.room) },
                onSelect: { selectedCard = $0 }
            )
        } else {
            MeetupTab() // parameterless; see below
        }
    }
}

// MARK: - Small subviews to ease type-checking

private struct ChatTab: View {
    let isLoading: Bool
    let cards: [ChatRoomCardData]
    let isNew: (ChatRoomCardData) -> Bool
    let onSelect: (ChatRoomCardData) -> Void

    var body: some View {
        ChatListSection(
            isLoading: isLoading,
            cards: cards,
            isNew: { isNew($0) },
            onSelect: { onSelect($0) }
        )
    }
}

private struct MeetupTab: View {
    var body: some View {
        MeetupListView()
    }
}

// Keep the destination tiny and explicit
private struct ChatDestinationWrapper: View {
    let card: ChatRoomCardData
    let authVM: AuthViewModel
    let markRead: () -> Void
    let onBack: () -> Void

    var body: some View {
        ChatDestination(
            card: card,
            onBack: onBack,
            authVM: authVM
        )
        .onAppear(perform: markRead)
        .onDisappear(perform: markRead)
    }
}
