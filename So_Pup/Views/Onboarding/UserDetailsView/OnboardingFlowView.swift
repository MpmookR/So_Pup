import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct OnboardingFlowView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentStep: Int = 0

    var body: some View {
        NavigationStack {
            buildStepView()
        }
    }

    @ViewBuilder
    private func buildStepView() -> some View {
        switch currentStep {
        case 0:
            UserGeneralDetailsView(
                onNext: { currentStep += 1 },
                onBack: {}
            )

        case 1:
            DogGeneralDetailsView(
                onNext: { currentStep += 1 },
                onBack: { currentStep -= 1 }
            )

        case 2:
            MoreDogDetailsView(
                onNext: {
                    onboardingVM.determineMode()
                    currentStep = (onboardingVM.mode == "puppy") ? 5 : 3
                },
                onBack: { currentStep -= 1 }
            )

        case 3:
            BehaviourView(
                onNext: { currentStep += 1 },
                onBack: { currentStep -= 1 }
            )

        case 4:
            NeuteredStatusView(
                onNext: { currentStep += 1 },
                onBack: { currentStep -= 1 }
            )

        case 5:
            LoadingToHomeView(
                onComplete: {
                    Task {
                        do {
                            await onboardingVM.fetchUserLocation()
                            try await onboardingVM.saveToFirebase()
                            await markOnboardingComplete()
                            authViewModel.hasCompletedOnboarding = true
                        } catch {
                            print("❌ Failed to complete onboarding: \(error.localizedDescription)")
                        }
                    }
                },
                mode: DogMode(rawValue: onboardingVM.mode) ?? .puppy,
                matchRequestVM: MatchRequestViewModel(authVM: authViewModel),
            )

        default:
            EmptyView()
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
