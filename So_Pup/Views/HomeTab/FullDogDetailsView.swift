import SwiftUI

struct FullDogDetailsView: View {
    
    let dog: DogModel
    let owner: UserModel
    let userCoordinate: Coordinate
    let reviews: [DogReview]
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
                .navigationDestination(isPresented: $showRequestView){
                    SendConnectRequestView(
                        dogName: dog.displayName,
                        onBack: {showRequestView = false},
                        onSend: { message in
                            // MARK: Call match request logic here
                            print("Sent message: \(message)")
                            showRequestView = false
                        }
                    )
                }
                
            }
        }
    }
}

//#Preview {
//    var dog = MockDogData.dog3
//    let owner = MockUserData.user3
//    dog.ownerId = owner.id
//
//    let coordinate = owner.coordinate
//    let dogReviews = MockDogReviewData.all.filter { $0.reviewedDogId == dog.id }
//
//    NavigationView {
//        FullDogDetailsView(
//            dog: dog,
//            owner: owner,
//            userCoordinate: coordinate,
//            reviews: dogReviews
//        )
//    }
//}


