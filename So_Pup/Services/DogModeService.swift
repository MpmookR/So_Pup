import Foundation
import FirebaseAuth

// A singleton service to handle dog-related API calls.
final class DogModeService {
    static let shared = DogModeService()
    private init() {}
    
    private let baseURL = "https://api-2z4snw37ba-uc.a.run.app/dogs"
    
    // MARK: - Update Vaccination Dates
    func updateVaccinations(
        dogId: String,
        coreVaccination1Date: Date? = nil,
        coreVaccination2Date: Date? = nil,
        authToken: String
    ) async throws -> VaccinationUpdateResponse {
        guard let url = URL(string: "\(baseURL)/\(dogId)/vaccinations") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        // Prepare vaccination data using dictionary encoding (following MatchRequestService pattern)
        var body: [String: Any] = [:]
        
        if let vaccination1Date = coreVaccination1Date {
            body["coreVaccination1Date"] = ISO8601DateFormatter().string(from: vaccination1Date)
        }
        
        if let vaccination2Date = coreVaccination2Date {
            body["coreVaccination2Date"] = ISO8601DateFormatter().string(from: vaccination2Date)
        }
        
        // Encode the body as JSON
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("📦 Request:", body)
        
        // Send the HTTP request and wait for the response
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate the HTTP response
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let responseData = try decoder.decode(VaccinationUpdateResponse.self, from: data)
        print("✅ Vaccination update successful, ready to switch: \(responseData.readyToSwitchMode)")
        return responseData
    }
    
    // MARK: - Manual Mode Switch
    func switchDogMode(dogId: String, mode: DogMode, authToken: String) async throws -> DogModel {
        guard let url = URL(string: "\(baseURL)/\(dogId)/modeSwitch") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["mode": mode.rawValue]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("📦 Request:", body)
        
        // Send the HTTP request and wait for the response
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate the HTTP response
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let responseData = try decoder.decode(ModeSwitchResponse.self, from: data)
        print("✅ Mode switch successful: \(responseData.message)")
        return responseData.dog
    }
    
    // MARK: - Update Social Dog Data (Behavior/Neutered Status)
    func updateSocialDogData(
        dogId: String,
        isNeutered: Bool? = nil,
        behavior: DogBehavior? = nil,
        authToken: String
    ) async throws -> DogModel {
        guard let url = URL(string: "\(baseURL)/\(dogId)/behavior") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        // Prepare request body using dictionary (following the backend structure)
        var body: [String: Any] = [:]
        
        if let isNeutered = isNeutered {
            body["isNeutered"] = isNeutered
        }
        
        if let behavior = behavior {
            // Convert behavior to dictionary
            let encoder = JSONEncoder()
            let behaviorData = try encoder.encode(behavior)
            if let behaviorDict = try JSONSerialization.jsonObject(with: behaviorData) as? [String: Any] {
                body["behavior"] = behaviorDict
            }
        }
        
        // Encode the body as JSON
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("📦 Social Dog Data Update Request:", body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Parse the response which contains message and dog
        let responseData = try decoder.decode(SocialDataUpdateResponse.self, from: data)
        print("✅ Social dog data update successful: \(responseData.message)")
        return responseData.dog
    }

}

// MARK: - Response Models
struct VaccinationUpdateResponse: Codable {
    let message: String
    let dog: DogModel
    let readyToSwitchMode: Bool
    let canSwitchToSocial: Bool
}

struct ModeSwitchResponse: Codable {
    let message: String
    let dog: DogModel
}

struct SocialDataUpdateResponse: Codable {
    let message: String
    let dog: DogModel
}

struct ErrorResponse: Codable {
    let error: String
}
