import SwiftUI

struct HomeView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            modeStatusView
            dogAgeView
            Spacer()
            logoutButton
        }
        .padding()
        .onAppear {
            onboardingVM.determineMode()
        }
    }

    private var modeStatusView: some View {
        Group {
            if onboardingVM.mode == "puppy" {
                Text("👶 Hi! I’m in Puppy Mode (under 12 weeks)")
                    .font(.title)
                    .foregroundColor(.blue)
            } else {
                Text("🐕 Hi! I’m in Social Mode (12 weeks and older)")
                    .font(.title)
                    .foregroundColor(.green)
            }
        }
    }

    private var dogAgeView: some View {
        let ageInWeeks = Calendar.current.dateComponents([.weekOfYear], from: onboardingVM.dogDOB, to: Date()).weekOfYear ?? 0
        return Text("Dog age: \(ageInWeeks) weeks")
            .font(.subheadline)
            .foregroundColor(.gray)
    }

    private var logoutButton: some View {
        Button(action: {
            authViewModel.signOut()
        }) {
            Text("Log Out")
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(OnboardingViewModel())
        .environmentObject(AuthViewModel())
}
