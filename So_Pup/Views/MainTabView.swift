//
//  Logged-in root shell of the app. Provides a four-tab layout
//  (Home, Match, Chat, Profile) and injects a GlobalRouter to coordinate
//  navigation events across tabs.
//
//  Key Responsibilities:
//  - Render the main TabView once the user is authenticated and onboarded
//  - Share a single GlobalRouter across all tabs
//  - Automatically switch to the Chat tab when a new chat room is created
//
//  State / Env:
//  - selectedTabIndex (@State): current tab index
//  - authViewModel, chatVM, matchRequestVM from environment
//  - router (@StateObject): global navigation coordinator
//
//  Usage:
//  Used only from RootView once login + onboarding are complete.
//
import SwiftUI

struct MainTabView: View {
    @State private var selectedTabIndex = 0

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var matchRequestVM: MatchRequestViewModel

    @StateObject private var router = GlobalRouter()

    var body: some View {
        TabView(selection: $selectedTabIndex) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            MatchView()
                .tabItem { Label("Match", systemImage: "heart.circle.fill") }
                .tag(1)

            ChatView()
                .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(2)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(3)
        }
        .tint(Color.socialAccent)
        .environmentObject(router) // router created here and shared app-wide

        // Navigate to Chat tab automatically when a new chat room is created
        // after a match request is accepted, MatchRequestVM sets pendingChatRoomId
        .onChange(of: matchRequestVM.pendingChatRoomId, initial: false) { _, newChatId in
            guard let id = newChatId else { return }
            router.pendingChatRoomId = id   // pass navigation request into global router
            selectedTabIndex = 2            // switch visible tab to Chat
        }
    }
}
