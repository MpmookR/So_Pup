import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import SwiftData
import FirebaseMessaging

@main
struct SoPupApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate  // to request the apnToken

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @StateObject private var appOptionsService = AppOptionsService()
    @StateObject private var matchRequestVM: MatchRequestViewModel

    init() {
        FirebaseApp.configure()
        PushManager.shared.setupPush()

        let authVM = AuthViewModel()
        _authViewModel = StateObject(wrappedValue: authVM)
        _matchRequestVM = StateObject(wrappedValue: MatchRequestViewModel(authVM: authVM))

    //    configureFirebaseEmulators()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(onboardingViewModel)
                .environmentObject(appOptionsService)
                .environmentObject(matchRequestVM)
                .modelContainer(for: DogFilterSettingsModel.self)
                .task {
                    await authViewModel.checkAuthStatus()
                    await appOptionsService.fetchOptions()
                    await matchRequestVM.loadCurrentDogId()
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
