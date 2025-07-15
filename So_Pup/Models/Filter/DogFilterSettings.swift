import Foundation

// Used in your app logic and UI

struct DogFilterSettings {
    var maxDistanceInKm: Int = 100
    var selectedGender: DogGenderOption? = nil
    var selectedSizes: Set<SizeOption> = []

    // Set<> to support multi-select via BehaviourSelection
    var selectedPlayStyleTags: Set<String> = []
    var selectedEnvironmentTags: Set<String> = []
    var selectedTriggerTags: Set<String> = []

    var selectedHealthStatus: HealthVerificationStatus? = nil
    var neuteredOnly: Bool? = nil
}

