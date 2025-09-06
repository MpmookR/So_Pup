/// -------------------
/// User & dog onboarding:
/// - Captures profile fields, location, images, and behaviour tags
/// - Determines mode (puppy/social) from DOB and parses input enums
/// - Uploads media to Firebase Storage and persists User/Dog to Firestore in a transaction
/// - Generates geohash from coordinates for geo-queries
/// - Retrieves FCM token for push notifications
///
/// Key collaborators:
/// - `LocationService` (fetches coordinate/city)
/// - `FirebaseMediaService` (uploads profile/dog images)
/// - `PushManager` (gets FCM token)
/// - Firebase `Auth`/`Firestore` (UID, writes via transaction)
/// - `GFUtils` (geohash)
///
/// Public state is exposed via `@Published` for SwiftUI to react to changes.
/// -------------------

import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import CoreLocation
import GeoFire
import GeoFireUtils
import FirebaseMessaging

///https://firebase.google.com/docs/storage/ios/start?
@MainActor
class OnboardingViewModel: ObservableObject {
    // User
    @Published var name = ""
    @Published var gender = ""
    @Published var profilePicture: UIImage?
    @Published var bio = ""
    @Published var languages: [String] = []
    
    @Published var location = ""
    @Published var userCoordinate: CLLocationCoordinate2D?
    @Published var locationErrorMessage: String?
    @Published var locationPermissionDenied: Bool = false
    @Published var pushToken: String? = nil
    
    // Dog
    @Published var dogName = ""
    @Published var dogGender = ""
    @Published var dogSize = ""
    @Published var dogBreed = ""
    @Published var mixedBreed = ""
    @Published var dogDOB = Date()
    @Published var dogIsNeutered: Bool?
    @Published var dogImages: [UIImage] = [] // up to 5
    
    // dog behaviour
    @Published var selectedPlayStyles: Set<String> = []
    @Published var selectedPlayEnvironments: Set<String> = []
    @Published var selectedTriggerSensitivities: Set<String> = []
    
    @Published var customPlayStyle: String?
    @Published var customPlayEnvironment: String?
    @Published var customTriggerSensitivity: String?
    
    @Published var dogWeight: Double = 0
    @Published var dogWeightString: String = "" {
        /// didSet runs immediately after a property’s value changes
        /// it wont run during initialization, only when new value assigned
        didSet {
            let sanitized = dogWeightString.replacingOccurrences(of: ",", with: ".")
            dogWeight = Double(sanitized) ?? 0
        }
    }
    
    init() {
        dogWeightString = dogWeight == 0 ? "" : String(format: "%.2f", dogWeight)
    }
    
    // building HealthStatus
    @Published var fleaTreatmentDate: Date?
    @Published var wormingTreatmentDate: Date?
    @Published var coreVaccination1Date: Date?
    @Published var coreVaccination2Date: Date?
    
    @Published var mode = "puppy"
    @Published var status = "incomplete"
    
    // check mode based on dog DOB
    func determineMode() {
        let age = Calendar.current.dateComponents([.weekOfYear], from: dogDOB, to: Date()).weekOfYear ?? 0
        mode = age < 12 ? "puppy" : "social"
    }
    
    // fetch user location
    func fetchUserLocation() async {
        let service = LocationService()
        
        do {
            // Attempt to fetch coordinate and city from CoreLocation
            let result = try await service.requestLocation()
            
            // Store successful location and clear previous errors
            self.userCoordinate = result.coordinate
            self.location = result.city ?? "Unknown"
            self.locationPermissionDenied = false
            self.locationErrorMessage = nil
            print("📍 Location fetched: \(result.coordinate), City: \(result.city ?? "-")")
            
        } catch LocationService.LocationError.permissionDenied {
            // User explicitly denied location access
            self.userCoordinate = nil
            self.location = "Unknown"
            self.locationPermissionDenied = true
            self.locationErrorMessage = "You’ve denied location access. This means matching and visibility based on your location won’t work properly."
            
        } catch {
            // Other failure (e.g., system error, timeout)
            self.userCoordinate = nil
            self.location = "Unknown"
            self.locationPermissionDenied = true
            self.locationErrorMessage = "Unable to retrieve your location."
            print("❌ Location error: \(error.localizedDescription)")
        }
    }
    
    func saveToFirebase() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        do {
            // MARK: - Parse enums and conditionals
            let parsedGender = DogGenderOption(rawValue: dogGender) ?? .male
            let parsedSize = SizeOption(rawValue: dogSize) ?? .medium
            let parsedMode = DogMode(rawValue: mode) ?? .puppy
            let parsedStatus = DogProfileStatus(rawValue: status) ?? .incomplete
            let neutered = parsedMode == .social ? dogIsNeutered : nil
            let healthData = parsedMode == .social ? HealthStatus(fleaTreatmentDate: nil, wormingTreatmentDate: nil) : nil
            let core1 = parsedMode == .puppy ? coreVaccination1Date : nil
            let core2 = parsedMode == .puppy ? coreVaccination2Date : nil
            let finalBreed = mixedBreed.isEmpty ? dogBreed : mixedBreed
            
            // MARK: - Upload profile picture (if any)
            let profilePictureURL: String? = profilePicture != nil
            ? try await FirebaseMediaService.shared.uploadImage( profilePicture, path: "users/\(uid)/profile.jpg"): nil
            
            
            // MARK: - Upload only 1 dog image during onboarding
            let dogImageURLs = try await FirebaseMediaService.shared.uploadImages(
                dogImages,
                pathPrefix: "dogs/\(uid)/",
                limit: 1 // Only 1 image during onboarding
            )
            
            print("✅ Uploaded profile and dog image(s)")
            
            // MARK: - Prepare DogBehavior if in social mode
            let behaviorData: DogBehavior? = parsedMode == .social ? DogBehavior(
                playStyles: Array(selectedPlayStyles),
                preferredPlayEnvironments: Array(selectedPlayEnvironments),
                triggersAndSensitivities: Array(selectedTriggerSensitivities),
                customPlayStyle: customPlayStyle,
                customPlayEnvironment: customPlayEnvironment,
                customTriggerSensitivity: customTriggerSensitivity
            ) : nil
            
            // MARK: - Prepare coordinate data
            let lat = userCoordinate?.latitude ?? 0
            let lng = userCoordinate?.longitude ?? 0
            let geoHash = GFUtils.geoHash(forLocation: CLLocationCoordinate2D(latitude: lat, longitude: lng))

            let coordinate = Coordinate(
                latitude: lat,
                longitude: lng,
                geohash: geoHash 
            )
            
            let dogId = try await getOrCreateDogId(for: uid, db: db)
            let dogRef = db.collection("dogs").document(dogId)
            let userRef = db.collection("users").document(uid)
            
            // MARK: - Create dog model
            let dog = DogModel(
                id: dogId,
                ownerId: uid,
                name: dogName,
                gender: parsedGender,
                size: parsedSize,
                weight: dogWeight,
                breed: finalBreed,
                dob: dogDOB,
                isNeutered: neutered,
                behavior: behaviorData,
                healthStatus: healthData,
                coreVaccination1Date: core1,
                coreVaccination2Date: core2,
                mode: parsedMode,
                status: parsedStatus,
                imageURLs: dogImageURLs,
                coordinate: coordinate,
                isMock: false
            )
            
            self.pushToken = await PushManager.shared.getFCMToken()

            // MARK: - Create user model
            let user = UserModel(
                id: uid,
                name: name,
                gender: UserGenderOption(rawValue: gender) ?? .other,
                profilePictureURL: profilePictureURL ?? "",
                location: location,
                coordinate: coordinate,
                locationPermissionDenied: userCoordinate == nil,
                bio: bio,
                languages: languages,
                customLanguage: nil,
                primaryDogId: dogId,
                isMock: false,
                pushToken: pushToken
            )
            
            
            // MARK: - Save both model in a transaction
            _ = try await db.runTransaction({ transaction, errorPointer in
                do {
                    try transaction.setData(from: dog, forDocument: dogRef)
                    try transaction.setData(from: user, forDocument: userRef)
                    print("✅ Transaction: user + dog written")
                    return nil
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            })
        }
    }
}

// It prevents from accidentally creating a new dog every time the user updates their profile. That would cause duplicates.
private func getOrCreateDogId(for uid: String, db: Firestore) async throws -> String {
    let snapshot = try await db.collection("dogs")
        .whereField("ownerId", isEqualTo: uid)
        .getDocuments()
    
    if let existing = snapshot.documents.first {
        print("⚠️ Existing dog found")
        return existing.documentID
    } else {
        print("✅ No existing dog, creating new one")
        return db.collection("dogs").document().documentID
    }
}
