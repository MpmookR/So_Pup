import CoreLocation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class MatchingViewModel: ObservableObject {

    // MARK: - Injected dependencies
    private let matchRequestVM: MatchRequestViewModel

    // MARK: - Published state
    @Published var matchedProfiles: [MatchProfile] = []
    @Published var userCoordinate: CLLocationCoordinate2D?  // viewer location
    @Published var filterSettings: DogFilterSettings = .init()
    @Published var isLoading: Bool = false
    @Published var hasLoadedOnce: Bool = false

    // MARK: - Services
    private let locationService = LocationService()
    private let profileDataService = ProfileDataService()
    private let db = Firestore.firestore()

    // MARK: - Cached data
    private var allDogs: [DogModel] = []
    private var allUsers: [UserModel] = []

    // MARK: - Init
    init(matchRequestVM: MatchRequestViewModel) {
        self.matchRequestVM = matchRequestVM
    }

    // MARK: - Derived
    var currentDog: DogModel? {
        allDogs.first { $0.ownerId == Auth.auth().currentUser?.uid }
    }

    var candidateDogIds: [String] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        return allDogs.filter { $0.ownerId != uid }.map { $0.id }
    }

    // MARK: - Public API
    func initialize(with filter: DogFilterSettings) async {
        await runLoadingBlock {
            self.filterSettings = filter
            await fetchLocation()
            await fetchData()
            await applyScoring(using: filter)
        }
    }

    func load() async {
        await runLoadingBlock {
            await fetchLocation()
            await fetchData()
            await applyScoring(using: DogFilterSettings())
        }
    }

    // MARK: - Internals
    private func fetchLocation() async {
        do {
            let (coordinate, _) = try await locationService.requestLocation()
            userCoordinate = coordinate
        } catch {
            print("❌ Location error: \(error)")
            userCoordinate = nil
        }
    }

    private func fetchData() async {
        do {
            allDogs = try await profileDataService.fetchAllDogs()
            allUsers = try await profileDataService.fetchAllUsers()
            print("✅ Dogs fetched: \(allDogs.count), Users fetched: \(allUsers.count)")
        } catch {
            print("❌ Failed to fetch profile data: \(error)")
            allDogs = []
            allUsers = []
        }
    }

    /// Builds MatchScoringDTO and calls backend
    func applyScoring(using filter: DogFilterSettings) async {
        guard let currentDog, let userLoc = userCoordinate else {
            matchedProfiles = []
            if currentDog == nil { print("❌ No dog for current user") }
            if userCoordinate == nil { print("❌ userCoordinate is nil") }
            return
        }

        // Collect exclusions from MatchRequestViewModel (pending + requested)
        let excludedDogIds =
            matchRequestVM.pendingCards.map { $0.dog.id } +
            matchRequestVM.requestedCards.map { $0.dog.id }

        do {
            let scored = try await MatchScoringService.shared.sendScoringRequest(
                currentDog: currentDog,
                candidateDogIds: candidateDogIds,
                userLocation: Coordinate(from: userLoc),
                filters: filter,
                excludedDogIds: excludedDogIds
            )
            updateScoredMatches(scored)
        } catch {
            print("❌ Failed to load scoring matches: \(error)")
            matchedProfiles = []
        }
    }

    /// Maps ScoredDog -> MatchProfile (adds distance)
    func updateScoredMatches(_ scoredDogs: [ScoredDog]) {
        guard let userLoc = userCoordinate else { matchedProfiles = []; return }
        matchedProfiles = scoredDogs.compactMap { scored in
            guard let owner = allUsers.first(where: { $0.id == scored.dog.ownerId }) else { return nil }
            let distance = calculateDistance(from: userLoc, to: owner.coordinate)
            return MatchProfile(dog: scored.dog, owner: owner, distanceInMeters: distance)
        }
    }

    private func calculateDistance(from user: CLLocationCoordinate2D, to coordinate: Coordinate) -> CLLocationDistance {
        let a = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let b = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return a.distance(from: b)
    }

    private func runLoadingBlock(_ op: () async -> Void) async {
        isLoading = true
        defer { isLoading = false; hasLoadedOnce = true }
        await op()
    }
}
