import Foundation

protocol DogProfile {
    // common for all dogs
    var id: String { get }
    var name: String { get }
    var gender: DogGenderOption { get }
    var size: SizeOption { get }
    var weight: Double { get }
    var breed: String { get }
    var dob: Date { get }
    var mode: DogMode { get }
    var status: DogProfileStatus { get }
    var imageURLs: [String] { get }
    var bio: String? { get }
    var isMock: Bool? { get }
}


protocol PuppyProfile {
    // Puppy specific
    var coreVaccination1Date: Date? { get }
    var coreVaccination2Date: Date? { get }
}

protocol SocialDogProfile {
    // Social specific
    var isNeutered: Bool? { get }
    var behavior: DogBehavior? { get }
    var healthStatus: HealthStatus? { get }
}



