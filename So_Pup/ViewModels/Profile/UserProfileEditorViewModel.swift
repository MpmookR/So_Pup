import Foundation
import SwiftUI

@MainActor
final class UserProfileEditorViewModel: ObservableObject {
    // MARK: - Draft fields bound to the UI
    @Published var name: String
    @Published var bio: String?
    @Published var location: String?
    @Published var coordinate: Coordinate?
    @Published var languages: [String]
    @Published var customLanguage: String?
    @Published var imageURL: String?

    // MARK: - UI state
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    @Published var successMessage: String?

    // MARK: - Internals
    private var original: UserModel
    private let service: UserProfileEditionService
    private let afterSave: (UserModel) -> Void

    // MARK: - Init
    init(
        initial: UserModel,
        service: UserProfileEditionService = .shared,
        afterSave: @escaping (UserModel) -> Void
    ) {
        self.original = initial
        self.service = service
        self.afterSave = afterSave

        // seed drafts
        self.name = initial.name
        self.bio = initial.bio
        self.location = initial.location
        self.coordinate = initial.coordinate
        self.languages = initial.languages
        self.customLanguage = initial.customLanguage
        self.imageURL = initial.profilePictureURL
    }

    // MARK: - Public

    /// Sync drafts from a fresh server copy (e.g., parent reloaded).
    func sync(from user: UserModel) {
        guard user.id == original.id else { return }
        self.original = user
        self.name = user.name
        self.bio = user.bio
        self.location = user.location
        self.coordinate = user.coordinate
        self.languages = user.languages
        self.customLanguage = user.customLanguage
        self.imageURL = user.profilePictureURL
    }

    /// Save only changed fields. Shows spinner + error UI.
    func save() async {
        guard validate() else { return }
        guard hasChanges else {
            successMessage = "No changes to save."
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            let updated = try await service.updateUserProfile(
                userId: original.id,
                name: diffName,
                bio: diffBio,
                location: diffLocation,
                coordinate: diffCoordinate,
                languages: diffLanguages,
                customLanguage: diffCustomLanguage,
                imageURL: diffImageURL
            )

            // Update local original + drafts
            sync(from: updated)
            afterSave(updated)

            successMessage = "Profile updated ✅"
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    func resetToServer() {
        sync(from: original)
        successMessage = "Reverted changes."
    }

    // MARK: - Derived state

    var canSave: Bool {
        !isSaving && validate(silent: true) && hasChanges
    }

    var hasChanges: Bool {
        diffName != nil ||
        diffBio != nil ||
        diffLocation != nil ||
        diffCoordinate != nil ||
        diffLanguages != nil ||
        diffCustomLanguage != nil ||
        diffImageURL != nil
    }

    // MARK: - Validation

    @discardableResult
    private func validate(silent: Bool = false) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            if !silent {
                errorMessage = "Name is required."
                showErrorAlert = true
            }
            return false
        }
        return true
    }

    // MARK: - Diff helpers (nil means "unchanged")

    private var diffName: String? {
        name != original.name ? name : nil
    }

    private var diffBio: String? {
        (bio ?? "") != (original.bio ?? "") ? bio : nil
    }

    private var diffLocation: String? {
        (location ?? "") != (original.location ?? "") ? location : nil
    }

    private var diffCoordinate: Coordinate? {
        equal(original.coordinate, coordinate) ? nil : coordinate
    }

    private var diffLanguages: [String]? {
        equalStringArrayIgnoringOrder(original.languages, languages) ? nil : languages
    }

    private var diffCustomLanguage: String? {
        (customLanguage ?? "") != (original.customLanguage ?? "") ? customLanguage : nil
    }

    private var diffImageURL: String? {
        (imageURL ?? "") != (original.profilePictureURL ?? "") ? imageURL : nil
    }

    private func equal(_ lhs: Coordinate?, _ rhs: Coordinate?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): return true
        case let (l?, r?):
            return l.latitude == r.latitude && l.longitude == r.longitude
        default:
            return false
        }
    }

    private func equalStringArrayIgnoringOrder(_ lhs: [String], _ rhs: [String]) -> Bool {
        Set(lhs.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }) ==
        Set(rhs.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
    }
}
