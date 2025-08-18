import Foundation
import SwiftUI

///
/// - Owns the editable dog fields (basic, behavior, images, health)
/// - Validates + computes diffs to send only changed fields
/// - Calls UserProfileEditionService endpoints
/// - Notifies parent via `afterSave` with the updated DogModel
///
@MainActor
final class DogProfileEditorViewModel: ObservableObject {
    // MARK: - Draft fields bound to UI

    // Basic
    @Published var name: String
    @Published var dob: Date
    @Published var breed: String
    @Published var weight: Double
    @Published var gender: DogGenderOption
    @Published var size: SizeOption
    @Published var bio: String?
    @Published var coordinate: Coordinate

    // Behavior / Health
    @Published var isNeutered: Bool?
    @Published var behavior: DogBehavior?
    @Published var fleaTreatmentDate: Date?
    @Published var wormingTreatmentDate: Date?

    // Media
    @Published var imageURLs: [String]

    // UI state
    @Published var isSavingBasic = false
    @Published var isSavingBehavior = false
    @Published var isSavingImages = false
    @Published var isSavingHealth = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    @Published var successMessage: String?

    // Internals
    private var original: DogModel
    private let service: UserProfileEditionService
    private let afterSave: (DogModel) -> Void

    // MARK: - Init

    init(
        initial: DogModel,
        service: UserProfileEditionService = .shared,
        afterSave: @escaping (DogModel) -> Void
    ) {
        self.original = initial
        self.service = service
        self.afterSave = afterSave

        // Seed drafts from original
        self.name = initial.name
        self.dob = initial.dob
        self.breed = initial.breed
        self.weight = initial.weight
        self.gender = initial.gender
        self.size = initial.size
        self.bio = initial.bio
        self.coordinate = initial.coordinate

        self.isNeutered = initial.isNeutered
        self.behavior = initial.behavior
        self.fleaTreatmentDate = initial.healthStatus?.fleaTreatmentDate
        self.wormingTreatmentDate = initial.healthStatus?.wormingTreatmentDate

        self.imageURLs = initial.imageURLs
    }

    // MARK: - Public: sync from fresh server copy

    func sync(from dog: DogModel) {
        guard dog.id == original.id else { return }
        original = dog

        name = dog.name
        dob = dog.dob
        breed = dog.breed
        weight = dog.weight
        gender = dog.gender
        size = dog.size
        bio = dog.bio
        coordinate = dog.coordinate

        isNeutered = dog.isNeutered
        behavior = dog.behavior
        fleaTreatmentDate = dog.healthStatus?.fleaTreatmentDate
        wormingTreatmentDate = dog.healthStatus?.wormingTreatmentDate

        imageURLs = dog.imageURLs
    }

    // MARK: - Save groups

    /// Save basic (name/dob/breed/weight/gender/size/bio/coordinate)
    func saveBasic() async {
        guard validateBasic() else { return }
        guard hasBasicChanges else {
            successMessage = "No basic changes to save."
            return
        }

        isSavingBasic = true
        defer { isSavingBasic = false }

        do {
            let updated = try await service.updateDogBasicProfile(
                dogId: original.id,
                name: diffName,
                dob: diffDob,
                breed: diffBreed,
                weight: diffWeight,
                gender: diffGender,
                size: diffSize,
                bio: diffBio,
                coordinate: diffCoordinate
            )
            sync(from: updated)
            afterSave(updated)
            successMessage = "Dog profile updated ✅"
        } catch {
            popError("Failed to update dog profile", error)
        }
    }

    /// Save behavior (neutered + behavior blob)
    func saveBehavior() async {
        // No strict validation; optional fields are allowed
        guard hasBehaviorChanges else {
            successMessage = "No behavior changes to save."
            return
        }

        isSavingBehavior = true
        defer { isSavingBehavior = false }

        do {
            let updated = try await service.updateDogBehaviorProfile(
                dogId: original.id,
                isNeutered: diffIsNeutered,
                behavior: diffBehavior
            )
            sync(from: updated)
            afterSave(updated)
            successMessage = "Behavior updated ✅"
        } catch {
            popError("Failed to update behavior", error)
        }
    }

    /// Save images (expects URLs already uploaded elsewhere; this just persists list)
    func saveImages() async {
        guard hasImageChanges else {
            successMessage = "No image changes to save."
            return
        }

        isSavingImages = true
        defer { isSavingImages = false }

        do {
            let updated = try await service.updateDogImages(dogId: original.id, imageURLs: imageURLs)
            sync(from: updated)
            afterSave(updated)
            successMessage = "Images updated ✅"
        } catch {
            popError("Failed to update images", error)
        }
    }
    // MARK: Health

    func setHealthDates(flea: Date?, worming: Date?) async {
        guard flea != nil || worming != nil else {
            popError("Provide at least one treatment date.", nil)
            return
        }
        isSavingHealth = true
        defer { isSavingHealth = false }

        do {
            let updated = try await service.updateDogHealth(
                dogId: original.id,
                fleaTreatmentDate: flea,
                wormingTreatmentDate: worming
            )
            sync(from: updated)
            afterSave(updated)
            successMessage = "Health status updated ✅"
        } catch {
            popError("Failed to update health status", error)
        }
    }

    // MARK: - Derived: change detection

    var hasBasicChanges: Bool {
        diffName != nil ||
        diffDob != nil ||
        diffBreed != nil ||
        diffWeight != nil ||
        diffGender != nil ||
        diffSize != nil ||
        diffBio != nil ||
        diffCoordinate != nil
    }

    var hasBehaviorChanges: Bool {
        diffIsNeutered != nil || diffBehavior != nil
    }

    var hasImageChanges: Bool {
        original.imageURLs != imageURLs
    }

    // MARK: - Validation

    @discardableResult
    private func validateBasic(silent: Bool = false) -> Bool {
        let nm = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nm.isEmpty else { return fail("Dog name is required.", silent: silent) }
        guard weight >= 0 else { return fail("Weight cannot be negative.", silent: silent) }
        guard dob <= Date() else { return fail("Date of birth cannot be in the future.", silent: silent) }
        return true
    }

    private func fail(_ message: String, silent: Bool) -> Bool {
        if !silent { errorMessage = message; showErrorAlert = true }
        return false
    }

    // MARK: - Diff helpers (nil means "unchanged")

    private var diffName: String? { name != original.name ? name : nil }
    private var diffDob: Date?    { dob != original.dob ? dob : nil }
    private var diffBreed: String? {
        breed != original.breed ? breed : nil
    }
    private var diffWeight: Double? {
        weight != original.weight ? weight : nil
    }
    private var diffGender: DogGenderOption? {
        gender != original.gender ? gender : nil
    }
    private var diffSize: SizeOption? {
        size != original.size ? size : nil
    }
    private var diffBio: String? {
        (bio ?? "") != (original.bio ?? "") ? bio : nil
    }
    private var diffCoordinate: Coordinate? {
        coordinatesEqual(original.coordinate, coordinate) ? nil : coordinate
    }

    private var diffIsNeutered: Bool? {
        // nil = unchanged, non-nil = changed to true/false
        if original.isNeutered == isNeutered { return nil }
        return isNeutered
    }

    private var diffBehavior: DogBehavior? {
        behaviorsEqual(original.behavior, behavior) ? nil : behavior
    }

    // MARK: - Equality helpers

    private func coordinatesEqual(_ a: Coordinate, _ b: Coordinate) -> Bool {
        a.latitude == b.latitude && a.longitude == b.longitude
    }

    private func optionalsEqual<T: Equatable>(_ a: T?, _ b: T?) -> Bool {
        a == b
    }

    // DogBehavior might not be Equatable; compare via JSON
    private func behaviorsEqual(_ a: DogBehavior?, _ b: DogBehavior?) -> Bool {
        switch (a, b) {
        case (nil, nil): return true
        case let (l?, r?):
            let enc = JSONEncoder()
            enc.dateEncodingStrategy = .iso8601
            guard
                let ld = try? enc.encode(l),
                let rd = try? enc.encode(r)
            else { return false }
            return ld == rd
        default:
            return false
        }
    }

    // MARK: - Error helper

    private func popError(_ prefix: String, _ error: Error?) {
        if let error { errorMessage = "\(prefix): \(error.localizedDescription)" }
        else { errorMessage = prefix }
        showErrorAlert = true
    }
}

