import SwiftUI

struct SocialModeDataInputSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var dogModeSwitcher: DogModeSwitcherViewModel
    
    // Behavior data
    @State private var selectedPlayStyles: Set<String> = []
    @State private var selectedPlayEnvironments: Set<String> = []
    @State private var selectedTriggerSensitivities: Set<String> = []
    
    // Neutered status
    @State private var isNeutered: Bool? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🎾 Complete your social profile")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.socialText)
                            .multilineTextAlignment(.center)
                        
                        Text("Help us find the perfect playmates for your pup!")
                            .font(.subheadline)
                            .foregroundColor(Color.socialText.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    
                    // Neutered Status Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Neutered Status")
                            .font(.headline)
                            .foregroundColor(Color.socialText)
                        
                        HStack(spacing: 16) {
                            Button(action: { isNeutered = true }) {
                                HStack {
                                    Image(systemName: isNeutered == true ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isNeutered == true ? Color.socialAccent : Color.gray)
                                    Text("Yes, neutered")
                                        .foregroundColor(Color.socialText)
                                }
                            }
                            
                            Button(action: { isNeutered = false }) {
                                HStack {
                                    Image(systemName: isNeutered == false ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isNeutered == false ? Color.socialAccent : Color.gray)
                                    Text("Not neutered")
                                        .foregroundColor(Color.socialText)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Behavior Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Behavior Profile")
                            .font(.headline)
                            .foregroundColor(Color.socialText)
                        
                        // Play Styles
                        BehaviourSelection(
                            title: "Play Style",
                            options: playStyleOptions,
                            selectedOptions: $selectedPlayStyles,
                            allowsMultipleSelection: true,
                            showToggle: false,
                            allowCustomTags: true
                        )
                        
                        // Play Environments
                        BehaviourSelection(
                            title: "Preferred Play Environment",
                            options: playEnvironmentOptions,
                            selectedOptions: $selectedPlayEnvironments,
                            allowsMultipleSelection: true,
                            showToggle: false,
                            allowCustomTags: true
                        )
                        
                        // Triggers & Sensitivities
                        BehaviourSelection(
                            title: "Triggers & Sensitivities",
                            options: triggerSensitivityOptions,
                            selectedOptions: $selectedTriggerSensitivities,
                            allowsMultipleSelection: true,
                            showToggle: false,
                            allowCustomTags: true
                        )
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Social Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.socialText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSocialData()
                    }
                    .foregroundColor(Color.socialText)
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
        }

        .onAppear {
            loadExistingData()
        }
    }
    
    private var isFormValid: Bool {
        // At least neutered status should be selected
        isNeutered != nil
    }
    
    private func loadExistingData() {
        let dog = dogModeSwitcher.dog
        
        // Load existing neutered status
        isNeutered = dog.isNeutered
        
        // Load existing behavior
        if let behavior = dog.behavior {
            selectedPlayStyles = Set(behavior.playStyles)
            selectedPlayEnvironments = Set(behavior.preferredPlayEnvironments)
            selectedTriggerSensitivities = Set(behavior.triggersAndSensitivities)
        }
    }
    
    private func saveSocialData() {
        Task {
            // Prepare behavior data (only if selections made)
            var behavior: DogBehavior? = nil
            if !selectedPlayStyles.isEmpty || !selectedPlayEnvironments.isEmpty || !selectedTriggerSensitivities.isEmpty {
                behavior = DogBehavior(
                    playStyles: Array(selectedPlayStyles),
                    preferredPlayEnvironments: Array(selectedPlayEnvironments),
                    triggersAndSensitivities: Array(selectedTriggerSensitivities)
                )
            }
            
            // Update social data (neutered status and behavior)
            await dogModeSwitcher.updateSocialData(
                isNeutered: isNeutered,
                behavior: behavior
            )
            
            await MainActor.run {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

