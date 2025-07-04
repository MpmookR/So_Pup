//import SwiftUI
//import FirebaseCore
//
//@main
//struct TestApp: App {
//    @StateObject private var onboardingVM = OnboardingViewModel()
//
//    init() {
//        FirebaseApp.configure()
//
//        // Upload dog breeds to Firestore during development
//        #if DEBUG
//        BreedUploader.uploadBreeds()
//        #endif
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            NavigationStack {
//                MoreDogDetailsView(onNext: {}, onBack: {})
//                    .environmentObject(onboardingVM)
//            }
//        }
//    }
//}
//
//
