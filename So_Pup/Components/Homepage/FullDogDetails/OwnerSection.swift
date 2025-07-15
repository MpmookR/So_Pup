import SwiftUI

struct OwnerSection: View {
    let owner: UserModel
    let dog: DogModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Meet \(dog.name) Owner")
                .font(.headline)
                .foregroundStyle(Color.socialText)

            // Yellow background info card
            HStack(alignment: .center, spacing: 16) {
                // Profile Image
                AsyncImage(url: URL(string: owner.profilePictureURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 84, height: 84)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 1))

                // Name + Labels
                VStack(alignment: .leading, spacing: 8) {
                    Text(owner.name)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.black)

                    LabelTag(
                        text: owner.gender.rawValue,
                        icon: Image(systemName: "person"),
                        mode: dog.mode,

                    )
                    LabelTag(
                        text: owner.languages.joined(separator: ", "),
                        icon: Image(systemName: "message.badge.waveform"),
                        mode: dog.mode,
                    )
                }

                Spacer()
            }
            .padding(8)
            .background(dog.mode == .puppy ? Color.puppyAccent : Color.socialAccent)
            .cornerRadius(21)

            // Bio
            VStack(alignment: .leading, spacing: 8) {
                
                Text("About \(owner.name)")
                    .font(.headline)
                    .foregroundStyle(Color.socialText)
                
                if let bio = owner.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.body)
                        .foregroundStyle(Color.socialText)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("\(owner.name) will write something soon...")
                        .font(.body)
                        .foregroundStyle(Color.socialText)
                }
            }

        }
        .padding(.vertical, 16)
        .padding(.horizontal,16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(dog.mode == .puppy ? Color.puppyLight : Color.socialLight)
        .cornerRadius(21)

    }
}

#Preview {
    OwnerSection(
        owner: MockUserData.user3,
        dog: MockDogData.dog3)
}
