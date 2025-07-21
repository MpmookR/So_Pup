import SwiftUI

struct BehaviourView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var optionsService: AppOptionsService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showAlert = false
    
    var onNext: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            Color.socialLight
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                OnboardingProgressBar(
                    progress: 0.7,
                    showBackButton: true,
                    onBack: onBack
                )
                Text("\(onboardingVM.dogName)'s Behaviour")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                
                Text("Note: You can select multiple options in each section")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .italic()
                
                if let options = optionsService.options {
//                    Text("Debug: \(options.playStyleOptions.joined(separator: ", "))")
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            BehaviourSelection(
                                title: "Play Style",
                                options: options.playStyleOptions,
                                selectedOptions: $onboardingVM.selectedPlayStyles,
                                showToggle: true
                            )
                            
                            BehaviourSelection(
                                title: "Preferred Play Environment",
                                options: options.playEnvironmentOptions,
                                selectedOptions: $onboardingVM.selectedPlayEnvironments,
                                showToggle: true
                            )
                            
                            BehaviourSelection(
                                title: "Triggers & Sensitivities",
                                options: options.triggerSensitivityOptions,
                                selectedOptions: $onboardingVM.selectedTriggerSensitivities,
                                showToggle: true
                            )
                        }
                    }
                } else {
                    ProgressView("Loading behaviour options...")
                }
                
                Spacer()
                
                NextButton(
                    title: "Next",
                    isDisabled: onboardingVM.selectedPlayStyles.isEmpty || onboardingVM.selectedPlayEnvironments.isEmpty || onboardingVM.selectedTriggerSensitivities.isEmpty,
                    backgroundColor: .socialButton,
                    foregroundColor: .socialText,
                    onTap: {
                        if onboardingVM.selectedPlayStyles.isEmpty || onboardingVM.selectedPlayEnvironments.isEmpty || onboardingVM.selectedTriggerSensitivities.isEmpty {
                            showAlert = true
                        } else {
                            onNext()
                        }
                    }
                )
                
            }
            .padding()
        }
    

        .onTapGesture {
            hideKeyboard()
        }
    }
}

#Preview {
    BehaviourView(onNext: {}, onBack: {})
        .environmentObject(OnboardingViewModel())
    
}
