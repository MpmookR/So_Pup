import SwiftUI

struct ChatView: View {
    private let tabOptions = ["Chat", "Meet-Up"]
        @State private var selectedTab = "Chat"
    
    var body: some View {
        NavigationStack {
            VStack{
                CustomNavBar(title: "Chat")
                TopTabSwitcher(tabs: tabOptions, selectedTab: $selectedTab)
                
                ScrollView{
                    VStack(spacing: 16){
                        if selectedTab == "Chat"{
                            Text("I am chat")
//                            ChatListCard
//                            (dog: <#T##DogModel#>, owner: <#T##UserModel#>, userCoordinate: <#T##Coordinate#>)
                        } else {
                            Text("Meet-Up")
//                            MeetupCard

                        }
                    }
                    .padding(.top)

                }
            }
        }
    }
}

#Preview {
    ChatView()
}

