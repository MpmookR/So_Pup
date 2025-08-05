import SwiftUI

struct ChatScreen: View {
    let dog: DogModel
    var onBack: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar mock
            CustomNavBar(
                title: "\(dog.displayName)'s Profile",
                showBack: true,
                onBackTap: onBack,
                backgroundColor: .white
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ChatBubble(text: "Hi Scooby, excited to meet you!", isCurrentUser: false)
                    ChatBubble(text: "Hello, Ryu. Scooby is here :)", isCurrentUser: true)
                    ChatBubble(text: "Are you free this coming Saturday?", isCurrentUser: true)
                    ChatBubble(text: "Yes! Are you free to meet around 4pm at AB park?", isCurrentUser: false)
                    ChatBubble(text: "That's perfect!", isCurrentUser: true)
//                    MeetupCardBubble(title: "Meet Ryu", time: "Sat, 10 Jun at 16:00")
                    ChatBubble(text: "Just created the meet up. feel free to adjust", isCurrentUser: true)
                }
                .padding(.top, 8)
            }


            ChatInputBar()
        }
        .padding(.horizontal)
        .background(Color(.white))
    }
}

#Preview {
    ChatScreen(
        dog: MockDogData.dog2, onBack: {}
    )
}


