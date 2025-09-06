//
//  Main application entry point. Configures Firebase, sets up global
//  view models and services, and injects them into the environment.
//
//  Key Responsibilities:
//  - Configure Firebase SDKs and push notifications
//  - Construct all root-level view models (Auth, Match, Chat, Meetup, Review)
//    and pass shared dependencies (e.g. AuthViewModel)
//  - Provide a GlobalRouter for navigation coordination across tabs
//  - Provide an AppReloadBus for triggering app-wide refreshes
//  - Kick off initial tasks (auth check, options fetch, dog ID load)
//  - Listen to reloadBus events and re-fetch core data sets
//
//  Usage:
//  Declared with @main, this struct is the true entrypoint for the iOS app.
//
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
    @StateObject private var reloadBus = AppReloadBus()
    
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
            // Inject global environment objects
                .environmentObject(authViewModel)
                .environmentObject(onboardingViewModel)
                .environmentObject(appOptionsService)
                .environmentObject(matchingVM)
                .environmentObject(matchRequestVM)
                .environmentObject(chatVM)
                .environmentObject(meetupVM)
                .environmentObject(reviewVM)
                .environmentObject(reloadBus)
                .modelContainer(for: DogFilterSettingsModel.self)
            // Initial tasks: auth check, config fetch, dog ID
                .task {
                    await authViewModel.checkAuthStatus()
                    await appOptionsService.fetchOptions()
                    await matchRequestVM.loadCurrentDogId()
                }
            // Global reload handling:
            // When `reloadBus.reload()` is called anywhere in the app, it updates `tick`
            // That triggers this `.onReceive`, which in turn re-fetches data in the core
            // view models. Their @Published properties update, and SwiftUI automatically
            // refreshes any views that depend on them.
                .onReceive(reloadBus.$tick) { _ in
                    Task {
                        // Kick the key VMs so UI updates everywhere
                        await matchingVM.load()                     // reloads the list of match candidates
                        await matchRequestVM.fetchMatchRequests()   // reloads pending match requests
                        await meetupVM.loadUserMeetups()            // reloads user meetups
                    }
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

