import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
class ProfileEditViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var dog: DogModel
    @Published var isUpdating = false
    @Published var errorMessage = ""
    @Published var showErrorAlert = false
    
    // MARK: - Private Properties
    private let profileService = UserProfileEditionService.shared
    
    // MARK: - Initialization
    init(dog: DogModel) {
        self.dog = dog
    }
    
    // MARK: - Health Status Update Methods
    func updateFleaTreatmentDate(_ date: Date) async {
        isUpdating = true
        
        do {
            let updatedDog = try await profileService.updateFleaTreatmentDate(
                dogId: dog.id,
                date: date
            )
            
            self.dog = updatedDog
            print("✅ Flea treatment date updated successfully")
            
            // Trigger profile update callback
            await onProfileUpdated?()
            
        } catch {
            errorMessage = "Failed to update flea treatment date. Please try again."
            showErrorAlert = true
            print("❌ Failed to update flea treatment date: \(error)")
        }
        
        isUpdating = false
    }
    
    func updateWormingTreatmentDate(_ date: Date) async {
        isUpdating = true
        
        do {
            let updatedDog = try await profileService.updateWormingTreatmentDate(
                dogId: dog.id,
                date: date
            )
            
            self.dog = updatedDog
            print("✅ Worming treatment date updated successfully")
            
            // Trigger profile update callback
            await onProfileUpdated?()
            
        } catch {
            errorMessage = "Failed to update worming treatment date. Please try again."
            showErrorAlert = true
            print("❌ Failed to update worming treatment date: \(error)")
        }
        
        isUpdating = false
    }
    
    // MARK: - Profile Update Callback
    var onProfileUpdated: (() async -> Void)?
    
    // MARK: - Update Profile Data
    func updateProfileData() async {
        await onProfileUpdated?()
    }
    
    // MARK: - Sync Dog Data
    func syncDogData(_ dog: DogModel) {
        self.dog = dog
    }
}
