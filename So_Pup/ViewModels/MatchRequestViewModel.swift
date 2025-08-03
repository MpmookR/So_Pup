import Foundation
import FirebaseAuth

@MainActor
final class MatchRequestViewModel: ObservableObject {
    private let authVM: AuthViewModel
    private let profileService = ProfileDataService()
    
    @Published var currentDogId: String? = nil
    
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var isRequestPending: Bool = false
    
    init(authVM: AuthViewModel) {
        self.authVM = authVM
    }
    
    // Sends a match request to the backend and shows alert based on result
    func sendRequest(fromDogId: String, toUserId: String, toDogId: String, message: String) async {
        do {
            let token = try await authVM.fetchIDToken()
            let _ = try await MatchRequestService.shared.sendMatchRequest(
                fromDogId: fromDogId,
                toUserId: toUserId,
                toDogId: toDogId,
                message: message,
                authToken: token
            )
            alertMessage = "Match request sent!"
            isRequestPending = true  // Set to true so the UI updates accordingly
            
        } catch {
            alertMessage = "❌ Failed to send request: \(error.localizedDescription)"
        }
        showAlert = true
    }
    
    func loadCurrentDogId() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            if let user = try await profileService.fetchUser(by: uid) {
                currentDogId = user.primaryDogId
                print("✅ Loaded current dog ID: \(currentDogId ?? "")")
            }
        } catch {
            print("❌ Failed to fetch current user: \(error.localizedDescription)")
        }
    }
    
    // Checks if a pending match request already exists between user's dog and target dog
    func checkIfRequestExists(fromDogId: String, toDogId: String) async {
        do {
            let token = try await authVM.fetchIDToken()
            let exists = try await MatchRequestService.shared.checkIfRequestExists(
                fromDogId: fromDogId,
                toDogId: toDogId,
                authToken: token
            )
            self.isRequestPending = exists
            print("📍 Pending request exists:", exists)
        } catch {
            print("❌ Error checking match request status:", error.localizedDescription)
        }
    }

    
}


