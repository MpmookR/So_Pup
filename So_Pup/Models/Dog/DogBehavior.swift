import Foundation

struct DogBehavior: Codable, Equatable, Hashable {
    // Selected from predefined options
    var playStyles: [String]
    var preferredPlayEnvironments: [String]
    var triggersAndSensitivities: [String]
    
    // custom values when "Other" is selected
    var customPlayStyle: String?                 
    var customPlayEnvironment: String?
    var customTriggerSensitivity: String?
}

extension DogBehavior {
    var tags: [String] {
        var result: [String] = []

        result.append(contentsOf: playStyles)
        result.append(contentsOf: preferredPlayEnvironments)
        result.append(contentsOf: triggersAndSensitivities)

        if let custom = customPlayStyle, !custom.isEmpty {
            result.append(custom)
        }
        if let custom = customPlayEnvironment, !custom.isEmpty {
            result.append(custom)
        }
        if let custom = customTriggerSensitivity, !custom.isEmpty {
            result.append(custom)
        }

        return result
    }
}

