import SwiftUI
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class MatchingViewModel: ObservableObject {
    
    @Published var matchedProfiles: [MatchProfile] = []
    @Published var userCoordinate: CLLocationCoordinate2D? // for user distance calculation
    @Published var filterSettings: DogFilterSettings = DogFilterSettings()
    
    private let locationService = LocationService()
    private let profileDataService = ProfileDataService()
    
    private let db = Firestore.firestore()
    
    // fetched profile from firestore
    private var allDogs: [DogModel] = []
    private var allUsers: [UserModel] = []
    
    var currentDog: DogModel? {
        allDogs.first { $0.ownerId == Auth.auth().currentUser?.uid }
    }

    var candidateDogIds: [String] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        return allDogs.filter { $0.ownerId != userId }.map { $0.id }
    }

    func initialize(with filter: DogFilterSettings) async {
        self.filterSettings = filter // store the filter setting in swiftData
        await fetchLocation() // get the user location
        await fetchData() // load from firestore
        await applyScoring(using: filter)  // Score and filter matches based on the filter
    }
    
    // Load location and data, then compute matches
    func load() async {
        await fetchLocation()
        await fetchData()
        await applyScoring(using: DogFilterSettings())
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
            allDogs = try await profileDataService.fetchAllDogs()
            print("Dogs fetched: \(allDogs.count)")
            
            allUsers = try await profileDataService.fetchAllUsers()
            print("Users fetched: \(allUsers.count)")
            
        } catch {
            print("❌ Failed to fetch profile data: \(error)")
            allDogs = []
            allUsers = []
        }
    }
    
    
    // builds MatchScoringDTO and sends to API
    func applyScoring(using filter: DogFilterSettings) async {
        guard let currentDog, let userLoc = userCoordinate else {
            matchedProfiles = []
            
            if currentDog == nil {
                print("❌ No dog found for current user")
            }
            if userCoordinate == nil {
                print("❌ User coordinate is nil")
            }
            return
        }

        do {
            let scored = try await MatchScoringService.shared.sendScoringRequest(
                currentDog: currentDog,
                candidateDogIds: candidateDogIds,
                userLocation: Coordinate(from: userLoc),
                filters: filter
            )

            updateScoredMatches(scored)
        } catch {
            print("❌ Failed to load scoring matches: \(error)")
            matchedProfiles = []
        }
    }

    
    // maps ScoredDog to MatchProfile, including distance
    func updateScoredMatches(_ scoredDogs: [ScoredDog]) {
        guard let userLoc = userCoordinate else {
            matchedProfiles = []
            return
        }
        
        matchedProfiles = scoredDogs.compactMap { scored in
            guard let owner = allUsers.first(where: { $0.id == scored.dog.ownerId }) else {
                return nil
            }
            
            let distance = calculateDistance(from: userLoc, to: owner.coordinate)
            
            return MatchProfile(dog: scored.dog, owner: owner, distanceInMeters: distance)
        }
    }
    
    
    // Calculate distance in meters between current user and another coordinate
    /// CLLocation.distance(from:) Returns the distance (in meters) from the receiver to the specified location.
    private func calculateDistance(from user: CLLocationCoordinate2D, to coordinate: Coordinate) -> CLLocationDistance {
        let userLoc = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let ownerLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return userLoc.distance(from: ownerLoc)
    }
}

