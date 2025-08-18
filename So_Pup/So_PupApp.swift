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
    @StateObject private var matchingVM: MatchingViewModel
    @StateObject private var chatVM: ChatViewModel
    @StateObject private var meetupVM: MeetupViewModel
    @StateObject private var reviewVM: ReviewViewModel
    @StateObject private var router: GlobalRouter
    
    init() {
        FirebaseApp.configure()
        PushManager.shared.setupPush()
        
        // Create dependencies in order
        let authVM = AuthViewModel()    // Build a single auth VM and pass it to dependents
        let matchReqVM = MatchRequestViewModel(authVM: authVM)
        let matchVM = MatchingViewModel(matchRequestVM: matchReqVM)
        
        _authViewModel          = StateObject(wrappedValue: authVM)
        _onboardingViewModel    = StateObject(wrappedValue: OnboardingViewModel())
        _appOptionsService      = StateObject(wrappedValue: AppOptionsService())
        _matchRequestVM         = StateObject(wrappedValue: matchReqVM)
        _matchingVM             = StateObject(wrappedValue: matchVM)
        _chatVM                 = StateObject(wrappedValue: ChatViewModel(authVM: authVM))
        _meetupVM               = StateObject(wrappedValue: MeetupViewModel(authVM: authVM))
        _reviewVM               = StateObject(wrappedValue: ReviewViewModel(authVM: authVM))
        _router                 = StateObject(wrappedValue: GlobalRouter())
        
        //    configureFirebaseEmulators()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(onboardingViewModel)
                .environmentObject(appOptionsService)
                .environmentObject(matchingVM)
                .environmentObject(matchRequestVM)
                .environmentObject(chatVM)
                .environmentObject(meetupVM)
                .environmentObject(reviewVM)
                .modelContainer(for: DogFilterSettingsModel.self)
                .task {
                    await authViewModel.checkAuthStatus()
                    await appOptionsService.fetchOptions()
                    await matchRequestVM.loadCurrentDogId()
                }
        }
    }
}

/// Connect iOS frontend to local Firebase emulators
//    private func configureFirebaseEmulators() {
//        let localIP = "192.168.0.49" // my mac and iOSdevice
//
//        // Firestore Emulator
//        let firestore = Firestore.firestore()
//        let firestoreSettings = firestore.settings
//        firestoreSettings.host = "\(localIP):8080"
//        firestoreSettings.isSSLEnabled = false
//        firestoreSettings.isPersistenceEnabled = false
//        firestore.settings = firestoreSettings
//
//        // Auth Emulator
//        Auth.auth().useEmulator(withHost: localIP, port: 9099)
//
//        // Functions Emulator
//        Functions.functions().useEmulator(withHost: localIP, port: 5001)
//    }

