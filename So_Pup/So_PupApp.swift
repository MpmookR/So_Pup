import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import SwiftData

@main
struct SoPupApp: App {
    
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @StateObject private var appOptionsService = AppOptionsService()

    
    init() {
        FirebaseApp.configure()

    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(onboardingViewModel)
                .environmentObject(appOptionsService) 
                .modelContainer(for: DogFilterSettingsModel.self)
            
                .task {
                    await authViewModel.checkAuthStatus() // check login user
                    await appOptionsService.fetchOptions()
                }
        }
    }
}
