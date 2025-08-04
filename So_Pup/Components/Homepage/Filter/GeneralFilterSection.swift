import SwiftUI

struct GeneralFilterSection: View {
    @Binding var filterSettings: DogFilterSettings
    let allSizes: [SizeOption] = SizeOption.allCases
    
    // Local bindings to avoid inline complexity
    private var genderBinding: Binding<DogGenderOption?> {
        Binding(
            get: { filterSettings.selectedGender },
            set: { filterSettings.selectedGender = $0 }
        )
    }
    
    private var healthBinding: Binding<HealthVerificationStatus?> {
        Binding(
            get: { filterSettings.selectedHealthStatus },
            set: { filterSettings.selectedHealthStatus = $0 }
        )
    }
    
    private var neuteredBinding: Binding<Bool> {
        Binding(
            get: { filterSettings.neuteredOnly ?? false },
            set: { filterSettings.neuteredOnly = $0 }
        )
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Distance Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Distance")
                        .fontWeight(.bold)
                    Spacer()
                    
                    Text(
                        filterSettings.maxDistanceInKm == 100
                        ? "All locations"
                        : "Within \(filterSettings.maxDistanceInKm) km"
                    )                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Slider(
                        value: Binding(
                            get: { Double(filterSettings.maxDistanceInKm) },
                            set: { filterSettings.maxDistanceInKm = Int($0.rounded()) }
                        ),
                        in: 1...100,
                        step: 1
                    )
                    .accentColor(.socialButton)
                }
                .padding(.vertical, 8)
                
                Divider()
            }
            
            // General Info Section
            VStack(alignment: .leading, spacing: 16) {
                Text("General")
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8){
                    Text("Gender")
                        .font(.body)
                    // Gender Picker
                    Picker("Gender", selection: genderBinding) {
                        Text("All").tag(DogGenderOption?.none)
                        ForEach(DogGenderOption.allCases, id: \.self) { gender in
                            Text(gender.rawValue.capitalized).tag(Optional(gender))
                            
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Health Verification Picker
                VStack(alignment: .leading, spacing: 8){
                    Text("Health Status")
                        .font(.body)
                    Picker("Health Status", selection: healthBinding) {
                        Text("All").tag(HealthVerificationStatus?.none)
                        ForEach(HealthVerificationStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(Optional(status))
                        }
                    }
                    .pickerStyle(.segmented)
                    
                }
                // age
                // Age Range Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferred Age")
                        .font(.body)
                    
                    Picker("Preferred Age", selection: $filterSettings.preferredAgeOption) {
                        ForEach(PreferredAgeOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                
                // Size Multi-select
                VStack(alignment: .leading, spacing: 8) {
                    Text("Size")
                        .font(.body)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)]) {
                        ForEach(allSizes, id: \.self) { size in
                            let isSelected = filterSettings.selectedSizes.contains(size)
                            Button(action: {
                                if isSelected {
                                    filterSettings.selectedSizes.remove(size)
                                } else {
                                    filterSettings.selectedSizes.insert(size)
                                }
                            }) {
                                Text(size.rawValue.capitalized)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .frame(minWidth: 120)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? Color.socialAccent : Color(.systemGray5))
                                    .foregroundColor(.black)
                                    .cornerRadius(99)
                            }
                        }
                    }
                }
                
                // Neutered Toggle
                Toggle("Neutered Only", isOn: neuteredBinding)
                    .toggleStyle(SwitchToggleStyle(tint: Color.socialButton))
                
            }
        }
    }
}

//#Preview {
//    @State var tempSettings = DogFilterSettings(
//        maxDistanceInKm: 10,
//        selectedGender: .female,
//        selectedSizes: [.small, .medium],
//        selectedHealthStatus: .verified,
//        neuteredOnly: true
//    )
//    
//    GeneralFilterSection(filterSettings: $tempSettings)
//        .padding()
//}



