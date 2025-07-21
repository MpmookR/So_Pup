import SwiftUI
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class MatchingViewModel: ObservableObject {
    
    @Published var matchedProfiles: [MatchProfile] = []
    @Published var userCoordinate: CLLocationCoordinate2D? // for user distance calculation
    
    private let locationService = LocationService()
    private let db = Firestore.firestore()
    
    // fetched profile from firestore
    private var allDogs: [DogModel] = []
    private var allUsers: [UserModel] = []
    
    // Load location and data, then compute matches
    func load() async {
        await fetchLocation()
        await fetchData()
        applyMatching()
    }
    
    private func fetchLocation() async {
        do {
            let (coordinate, _) = try await locationService.requestLocation()
            userCoordinate = coordinate
        } catch {
            print("Location error: \(error)")
        }
    }
    
    private func fetchData() async {
        do {
            let dogSnapshot = try await db.collection("dogs").getDocuments()
            allDogs = dogSnapshot.documents.compactMap { try? $0.data(as: DogModel.self) }
            print("Dogs fetched: \(allDogs.count)")
            
            let userSnapshot = try await db.collection("users").getDocuments()
            allUsers = userSnapshot.documents.compactMap { try? $0.data(as: UserModel.self) }
            print("Users fetched: \(allUsers.count)")
        } catch {
            print("❌ Failed to fetch data: \(error)")
        }
    }
    
    
    // Run matching again with custom filters
    func applyMatching(using filter: DogFilterSettings = .init()) {
        guard let userLoc = userCoordinate,
        let currentUserId = Auth.auth().currentUser?.uid // the singleton instance of Firebase Auth
        
        else {
            matchedProfiles = []
            return
        }
        // Build matched profiles by checking all dogs against filters
        matchedProfiles = allDogs.compactMap { dog -> MatchProfile? in
            guard let owner = allUsers.first(where: { $0.id == dog.ownerId }) else { return nil }

            // Skip if this dog belongs to the current user
            if owner.id == currentUserId {
                return nil
            }
            
            // Filter out if the dog doesn't match the criteria
            if !isMatch(dog, with: filter) {
                return nil
            }
            
            // Calculate distance between user and dog owner
            let dist = calculateDistance(from: userLoc, to: owner.coordinate)
            
            // filter by the max distance
            /// when maxDistanceInKm < 100 - no distance limit applies
            if filter.maxDistanceInKm < 100, dist > Double(filter.maxDistanceInKm) * 1000 {
                return nil
            }
            
            
            return MatchProfile(dog: dog, owner: owner, distanceInMeters: dist)
        }
        // Sort results by closest distance
        .sorted { ($0.distanceInMeters ?? 0) < ($1.distanceInMeters ?? 0) }
    }
    
    // match dog model with the filter > if the seleted filter doesn't match profile, the dog profile won't be included
    private func isMatch(_ dog: DogModel, with filter: DogFilterSettings) -> Bool {
        if let gender = filter.selectedGender, dog.gender != gender { return false }
        if !filter.selectedSizes.isEmpty, !filter.selectedSizes.contains(dog.size) { return false }
        if let status = filter.selectedHealthStatus, dog.healthVerificationStatus != status { return false }
        if let neutered = filter.neuteredOnly, dog.isNeutered != neutered { return false }
        
        if !filter.selectedPlayStyleTags.isEmpty {
            let dogTags = Set(dog.behavior?.playStyles ?? [])
            if filter.selectedPlayStyleTags.isDisjoint(with: dogTags) {
                return false
            }
        }
        
        if !filter.selectedEnvironmentTags.isEmpty {
            let dogTags = Set(dog.behavior?.preferredPlayEnvironments ?? [])
            if filter.selectedEnvironmentTags.isDisjoint(with: dogTags) {
                return false
            }
        }
        
        if !filter.selectedTriggerTags.isEmpty {
            let dogTags = Set(dog.behavior?.triggersAndSensitivities ?? [])
            if filter.selectedTriggerTags.isDisjoint(with: dogTags) {
                return false
            }
        }
        
        return true
    }
    
    
    // Calculate distance in meters between current user and another coordinate
    /// CLLocation.distance(from:) Returns the distance (in meters) from the receiver to the specified location.
    private func calculateDistance(from user: CLLocationCoordinate2D, to coordinate: Coordinate) -> CLLocationDistance {
        let userLoc = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let ownerLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return userLoc.distance(from: ownerLoc)
    }
}

