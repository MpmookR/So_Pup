
//Identifiable
///Makes each enum case uniquely identifiable

//CaseIterable
///Allows enumName.allCases to return all cases
enum DogMode: String, CaseIterable, Identifiable, Codable {
    case puppy     // For dogs under 12 weeks
    case social    // For dogs 12 weeks and older

    var id: String { rawValue }
}

enum DogProfileStatus: String, CaseIterable, Identifiable, Codable {
    case incomplete   // Missing required info or treatments
    case ready        // All info filled and verified

    var id: String { rawValue }
}


enum UserGenderOption: String, CaseIterable, Identifiable, Codable{
    case female = "female"
    case male = "male"
    case other = "other"
    case preferNotToSay = "prefer not to say"

    var id: String { rawValue } //Uses the case’s string value as the unique ID
}


enum DogGenderOption: String, Codable, CaseIterable, Identifiable {
    case male
    case female
    
    var id: String { rawValue }
}

let languageOptions: [String] = [
    // Western Europe
    "English", "French", "Spanish", "Italian", "German", "Dutch", "Portuguese",
    "Greek", "Swedish", "Finnish", "Norwegian", "Danish",

    // Eastern Europe
    "Polish", "Czech", "Slovak", "Hungarian", "Romanian", "Bulgarian",
    "Ukrainian", "Russian", "Serbian", "Croatian", "Slovenian",
    "Lithuanian", "Latvian", "Estonian",

    // Asia
    "Chinese", "Japanese", "Korean", "Hindi", "Thai", "Vietnamese",
    "Indonesian", "Malay", "Filipino", "Bengali", "Tamil", "Urdu",
    "Turkish", "Farsi",
]

enum SizeOption: String, CaseIterable, Identifiable, Codable {
    case extraSmall = "Extra Small"
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"

    var id: String { rawValue }
}


enum HealthVerificationStatus: String, CaseIterable, Codable {
    case verified // if flea treament and worming Treatment is up to date
    case unverified
    
    var id: String { rawValue }
}

//let support custom tagging while enum becomes restrictive.
let playStyleOptions: [String] = [
    "Chaser",              // Enjoys chasing or being chased
    "Wrestler",            // Likes rough-and-tumble body play
    "Tugger",              // Loves tug-of-war games
    "Mouthy",              // Uses gentle mouthing during play
    "Gentle Player",       // Calm and soft play style
    "Independent",         // Plays alone or prefers minimal interaction
    "Ball-focused",        // Obsessed with fetching or holding balls
    "Social Butterfly",    // Engages play with all dogs/humans
    "Selective Player",    // Only plays with familiar dogs
    "Overexcited",         // Becomes overly energetic or hyper quickly
    "Explorer",            // More interested in sniffing or roaming
    "Observer",            // Watches other dogs play but rarely joins in
]

let playEnvironmentOptions: [String] = [
    "Open Fields",
    "Enclosed Parks",
    "Home Garden",
    "Daycare",
    "Indoor",
    "Flexible",           
]

let triggerSensitivityOptions: [String] = [
    "Loud noises",
    "Sudden movements",
    "Cats",
    "Vehicle",
    "Wheelchairs",
    "Vacuum cleaners",
    "Strangers",
]


// MARK: - not in firestore yet

enum PreferredAgeOption: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case puppyAge = "12w – 1y"
    case teenageAge = "1y – 3y"
    case adultAge = "3y+"
    case any = "Any"

    var ageRange: ClosedRange<Double>? {
        switch self {
        case .puppyAge: return 0.23...1
        case .teenageAge: return 1...3
        case .adultAge: return 3...20
        case .any: return nil
        }
    }
}




