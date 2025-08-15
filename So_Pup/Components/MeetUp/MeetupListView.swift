import SwiftUI

private enum MeetupTab: Int, CaseIterable {
    case all = 0, pending, upcoming, completed

    var title: String {
        switch self {
        case .all: return "All Meet-Up List"
        case .pending: return "Pending"
        case .upcoming: return "Upcoming"
        case .completed: return "Completed"
        }
    }
}

struct MeetupListView: View {
    @EnvironmentObject var meetupVM: MeetupViewModel
    @State private var selectedTab: MeetupTab = .all

    // Precompute to keep body simpler
    private var filteredMeetups: [MeetupSummaryDTO] {
        switch selectedTab {
        case .all:       return meetupVM.userMeetups
        case .pending:   return meetupVM.userMeetups.filter { $0.status == .pending }
        case .upcoming:  return meetupVM.userMeetups.filter { $0.status == .accepted }
        case .completed: return meetupVM.userMeetups.filter { $0.status == .completed }
        }
    }

    private var emptyMessage: String {
        switch selectedTab {
        case .all:       return "No meetups yet"
        case .pending:   return "No pending meetups"
        case .upcoming:  return "No accepted meetups"
        case .completed: return "No completed meetups"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            tabSelector

            if meetupVM.isLoading {
                loadingState
            } else if filteredMeetups.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredMeetups) { meetup in
                            MeetupCard(
                                meetup: meetup,
                                onAction: { action in handleMeetupAction(meetup: meetup, action: action) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        // Load once and also refresh when the tab changes (use .task(id:))
        .task(id: selectedTab) {
            await meetupVM.loadUserMeetups(
                type: selectedTab == .all ? nil : nil, // keep nil unless you later map type
                status: {
                    switch selectedTab {
                    case .all:       return nil
                    case .pending:   return .pending
                    case .upcoming:  return .accepted
                    case .completed: return .completed
                    }
                }()
            )
        }
        .refreshable { await meetupVM.loadUserMeetups() }

        // Surface VM feedback
        .alert(meetupVM.errorMessage, isPresented: $meetupVM.showError) {
            Button("OK", role: .cancel) { }
        }
        .alert(meetupVM.successMessage, isPresented: $meetupVM.showSuccess) {
            Button("OK", role: .cancel) { }
        }
        .animation(.easeInOut, value: meetupVM.isLoading)
        .animation(.easeInOut, value: selectedTab)
    }
}

// MARK: - UI Components
private extension MeetupListView {
    var tabSelector: some View {
        VStack {
            // Primary wide button for "All"
            tabButton(title: MeetupTab.all.title, for: .all)

            Divider()
            HStack(spacing: 6) {
                tabButton(title: MeetupTab.pending.title, for: .pending)
                tabButton(title: MeetupTab.upcoming.title, for: .upcoming)
                tabButton(title: MeetupTab.completed.title, for: .completed)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(21)
        .padding(.horizontal)
    }

    func tabButton(title: String, for tab: MeetupTab) -> some View {
        Button(title) { selectedTab = tab }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selectedTab == tab ? Color.socialButton : Color.clear)
            .foregroundColor(selectedTab == tab ? .white : .socialText)
            .cornerRadius(21)
    }

    var loadingState: some View {
        VStack {
            ProgressView().scaleEffect(1.2)
            Text("Loading meetups...")
                .foregroundColor(.socialText)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            VStack(spacing: 4) {
                Text(emptyMessage)
                    .font(.headline)
                    .foregroundColor(.socialText)
                    .multilineTextAlignment(.center)
                Text("Start chatting with other dog owners to create meetups!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Actions
private extension MeetupListView {
    func handleMeetupAction(meetup: MeetupSummaryDTO, action: MeetupAction) {
        Task {
            switch action {
            case .accept:
                await meetupVM.acceptMeetup(chatRoomId: meetup.chatRoomId, meetupId: meetup.id, receiverId: meetup.otherUserId)
            case .decline:
                await meetupVM.rejectMeetup(chatRoomId: meetup.chatRoomId, meetupId: meetup.id, receiverId: meetup.otherUserId)
            case .cancel:
                await meetupVM.cancelMeetup(chatRoomId: meetup.chatRoomId, meetupId: meetup.id, receiverId: meetup.otherUserId)
            case .complete:
                await meetupVM.markMeetupComplete(chatRoomId: meetup.chatRoomId, meetupId: meetup.id)
            case .review:
                // Navigate to review screen if needed
                print("Review for meetup \(meetup.id)")
            }
            await meetupVM.loadUserMeetups()
        }
    }
}
