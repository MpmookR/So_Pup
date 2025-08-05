import SwiftUI

struct ChatListCard: View {
    let dog: DogModel
    let owner: UserModel
    let userCoordinate: Coordinate

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
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

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(dog.mode == .puppy ? Color.puppyLight : Color.socialLight)
        .cornerRadius(21)
        .shadow(radius: 2)
    }
}


#Preview {
    VStack {
        ChatListCard(
            dog: MockDogData.dog1,
            owner: MockUserData.user1,
            userCoordinate: MockUserData.user1.coordinate)
    }
    .padding(.all)

}


