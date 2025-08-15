import SwiftUI

struct MeetupCard: View {
    let meetup: MeetupSummaryDTO
    var onAction: (MeetupAction) -> Void
    
    // Injected globally so you don’t have to pass meetupVM in every call
    @EnvironmentObject var meetupVM: MeetupViewModel

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                // Header: dog name + status
                HStack {
                    Text("Meet \(meetup.otherDogName)")
                        .fontWeight(.bold)
                        .foregroundColor(.socialText)
                    Spacer()
                    Text(meetup.status.rawValue.capitalized)
                        .font(.callout)
                        .foregroundColor(.socialText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(statusBackgroundColor)
                        .cornerRadius(16)
                }
                
                Divider()
                
                // Date & time
                HStack {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.socialText)
                    Spacer()
                    Text(timeRange)
                        .font(.caption)
                        .foregroundColor(.socialText)
                }
                
                // Location
                HStack {
                    Text("Location:")
                        .font(.caption)
                        .foregroundColor(.socialText)
                    Text(meetup.locationName)
                        .foregroundColor(.socialText)
                        .fontWeight(.bold)
                }
                
                // Status-based actions
                Group {
                    switch meetup.status {
                    case .pending:
                        HStack(spacing: 12) {
                            MeetupActionButton(actionType: .accept, isEnabled: !meetupVM.isLoading) {
                                Task {
                                    await meetupVM.acceptMeetup(
                                        chatRoomId: meetup.chatRoomId,
                                        meetupId: meetup.id,
                                        receiverId: meetup.otherUserId
                                    )
                                }
                            }
                            MeetupActionButton(actionType: .decline, isEnabled: !meetupVM.isLoading) {
                                Task {
                                    await meetupVM.rejectMeetup(
                                        chatRoomId: meetup.chatRoomId,
                                        meetupId: meetup.id,
                                        receiverId: meetup.otherUserId
                                    )
                                }
                            }
                        }
                        
                    case .accepted:
                        VStack(spacing: 10) {
                            MeetupActionButton(actionType: .cancel, isEnabled: !meetupVM.isLoading) {
                                Task {
                                    await meetupVM.cancelMeetup(
                                        chatRoomId: meetup.chatRoomId,
                                        meetupId: meetup.id,
                                        receiverId: meetup.otherUserId
                                    )
                                }
                            }
                            MeetupActionButton(actionType: .complete, isEnabled: !meetupVM.isLoading) {
                                Task {
                                    await meetupVM.markMeetupComplete(
                                        chatRoomId: meetup.chatRoomId,
                                        meetupId: meetup.id
                                    )
                                }
                            }
                        }
                        
                    default:
                        EmptyView()
                    }
                }
                
                // Review button if allowed
                if meetup.status.allowsComment {
                    MeetupActionButton(actionType: .review) {
                        // TODO: navigate to review flow with meetup.id
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 21)
                    .stroke(borderColor, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 21))
            .overlay {
                if meetupVM.isLoading {
                    Color.white.opacity(0.4)
                        .clipShape(RoundedRectangle(cornerRadius: 21))
                }
            }
        }
        .alert("Error", isPresented: $meetupVM.showError) {
            Button("OK") {}
        } message: {
            Text(meetupVM.errorMessage)
        }
        .alert("Success", isPresented: $meetupVM.showSuccess) {
            Button("OK") {}
        } message: {
            Text(meetupVM.successMessage)
        }
    }
    
    private var statusBackgroundColor: Color {
        switch meetup.status {
        case .pending:   return Color.socialLight
        case .accepted:  return Color.socialAccent
        case .rejected:  return Color.red.opacity(0.2)
        case .completed: return Color.blue.opacity(0.2)
        case .cancelled: return Color.gray.opacity(0.2)
        }
    }
    
    var borderColor: Color {
        if meetup.status.isActive {
            return meetup.status == .pending ? Color.socialAccent : Color.puppyAccent
        } else {
            return Color.gray
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: meetup.proposedTime)
    }
    
    private var timeRange: String {
        let startTime = meetup.proposedTime
        let endTime = Calendar.current.date(byAdding: .hour, value: 1, to: startTime) ?? startTime
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return "\(timeFormatter.string(from: startTime)) - \(timeFormatter.string(from: endTime))"
    }
}

#Preview {
    VStack(spacing: 20) {
        MeetupCard(
            meetup: MeetupSummaryDTO(
                id: "1",
                chatRoomId: "chat1",
                proposedTime: Date(),
                locationName: "Central Park",
                status: .pending,
                otherUserId: "user2",
                otherUserName: "John",
                otherDogId: "dog2",
                otherDogName: "Buddy",
                otherDogImageUrl: ""
            ),
            onAction: { _ in }
        )
        MeetupCard(
            meetup: MeetupSummaryDTO(
                id: "2",
                chatRoomId: "chat2",
                proposedTime: Date(),
                locationName: "Dog Meadow",
                status: .accepted,
                otherUserId: "user3",
                otherUserName: "Sam",
                otherDogId: "dog9",
                otherDogName: "Milo",
                otherDogImageUrl: ""
            ),
            onAction: { _ in }
        )
    }
    .environmentObject(MeetupViewModel(authVM: AuthViewModel()))
    .padding(.horizontal)
}
