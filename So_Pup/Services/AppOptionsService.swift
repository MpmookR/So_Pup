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

//            print(" Document data: \(data)")

            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            var decoded = try JSONDecoder().decode(AppOptions.self, from: jsonData)
            print("✅ Decoded base options")

//            let breeds = try await DogBreedFirestoreService.fetchBreeds()
//            print("✅ Breeds fetched: \(breeds.count)")
//
//            decoded.dogBreeds = breeds
            self.options = decoded
//
            print("✅ AppOptions fully loaded")

        } catch {
            errorMessage = "Failed to load AppOptions: \(error.localizedDescription)"
            print("❌ Error: \(error.localizedDescription)")
        }
    }

}
