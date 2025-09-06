import Foundation
import SwiftData

// This model is used for storing user-selected filter settings persistently using SwiftData.
/// SwiftData models (@Model classes) must follow specific rules (reference types, no computed vars, no Sets, etc)
@Model
class DogFilterSettingsModel {
    var maxDistanceInKm: Int
    var selectedGenderRaw: String?
    var selectedSizes: [String]
    var selectedPlayStyleTags: [String]
    var selectedEnvironmentTags: [String]
    var selectedTriggerTags: [String]
    var selectedHealthStatusRaw: String?
    var neuteredOnly: Bool?
    var preferredAgeOptionRaw: String

    init(
        maxDistanceInKm: Int = 60,
        selectedGenderRaw: String? = nil,
        selectedSizes: [String] = [],
        selectedPlayStyleTags: [String] = [],
        selectedEnvironmentTags: [String] = [],
        selectedTriggerTags: [String] = [],
        selectedHealthStatusRaw: String? = nil,
        neuteredOnly: Bool? = nil,
        preferredAgeOptionRaw: String = PreferredAgeOption.any.rawValue
    ) {
        self.maxDistanceInKm = maxDistanceInKm
        self.selectedGenderRaw = selectedGenderRaw
        self.selectedSizes = selectedSizes
        self.selectedPlayStyleTags = selectedPlayStyleTags
        self.selectedEnvironmentTags = selectedEnvironmentTags
        self.selectedTriggerTags = selectedTriggerTags
        self.selectedHealthStatusRaw = selectedHealthStatusRaw
        self.neuteredOnly = neuteredOnly
        self.preferredAgeOptionRaw = preferredAgeOptionRaw
    }
}

extension DogFilterSettingsModel {
    
    // turns saved data from SwiftData into a regular struct that the UI understands
    /// use case: Load from database and bind to UI
    func toStruct() -> DogFilterSettings {
        return DogFilterSettings(
            maxDistanceInKm: self.maxDistanceInKm,
            selectedGender: DogGenderOption(rawValue: self.selectedGenderRaw ?? ""),
            selectedSizes: Set(self.selectedSizes.compactMap { SizeOption(rawValue: $0) }),
            preferredAgeOption: PreferredAgeOption(rawValue: self.preferredAgeOptionRaw) ?? .any,
            selectedPlayStyleTags: Set(self.selectedPlayStyleTags),
            selectedEnvironmentTags: Set(self.selectedEnvironmentTags),
            selectedTriggerTags: Set(self.selectedTriggerTags),
            selectedHealthStatus: HealthVerificationStatus(rawValue: self.selectedHealthStatusRaw ?? ""),
            neuteredOnly: self.neuteredOnly
        )
    }

    // converts a DogFilterSettings struct (maybe modified via UI) into a SwiftData-compatible model
    /// Use case: Save current filter settings from UI back to the local store
    static func fromStruct(_ settings: DogFilterSettings) -> DogFilterSettingsModel {
        return DogFilterSettingsModel(
            maxDistanceInKm: settings.maxDistanceInKm,
            selectedGenderRaw: settings.selectedGender?.rawValue,
            selectedSizes: settings.selectedSizes.map { $0.rawValue },
            selectedPlayStyleTags: Array(settings.selectedPlayStyleTags),
            selectedEnvironmentTags: Array(settings.selectedEnvironmentTags),
            selectedTriggerTags: Array(settings.selectedTriggerTags),
            selectedHealthStatusRaw: settings.selectedHealthStatus?.rawValue,
            neuteredOnly: settings.neuteredOnly,
            preferredAgeOptionRaw: settings.preferredAgeOption.rawValue
        )
    }
}
