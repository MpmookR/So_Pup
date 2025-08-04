import SwiftUI
import FirebaseFunctions

struct MatchView: View {
    @EnvironmentObject var matchRequestVM: MatchRequestViewModel
    @StateObject private var matchingVM = MatchingViewModel()

    @State private var selectedTab = "Pending"
    @State private var hasLoaded = false

    private let tabOptions = ["Pending", "Requested"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CustomNavBar(title: "Match")
                TopTabSwitcher(tabs: tabOptions, selectedTab: $selectedTab)

                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTab == "Pending" {
                            ForEach(matchRequestVM.pendingCards) { card in
                                NavigationLink(
                                    value: MatchProfile(dog: card.dog, owner: card.owner, distanceInMeters: nil)
                                ) {
                                    MatchCard(
                                        dog: card.dog,
                                        owner: card.owner,
                                        userCoordinate: card.owner.coordinate,
                                        message: card.message,
                                        direction: card.direction,
                                        onViewProfile: {
                                            // Will be handled by NavigationLink
                                        },
                                        onAccept: {
                                            Task {
                                                await matchRequestVM.updateMatchStatus(
                                                    requestId: card.requestId,
                                                    status: .accepted
                                                )
                                                await matchRequestVM.fetchMatchRequests()
                                            }
                                        },
                                        onDecline: {
                                            Task {
                                                await matchRequestVM.updateMatchStatus(
                                                    requestId: card.requestId,
                                                    status: .rejected
                                                )
                                                await matchRequestVM.fetchMatchRequests()
                                            }
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        } else {
                            ForEach(matchRequestVM.requestedCards) { card in
                                MatchCard(
                                    dog: card.dog,
                                    owner: card.owner,
                                    userCoordinate: card.owner.coordinate,
                                    message: card.message,
                                    direction: card.direction
                                )
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .onAppear {
                guard !hasLoaded else { return }
                hasLoaded = true
                Task {
                    await matchRequestVM.loadCurrentDogId()
                    await matchRequestVM.fetchMatchRequests()
                }
            }
            .navigationDestination(for: MatchProfile.self) { profile in
                if let viewerCoordinate = matchingVM.userCoordinate {
                    FullDogDetailsView(
                        dog: profile.dog,
                        owner: profile.owner,
                        userCoordinate: Coordinate(from: viewerCoordinate),
                        reviews: [],
                        matchRequestVM: matchRequestVM
                    )
                } else {
                    Text("Loading...")
                }
            }
        }
    }
}
