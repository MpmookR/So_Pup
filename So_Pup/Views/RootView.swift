import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel : AuthViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if authViewModel.isLoggedIn {
                    if authViewModel.hasCompletedOnboarding {
                        HomeView()
                            .transition(.opacity)
                    } else {
                        OnboardingFlowView()
                            .environmentObject(OnboardingViewModel())
                            .transition(.opacity)
                    }
                } else {
                    RegisterView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: authViewModel.hasCompletedOnboarding)
        }
    }
}


