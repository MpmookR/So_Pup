import SwiftUI

struct MatchCard: View {
    let dog: DogModel
    let owner: UserModel
    let viewerCoordinate: Coordinate?
    let message: String
    let direction: MatchRequestCardData.MatchDirection
        
    var onAccept: (() -> Void)? = nil
    var onDecline: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row
            HStack(alignment: .top) {
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

                ViewProfileButton(dog: dog, owner: owner, viewerCoordinate: viewerCoordinate)

            }

            // Avatar and dog details
            HStack(alignment: .center, spacing: 8) {
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

                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(dog.gender.rawValue.capitalized, systemImage: "person")
                        Label(dog.ageText, systemImage: "birthday.cake")
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Label(dog.breed, systemImage: "pawprint")
                        Label("\(Int(dog.weight)) kg", systemImage: "scalemass")
                    }
                }
                .foregroundColor(Color.socialText)
                .font(.footnote)
                .padding(.horizontal, 16)
            }

            // Message
            VStack(alignment: .leading, spacing: 8) {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(Color.socialText)
                    .padding(.all)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(21)

            // Action Buttons
            HStack(alignment: .center, spacing: 12) {
                if direction == .incoming {
                    SubmitButton(
                        title: "Decline",
                        backgroundColor: .white,
                        foregroundColor: .black,
                        borderColor: .red,
                        action: { onDecline?() }
                    )

                    SubmitButton(
                        title: "Accept",
                        backgroundColor: Color.socialAccent,
                        foregroundColor: .black,
                        borderColor: Color.socialBorder,
                        action: { onAccept?() }
                    )

                } else {
                    SubmitButton(
                        title: "Pending Request",
                        backgroundColor: Color.socialLight,
                        foregroundColor: Color.socialText,
                        borderColor: Color.gray.opacity(0.4),
                        action: {}
                    )
                    .disabled(true)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)

        }
        .padding()
        .background(dog.mode == .puppy ? Color.puppyLight : Color.socialLight)
        .cornerRadius(21)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 24) {
        MatchCard(
            dog: MockDogData.dog1,
            owner: MockUserData.user1,
            viewerCoordinate: MockUserData.user2.coordinate,
            message: "Hi! Our pups might get along — happy to connect and see if they'd enjoy a walk together! 🐶",
            direction: .incoming,
            onAccept: { print("Accepted") },
            onDecline: { print("Declined") }
        )

        MatchCard(
            dog: MockDogData.dog2,
            owner: MockUserData.user2,
            viewerCoordinate: MockUserData.user1.coordinate,
            message: "Looking forward to meeting you both soon!",
            direction: .outgoing
        )
    }
}
