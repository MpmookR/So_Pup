// -------------------
//  Service responsible for loading and providing application-wide configuration
//  options from Firestore (`config/Options` document). Implements a singleton
//  pattern for global access and exposes its state as an `ObservableObject`
//  for SwiftUI views.
//
//  Key Responsibilities:
//  - Fetches and decodes the `AppOptions` document from Firestore
//  - Publishes the latest options to SwiftUI views
//  - Tracks loading and error state during fetch operations
//
//  Usage:
//  Access via `AppOptionsService.shared` and observe in SwiftUI views to
//  automatically react to changes in configuration.
// -------------------
import Foundation
import FirebaseFirestore

@MainActor
class AppOptionsService: ObservableObject {
    @Published var options: AppOptions?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    static let shared = AppOptionsService()  //  Singleton - global access

    func fetchOptions() async {
        isLoading = true
        errorMessage = nil
        print("🟡 fetchOptions started...")

        defer {
            isLoading = false
            print("🟡 fetchOptions finished.")
        }

        do {
            print("📥 Fetching 'config/Options' document...")
            let docRef = Firestore.firestore().collection("config").document("Options")
            let snapshot = try await docRef.getDocument()
            print("📦 Document snapshot received")

            guard let data = snapshot.data() else {
                print("❌ 'config/Options' document is empty.")
                errorMessage = "⚠️ No options data found in 'config/Options'"
                return
            }


            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            var decoded = try JSONDecoder().decode(AppOptions.self, from: jsonData)
            print("✅ Decoded base options")

            self.options = decoded
//
            print("✅ AppOptions fully loaded")

        } catch {
            errorMessage = "Failed to load AppOptions: \(error.localizedDescription)"
            print("❌ Error: \(error.localizedDescription)")
        }
    }

}
