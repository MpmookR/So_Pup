import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import SwiftData

@main
struct SoPupApp: App {
    
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @StateObject private var appOptionsService = AppOptionsService()

    init() {
        FirebaseApp.configure()
//        configureFirebaseEmulators() // // Comment out for production
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(onboardingViewModel)
                .environmentObject(appOptionsService)
                .modelContainer(for: DogFilterSettingsModel.self)
                .task {
                    await authViewModel.checkAuthStatus()
                    await appOptionsService.fetchOptions()
                }
        }
    }

    /// Connect iOS frontend to local Firebase emulators
    private func configureFirebaseEmulators() {
        let localIP = "192.168.0.49" // my mac and iOSdevice

        // Firestore Emulator
        let firestore = Firestore.firestore()
        let firestoreSettings = firestore.settings
        firestoreSettings.host = "\(localIP):8080"
        firestoreSettings.isSSLEnabled = false
        firestoreSettings.isPersistenceEnabled = false
        firestore.settings = firestoreSettings

        // Auth Emulator
        Auth.auth().useEmulator(withHost: localIP, port: 9099)

        // Functions Emulator
        Functions.functions().useEmulator(withHost: localIP, port: 5001)
    }
}
