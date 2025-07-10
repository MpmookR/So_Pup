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
}
