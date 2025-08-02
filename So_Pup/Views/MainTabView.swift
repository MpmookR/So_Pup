import SwiftUI

struct MainTabView: View {
    @StateObject private var matchRequestVM = MatchRequestViewModel(authVM: AuthViewModel())

    var body: some View {
        
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            MatchView()
                .tabItem {
                    Image(systemName: "heart.circle.fill")
                    Text("Match")
                }

            ChatView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Chat")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
        }
        .accentColor(Color.socialAccent)
        .environmentObject(matchRequestVM)
    }
}
