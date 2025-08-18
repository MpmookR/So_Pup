import SwiftUI
import FirebaseFunctions

struct MatchView: View {
    @EnvironmentObject var matchRequestVM: MatchRequestViewModel
    @EnvironmentObject var matchingVM: MatchingViewModel
    
    @State private var selectedTab = "Pending"
    @State private var hasLoaded = false

    private let tabOptions = ["Pending", "Requested"]

    var body: some View {
        NavigationStack {
            VStack {
                TopTabSwitcher(tabs: tabOptions, selectedTab: $selectedTab)
                    .padding(.top, 16)

                ScrollView {
                    LazyVStack(spacing: 16) {
                        if selectedTab == "Pending" {
                            pendingSection()
                        } else {
                            requestedSection()
                        }
                    }
                    .padding(.top)
                }
                .background(.white)
            }
            // Keep destination at the stack level to simplify generics
            .navigationDestination(for: MatchProfile.self) { profile in
                if let viewerCoordinate = matchingVM.userCoordinate {
                    FullDogDetailsView(
                        dog: profile.dog,
                        owner: profile.owner,
                        userCoordinate: Coordinate(from: viewerCoordinate)
                    )
                } else {
                    Text("Loading...")
                }
            }
            // One-time load
            .task {
                guard !hasLoaded else { return }
                hasLoaded = true
                await matchRequestVM.loadCurrentDogId()
                await matchRequestVM.fetchMatchRequests()
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private func pendingSection() -> some View {
        if matchRequestVM.pendingCards.isEmpty {
            Text("No pending match requests yet 🐾")
                .foregroundColor(.gray)
                .padding(.top, 50)
        } else {
            ForEach(matchRequestVM.pendingCards) { card in
                NavigationLink(
                    value: MatchProfile(dog: card.dog, owner: card.owner, distanceInMeters: nil)
                ) {
                    pendingCardLabel(for: card)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func requestedSection() -> some View {
        if matchRequestVM.requestedCards.isEmpty {
            Text("You haven’t sent any match requests yet 🐶")
                .foregroundColor(.gray)
                .padding(.top, 50)
        } else {
            ForEach(matchRequestVM.requestedCards) { card in
                MatchCard(
                    dog: card.dog,
                    owner: card.owner,
                    viewerCoordinate: matchingVM.userCoordinate.map(Coordinate.init),
                    message: card.message,
                    direction: card.direction
                )
            }
        }
    }

    // MARK: - Label (concrete type to avoid generic blow-ups)

    @ViewBuilder
    private func pendingCardLabel(for card: MatchRequestCardData) -> some View {
        MatchCard(
            dog: card.dog,
            owner: card.owner,
            viewerCoordinate: matchingVM.userCoordinate.map(Coordinate.init),
            message: card.message,
            direction: card.direction,
            onAccept: { handleStatusUpdate(requestId: card.requestId, status: .accepted) },
            onDecline: { handleStatusUpdate(requestId: card.requestId, status: .rejected) }
        )
    }

    // MARK: - Actions

    private func handleStatusUpdate(requestId: String, status: MatchRequestStatus) {
        Task {
            await matchRequestVM.updateMatchStatus(requestId: requestId, status: status)
            await matchRequestVM.fetchMatchRequests()
        }
    }
}
