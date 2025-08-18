//import SwiftUI
//import FirebaseAuth
//import FirebaseCore
//
//@main
//struct MockUploadTestApp: App {
////    init() {
////        FirebaseApp.configure()
////
////        #if DEBUG
////        Task {
////            await MockDataUploader.uploadMockData()
////        }
////        #endif
////    }
//    
//    init() {
//        FirebaseApp.configure()
//        
//        // TEMPORARY: Force logout on app launch
//        do {
//            try Auth.auth().signOut()
//            print("✅ Force logout successful")
//        } catch {
//            print("❌ Force logout failed: \(error)")
//        }
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            Text("logging out...")
//        }
//    }
//}
//
//
