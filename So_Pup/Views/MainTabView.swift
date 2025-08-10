import SwiftUI

struct MainTabView: View {
    @State private var selectedTabIndex = 0

    @StateObject private var matchRequestVM = MatchRequestViewModel(authVM: AuthViewModel())
    @StateObject private var chatVM = ChatViewModel(authVM: AuthViewModel())
    
    @StateObject private var router = GlobalRouter()

    var body: some View {
        TabView(selection: $selectedTabIndex) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            // If you need the binding in MatchView, add an initializer that accepts it.
            MatchView()
                .tabItem {
                    Image(systemName: "heart.circle.fill")
                    Text("Match")
                }
                .tag(1)

            ChatView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Chat")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(Color.socialAccent)
        .environmentObject(matchRequestVM)
        .environmentObject(chatVM)
        .environmentObject(router)
        // When backend returns chatRoomId, flip to Chat tab and hand it to router
        .onReceive(matchRequestVM.$pendingChatRoomId.compactMap { $0 }) { newChatId in
            router.pendingChatRoomId = newChatId
            selectedTabIndex = 2
        }
    }
}
