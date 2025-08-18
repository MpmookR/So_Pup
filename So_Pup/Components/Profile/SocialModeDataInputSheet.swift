import SwiftUI

struct SocialModeDataInputSheet: View {
    @Environment(\.dismiss) private var dismiss
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
                            .font(.title2).fontWeight(.bold)
                            .foregroundColor(Color.socialText)
                            .multilineTextAlignment(.center)
                        Text("Help us find the perfect playmates for your pup!")
                            .font(.subheadline)
                            .foregroundColor(Color.socialText.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)

                    // Neutered Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Neutered Status")
                            .font(.headline)
                            .foregroundColor(Color.socialText)

                        HStack(spacing: 16) {
                            Button { isNeutered = true } label: {
                                HStack {
                                    Image(systemName: isNeutered == true ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isNeutered == true ? Color.socialAccent : .gray)
                                    Text("Yes, neutered").foregroundColor(Color.socialText)
                                }
                            }
                            Button { isNeutered = false } label: {
                                HStack {
                                    Image(systemName: isNeutered == false ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isNeutered == false ? Color.socialAccent : .gray)
                                    Text("Not neutered").foregroundColor(Color.socialText)
                                }
                            }
                        }
                    }

                    Divider()

                    // Behavior
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Behavior Profile")
                            .font(.headline)
                            .foregroundColor(Color.socialText)

                        BehaviourSelection(
                            title: "Play Style",
                            options: playStyleOptions,
                            selectedOptions: $selectedPlayStyles,
                            allowsMultipleSelection: true,
                            showToggle: false,
                            allowCustomTags: true
                        )

                        BehaviourSelection(
                            title: "Preferred Play Environment",
                            options: playEnvironmentOptions,
                            selectedOptions: $selectedPlayEnvironments,
                            allowsMultipleSelection: true,
                            showToggle: false,
                            allowCustomTags: true
                        )

                        BehaviourSelection(
                            title: "Triggers & Sensitivities",
                            options: triggerSensitivityOptions,
                            selectedOptions: $selectedTriggerSensitivities,
                            allowsMultipleSelection: true,
                            showToggle: false,
                            allowCustomTags: true
                        )
                    }

                    Spacer(minLength: 120) // leave room above the bottom button
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Social Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        // Pin the SubmitButton above the home indicator
        .safeAreaInset(edge: .bottom) {
            SubmitButton(
                title: dogModeSwitcher.isUpdating ? "Saving…" : "Save",
                iconName: nil,
                backgroundColor: (isFormValid && !dogModeSwitcher.isUpdating) ? Color.socialAccent : Color.gray.opacity(0.3),
                foregroundColor: (isFormValid && !dogModeSwitcher.isUpdating) ? .black : .gray
            ) {
                Task { await saveAndClose() }
            }
            .disabled(!isFormValid || dogModeSwitcher.isUpdating)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .onAppear { loadExistingData() }
    }

    // Must select neutered status at minimum
    private var isFormValid: Bool { isNeutered != nil }

    private func loadExistingData() {
        let dog = dogModeSwitcher.dog
        isNeutered = dog.isNeutered
        if let behavior = dog.behavior {
            selectedPlayStyles = Set(behavior.playStyles)
            selectedPlayEnvironments = Set(behavior.preferredPlayEnvironments)
            selectedTriggerSensitivities = Set(behavior.triggersAndSensitivities)
        }
    }

    private func saveAndClose() async {
        // Build behavior only if the user selected something
        var behavior: DogBehavior? = nil
        if !selectedPlayStyles.isEmpty || !selectedPlayEnvironments.isEmpty || !selectedTriggerSensitivities.isEmpty {
            behavior = DogBehavior(
                playStyles: Array(selectedPlayStyles),
                preferredPlayEnvironments: Array(selectedPlayEnvironments),
                triggersAndSensitivities: Array(selectedTriggerSensitivities)
            )
        }

        await dogModeSwitcher.updateSocialData(
            isNeutered: isNeutered,
            behavior: behavior
        )

        // Pop/dismiss back to ProfileView (works for both sheet and push)
        await MainActor.run { dismiss() }
    }
}
