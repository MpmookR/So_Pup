import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseAuth

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
            
            // Check login + onboarding status as early as possible
                .task {
                    await authViewModel.checkAuthStatus()
                }
        }
    }
}
