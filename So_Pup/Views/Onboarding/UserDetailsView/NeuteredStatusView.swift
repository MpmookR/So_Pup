import SwiftUI

struct NeuteredStatusView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showAlert = false

    var onNext: () -> Void
    var onBack: () -> Void


    var body: some View {
        ZStack {
            Color.socialLight
                .ignoresSafeArea()

            VStack(spacing: 40) {
                OnboardingProgressBar(
                    progress: 0.9,
                    showBackButton: true,
                    onBack: onBack
                )

                Spacer()

                Text("Is \(onboardingVM.dogName) neutered?")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                HStack(spacing: 20) {
                    Button(action: {
                        onboardingVM.dogIsNeutered = true
                    }) {
                        Text("Yes")
                            .foregroundColor(Color.socialText)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.socialAccent)
                            .overlay(
                                RoundedRectangle(cornerRadius: 99)
                                    .stroke(onboardingVM.dogIsNeutered == true ? Color.black : Color.clear, lineWidth: 3)
                            )
                            .cornerRadius(99)
                    }

                    Button(action: {
                        onboardingVM.dogIsNeutered = false
                    }) {
                        Text("No")
                            .foregroundColor(Color.socialText)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.socialAccent)
                            .overlay(
                                RoundedRectangle(cornerRadius: 99)
                                    .stroke(onboardingVM.dogIsNeutered == false ? Color.black : Color.clear, lineWidth: 3)
                            )
                            .cornerRadius(99)
                    }
                }

                Spacer()
                
                NextButton(
                    title: "Next",
                    isDisabled: onboardingVM.dogIsNeutered == nil,
                    backgroundColor: .socialButton,
                    foregroundColor: .socialText,
                    onTap: {
                        if onboardingVM.dogIsNeutered == nil {
                            showAlert = true
                        } else {
                            onNext()
                        }
                    }
                )
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        NeuteredStatusView(onNext: {}, onBack: {})
            .environmentObject(OnboardingViewModel())
    }
}

