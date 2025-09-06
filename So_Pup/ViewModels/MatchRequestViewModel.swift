/// -------------------
//  ViewModel responsible for managing match request logic in the SoPup app.
///  Handles sending, checking, fetching, and updating match requests between dogs,
///  and exposes state to the UI via published properties. It integrates with
///  Firebase Authentication for secure user identification and ProfileDataService
///  for resolving dog and owner information.
///
//  Key Responsibilities:
///  - Send match requests and handle success/failure alerts
///  - Load the current user's primary dog ID
///  - Check if a match request already exists between two dogs
///  - Fetch incoming and outgoing match requests and convert them into card data
///  - Update match request status (e.g., accepted/declined) and navigate to chat if accepted
/// -------------------
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
    
    @Published var pendingCards: [MatchRequestCardData] = []
    @Published var requestedCards: [MatchRequestCardData] = []
    
    @Published var pendingChatRoomId: String? = nil
    
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
    
    func fetchMatchRequests() async {
        guard let dogId = currentDogId else {
            print("❌ No dogId found. Cannot fetch match requests.")
            return
        }
        do {
            let token = try await authVM.fetchIDToken()
            
            // fetch both API requests in parallel
            async let incomingRaw = MatchRequestService.shared.fetchMatchRequests(dogId: dogId, type: "incoming", authToken: token)
            async let outgoingRaw = MatchRequestService.shared.fetchMatchRequests(dogId: dogId, type: "outgoing", authToken: token)
            
            let (incoming, outgoing) = try await (incomingRaw, outgoingRaw)
            
            print("📥 Incoming: \(incoming.count), 📤 Outgoing: \(outgoing.count)")

            self.pendingCards = await convertToCardData(from: incoming, direction: .incoming)
            self.requestedCards = await convertToCardData(from: outgoing, direction: .outgoing)
            
        } catch {
            print("❌ Failed to load match requests:", error)
        }
    }

    
    func updateMatchStatus(requestId: String, status: MatchRequestStatus) async {
        do {
            let token = try await authVM.fetchIDToken()
            let response = try await MatchRequestService.shared.updateMatchStatus(
                requestId: requestId,
                status: status,
                authToken: token
            )
            
            print("✅ Updated status for request \(requestId) to \(status.rawValue)")
            
            if status == .accepted, let chatRoomId = response.chatRoomId {
                // Store for MainTabView -> ChatView navigation
                pendingChatRoomId = chatRoomId
                print("✅ Match staus is \(status.rawValue), navigate to chatRoomId: \(chatRoomId)")
            }
            
        } catch {
            print("❌ Failed to update match status for \(requestId):", error)
            alertMessage = "Error updating match request: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    // helper
    private func convertToCardData(
        from requests: [MatchRequest],
        direction: MatchRequestCardData.MatchDirection
    ) async -> [MatchRequestCardData] {
        await withTaskGroup(of: MatchRequestCardData?.self) { group in
            for request in requests {
                group.addTask {
                    let dogId = (direction == .incoming) ? request.fromDogId : request.toDogId
                    print("🐶 Fetching dog [\(dogId)] for request \(request.id)")
                    
                    do {
                        guard let dog = try await self.profileService.fetchDog(by: dogId),
                              let owner = try await self.profileService.fetchUser(by: dog.ownerId)
                        else {
                            print("⚠️ Could not resolve dog or owner for request \(request.id)")
                            return nil }
                        
                        print("✅ Loaded dog '\(dog.displayName)' and owner '\(owner.name)' for request \(request.id)")
                        
                        return MatchRequestCardData(
                            id: request.id,
                            dog: dog,
                            owner: owner,
                            message: request.message,
                            requestId: request.id,
                            direction: direction
                        )
                    } catch {
                        print("❌ Error loading card data:", error)
                        return nil
                    }
                }
            }
            
            //  Wait for all tasks and collect successful ones
            var result: [MatchRequestCardData] = []
            for await value in group {
                if let value = value {
                    result.append(value)
                }
            }
            print("📦 Built \(result.count) card(s) for direction: \(direction)")
            return result
        }
    }
    
}

