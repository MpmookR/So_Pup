import Foundation

// Used in app logic and UI for filtering
struct DogFilterSettings: Equatable {
    var maxDistanceInKm: Int = 100
    var selectedGender: DogGenderOption? = nil
    var selectedSizes: Set<SizeOption> = []
    var preferredAgeOption: PreferredAgeOption = .any
    
    // Set<> to support multi-select via BehaviourSelection
    var selectedPlayStyleTags: Set<String> = []
    var selectedEnvironmentTags: Set<String> = []
    var selectedTriggerTags: Set<String> = []
    
    var selectedHealthStatus: HealthVerificationStatus? = nil
    var neuteredOnly: Bool? = nil
}

// This is a computed property that converts the enum into a format suitable for backend scoring.
extension DogFilterSettings {
    func resolvedPreferredAgeRange() -> ClosedRange<Double>? {
        preferredAgeOption.ageRange
    }
//converter from app logic to API format
    func toDTO() -> DogFilterSettingsDTO {
            DogFilterSettingsDTO(
                maxDistanceInKm: self.maxDistanceInKm,
                selectedGender: self.selectedGender?.rawValue,
                selectedSizes: self.selectedSizes.map { $0.rawValue },
                selectedPlayStyleTags: Array(self.selectedPlayStyleTags),
                selectedEnvironmentTags: Array(self.selectedEnvironmentTags),
                selectedTriggerTags: Array(self.selectedTriggerTags),
                selectedHealthStatus: self.selectedHealthStatus?.rawValue,
                neuteredOnly: self.neuteredOnly,
                preferredAgeRange: self.resolvedPreferredAgeRange().map { [$0.lowerBound, $0.upperBound] }
            )
        }
}





