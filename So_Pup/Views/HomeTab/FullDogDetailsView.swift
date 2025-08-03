import SwiftUI

struct FullDogDetailsView: View {
    
    let dog: DogModel
    let owner: UserModel
    let userCoordinate: Coordinate
    let reviews: [DogReview]
    
    @ObservedObject var matchRequestVM: MatchRequestViewModel
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
                        
                        if !reviews.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Reviews")
                                    .font(.headline)
                                    .foregroundColor(Color.socialText)
                                
                                ForEach(reviews) { review in
                                    ReviewSection(review: review)
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Reviews")
                                    .font(.headline)
                                    .foregroundColor(Color.socialText)
                                
                                Text("No reviews just yet. Once \(dog.displayName) has a few successful meetups, you’ll see what others think!")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .padding(.top, 16)
                            }
                        }
                    }
                    
                }
                .padding(.horizontal)
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

    
    
    
    
    
    
