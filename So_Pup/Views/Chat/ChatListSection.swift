import SwiftUI

struct ChatListSection: View {
    let isLoading: Bool
    let cards: [ChatRoomCardData]
    let isNew: (ChatRoomCardData) -> Bool
    let onSelect: (ChatRoomCardData) -> Void

    var body: some View {
        if isLoading {
            ProgressView("Loading chats…")
        } else if cards.isEmpty {
            Text("No conversations yet")
                .foregroundColor(.gray)
                .padding()
        } else {
            ForEach(cards) { card in
                ChatListCard(
                    chatroom: card.room,
                    dog: card.dog,
                    owner: card.owner,
                    userCoordinate: card.owner.coordinate,
                    isNew: isNew(card)
                )
                .onTapGesture { onSelect(card) }
            }
        }
    }
}

