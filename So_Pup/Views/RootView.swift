//
//  Top-level entry point of the UI. Decides which flow to show
//  based on authentication state.
//
//  Key Responsibilities:
//  - Show a loading indicator while checking auth status
//  - Route logged-out users to RegisterView
//  - Route logged-in but not onboarded users to OnboardingFlowView
//  - Route fully onboarded users to MainTabView (the logged-in shell)
//  - Reset NavigationStack whenever login status changes
//
//  Usage:
//  Place at the root of  SwiftUI App. Must be provided with
//  AuthViewModel as an @EnvironmentObject.
//
import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel : AuthViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if authViewModel.isCheckingAuthStatus {
                    ProgressView("Loading...")
                } else if authViewModel.isLoggedIn {
                    if authViewModel.hasCompletedOnboarding {
                        MainTabView()
                            .transition(.opacity)
                    } else {
                        OnboardingFlowView()
                            .transition(.opacity)
                    }
                } else {
                    RegisterView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: authViewModel.isLoggedIn)
            .animation(.easeInOut(duration: 0.5), value: authViewModel.hasCompletedOnboarding)
        }
        .id(authViewModel.isLoggedIn) // resets the entire nav stack when login flips
    }
}


