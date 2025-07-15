import Foundation

struct DogModel: Identifiable, Codable{
    var id: String = UUID().uuidString
    var name: String
    var gender: DogGenderOption
    var size: SizeOption
    var weight: Double
    var breed: String
    var dob: Date
    var isNeutered: Bool?
    
    // for dogs >= 12 weeks
    var behavior: DogBehavior?
    var healthStatus: HealthStatus?
    
    // for < 12 weeks
    var coreVaccination1Date: Date?
    var coreVaccination2Date: Date?
    
    var mode: DogMode
    var status: DogProfileStatus
    var imageURLs: [String] // max 5, stored in Firebase Storage
    
    var bio: String?
    
    var isMock: Bool = false // for testing
}

/// Equatable allows values of a type to be compated using == or !=
struct HealthStatus : Codable, Equatable{
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
