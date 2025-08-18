import SwiftUI

// MARK: - Social Mode Content
struct SocialModeContent: View {
    let dog: DogModel
    let profileEditVM: ProfileEditViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Pup's Profile Section
            SocialProfileSection(dog: dog)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            // Behavior Section
            if let behavior = dog.behavior {
                BehaviorSection(behavior: behavior, dogName: dog.displayName)
                    .padding(.horizontal, 16)
            }
            
            // Health Status Section
            HealthStatusSection(profileEditVM: profileEditVM)
                .padding(.horizontal, 16)
        }
    }
}

// MARK: - Social Profile Section
struct SocialProfileSection: View {
    let dog: DogModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pup's profile")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.socialText)
                
                Spacer()
                
                Button(action: {
                    // TODO: Implement dog profile editing
                    print("Edit dog profile tapped")
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.socialText)
                        .frame(width: 28, height: 28)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            
            HStack(spacing: 16) {
                // Dog Photo
                AsyncImage(url: URL(string: dog.imageURLs.first ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "pawprint.fill")
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                // Dog Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack{
                        Text(dog.displayName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.socialText)
                        
                        Spacer()
                        // average rating here
                    }
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: dog.gender == .male ? "person" : "person.fill")
                                .font(.caption)
                            Text(dog.gender.rawValue.capitalized)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(dog.ageText)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "pawprint")
                                .font(.caption)
                            Text(dog.breed)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "scalemass")
                                .font(.caption)
                            Text("\(Int(dog.weight)) kg")
                                .font(.caption)
                        }
                    }
                }
                .foregroundColor(Color.socialText)
            }
        }
        .padding(16)
        .background(Color.socialLight)
        .cornerRadius(16)
    }
}

// MARK: - Behavior Section
struct BehaviorSection: View {
    let behavior: DogBehavior
    let dogName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(dogName)'s behaviour")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.socialText)
                
                Spacer()
                
                Button(action: {
                    // TODO: Implement behavior editing
                    print("Edit behavior tapped")
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.socialText)
                        .frame(width: 28, height: 28)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                // Play Style
                if !behavior.playStyles.isEmpty {
                    BehaviorTagSection(title: "Play Style", tags: behavior.playStyles)
                }
                
                // Preferred Play Environment
                if !behavior.preferredPlayEnvironments.isEmpty {
                    BehaviorTagSection(title: "Preferred Play Environment", tags: behavior.preferredPlayEnvironments)
                }
                
                // Triggers & Sensitivities
                if !behavior.triggersAndSensitivities.isEmpty {
                    BehaviorTagSection(title: "Triggers & Sensitivities", tags: behavior.triggersAndSensitivities)
                }
            }
        }
        .padding(16)
        .background(Color.socialLight)
        .cornerRadius(16)
    }
}

// MARK: - Behavior Tag Section
struct BehaviorTagSection: View {
    let title: String
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.socialText)
            
            FlexibleTagView(
                tags: tags,
                showSeeMore: false,
                onSeeMoreTapped: nil,
                mode: .social
            )
        }
    }
}




