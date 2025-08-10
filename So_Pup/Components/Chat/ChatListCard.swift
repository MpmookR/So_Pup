import SwiftUI

struct ChatListCard: View {
    let chatroom: ChatRoom
    let dog: DogModel
    let owner: UserModel
    let userCoordinate: Coordinate
    let isNew: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            if let url = dog.imageURLs.first, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 68, height: 68)
                .clipShape(Circle())
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(dog.displayName)
                    .font(.headline)
                    .foregroundColor(Color.socialText)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.black)

                    Text(owner.location)
                }
                .font(.caption)
                .foregroundColor(Color.socialText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // New message icon on the right middle
            Image(systemName: isNew ? "message.badge.filled.fill.rtl" : "message")
                .foregroundColor(isNew ? .red : .gray)
                .imageScale(.large)
                .frame(width: 30, height: 30)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(dog.mode == .puppy ? Color.puppyLight : Color.socialLight)
        .cornerRadius(21)
        .shadow(radius: 2)
    }
}
