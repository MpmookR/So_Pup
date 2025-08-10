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
        .environmentObject(router) // only router is created here

        // Flip to Chat tab when a room is created
        .onChange(of: matchRequestVM.pendingChatRoomId, initial: false) { _, newChatId in
            guard let id = newChatId else { return }
            router.pendingChatRoomId = id
            selectedTabIndex = 2
        }
    }
}
