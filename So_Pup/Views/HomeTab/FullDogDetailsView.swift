import SwiftUI

struct FullDogDetailsView: View {
    
    let dog: DogModel
    let owner: UserModel
    let userCoordinate: Coordinate?
    
    @EnvironmentObject private var matchRequestVM: MatchRequestViewModel
    var onBack: (() -> Void)? = nil
    
    @State private var showRequestView = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomNavBar(
                    title: "\(dog.displayName)'s Profile",
                    showBack: true,
                    onBackTap: onBack,
                    backgroundColor: .white
                )
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        DogSection(dog: dog, owner: owner, userCoordinate: userCoordinate)
                        
                        OwnerSection(owner: owner, dog: dog)
                        
                        Divider()
                        
                        ReviewSection(dogName: dog.displayName, owner: owner)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .navigationBarBackButtonHidden(true)
                
                // MARK: - match button
                ConnectButton(
                    label: matchRequestVM.isRequestPending ? "Request Sent" : "Let's Connect",
                    alreadyConnected: matchRequestVM.isRequestPending
                ) {
                    if !matchRequestVM.isRequestPending {
                        showRequestView = true
                    }
                }
                .disabled(matchRequestVM.isRequestPending)
                .padding(.horizontal)
                .navigationDestination(isPresented: $showRequestView) {
                    SendConnectRequestView(
                        dogName: dog.displayName,
                        onBack: { showRequestView = false },
                        onSend: { message in
                            Task {
                                if let fromDogId = matchRequestVM.currentDogId {
                                    await matchRequestVM.sendRequest(
                                        fromDogId: fromDogId,
                                        toUserId: owner.id,
                                        toDogId: dog.id,
                                        message: message
                                    )
                                    // Refresh match requests after sending
                                    await matchRequestVM.fetchMatchRequests()

                                } else {
                                    matchRequestVM.alertMessage = "❌ Your dog profile could not be loaded."
                                    matchRequestVM.showAlert = true
                                }
                            }
                        }
                    )
                    .alert(isPresented: $matchRequestVM.showAlert) {
                        Alert(
                            title: Text("Match Request"),
                            message: Text(matchRequestVM.alertMessage),
                            dismissButton: .default(Text("OK"), action:{
                                showRequestView = false
                            })
                        )
                    }
                }
            }
            .task {
                if matchRequestVM.currentDogId == nil {
                    await matchRequestVM.loadCurrentDogId()
                }
                if let fromId = matchRequestVM.currentDogId {
                    await matchRequestVM.checkIfRequestExists(fromDogId: fromId, toDogId: dog.id)
                }
            }
        }
    }
}

    
    
    
    
    
    
