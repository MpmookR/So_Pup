import SwiftUI

// MARK: - Social Mode Content
/// Purpose: shows a dog's social profile sections (profile, behaviour, health)
/// Note: uses DogProfileEditorViewModel for updates (no ProfileEditViewModel).
struct SocialModeContent: View {
    let dog: DogModel
    let dogEditorVM: DogProfileEditorViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Pup's Profile
            SocialProfileSection(dog: dog)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            // Behaviour
            if let behavior = dog.behavior {
                BehaviorSection(behavior: behavior, dogName: dog.displayName)
                    .padding(.horizontal, 16)
            }

            // Health
            HealthStatusSection(vm: dogEditorVM)
                .padding()
        }
    }
}

// MARK: - Social Profile Section (unchanged UI; edit action is a TODO)
struct SocialProfileSection: View {
    let dog: DogModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pup's profile")
                    .font(.title3).fontWeight(.semibold)
                    .foregroundColor(Color.socialText)
                Spacer()
                Button {
                    // TODO: present edit sheet for basic dog profile (wire to dogEditorVM.saveBasic())
                    print("Edit dog profile tapped")
                } label: {
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
                AsyncImage(url: URL(string: dog.imageURLs.first ?? "")) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                        .overlay(Image(systemName: "pawprint.fill").foregroundColor(.white))
                }
                .frame(width: 60, height: 60).clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(dog.displayName)
                            .font(.title3).fontWeight(.semibold)
                            .foregroundColor(Color.socialText)
                        Spacer()
                        // TODO: average rating
                    }
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: dog.gender == .male ? "person" : "person.fill").font(.caption)
                            Text(dog.gender.rawValue.capitalized).font(.caption)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "calendar").font(.caption)
                            Text(dog.ageText).font(.caption)
                        }
                    }
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "pawprint").font(.caption)
                            Text(dog.breed).font(.caption)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "scalemass").font(.caption)
                            Text("\(Int(dog.weight)) kg").font(.caption)
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

// MARK: - Behaviour (unchanged UI; edit action is a TODO)
struct BehaviorSection: View {
    let behavior: DogBehavior
    let dogName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(dogName)'s behaviour")
                    .font(.title3).fontWeight(.semibold)
                    .foregroundColor(Color.socialText)
                Spacer()
                Button {
                    // TODO: present edit behaviour sheet, then call dogEditorVM.saveBehavior()
                    print("Edit behavior tapped")
                } label: {
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
                if !behavior.playStyles.isEmpty {
                    BehaviorTagSection(title: "Play Style", tags: behavior.playStyles)
                }
                if !behavior.preferredPlayEnvironments.isEmpty {
                    BehaviorTagSection(title: "Preferred Play Environment", tags: behavior.preferredPlayEnvironments)
                }
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

struct BehaviorTagSection: View {
    let title: String
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline).fontWeight(.medium)
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


