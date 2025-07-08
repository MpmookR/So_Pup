import SwiftUI

struct LoadingToHomeView: View {
    var onComplete: () -> Void
    @State private var navigateToHome = false

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

                    Text("loading to social mode")
                        .font(.body)
                        .foregroundColor(.black)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    onComplete()
                    navigateToHome = true
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }
        
    }
}

#Preview {
    LoadingToHomeView(onComplete: {})
}
