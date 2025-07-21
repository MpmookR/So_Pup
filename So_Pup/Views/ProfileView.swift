import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var currentUser: UserModel?
    @State private var currentDog: DogModel?
    @State private var isLoading = true

    private let profileService = ProfileDataService()
    
    var body: some View {
        VStack(spacing: 16) {
            if isLoading {
                ProgressView("Loading profile...")
            } else if let user = currentUser {
                VStack(spacing: 8) {
                    if let imageUrl = user.profilePictureURL {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    }

                    Text(user.name)
                        .font(.title2)

                    if let dog = currentDog {
                        Text("Dog: \(dog.displayName ?? "Unknown")")
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("No profile found.")
            }

            Button("Logout") {
                authVM.signOut()
            }
            .foregroundColor(.red)
            .padding(.top, 20)
        }
        .padding()
        .task {
            await loadProfile()
        }
    }

    private func loadProfile() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }


        do {
            let user = try await profileService.fetchUser(by: uid)
            self.currentUser = user
            if let dogId = user?.primaryDogId {
                self.currentDog = try await profileService.fetchDog(by: dogId)
            }
        } catch {
            print("❌ Failed to load user or dog: \(error)")
        }

        isLoading = false
    }
}


#Preview {
    ProfileView()
}
