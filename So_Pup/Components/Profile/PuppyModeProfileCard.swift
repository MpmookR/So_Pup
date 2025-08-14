import SwiftUI

// MARK: - Puppy Mode Content
struct PuppyModeContent: View {
    let dog: DogModel
    let dogModeSwitcher: DogModeSwitcherViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Pup's Profile Section
            PuppyProfileSection(dog: dog)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            // Core Vaccination Section
            CoreVaccinationSection(dogModeSwitcher: dogModeSwitcher)
                .padding(.horizontal, 16)
        }
    }
}

// MARK: - Puppy Profile Section
struct PuppyProfileSection: View {
    let dog: DogModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pup's profile")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.socialText)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.socialText)
                        .frame(width: 28, height: 28)
                        .background(Color.socialLight)
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
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                
                // Dog Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(dog.displayName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.socialText)
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: dog.gender == .male ? "person" : "person.fill")
                                .font(.caption)
                            Text(dog.gender.rawValue.capitalized)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(dog.ageText)
                                .font(.subheadline)
                        }
                    }
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "pawprint")
                                .font(.caption)
                            Text(dog.breed)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "scalemass")
                                .font(.caption)
                            Text("\(Int(dog.weight)) kg")
                                .font(.subheadline)
                        }
                    }
                }
                .foregroundColor(Color.socialText)
            }
        }
        .padding(16)
        .background(Color.puppyLight)
        .cornerRadius(16)
    }
}




