import SwiftUI

// the view uses for prep .loadCurrentDogId data, then switch to MainTabView via RootView
struct LoadingToHomeView: View {
    
    var onComplete: () -> Void
    let mode: DogMode
    
    @EnvironmentObject var matchRequestVM: MatchRequestViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    

    var body: some View {
        
        ZStack {
            Color.socialLight
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("socialLoading")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                
                ProgressView()
                
                Text(mode == .puppy ? "loading to puppy mode" : "loading to social mode")
                    .font(.body)
                    .foregroundColor(.black)
            }
        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                onComplete()
//                navigateToHome = true
//            }
//        }
//        .navigationDestination(isPresented: $navigateToHome) {
//            HomeView()
//                .environmentObject(MatchRequestViewModel(authVM: AuthViewModel()))
//        }
        .task {
            // preloading on first home load
            await matchRequestVM.loadCurrentDogId()

            try? await Task.sleep(nanoseconds: 1_000_000_000)

            onComplete()
        }
    }
}

