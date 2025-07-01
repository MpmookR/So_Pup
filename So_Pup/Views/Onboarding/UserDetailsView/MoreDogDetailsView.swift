import SwiftUI

struct MoreDogDetailsView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSize: SizeOption?
    @State private var showSizeOptions = false
    
    @State private var showAlert = false
    
    var onNext: () -> Void
    var onBack: () -> Void

    
    var body: some View {
        ZStack {
            Color.socialLight
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                
                OnboardingProgressBar(
                    progress: 0.5,
                    showBackButton: true,
                    onBack: onBack
                )
                
                // Title
                Text("General Details About Your Puppy")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                
                // input field
                VStack {
                    SelectableField(
                        label: "Puppy weight",
                        value: $onboardingVM.dogWeightString,
                        placeholder: "enter weight in Kilograms",
                        filled: true
                    )
                    .keyboardType(.decimalPad)
                    
                    SelectableField(
                        label: "Puppy Size",
                        value: $onboardingVM.dogSize,
                        placeholder: "Select size",
                        filled: true,
                        trailingIcon: "chevron.down",
                        trailingAction: {
                            showSizeOptions = true
                        }
                    )
                    .confirmationDialog("Select Size", isPresented: $showSizeOptions, titleVisibility: .visible) {
                        ForEach(SizeOption.allCases, id: \.self) { size in
                            Button(size.rawValue.capitalized) {
                                onboardingVM.dogSize = size.rawValue
                                selectedSize = size
                            }
                        }
                    }
                    
                    CustomDatePicker(
                        title: "Puppy Date Of Birth",
                        placeholder: "Select date...",
                        selectedDate: $onboardingVM.dogDOB,
                        dateRule: .noFuture,
                        includeTime: false
                    )
                }
                
                Spacer()
                
                NextButton(
                    title: "Next",
                    isDisabled: onboardingVM.dogWeightString.isEmpty || onboardingVM.dogSize.isEmpty || onboardingVM.dogDOB == Date(),
                    backgroundColor: .socialButton,
                    foregroundColor: .socialText,
                    onTap: {
                        if onboardingVM.dogWeightString.isEmpty || onboardingVM.dogSize.isEmpty || onboardingVM.dogDOB == Date() {
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

