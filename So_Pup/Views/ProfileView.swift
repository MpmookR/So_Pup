import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var currentUser: UserModel?
    @State private var currentDog: DogModel?
    @State private var isLoading = true
    @State private var showEditProfile = false
    @State private var showEducationHubAlert = false
    @State private var showSocialDataInput = false
    @State private var dogModeSwitcher: DogModeSwitcherViewModel?

    private let profileService = ProfileDataService()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading profile...")
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LazyVStack(spacing: 16) {
                        // We use currentDog for UI state since loadProfile() refreshes it after mode changes
                        if let user = currentUser,
                        let dog = currentDog,
                        let dogModeSwitcher = dogModeSwitcher {
                            // User Profile Header
                            UserProfileCard(
                                user: user,
                                dogMode: dog.mode,
                                showEditProfile: $showEditProfile
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
                            // Content based on dog mode
                            if dog.mode == .puppy {
                                PuppyModeContent(dog: dog, dogModeSwitcher: dogModeSwitcher)
                            } else {
                                SocialModeContent(dog: dog)
                            }
                            
                            // Education Hub Section
                            EducationHubSection(dogMode: dog.mode, showAlert: $showEducationHubAlert)
                                .padding(.horizontal, 16)
                            
                            // Social Mode Unlock Section (only for puppy mode)
                            if dog.mode == .puppy {
                                SocialModeUnlockSection(dogModeSwitcher: dogModeSwitcher)
                                    .padding(.horizontal, 16)
                            }
                            
                            // Logout Button
                            Button(action: {
                                authVM.signOut()
                            }) {
                                Text("Log Out")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 80) // Space for tab bar
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(.white)
        }
        .task {
            await loadProfile()
        }
        .alert("Coming Soon", isPresented: $showEducationHubAlert) {
            Button("OK") { }
        } message: {
            Text("Education Hub will be available soon 🐾")
        }
        .sheet(isPresented: $showSocialDataInput) {
            if let dogModeSwitcher = dogModeSwitcher {
                SocialModeDataInputSheet(dogModeSwitcher: dogModeSwitcher)
            }
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
            if let dogId = user?.primaryDogId,
               let dog = try await profileService.fetchDog(by: dogId) {
                self.currentDog = dog
                let viewModel = DogModeSwitcherViewModel(dog: dog)
                // Set callback to reload profile when mode changes
                viewModel.onModeChangeSuccess = {
                    await self.loadProfile()
                    // Check if dog switched to social mode but needs social data input
                    self.checkForSocialDataPrompt()
                }
                // Set callback to reload profile when social data is updated
                viewModel.onSocialDataUpdated = {
                    await self.loadProfile()
                }
                self.dogModeSwitcher = viewModel
            }
        } catch {
            print("❌ Failed to load user or dog: \(error)")
        }

        isLoading = false
    }
    
    @MainActor
    private func checkForSocialDataPrompt() {
        // Show social data input if dog is in social mode but missing essential data
        if let dog = currentDog, dog.mode == .social {
            // Check if essential social data is missing
            let missingNeuteredStatus = dog.isNeutered == nil
            let missingBehavior = dog.behavior == nil
            
            if missingNeuteredStatus || missingBehavior {
                showSocialDataInput = true
            }
        }
    }
}

#Preview {
    ProfileView()
}
