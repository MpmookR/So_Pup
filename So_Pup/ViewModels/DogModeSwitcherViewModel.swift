/// ------------------------
/// To manage vaccine updates and switching a dog from Puppy to Social mode.
///
/// Responsibilities
/// - Update vaccination dates and reflect backend responses (dog data + readiness flags).
/// - Manually switch mode when eligible; update social data (behaviour, neutered).
/// - Expose UI state: `dog`, `isUpdating`, success/error banners, readiness booleans.
///
/// Key collaborators
/// - `DogModeService` (.shared) --> updateVaccinations / switchDogMode / updateSocialDogData
/// - Firebase `Auth` -->  fetch ID token via `Auth.auth().currentUser?.getIDToken()`
///
/// UI notes
/// - Call the public methods from views; bind to `@Published` for instant UI updates.
/// - Optional callbacks `onModeChangeSuccess` / `onSocialDataUpdated` let the parent refresh.
/// ------------------------
import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
class DogModeSwitcherViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var dog: DogModel
    @Published var isUpdating = false
    @Published var errorMessage = ""
    @Published var showErrorAlert = false
    @Published var showModeChangeAlert = false
    @Published var readyToSwitchMode = false
    
    // MARK: - Private Properties
    private let dogModeService = DogModeService.shared
    
    // MARK: - Callbacks
    var onModeChangeSuccess: (() async -> Void)?
    var onSocialDataUpdated: (() async -> Void)?
    
    // MARK: - Initialization
    init(dog: DogModel) {
        self.dog = dog
    }
    
    // MARK: - Vaccination Update Methods
    func updateFirstVaccination(date: Date) async {
        await updateVaccination(coreVaccination1Date: date, coreVaccination2Date: nil)
    }
    
    func updateSecondVaccination(date: Date) async {
        await updateVaccination(coreVaccination1Date: nil, coreVaccination2Date: date)
    }
    
    // MARK: - Private Business Logic
    private func updateVaccination(
        coreVaccination1Date: Date? = nil,
        coreVaccination2Date: Date? = nil
    ) async {
        // Start loading state
        isUpdating = true
        
        do {
            // Get authentication token
            guard let authToken = try await Auth.auth().currentUser?.getIDToken() else {
                throw URLError(.userAuthenticationRequired)
            }
            
            // Call the service to update vaccination
            let response = try await dogModeService.updateVaccinations(
                dogId: dog.id,
                coreVaccination1Date: coreVaccination1Date,
                coreVaccination2Date: coreVaccination2Date,
                authToken: authToken
            )
            
            // Handle successful update
            await handleSuccessfulUpdate(response: response, vaccinationType: coreVaccination1Date != nil ? "first" : "second")
            
        } catch {
            // Handle error
            await handleUpdateError(error: error, vaccinationType: coreVaccination1Date != nil ? "first" : "second")
        }
        
        // End loading state
        isUpdating = false
    }
    
    private func handleSuccessfulUpdate(response: VaccinationUpdateResponse, vaccinationType: String) async {
        // Update dog data from backend response
        self.dog = response.dog
        
        // Update readiness status from backend
        self.readyToSwitchMode = response.readyToSwitchMode
        
        print("✅ \(vaccinationType.capitalized) vaccination updated successfully")
        print("💡 Ready to switch mode: \(response.readyToSwitchMode)")
        print("💡 Can switch to social: \(response.canSwitchToSocial)")
        
       
        if response.readyToSwitchMode {
            print("🎉 Both vaccinations complete! User can now switch to social mode when ready.")
        }
    }
    
    private func handleUpdateError(error: Error, vaccinationType: String) async {
        errorMessage = "Failed to update \(vaccinationType) vaccination. Please check your internet connection and try again."
        showErrorAlert = true
        print("❌ Failed to update \(vaccinationType) vaccination: \(error)")
    }
    
    // MARK: - Manual Mode Switch
    func switchToSocialMode() async {
        guard dog.mode == .puppy else { return }
        
        isUpdating = true
        
        do {
            guard let authToken = try await Auth.auth().currentUser?.getIDToken() else {
                throw URLError(.userAuthenticationRequired)
            }
            
            let updatedDog = try await dogModeService.switchDogMode(
                dogId: dog.id,
                mode: .social,
                authToken: authToken
            )
            
            self.dog = updatedDog
            showModeChangeAlert = true
            print("✅ Manually switched to social mode")
            
        } catch {
            errorMessage = "Failed to switch to social mode. Please ensure all vaccinations are completed."
            showErrorAlert = true
            print("❌ Failed to switch mode: \(error)")
        }
        
        isUpdating = false
    }
    
    // MARK: - Mode Change Success Handler
    func handleModeChangeSuccess() async {
        await onModeChangeSuccess?()
    }
    
    // MARK: - Behavior Update
    func updateBehavior(_ behavior: DogBehavior) async {
        isUpdating = true
        
        do {
            guard let authToken = try await Auth.auth().currentUser?.getIDToken() else {
                throw URLError(.userAuthenticationRequired)
            }
            
            let updatedDog = try await dogModeService.updateSocialDogData(
                dogId: dog.id,
                behavior: behavior,
                authToken: authToken
            )
            
            self.dog = updatedDog
            print("✅ Behavior updated successfully")
            
        } catch {
            errorMessage = "Failed to update behavior. Please try again."
            showErrorAlert = true
            print("❌ Failed to update behavior: \(error)")
        }
        
        isUpdating = false
    }
    
    // MARK: - Neutered Status Update
    func updateNeuteredStatus(_ isNeutered: Bool) async {
        isUpdating = true
        
        do {
            guard let authToken = try await Auth.auth().currentUser?.getIDToken() else {
                throw URLError(.userAuthenticationRequired)
            }
            
            let updatedDog = try await dogModeService.updateSocialDogData(
                dogId: dog.id,
                isNeutered: isNeutered,
                authToken: authToken
            )
            
            self.dog = updatedDog
            print("✅ Neutered status updated successfully")
            
        } catch {
            errorMessage = "Failed to update neutered status. Please try again."
            showErrorAlert = true
            print("❌ Failed to update neutered status: \(error)")
        }
        
        isUpdating = false
    }
    

    
    // MARK: - Update Multiple Social Data Fields
    func updateSocialData(
        isNeutered: Bool? = nil,
        behavior: DogBehavior? = nil
    ) async {
        isUpdating = true
        
        do {
            guard let authToken = try await Auth.auth().currentUser?.getIDToken() else {
                throw URLError(.userAuthenticationRequired)
            }
            
            let updatedDog = try await dogModeService.updateSocialDogData(
                dogId: dog.id,
                isNeutered: isNeutered,
                behavior: behavior,
                authToken: authToken
            )
            
            self.dog = updatedDog
            print("✅ Social data updated successfully")
            
            // Trigger profile reload callback
            await onSocialDataUpdated?()
            
        } catch {
            errorMessage = "Failed to update social data. Please try again."
            showErrorAlert = true
            print("❌ Failed to update social data: \(error)")
        }
        
        isUpdating = false
    }
    
    // MARK: - Computed Properties
    var isVaccinationComplete: Bool {
        dog.coreVaccination1Date != nil && dog.coreVaccination2Date != nil
    }
    
    var canSwitchToSocialMode: Bool {
        dog.mode == .puppy && readyToSwitchMode
    }
}
