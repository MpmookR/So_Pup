import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import SwiftData

@main
struct SoPupApp: App {
    
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(onboardingViewModel)
                .modelContainer(for: DogFilterSettingsModel.self)
            
            // Check login + onboarding status as early as possible
                .task {
                    await authViewModel.checkAuthStatus()
                }
        }
    }
}
