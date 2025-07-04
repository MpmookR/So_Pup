import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import FirebaseStorage

///https://firebase.google.com/docs/storage/ios/start?
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
    @Published var dogBreed = ""
    @Published var mixedBreed = ""
    @Published var dogDOB = Date()
    @Published var dogIsNeutered: Bool?
    @Published var dogImages: [UIImage] = [] // up to 5
    @Published var dogHealthStatus: [String] = []
    
    // dog behaviour
    @Published var selectedPlayStyles: Set<String> = []
    @Published var selectedPlayEnvironments: Set<String> = []
    @Published var selectedTriggerSensitivities: Set<String> = []
    
    @Published var customPlayStyle: String?
    @Published var customPlayEnvironment: String?
    @Published var customTriggerSensitivity: String?
    
    
    
    @Published var dogWeight: Double = 0
    @Published var dogWeightString: String = "" {
        // didSet runs immediately after a property’s value changes
        /// it wont run during initialization, only when new value assigned
        didSet {
            let sanitized = dogWeightString.replacingOccurrences(of: ",", with: ".")
            dogWeight = Double(sanitized) ?? 0
        }
    }
    
    init() {
        dogWeightString = dogWeight == 0 ? "" : String(format: "%.2f", dogWeight)
    }
    
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        do {
            // MARK:  initialised them here as te complier cannot process long struct
            let parsedGender = DogGenderOption(rawValue: dogGender) ?? .other
            let parsedSize = SizeOption(rawValue: dogSize) ?? .medium
            let parsedMode = DogMode(rawValue: mode) ?? .puppy
            let parsedStatus = DogProfileStatus(rawValue: status) ?? .incomplete
            
            let fleaDate = parsedMode == .social ? fleaTreatmentDate : nil
            let wormingDate = parsedMode == .social ? wormingTreatmentDate : nil
            let core1 = parsedMode == .puppy ? coreVaccination1Date : nil
            let core2 = parsedMode == .puppy ? coreVaccination2Date : nil
            
            // 1. Upload profile picture
            var profileURL: String? = nil
            if let profileImage = profilePicture {
                print("⚠️ Is profilePicture nil? \(profilePicture == nil)")

                profileURL = try await FirebaseStorageService.shared.uploadImage(
                    profileImage,
                    path: "users/\(uid)/profile.jpg"
                )
            }

            // 2. Upload dog images
            var dogImageURLs: [String] = []
            for (index, image) in dogImages.prefix(5).enumerated() {
                let path = "dogs/\(uid)/\(index).jpg"
                let url = try await FirebaseStorageService.shared.uploadImage(image, path: path)
                dogImageURLs.append(url)
            }
            print("✅ Uploaded dog images")

            
            // 3. Prepare DogBehavior (for dogs >= 12 weeks)
            // save dog's behavior only for socail mode user
            let behaviorData: DogBehavior? = mode == "social" ? DogBehavior(
                playStyles: Array(selectedPlayStyles),
                preferredPlayEnvironments: Array(selectedPlayEnvironments),
                triggersAndSensitivities: Array(selectedTriggerSensitivities),
                customPlayStyle: customPlayStyle,
                customPlayEnvironment: customPlayEnvironment,
                customTriggerSensitivity: customTriggerSensitivity
            ) : nil
            
            
            let finalBreed = mixedBreed.isEmpty ? dogBreed : mixedBreed
            
            // 4. Create DogModel
            let dog = DogModel(
                name: dogName,
                gender: parsedGender,
                size: parsedSize,
                weight: dogWeight,
                breed: finalBreed,
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
            print("✅ Saved dog data successfully")
            
            
            // 6. Prepare user coordinate
            let coordinate = Coordinate(latitude: 0, longitude: 0) // Replace with actual from LocationManager
            
            // 7. Create UserModel
            let user = UserModel(
                id: uid,
                name: name,
                gender: UserGenderOption(rawValue: gender) ?? .other,
                profilePictureURL: profileURL ?? "",
                location: location,
                coordinate: coordinate,
                bio: bio,
                languages: languages,
                customLanguage: nil,
                dogId: dogRef.documentID
            )
            
            // 8. Save user
            try db.collection("users").document(uid).setData(from: user)
            print("✅ Saved user data successfully")
            
        } catch {
            print("❌ Error saving data to Firestore: \(error.localizedDescription)")
        }
    }
}


