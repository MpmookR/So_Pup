import SwiftUI

struct FilterDetailSheet: View {
    
    @Environment(\.dismiss) private var dismiss

    @Binding var filterSettings: DogFilterSettings
    
    var onDismiss: () -> Void
    var onApply: ([ScoredDog]) -> Void
    
    var currentDog: DogModel?
    var candidateIds: [String]
    var userCoordinate: Coordinate?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CustomNavBar(
                    title: "Match Filter",
                    showBack: true,
                    onBackTap: { dismiss() }
                )

                if let currentDog, let userCoordinate {
                    ScrollView {
                        VStack(spacing: 24) {
                            GeneralFilterSection(filterSettings: $filterSettings)

                            Divider()

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

                    VStack(spacing: 12) {
                        Button("Reset Filters") {
                            resetFilters()
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)

                        SubmitButton(
                            title: "Apply Filters",
                            backgroundColor: Color.socialButton,
                            foregroundColor: Color.socialText
                        ) {
                            Task {
                                await applyFiltersAndDismiss(currentDog: currentDog, userCoordinate: userCoordinate)
                            }
                        }
                        .padding()
                    }

                } else {
                    VStack(spacing: 20) {
                        ProgressView("Preparing filter…")
                        Button("Dismiss", action: onDismiss)
                    }
                    .padding()
                }
            }
        }
    }

    private func applyFiltersAndDismiss(currentDog: DogModel, userCoordinate: Coordinate) async {
        do {
            let scoredDogs = try await MatchScoringService.shared.sendScoringRequest(
                currentDog: currentDog,
                candidateDogIds: candidateIds,
                userLocation: userCoordinate,
                filters: filterSettings
            )
            onApply(scoredDogs)
            onDismiss()
        } catch {
            print("❌ Match scoring failed: \(error.localizedDescription)")
        }
    }

    private func resetFilters() {
        filterSettings = DogFilterSettings()
    }
}
