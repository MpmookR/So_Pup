
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


enum UserGenderOption: String, CaseIterable, Identifiable {
    case woman = "woman/girl"
    case man = "man/boy"
    case preferNotToSay = "prefer not to say"
    case other = "other"

    var id: String { rawValue } //Uses the case’s string value as the unique ID
}


enum DogGenderOption: String, Codable, CaseIterable, Identifiable {
    case male
    case female
    case other
    
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

    // Other
    "Other"
]

enum SizeOption: String, CaseIterable, Identifiable, Codable {
    case extraSmall = "Extra Small"
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"

    var id: String { rawValue }
}


enum HealthVerificationStatus: String {
    case verified
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
    "Other"                // User-defined
]

let playEnvironmentOptions: [String] = [
    "Open Fields",         // Large open spaces where dogs can run freely
    "Enclosed Parks",      // Fenced parks for safe off-leash play
    "Home Garden",         // Private backyard or garden
    "Daycare",             // Supervised group setting
    "Indoor",              // Inside home or indoor facility
    "Flexible",            // Comfortable in any environment
    "Other"
]

let triggerSensitivityOptions: [String] = [
    "Loud noises",         // Fireworks, thunder, shouting
    "Sudden movements",    // Fast gestures, unpredictable motion
    "Cats",                // Reacts to cats
    "Bicycles",            // Chases or barks at bikes
    "Wheelchairs",         // May react to assistive devices
    "Vacuum cleaners",     // Loud appliances or cleaning tools
    "Strangers",           // Nervous around unknown people
    "Other"
]

//MARK: mock up data
let locationOptions: [String] = [
    "London", "Manchester", "Birmingham", "Liverpool", "Leeds",
    "Glasgow", "Bristol", "Edinburgh", "Cardiff", "Belfast",
    "Other"
]


