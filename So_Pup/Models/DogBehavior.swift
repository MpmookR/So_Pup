import Foundation

struct DogBehavior: Codable {
    // Selected from predefined options
    var playStyles: [String]
    var preferredPlayEnvironments: [String]
    var triggersAndSensitivities: [String]
    
    // custom values when "Other" is selected
    var customPlayStyle: String?                 
    var customPlayEnvironment: String?
    var customTriggerSensitivity: String?
}



