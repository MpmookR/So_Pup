import SwiftUI

struct DogBreedSelector: View {
    @Binding var selectedBreed: String
    @Binding var customMixedBreed: String
    let allBreeds: [String]

    @State private var showBreedPicker = false
    @State private var isMixedBreed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Is your dog a mixed breed?", isOn: $isMixedBreed)
                .toggleStyle(SwitchToggleStyle(tint: Color.socialBorder))

            if isMixedBreed {
                TextField("Enter mixed breed", text: $customMixedBreed)
                    .padding()
                    .background(Color.socialAccent)
                    .cornerRadius(99)
            } else {
                Button {
                    showBreedPicker = true
                    
                } label: {
                    HStack {
                        Text(selectedBreed.isEmpty ? "Select breed" : selectedBreed)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.socialAccent)
                    .cornerRadius(99)
                }
                .confirmationDialog("Select Dog Breed", isPresented: $showBreedPicker, titleVisibility: .visible) {
                    ForEach(allBreeds, id: \.self) { breed in
                        Button(breed) {
                            selectedBreed = breed
                        }
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

#Preview {
    DogBreedSelectorPreviewWrapper()
}

private struct DogBreedSelectorPreviewWrapper: View {
    @State private var selected = ""
    @State private var mixed = ""

    private let sampleBreeds = [
        "Labrador", "German Shepherd", "Shiba Inu", "Golden Retriever", "Poodle"
    ]

    var body: some View {
        DogBreedSelector(
            selectedBreed: $selected,
            customMixedBreed: $mixed,
            allBreeds: sampleBreeds
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

