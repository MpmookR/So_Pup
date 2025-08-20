import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
final class MeetupViewModel: ObservableObject {
    private let authVM: AuthViewModel
    private let profileService = ProfileDataService()
    
    @Published var userMeetups: [MeetupSummaryDTO] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    init(authVM: AuthViewModel) {
        self.authVM = authVM
    }
    
    /// Create a new meetup request
    func createMeetupRequest(
        chatRoomId: String,
        proposedTime: Date,
        locationName: String,
        locationCoordinate: Coordinate,
        meetUpMessage: String,
        receiverId: String,
        receiverDogId: String
    ) async {
        // Ensure we have current user + a primary dog
        guard let currentUser = Auth.auth().currentUser,
              let user = try? await profileService.fetchUser(by: currentUser.uid),
              !user.primaryDogId.isEmpty else {
            await showError("Failed to get current user information")
            return
        }
        
        isLoading = true
        defer { isLoading = false } // avoid double toggle
        
        do {
            let token = try await authVM.fetchIDToken()
            
            // Local meetup model; backend sets id/timestamps as needed
            let meetup = MeetupRequest(
                id: "",
                chatRoomId: chatRoomId,
                senderId: currentUser.uid,
                senderDogId: user.primaryDogId,
                receiverId: receiverId,
                receiverDogId: receiverDogId,
                proposedTime: proposedTime,
                locationName: locationName,
                locationCoordinate: locationCoordinate,
                meetUpMessage: meetUpMessage,
                status: .pending,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            try await MeetupService.shared.createMeetupRequest(
                chatRoomId: chatRoomId,
                meetup: meetup,
                senderId: currentUser.uid,
                receiverId: receiverId,
                senderDogId: user.primaryDogId,
                receiverDogId: receiverDogId,
                authToken: token
            )
            
            await showSuccess("Meetup request sent successfully!")
            await loadUserMeetups()
        } catch {
            await showError("Failed to create meetup request: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Accept / Reject / Cancel / Complete
    func acceptMeetup(chatRoomId: String, meetupId: String, receiverId: String) async {
        await updateMeetupStatus(chatRoomId: chatRoomId, meetupId: meetupId, status: .accepted, receiverId: receiverId)
    }
    
    func rejectMeetup(chatRoomId: String, meetupId: String, receiverId: String) async {
        await updateMeetupStatus(chatRoomId: chatRoomId, meetupId: meetupId, status: .rejected, receiverId: receiverId)
    }
    
    func cancelMeetup(chatRoomId: String, meetupId: String, receiverId: String) async {
        await deleteMeetup(chatRoomId: chatRoomId, meetupId: meetupId, receiverId: receiverId)
    }
    
    func markMeetupComplete(chatRoomId: String, meetupId: String) async {
        guard Auth.auth().currentUser != nil else {
            await showError("Failed to get current user information")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let token = try await authVM.fetchIDToken()
            try await MeetupService.shared.markMeetupComplete(
                chatRoomId: chatRoomId,
                meetupId: meetupId,
                authToken: token
            )
            await showSuccess("Meetup marked as completed")
            await loadUserMeetups()     // non-throwing; handles its own errors
        } catch {
            await showError("Failed to mark meetup complete: \(error.localizedDescription)")
        }
    }
    // MARK: - Load
    
    /// Loads meetups for the current user with optional filters. Handles its own errors.
    func loadUserMeetups(type: String? = nil, status: MeetupStatus? = nil) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let token = try await authVM.fetchIDToken()
            let meetups = try await MeetupService.shared.fetchUserMeetups(
                userId: currentUser.uid,
                type: type,
                status: status,
                authToken: token
            )
            self.userMeetups = meetups
        } catch {
            await showError("Failed to load meetups: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private helpers
    
    private func updateMeetupStatus(
        chatRoomId: String,
        meetupId: String,
        status: MeetupStatus,
        receiverId: String
    ) async {
        guard Auth.auth().currentUser != nil else {
            await showError("Failed to get current user information")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let token = try await authVM.fetchIDToken()
            try await MeetupService.shared.updateMeetupStatus(
                chatRoomId: chatRoomId,
                meetupId: meetupId,
                status: status,
                receiverId: receiverId,
                authToken: token
            )
            await showSuccess("Meetup \(status.rawValue) successfully")
            await loadUserMeetups()   // no extra do/catch; function handles errors
        } catch {
            await showError("Failed to update meetup status: \(error.localizedDescription)")
        }
    }
    
    
    private func deleteMeetup(
        chatRoomId: String,
        meetupId: String,
        receiverId: String
    ) async {
        guard Auth.auth().currentUser != nil else {
            await showError("Failed to get current user information")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let token = try await authVM.fetchIDToken()
            try await MeetupService.shared.cancelMeetupRequest(
                chatRoomId: chatRoomId,
                meetupId: meetupId,
                receiverId: receiverId,
                authToken: token
            )
            await showSuccess("Meetup cancelled successfully")
            await loadUserMeetups()
        } catch {
            await showError("Failed to cancel meetup: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - UI feedback
    
    private func showError(_ message: String) async {
        errorMessage = message
        showError = true
    }
    
    private func showSuccess(_ message: String) async {
        successMessage = message
        showSuccess = true
    }
}
