import SwiftUI

struct UserGeneralDetailsView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showImagePicker = false
    @State private var selectedGender: UserGenderOption? = nil
    @State private var showGenderOptions = false
    @State private var showAlert = false
    
    var onNext: () -> Void

    
    var body: some View {
        ZStack {
            Color.socialLight
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                
                OnboardingProgressBar(
                    progress: 0.1,
                    showBackButton: true,
                    onBack: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                
                // Title
                Text("General Details About You")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                
                // Profile Picture Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Profile Picture")
                        .font(.body)
                    
                    Button(action: {
                        showImagePicker = true
                    }) {
                        if let image = onboardingVM.profilePicture {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "photo.badge.plus")
                                .foregroundColor(Color.black)
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(Color.yellow.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                }
                
                // input field
                VStack {
                    SelectableField(
                        label: "What is your name?",
                        value: $onboardingVM.name,
                        placeholder: "eg; Michael Scott",
                        filled: true
                    )
                    
                    SelectableField(
                        label: "What is your gender?",
                        value: $onboardingVM.gender,
                        placeholder: "Select your gender",
                        filled: true,
                        trailingIcon: "chevron.down",
                        trailingAction: {
                            showGenderOptions = true
                        }
                    )
                    .confirmationDialog("Select Gender", isPresented: $showGenderOptions, titleVisibility: .visible) {
                        ForEach(UserGenderOption.allCases, id: \.self) { gender in
                            Button(gender.rawValue.capitalized) {
                                onboardingVM.gender = gender.rawValue
                                selectedGender = gender
                            }
                        }
                    }
                    
                    LanguageSelector(
                        selectedLanguages: $onboardingVM.languages,
                        allLanguages: languageOptions,
                        allowCustomLanguage: true
                    )
                }
                
                Spacer()
                
                NextButton(
                    title: "Next",
                    isDisabled: onboardingVM.name.isEmpty || onboardingVM.gender.isEmpty,
                    backgroundColor: .socialButton,
                    foregroundColor: .socialText,
                    onTap: {
                        if onboardingVM.name.isEmpty || onboardingVM.gender.isEmpty {
                            showAlert = true
                        } else {
                            onNext()
                        }
                    }
                )


            }
            .padding()
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $onboardingVM.profilePicture)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

#Preview {
    NavigationStack {
        UserGeneralDetailsView(onNext: {})
            .environmentObject(OnboardingViewModel())
    }
}




