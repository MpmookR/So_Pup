import SwiftUI

struct DogGeneralDetailsView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    @State private var selectedGender: DogGenderOption?
    @State private var showGenderOptions = false
    
    @State private var selectedBreed = ""
    @State private var mixedBreed = ""
    
    @State private var showAlert = false
    
    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        ZStack {
            Color.socialLight
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                
                OnboardingProgressBar(
                    progress: 0.3,
                    showBackButton: true,
                    onBack: onBack
                )
                
                // Title
                Text("General Details About Your Puppy")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                
                // Profile Picture Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Puppy Profile Picture")
                        .font(.body)
                    
                    Button(action: {
                        showImagePicker = true
                    }) {
                        if let image = onboardingVM.dogImages.first {
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
                        label: "what is your puppy name?",
                        value: $onboardingVM.dogName,
                        placeholder: "enter puppy name",
                        filled: true
                    )
                    
                    SelectableField(
                        label: "what is your puppy gender?",
                        value: $onboardingVM.dogGender,
                        placeholder: "Select gender",
                        filled: true,
                        trailingIcon: "chevron.down",
                        trailingAction: {
                            showGenderOptions = true
                        }
                    )
                    .confirmationDialog("Select Gender", isPresented: $showGenderOptions, titleVisibility: .visible) {
                        ForEach(DogGenderOption.allCases, id: \.self) { gender in
                            Button(gender.rawValue.capitalized) {
                                onboardingVM.dogGender = gender.rawValue
                                selectedGender = gender
                            }
                        }
                    }
                    
                    DogBreedSelector(
                        selectedBreed: $onboardingVM.dogBreed,
                        customMixedBreed: $mixedBreed,
                        allBreeds: BreedService.loadDogBreeds()
                    )
                    
                }
                
                Spacer()
                
                NextButton(
                    title: "Next",
                    isDisabled: onboardingVM.dogName.isEmpty || onboardingVM.dogGender.isEmpty || onboardingVM.dogBreed.isEmpty,
                    backgroundColor: .socialButton,
                    foregroundColor: .socialText,
                    onTap: {
                        if onboardingVM.dogName.isEmpty || onboardingVM.dogGender.isEmpty || onboardingVM.dogBreed.isEmpty {
                            showAlert = true
                        } else {
                            onNext()
                        }
                    }
                )


            }
            .padding()
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onChange(of: selectedImage) { oldValue, newValue in
                if let image = newValue {
                    onboardingVM.dogImages = [image]
                }
            }

        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

//#Preview {
//    NavigationStack {
//        UserGeneralDetailsView()
//            .environmentObject(OnboardingViewModel())
//    }
//}



