import SwiftUI

struct FilterDetailSheet: View {
    
    @Environment(\.dismiss) private var dismiss  

    @Binding var filterSettings: DogFilterSettings
    var onDismiss: () -> Void

    let allSizes: [SizeOption] = [.small, .medium, .large]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CustomNavBar(
                    title: "Match Filter",
                    showBack: true,
                    onBackTap:{dismiss()}
                )

                ScrollView {
                    VStack(spacing: 24) {
                        
                        GeneralFilterSection(filterSettings: $filterSettings)

                        Divider()

                        // Pet Behaviour
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pet Behaviour")
                                .fontWeight(.bold)
                            Divider()

                            BehaviourSelection(
                                title: "Play Style",
                                options: playStyleOptions,
                                selectedOptions: $filterSettings.selectedPlayStyleTags,
                                showToggle: true,
                                allowCustomTags: false
                            )

                            BehaviourSelection(
                                title: "Environment",
                                options: playEnvironmentOptions,
                                selectedOptions: $filterSettings.selectedEnvironmentTags,
                                showToggle: true,
                                allowCustomTags: false
                            )

                            BehaviourSelection(
                                title: "Trigger",
                                options: triggerSensitivityOptions,
                                selectedOptions: $filterSettings.selectedTriggerTags,
                                showToggle: true,
                                allowCustomTags: false
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }

                Divider()

                SubmitButton(
                    title: "Apply Filters",
                    backgroundColor: Color.socialButton,
                    foregroundColor: Color.socialText
                ) {
                    onDismiss()
                }
                .padding()
            }
        }
    }
}
