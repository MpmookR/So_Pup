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
                
                // match button
                ConnectButton(alreadyConnected: false) {
                    showRequestView = true
                }
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
                                showRequestView = false
                            }
                        }
                    )
                    .task {
                        if matchRequestVM.currentDogId == nil {
                            await matchRequestVM.loadCurrentDogId()
                        }
                    }
                    .alert(isPresented: $matchRequestVM.showAlert) {
                        Alert(
                            title: Text("Match Request"),
                            message: Text(matchRequestVM.alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
        }
    }
}
    //#Preview {
    //    let mockDog = MockDogData.dog1
    //    let mockOwner = MockUserData.user1
    //    let mockCoordinate = Coordinate(latitude: 51.5074, longitude: -0.1278)
    //    let mockReviews = MockDogReviewData.all
    //
    //    return NavigationStack {
    //        FullDogDetailsView(
    //            dog: mockDog,
    //            owner: mockOwner,
    //            userCoordinate: mockCoordinate,
    //            reviews: mockReviews
    //        )
    //    }
    //}
    
    
    
    
    
    
