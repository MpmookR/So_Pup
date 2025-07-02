import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct OnboardingFlowView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentStep: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                switch currentStep {
                case 0:
                    UserGeneralDetailsView(
                        onNext: { currentStep += 1 },
                        onBack: {}
                    )
                    .environmentObject(onboardingVM)
                    
                case 1:
                    DogGeneralDetailsView(
                        onNext: { currentStep += 1 },
                        onBack: { currentStep -= 1 }
                    )
                    .environmentObject(onboardingVM)
                    
                case 2:
                    MoreDogDetailsView(
                        onNext: { currentStep += 1 },
                        onBack: { currentStep -= 1 }
                        
                    )
                    .environmentObject(onboardingVM)
                    
                case 3:
                    BehaviourView(
                        onNext: { currentStep += 1 },
                        onBack: { currentStep -= 1 }
                        
                    )
                    .environmentObject(onboardingVM)
                    
                case 4:
                    NeuteredStatusView(
                        onNext: { currentStep += 1 },
                        onBack: { currentStep -= 1 }
                        
                    )
                    .environmentObject(onboardingVM)
                    
                case 5:
                    LoadingToHomeView(
                        onComplete: {
                            Task {
                                do {
                                    try await onboardingVM.saveToFirebase() // Saves user and dog data
                                    await markOnboardingComplete()       // Updates Firestore flag
                                    authViewModel.hasCompletedOnboarding = true // Triggers RootView update
                                } catch {
                                    print ("❌ Failed to complete onboarding: \(error.localizedDescription)")
                                           // Optionally: show alert to user")
                                }
                            }
                        }
                    )                    
                default:
                    EmptyView()
                }
            }
        }
    }
    
    private func markOnboardingComplete() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        do {
            try await db.collection("users").document(uid).setData([
                "hasCompletedOnboarding": true
            ], merge: true)
        } catch {
            print("❌ Failed to update onboarding status: \(error.localizedDescription)")
        }
    }
}
