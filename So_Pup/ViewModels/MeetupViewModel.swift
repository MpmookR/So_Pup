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
    
    // MARK: - Public Methods
    
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
        guard let currentUser = Auth.auth().currentUser,
              let user = try? await profileService.fetchUser(by: currentUser.uid),
              !user.primaryDogId.isEmpty else {
            await showError("Failed to get current user information")
            return
        }
        
        let senderDogId = user.primaryDogId
        
        isLoading = true
        
        do {
            let token = try await authVM.fetchIDToken()
            
            // Create meetup request object
            let meetup = MeetupRequest(
                id: "", // Will be set by backend
                chatRoomId: chatRoomId,
                senderId: currentUser.uid,
                senderDogId: senderDogId,
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
            
            let _ = try await MeetupService.shared.createMeetupRequest(
                chatRoomId: chatRoomId,
                meetup: meetup,
                senderId: currentUser.uid,
                receiverId: receiverId,
                senderDogId: senderDogId,
                receiverDogId: receiverDogId,
                authToken: token
            )
            
            await showSuccess("Meetup request sent successfully!")
            
        } catch {
            await showError("Failed to create meetup request: \(error.localizedDescription)")
        }
        
        isLoading = false
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
            guard let currentUser = Auth.auth().currentUser else {
                await showError("Failed to get current user information")
                return
            }
            
            isLoading = true
            do {
                let token = try await authVM.fetchIDToken()
                try await MeetupService.shared.markMeetupComplete(chatRoomId: chatRoomId, meetupId: meetupId, authToken: token)
                
                await showSuccess("Meetup marked as completed")
                await loadUserMeetups()
            } catch {
                await showError("Failed to mark meetup complete: \(error.localizedDescription)")
            }
            isLoading = false
        }
        
        // MARK: - Load
        
        /// Load meetups for current user with optional filters
        func loadUserMeetups(type: String? = nil, status: MeetupStatus? = nil) async {
            guard let currentUser = Auth.auth().currentUser else { return }
            
            isLoading = true
            do {
                let token = try await authVM.fetchIDToken()
                let meetups = try await MeetupService.shared.fetchUserMeetups(
                    userId: currentUser.uid,
                    type: type,
                    status: status,
                    authToken: token
                )
                userMeetups = meetups
            } catch {
                await showError("Failed to load meetups: \(error.localizedDescription)")
            }
            isLoading = false
        }
        
        // MARK: - Private helpers
        
        private func updateMeetupStatus(chatRoomId: String, meetupId: String, status: MeetupStatus, receiverId: String) async {
            guard Auth.auth().currentUser != nil else {
                await showError("Failed to get current user information")
                return
            }
            
            isLoading = true
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
                await loadUserMeetups()
            } catch {
                await showError("Failed to update meetup status: \(error.localizedDescription)")
            }
            isLoading = false
        }
        
        private func deleteMeetup(chatRoomId: String, meetupId: String, receiverId: String) async {
            guard Auth.auth().currentUser != nil else {
                await showError("Failed to get current user information")
                return
            }
            
            isLoading = true
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
            isLoading = false
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
