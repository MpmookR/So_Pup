import Foundation
import FirebaseAuth

@MainActor
final class MatchRequestViewModel: ObservableObject {
    private let authVM: AuthViewModel
    private let profileService = ProfileDataService()
    
    @Published var currentDogId: String? = nil
    
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
        
    init(authVM: AuthViewModel) {
            self.authVM = authVM
        }

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
                print("✅ Loaded current dog ID: \(currentDogId)")
            }
        } catch {
            print("❌ Failed to fetch current user: \(error.localizedDescription)")
        }
    }

}


