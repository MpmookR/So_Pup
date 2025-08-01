import Foundation
import SwiftData

@Observable
class DogFilterStorageService {
    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }

    /// Loads the saved filter settings or returns a default struct if none exist.
    func loadFilterSettings() -> DogFilterSettings {
        var descriptor = FetchDescriptor<DogFilterSettingsModel>()
        descriptor.fetchLimit = 1 /// Only return at most one record from the store and only one saved filter at a time

        if let storedModel = try? modelContext.fetch(descriptor).first {
            return storedModel.toStruct()
        } else {
            return DogFilterSettings() // default values
        }
    }

    /// Saves or updates the current filter settings in SwiftData.
    func saveFilterSettings(_ settings: DogFilterSettings) {
        var descriptor = FetchDescriptor<DogFilterSettingsModel>()
        descriptor.fetchLimit = 1

        if let existingModel = try? modelContext.fetch(descriptor).first {
            existingModel.maxDistanceInKm = settings.maxDistanceInKm
            existingModel.selectedGenderRaw = settings.selectedGender?.rawValue
            existingModel.selectedSizes = settings.selectedSizes.map { $0.rawValue }
            existingModel.selectedPlayStyleTags = Array(settings.selectedPlayStyleTags)
            existingModel.selectedEnvironmentTags = Array(settings.selectedEnvironmentTags)
            existingModel.selectedTriggerTags = Array(settings.selectedTriggerTags)
            existingModel.selectedHealthStatusRaw = settings.selectedHealthStatus?.rawValue
            existingModel.neuteredOnly = settings.neuteredOnly
        } else {
            let newModel = DogFilterSettingsModel.fromStruct(settings)
            modelContext.insert(newModel)
        }

        try? modelContext.save()
    }
}


