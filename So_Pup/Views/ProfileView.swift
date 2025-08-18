import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var currentUser: UserModel?
    @State private var currentDog: DogModel?
    @State private var isLoading = true
    @State private var isReloading = false // Prevent concurrent loads
    @State private var showEditProfile = false
    @State private var showEducationHubAlert = false
    @State private var showSocialDataInput = false
    @State private var loadingError: String?
    @State private var showErrorAlert = false
    @State private var dogModeSwitcher: DogModeSwitcherViewModel?
    @State private var profileEditVM: ProfileEditViewModel?

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
                            } else if let profileEditVM = profileEditVM {
                                SocialModeContent(dog: dog, profileEditVM: profileEditVM)
                            } else {
                                // Fallback loading state for social mode
                                VStack {
                                    ProgressView("Loading social profile...")
                                    Text("Setting up profile editor...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
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
        .alert("Profile Loading Error", isPresented: $showErrorAlert) {
            Button("Retry") {
                Task {
                    await loadProfile()
                }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text(loadingError ?? "An unknown error occurred")
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
        
        // Prevent concurrent loading calls
        guard !isReloading else {
            print("⚠️ loadProfile() already in progress, skipping...")
            return
        }
        
        isReloading = true
        defer { isReloading = false }

        do {
            let user = try await profileService.fetchUser(by: uid)
            self.currentUser = user
            if let dogId = user?.primaryDogId,
               let dog = try await profileService.fetchDog(by: dogId) {
                
                // Update current dog data
                self.currentDog = dog
                
                // Create or update DogModeSwitcherViewModel
                if let existingDogModeSwitcher = self.dogModeSwitcher {
                    // Sync existing ViewModel with new data
                    existingDogModeSwitcher.dog = dog
                } else {
                    // Create new ViewModel
                    let viewModel = DogModeSwitcherViewModel(dog: dog)
                    // Set callback to reload profile when mode changes
                    viewModel.onModeChangeSuccess = {
                        await self.reloadProfileData()
                        // Check if dog switched to social mode but needs social data input
                        self.checkForSocialDataPrompt()
                    }
                    // Set callback to reload profile when social data is updated
                    viewModel.onSocialDataUpdated = {
                        await self.reloadProfileData()
                    }
                    self.dogModeSwitcher = viewModel
                }
                
                // Create or update ProfileEditViewModel
                if let existingProfileEditVM = self.profileEditVM {
                    // Sync existing ViewModel with new data
                    existingProfileEditVM.syncDogData(dog)
                } else {
                    // Create new ViewModel
                    let profileEditVM = ProfileEditViewModel(dog: dog)
                    // Set callback to sync when profile data changes
                    profileEditVM.onProfileUpdated = {
                        await self.reloadProfileData()
                    }
                    self.profileEditVM = profileEditVM
                }
            }
        } catch {
            print("❌ Failed to load user or dog: \(error)")
            await MainActor.run {
                self.loadingError = "Failed to load profile: \(error.localizedDescription)"
                self.showErrorAlert = true
            }
        }

        isLoading = false
    }
    
    // MARK: - Reload Profile Data (for ViewModel callbacks)
    private func reloadProfileData() async {
        // Lighter reload that just syncs data without recreating ViewModels
        guard let uid = Auth.auth().currentUser?.uid,
              let user = currentUser else { return }
        
        let dogId = user.primaryDogId
        
        do {
            if let updatedDog = try await profileService.fetchDog(by: dogId) {
                await MainActor.run {
                    // Update all data sources with fresh data
                    self.currentDog = updatedDog
                    self.dogModeSwitcher?.dog = updatedDog
                    self.profileEditVM?.syncDogData(updatedDog)
                }
            }
        } catch {
            print("❌ Failed to reload profile data: \(error)")
        }
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
