import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

@MainActor
class OnboardingViewModel: ObservableObject {
    // User
    @Published var name = ""
    @Published var gender = ""
    @Published var profilePicture: UIImage?
    @Published var location = ""
    @Published var bio = ""
    @Published var languages: [String] = []
    
    // Dog
    @Published var dogName = ""
    @Published var dogGender = ""
    @Published var dogSize = ""
    @Published var dogWeight: Double = 0
    @Published var dogBreed = ""
    @Published var dogDOB = Date()
    @Published var dogIsNeutered: Bool?
    @Published var dogImages: [UIImage] = [] // up to 5
    @Published var dogBehaviorTags: [String] = []
    @Published var dogHealthStatus: [String] = []
    
    // health
    @Published var fleaTreatmentDate: Date?
    @Published var wormingTreatmentDate: Date?
    @Published var coreVaccination1Date: Date?
    @Published var coreVaccination2Date: Date?
    
    @Published var mode = "puppy"
    @Published var status = "incomplete"
    
    func determineMode() {
        let age = Calendar.current.dateComponents([.weekOfYear], from: dogDOB, to: Date()).weekOfYear ?? 0
        mode = age < 12 ? "puppy" : "social"
    }
    
    func saveToFirebase() async throws {
        
        // MARK:  initialised them here as te complier cannot process long struct
        let parsedGender = DogGenderOption(rawValue: dogGender) ?? .other
        let parsedSize = SizeOption(rawValue: dogSize) ?? .medium
        let parsedMode = DogMode(rawValue: mode) ?? .puppy
        let parsedStatus = DogProfileStatus(rawValue: status) ?? .incomplete

        let fleaDate = parsedMode == .social ? fleaTreatmentDate : nil
        let wormingDate = parsedMode == .social ? wormingTreatmentDate : nil
        let core1 = parsedMode == .puppy ? coreVaccination1Date : nil
        let core2 = parsedMode == .puppy ? coreVaccination2Date : nil
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // 1. Upload profile picture
        let profileURL = try await uploadImage(profilePicture, path: "users/\(uid)/profile.jpg")
        
        // 2. Upload dog images
        var dogImageURLs: [String] = []
        for (index, image) in dogImages.prefix(5).enumerated() {
            let url = try await uploadImage(image, path: "dogs/\(uid)/\(index).jpg")
            dogImageURLs.append(url)
        }
        
        // 3. Prepare DogBehavior (for dogs >= 12 weeks)
        let behaviorData: DogBehavior? = mode == "social" ? DogBehavior(
            playStyles: dogBehaviorTags,
            preferredPlayEnvironments: [], // Add real value
            triggersAndSensitivities: [],  // Add real value
            customPlayStyle: nil,          // Optional support for "Other"
            customPlayEnvironment: nil,
            customTriggerSensitivity: nil
        ) : nil
        
        // 4. Create DogModel
        let dog = DogModel(
            name: dogName,
            gender: parsedGender,
            size: parsedSize,
            weight: dogWeight,
            breed: dogBreed,
            dob: dogDOB,
            isNeutered: dogIsNeutered,
            behavior: behaviorData,
            fleaTreatmentDate: fleaDate,
            wormingTreatmentDate: wormingDate,
            coreVaccination1Date: core1,
            coreVaccination2Date: core2,
            mode: parsedMode,
            status: parsedStatus,
            imageURLs: dogImageURLs
        )

        
        // 5. Save dog
        let dogRef = db.collection("dogs").document()
        try dogRef.setData(from: dog)
        
        // 6. Prepare user coordinate
        let coordinate = Coordinate(latitude: 0, longitude: 0) // Replace with actual from LocationManager
        
        // 7. Create UserModel
        let user = UserModel(
            id: uid,
            name: name,
            gender: UserGenderOption(rawValue: gender) ?? .other,
            profilePictureURL: profileURL,
            location: location,
            coordinate: coordinate,
            bio: bio,
            languages: languages,
            customLanguage: nil,
            dogId: dogRef.documentID
        )
        
        // 8. Save user
        try db.collection("users").document(uid).setData(from: user)
    }
    
    private func uploadImage(_ image: UIImage?, path: String) async throws -> String {
        guard let image = image,
              let data = image.jpegData(compressionQuality: 0.8) else {
            return ""
        }
        let ref = Storage.storage().reference().child(path)
        _ = try await ref.putDataAsync(data)
        return try await ref.downloadURL().absoluteString
    }
}


