import SwiftUI

// MARK: - User Profile Card Component
struct UserProfileCard: View {
    let user: UserModel
    let dogMode: DogMode
    @Binding var showEditProfile: Bool
    
    var body: some View {
        HStack {
            // Profile Picture
            AsyncImage(url: URL(string: user.profilePictureURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.socialText)
                
                HStack(spacing: 4) {
                    Image(systemName: "person")
                        .font(.caption)
                        .foregroundColor(Color.socialText)
                    Text(user.gender.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(Color.socialText)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .font(.caption)
                        .foregroundColor(Color.socialText)
                    Text(user.location)
                        .font(.subheadline)
                        .foregroundColor(Color.socialText)
                }
            }
            
            Spacer()
            
            // Edit Button
            Button(action: { showEditProfile = true }) {
                Image(systemName: "pencil")
                    .font(.title3)
                    .foregroundColor(Color.socialText)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .padding(16)
        .background(dogMode == .puppy ? Color.puppyAccent : Color.socialAccent)
        .cornerRadius(16)
    }
}



