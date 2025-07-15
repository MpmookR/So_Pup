import SwiftUI

struct ProfileMatchCard: View {
    let dog: DogModel
    let owner: UserModel
    let userCoordinate: Coordinate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top Row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dog.displayName)
                        .font(.headline)
                        .foregroundColor(Color.socialText)
                    
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
                    
                    Text(owner.coordinate.formattedDistance(from: userCoordinate))
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
                            .foregroundColor(Color.socialText)
                        Label(dog.ageText, systemImage: "birthday.cake")
                            .foregroundColor(Color.socialText)
                        
                    }
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label(dog.breed, systemImage: "pawprint")
                            .foregroundColor(Color.socialText)
                        Label("\(Int(dog.weight)) kg", systemImage: "scalemass")
                            .foregroundColor(Color.socialText)
                        
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
                    },
                    mode: dog.mode
                )
            }
        }
        .padding()
        .background(dog.mode == .puppy ? Color.puppyLight : Color.socialLight)
        .cornerRadius(21)
        .shadow(radius: 2)
    }
    
}

#Preview {
    VStack(spacing: 20) {
        ProfileMatchCard(
            dog: MockDogData.dog1, 
            owner: MockUserData.user1,
            userCoordinate: MockUserData.user2.coordinate
        )
        
        ProfileMatchCard(
            dog: MockDogData.dog2,
            owner: MockUserData.user2,
            userCoordinate: MockUserData.user1.coordinate
        )
    }
    .padding()
}

