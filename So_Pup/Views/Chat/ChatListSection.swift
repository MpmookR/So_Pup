import SwiftUI

struct ChatListSection: View {
    let isLoading: Bool
    let cards: [ChatRoomCardData]
    let isNew: (ChatRoomCardData) -> Bool
    let onSelect: (ChatRoomCardData) -> Void

    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(1.1)
                    Text("Loading chats…")
                        .foregroundColor(.socialText)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

            } else if cards.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 44, weight: .regular))
                        .foregroundColor(.gray)
                    Text("No conversations yet")
                        .foregroundColor(.socialText)
                        .font(.headline)
                    Text("Start matching or say hi to begin a chat!")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)

            } else {
                LazyVStack(spacing: 16) {
                    ForEach(cards) { card in
                        ChatListCard(
                            chatroom: card.room,
                            dog: card.dog,
                            owner: card.owner,
                            userCoordinate: card.owner.coordinate,
                            isNew: isNew(card)
                        )
                        .contentShape(Rectangle()) // make the whole card tappable
                        .onTapGesture { onSelect(card) }
                    }
                }
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: isLoading)
        .animation(.easeInOut, value: cards.count)
    }
}


