import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var reloadBus: AppReloadBus
    @StateObject private var profileVM = ProfileViewModel()
    
    // Parent-owned success alert + push trigger
    @State private var showModeChangeAlert = false
    @State private var goToSocialDataInput = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                contentBody()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white)
        }
        .task { await profileVM.load() }
        
        // Errors
        .alert("Profile Loading Error", isPresented: $profileVM.showErrorAlert) {
            Button("Retry") { Task { await profileVM.load() } }
            Button("OK", role: .cancel) { }
        } message: {
            Text(profileVM.loadingError ?? "An unknown error occurred")
        }
        
        // Education hub info
        .alert("Coming Soon", isPresented: $profileVM.showEducationHubAlert) {
            Button("OK") { profileVM.showEducationHubAlert = false }
        } message: {
            Text("Education Hub will be available soon 🐾")
        }
        .tint(nil)
        
        // Success (mode switched). After OK, flip UI, reload, and push to input if needed
        .alert("🎉 Welcome to Social Mode!", isPresented: $showModeChangeAlert) {
            Button("OK") {
                Task {
                    let shouldShow = await profileVM.applyModeChangeNowAndRefresh()
                    reloadBus.reload()
                    if shouldShow {
                        // Make sure alert is fully dismissed before navigating
                        try? await Task.sleep(nanoseconds: 200_000_000)
                        await MainActor.run { goToSocialDataInput = true }
                    }
                }
            }
        } message: {
            Text("Your pup is now ready to socialize! You can now create meetups and connect with other pups nearby. 🎊🐾🐶")
        }
        
        // Hidden navigator (type-erased destination to keep the compiler happy)
        .background(navigationLinks())
    }
}

// MARK: - Pieces split out to keep the compiler calm
private extension ProfileView {
    @ViewBuilder
    func contentBody() -> some View {
        if profileVM.isLoading {
            loadingView()
        } else if let user = profileVM.currentUser,
                  let switcher = profileVM.dogModeSwitcher {
            let liveDog: DogModel = switcher.dog // explicit type helps the type-checker
            
            LazyVStack(spacing: 16) {
                header(user: user, dogMode: liveDog.mode)
                
                if liveDog.mode == .puppy {
                    PuppyModeContent(dog: liveDog, dogModeSwitcher: switcher)
                } else {
                    socialContent(dog: liveDog)
                }
                
                EducationHubSection(dogMode: liveDog.mode, showAlert: $profileVM.showEducationHubAlert)
                    .padding(.horizontal, 16)
                
                if liveDog.mode == .puppy {
                    SocialModeUnlockSection(dogModeSwitcher: switcher, modeChanged: $showModeChangeAlert)
                        .padding(.horizontal, 16)
                }
                
                logoutButton()
            }
        }
    }
    
    @ViewBuilder
    func loadingView() -> some View {
        VStack { Spacer(); ProgressView("Loading profile..."); Spacer() }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    func header(user: UserModel, dogMode: DogMode) -> some View {
        UserProfileCard(user: user, dogMode: dogMode, showEditProfile: $profileVM.showEditProfile)
            .padding(.horizontal, 16)
            .padding(.top, 16)
    }
    
    @ViewBuilder
    func socialContent(dog: DogModel) -> some View {
        if let dogEditor = profileVM.dogEditorVM {
            SocialModeContent(dog: dog, dogEditorVM: dogEditor)
        } else {
            // Small placeholder while the editor VM is wiring up
            VStack {
                ProgressView("Loading social profile…")
                Text("Setting up profile editor…")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func logoutButton() -> some View {
        Button("Log Out", role: .destructive) { authVM.signOut() }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 80)
    }
    
    // Hidden NavigationLink with type-erased destination avoids generic blow-ups
    @ViewBuilder
    func navigationLinks() -> some View {
        NavigationLink(
            destination: socialDataInputDestination(),
            isActive: $goToSocialDataInput
        ) { EmptyView() }
    }
    
    func socialDataInputDestination() -> AnyView {
        if let switcher = profileVM.dogModeSwitcher {
            return AnyView(SocialModeDataInputSheet(dogModeSwitcher: switcher))
        } else {
            return AnyView(EmptyView())
        }
    }
}
