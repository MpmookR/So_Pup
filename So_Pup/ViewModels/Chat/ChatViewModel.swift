import Foundation
import FirebaseFirestore
import FirebaseAuth

// ViewModel responsible for managing chat rooms list, profiles,
// and the "NEW" dot state for unread rooms.
// Uses Firestore realtime updates plus on-demand fetch.
@MainActor
final class ChatViewModel: ObservableObject {
    // Published state for UI
    @Published var chatRooms: [ChatRoom] = []                 // Raw chat rooms from backend
    @Published var chatRoomProfiles: [ChatRoomCardData] = []  // Enriched with dog+owner data
    @Published var isLoading = false                          // Spinner control
    @Published var errorMessage: String? = nil                // Error display

    // Services / dependencies
    private let profileService = ProfileDataService()         // For fetching dogs + users
    private let db = Firestore.firestore()
    private let authVM: AuthViewModel                         // For auth token in API calls

    // Internal state
    private var listener: ListenerRegistration?               // Firestore listener for rooms
    private var buildTask: Task<Void, Never>?                  // Task to build cards (cancel on new snapshot)
    private var currentUserId: String?                         // Cached for filtering
    private var currentDogId: String?                          // My dog's id, for "other dog" detection

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
        let key = "lastSeen_\(chatRoom.id)"
        let lastSeen = (UserDefaults.standard.object(forKey: key) as? Date) ?? .distantPast
        guard let messageDate = Self.parseISO(chatRoom.newestISOTimeString) else { return false }
        return messageDate > lastSeen
    }

    /// Marks the chat room as read by saving the latest message timestamp into UserDefaults.
    func markChatRoomAsRead(_ chatRoom: ChatRoom) {
        let key = "lastSeen_\(chatRoom.id)"
        let currentStored = (UserDefaults.standard.object(forKey: key) as? Date) ?? .distantPast

        if let latest = Self.parseISO(chatRoom.newestISOTimeString) {
            // Store the later of the two to avoid moving backwards in time
            let toStore = max(currentStored, latest)
            UserDefaults.standard.set(toStore, forKey: key)
        } else {
            // If no messages exist, store now so it won't appear as NEW
            UserDefaults.standard.set(Date(), forKey: key)
        }
        // Trigger a published change to refresh UI immediately
        /// tells SwiftUI that something in the ObservableObject changed.
        /// Even though chatRoomProfiles didn’t change, SwiftUI will re-run the isChatRoomNew calls in Chat view, so isNew becomes false instantly.
        objectWillChange.send()
    }

    // MARK: - Helpers

    /// Shared ISO8601 date formatter (with fractional seconds for Firestore compatibility).
    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    /// Parses an ISO8601 string into a Date, returning nil if empty or invalid.
    private static func parseISO(_ s: String) -> Date? {
        guard !s.isEmpty else { return nil }
        return iso.date(from: s)
    }
}


