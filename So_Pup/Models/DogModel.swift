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
    var fleaTreatmentDate: Date?
    var wormingTreatmentDate: Date?
    
    // for < 12 weeks
    var coreVaccination1Date: Date?
    var coreVaccination2Date: Date?
    
    var mode: DogMode
    var status: DogProfileStatus
    var imageURLs: [String] // max 5, stored in Firebase Storage
}


