import Foundation

struct DogModel: Identifiable, Codable, Hashable, DogProfile, PuppyProfile, SocialDogProfile {
    var id: String = UUID().uuidString
    
    var ownerId: String
    
    var name: String
    var gender: DogGenderOption
    var size: SizeOption
    var weight: Double
    var breed: String
    var dob: Date
    var isNeutered: Bool?
    
    // social > 12
    var behavior: DogBehavior?
    var healthStatus: HealthStatus? //verified or unverified
    
    // Puppy: dogs under 12 weeks
    var coreVaccination1Date: Date?
    var coreVaccination2Date: Date?
    
    var mode: DogMode
    var status: DogProfileStatus //incomplete , ready for social mode
    var imageURLs: [String] // max 5, stored in Firebase Storage
    
    var bio: String?
    
    var coordinate: Coordinate // Copy coordinate from user
    
    var isMock: Bool?
}

/// Equatable allows values of a type to be compared using == or !=
struct HealthStatus : Codable, Equatable, Hashable{
    var fleaTreatmentDate: Date?
    var wormingTreatmentDate: Date?
}

extension DogModel {
    var healthVerificationStatus: HealthVerificationStatus {
        guard let health = healthStatus else { return .unverified }
        if health.fleaTreatmentDate != nil || health.wormingTreatmentDate != nil {
            return .verified
        }
        return .unverified
    }
    
    var ageInWeeks: Int {
        Calendar.current.dateComponents([.weekOfYear], from: dob, to: Date()).weekOfYear ?? 0
    }
    
    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: dob, to: Date()).month ?? 0
    }
    
    var ageInYears: Int {
        Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
    }
    
    var ageText: String {
        if ageInWeeks < 12 {
            return "\(ageInWeeks) weeks"
        } else if ageInYears < 1 {
            return "\(ageInMonths) months"
        } else {
            return "\(ageInYears) years"
        }
    }
    
    var displayName: String {
            mode == .puppy ? "Puppy \(name)" : name
        }
}
