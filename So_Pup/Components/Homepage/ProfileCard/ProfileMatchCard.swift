import SwiftUI

struct ProfileMatchCard: View {
    let dog: DogModel
    let owner: UserModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top Row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dog.name)
                        .font(.headline)

                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(Color.black)
                        
                        Text("\(owner.location)")
                    }
                    .font(.caption)
                    .foregroundColor(Color.socialText)
                }

                Spacer()

                VStack (spacing: 4) {
                    Button(action: {
                        // Match logic
                    }) {
                        Image(systemName: "plus.message.fill")
                            .font(.title3)
                            .foregroundColor(dog.mode == .puppy ? Color.puppyButton : Color.socialButton)
                    }
                    
                    Text("1 km away")
                        .font(.caption)
                        .foregroundColor(Color.socialText)
                }
            }

            // Owner avatar + dog details
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
                        Label(ageText(from: dog.dob), systemImage: "calendar")

                    }
                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Label(dog.breed, systemImage: "pawprint")
                        Label("\(Int(dog.weight)) kg", systemImage: "scalemass")
                    }
                }
                .padding(.horizontal, 16.0)
                .font(.footnote)
            }

            // Tags (social mode only)
            if dog.mode == .social, let behavior = dog.behavior {
                FlexibleTagView(
                    tags: behavior.tags,
                    showSeeMore: true,
                    onSeeMoreTapped: {
                        print("Navigate to full profile")
                    }
                )
            }
        }
        .padding()
        .background(dog.mode == .puppy ? Color.puppyLight : Color.socialLight)
        .cornerRadius(21)
        .shadow(radius: 2)
    }

    private func ageText(from dob: Date) -> String {
        let now = Date()
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: dob, to: now).weekOfYear ?? 0
        let years = Calendar.current.dateComponents([.year], from: dob, to: now).year ?? 0

        if weeks < 12 {
            return "\(weeks) weeks"
        } else if years < 1 {
            let months = Calendar.current.dateComponents([.month], from: dob, to: now).month ?? 0
            return "\(months) months"
        } else {
            return "\(years) years"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProfileMatchCard(
            dog: MockDogData.dog1, // Puppy Mode
            owner: MockUserData.user1
        )
        
        ProfileMatchCard(
            dog: MockDogData.dog2, // Social Mode
            owner: MockUserData.user2
        )
    }
    .padding()
}

