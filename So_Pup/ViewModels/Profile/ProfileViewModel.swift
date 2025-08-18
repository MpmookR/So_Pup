import Foundation
import FirebaseAuth

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Public state (bind from views)
    @Published var currentUser: UserModel?
    @Published var currentDog: DogModel?

    @Published var isLoading = true
    @Published var isReloading = false
    @Published var loadingError: String?
    @Published var showErrorAlert = false

    @Published var showEditProfile = false
    @Published var showEducationHubAlert = false
    @Published var showSocialDataInput = false

    // Editors / child VMs
    @Published var dogModeSwitcher: DogModeSwitcherViewModel?
    @Published var userEditorVM: UserProfileEditorViewModel?
    @Published var dogEditorVM: DogProfileEditorViewModel?

    // Services
    private let profileService: ProfileDataService

    init(profileService: ProfileDataService = ProfileDataService()) {
        self.profileService = profileService
    }

    // MARK: - Load / Refresh

    func load() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        guard !isReloading else { return }
        isReloading = true
        defer { isReloading = false; isLoading = false }

        do {
            // Fetch user
            let user = try await profileService.fetchUser(by: uid)
            self.currentUser = user

            // Fetch dog
            if let dogId = user?.primaryDogId,
               let dog = try await profileService.fetchDog(by: dogId) {

                applyDog(dog)
                applyUser(user!) // safe after guard above
                checkForSocialDataPrompt()
            }
        } catch {
            loadingError = "Failed to load profile: \(error.localizedDescription)"
            showErrorAlert = true
            print("❌ ProfileViewModel.load error: \(error)")
        }
    }

    /// Lightweight refresh used by child VMs on success.
    func reloadDogOnly() async {
        guard let uid = Auth.auth().currentUser?.uid,
              let user = currentUser else { return }
        do {
            if let updatedDog = try await profileService.fetchDog(by: user.primaryDogId) {
                applyDog(updatedDog)
                // keep editors in sync
                dogModeSwitcher?.dog = updatedDog
                dogEditorVM?.sync(from: updatedDog)
            }
        } catch {
            print("❌ ProfileViewModel.reloadDogOnly error: \(error)")
        }
    }

    // MARK: - Private helpers

    private func applyUser(_ user: UserModel) {
        if let existing = userEditorVM {
            existing.sync(from: user)
        } else {
            userEditorVM = UserProfileEditorViewModel(
                initial: user,
                afterSave: { [weak self] updated in
                    self?.currentUser = updated
                }
            )
        }
    }

    private func applyDog(_ dog: DogModel) {
        self.currentDog = dog

        // Dog mode switcher
        if let existing = dogModeSwitcher {
            existing.dog = dog
        } else {
            let vm = DogModeSwitcherViewModel(dog: dog)
            vm.onModeChangeSuccess = { [weak self] in
                await self?.reloadDogOnly()
                self?.checkForSocialDataPrompt()
            }
            vm.onSocialDataUpdated = { [weak self] in
                await self?.reloadDogOnly()
            }
            dogModeSwitcher = vm
        }

        // Dog editor
        if let existingDogEditor = dogEditorVM {
            existingDogEditor.sync(from: dog)
        } else {
            dogEditorVM = DogProfileEditorViewModel(
                initial: dog,
                afterSave: { [weak self] updated in
                    self?.currentDog = updated
                    // also keep mode switcher aligned
                    self?.dogModeSwitcher?.dog = updated
                }
            )
        }
    }

    private func checkForSocialDataPrompt() {
        guard let dog = currentDog, dog.mode == .social else { return }
        let missingNeutered = dog.isNeutered == nil
        let missingBehavior = dog.behavior == nil
        showSocialDataInput = (missingNeutered || missingBehavior)
    }
}

// ProfileViewModel+ModeChange.swift
@MainActor
extension ProfileViewModel {
    /// Applies the just-updated dog immediately, reloads from backend,
    /// and returns whether we should prompt for social data.
    func applyModeChangeNowAndRefresh() async -> Bool {
        // Immediate UI flip to Social using the freshest dog from the switcher
        if let latest = dogModeSwitcher?.dog {
            applyDog(latest)            // updates currentDog, dogEditorVM, dogModeSwitcher, etc.
        }

        // Then fetch from backend to be fully up-to-date
        await reloadDogOnly()

        // Decide whether we need to show the social data sheet (neutered/behaviour missing)
        return shouldPromptSocialData()
    }

    /// Central check used by both sheet logic and other prompts.
    func shouldPromptSocialData() -> Bool {
        guard let d = currentDog, d.mode == .social else { return false }
        return (d.isNeutered == nil) || (d.behavior == nil)
    }
}

