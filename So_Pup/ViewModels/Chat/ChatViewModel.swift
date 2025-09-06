/// -------------
/// Main-actor view model that manages the chat list screen.
///
/// Responsibilities
/// - Maintains raw chat rooms (`chatRooms`) and enriched cards (`chatRoomProfiles`) for UI.
/// - Starts/stops a Firestore realtime listener for the current user's rooms,
///   ordered by last message timestamp.
/// - Performs on-demand sync via `ChatService` (REST/Cloud Functions) to keep the UI aligned
///   with backend state (e.g., after accepting a match).
/// - Enriches rooms with dog/owner data using `ProfileDataService` via `ChatCardBuilder`.
/// - Exposes "NEW" dot logic via `ChatReadState` (last-read timestamps in local storage).
/// - Manages lifecycle: cancels rebuild tasks and removes Firestore listeners on deinit.
///
/// Key collaborators
/// - `AuthViewModel` → provides fresh ID token for API calls.
/// - `ProfileDataService` → fetches `UserModel`/`DogModel` for card building.
/// - `ChatService` → fetch/create chat rooms via backend API.
/// - Firebase `Auth`/`Firestore` → current UID, snapshot listener, transactions/queries.
/// - `ChatCardBuilder` → maps `[ChatRoom]` → `[ChatRoomCardData]`.
/// - `ChatReadState` → local unread state ("NEW" dot).
///
/// UI notes
/// - `@Published` state drives the chat list and its loading/error indicators.
/// - Call `initializeChatListener()` from `onAppear` to bootstrap the listener and initial data.
/// -------------
import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class ChatViewModel: ObservableObject {
    // Published state for UI
    @Published var chatRooms: [ChatRoom] = []                 // Raw chat rooms from backend
    @Published var chatRoomProfiles: [ChatRoomCardData] = []  // Enriched with dog+owner data
    @Published var isLoading = false                          // Spinner control
    @Published var errorMessage: String? = nil                // Error display
    
    // Services/dependencies
    private let profileService = ProfileDataService()         // For fetching dogs + users
    private let db = Firestore.firestore()
    private let authVM: AuthViewModel                         // For auth token in API calls
    
    // Internal state
    private var listener: ListenerRegistration?               // Firestore listener for rooms
    private var buildTask: Task<Void, Never>?                 // Task to build cards (cancel on new snapshot)
    private var currentUserId: String?                        // Cached for filtering
    private var currentDogId: String?                         // My dog's id, for "other dog" detection
    
    init(authVM: AuthViewModel) {
        self.authVM = authVM
    }
    
    deinit {
        listener?.remove()
        buildTask?.cancel()
    }
    
    // MARK: - Setup / lifecycle
    
    /// Call this once from ChatView.onAppear to start the realtime listener
    /// and load initial profiles.
    func initializeChatListener() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user")
            return
        }
        
        do {
            // Get current user's profile to know my primary dogId
            guard let user = try await profileService.fetchUser(by: uid) else {
                print("❌ User not found in Firestore")
                return
            }
            
            self.currentUserId = uid
            self.currentDogId = user.primaryDogId
            
            print("✅ Current user ID: \(uid), dog ID: \(user.primaryDogId)")
            
            // Attach realtime Firestore listener for this user's rooms
            listenToChatRooms(currentUserId: uid)
            
            // Also load profile data immediately (useful after accepting a match)
            await loadChatRoomsWithProfiles()
            
        } catch {
            print("❌ Failed to fetch current user or dog ID:", error)
        }
    }
    
    // MARK: - Realtime listener
    
    /// Attaches a Firestore listener to chatRooms containing the current user.
    /// Orders rooms by last message timestamp.
    private func listenToChatRooms(currentUserId: String) {
        isLoading = true
        listener = db.collection("chatRooms")
            .whereField("userIds", arrayContains: currentUserId)
            .order(by: "lastMessage.timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to load chat rooms: \(error.localizedDescription)"
                    return
                }
                
                let rooms = snapshot?.documents.compactMap { try? $0.data(as: ChatRoom.self) } ?? []
                self.chatRooms = rooms
                
                // Build enriched card list from snapshot
                buildTask?.cancel()
                buildTask = Task { [weak self] in
                    guard let self, let currentDogId = self.currentDogId else { return }
                    let cards = await ChatCardBuilder.build(from: rooms,
                                                            currentDogId: currentDogId,
                                                            profileService: self.profileService)
                    self.chatRoomProfiles = cards
                }
                
                // triggers a secondary refresh via API (keeps UI in sync with backend state)
                Task { await self.loadChatRoomsWithProfiles() }
            }
    }
    
    // MARK: - API fetch methods
    
    /// Fetches rooms via API (not realtime) and updates `chatRooms`.
    func fetchChatRooms() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let token = try await authVM.fetchIDToken()
            let rooms = try await ChatService.shared.fetchChatRooms(authToken: token)
            self.chatRooms = rooms
            print("✅ Chat rooms loaded: \(rooms.count)")
        } catch {
            self.errorMessage = "Failed to fetch chat rooms: \(error.localizedDescription)"
            print("❌ Error fetching chat rooms:", error)
        }
        
        isLoading = false
    }
    
    /// Creates a new chatroom via API (or returns existing).
    func createChatroom(fromDogId: String, toUserId: String, toDogId: String) async {
        do {
            let token = try await authVM.fetchIDToken()
            let chatRoomId = try await ChatService.shared.createChatroom(
                fromDogId: fromDogId,
                toUserId: toUserId,
                toDogId: toDogId,
                authToken: token
            )
            print("✅ Chat room created (or already existed): \(chatRoomId)")
        } catch {
            print("❌ Failed to create chat room: \(error.localizedDescription)")
        }
    }
    
    /// Fetches rooms via API and rebuilds cards with profile data.
    func loadChatRoomsWithProfiles() async {
        guard let _ = currentUserId else {
            self.errorMessage = "Missing user ID"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let token = try await authVM.fetchIDToken()
            let rooms = try await ChatService.shared.fetchChatRooms(authToken: token)
            self.chatRooms = rooms
            buildTask?.cancel()
            buildTask = Task { [weak self] in
                guard let self, let currentDogId = self.currentDogId else { return }
                let cards = await ChatCardBuilder.build(from: rooms,
                                                        currentDogId: currentDogId,
                                                        profileService: self.profileService)
                self.chatRoomProfiles = cards
            }
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Failed to load chat room profiles:", error)
        }
        
        isLoading = false
    }
    
    // MARK: - "NEW" dot logic
    
    /// Returns true if the chat room has a message newer than the last seen timestamp in UserDefaults.
    func isChatRoomNew(_ chatRoom: ChatRoom) -> Bool {
        ChatReadState.isNew(room: chatRoom)
    }
    
    /// Marks the chat room as read by saving the latest message timestamp into UserDefaults.
    func markChatRoomAsRead(_ chatRoom: ChatRoom) {
        ChatReadState.markAsRead(room: chatRoom)
        // Trigger a published change to refresh UI immediately
        /// tells SwiftUI that something in the ObservableObject changed.
        /// Even though chatRoomProfiles didn’t change, SwiftUI will re-run the isChatRoomNew calls in Chat view, so isNew becomes false instantly.
        objectWillChange.send()
    }
}
