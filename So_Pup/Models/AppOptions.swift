import Foundation

// hold Options model matching the Firestore structure

struct AppOptions: Codable {
    var UserGenderOption: [String]
    var playEnvironmentOptions: [String]
    var DogMode: [String]
    var playStyleOptions: [String]
    var languageOptions: [String]
    var DogProfileStatus: [String]
    var DogGenderOption: [String]
    var HealthVerificationStatus: [String]
    var SizeOption: [String]
    var triggerSensitivityOptions: [String]
    
//    var dogBreeds: [String] = []  // Will be injected post-fetch
}

// Used at runtime to populate: Pickers, Multi-select views, Dynamic form choices
// This struct exists only for loading the available choices, not for storing user data.
