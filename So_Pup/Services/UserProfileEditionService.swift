import Foundation
import FirebaseAuth

// MARK: - User Profile Edition Service
// Handles API requests for updating user and dog profiles
// Aligns with the backend /profile controller endpoints
class UserProfileEditionService {
    static let shared = UserProfileEditionService()
    private let baseURL = "https://api-2z4snw37ba-uc.a.run.app/profile"
    
    private init() {}
    
    // MARK: - User Profile Updates
    
    /// Update user profile (name, bio, location, etc.)
    /// Endpoint: PUT /profile/user/:userId
    func updateUserProfile(
        userId: String,
        name: String? = nil,
        bio: String? = nil,
        location: String? = nil,
        coordinate: Coordinate? = nil,
        language: String? = nil,
        imageURL: String? = nil
    ) async throws -> UserModel {
        guard let user = Auth.auth().currentUser else {
            throw ProfileEditionError.notAuthenticated
        }
        
        let token = try await user.getIDToken()
        let url = URL(string: "\(baseURL)/user/\(userId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare request body
        var requestBody: [String: Any] = [:]
        if let name = name { requestBody["name"] = name }
        if let bio = bio { requestBody["bio"] = bio }
        if let location = location { requestBody["location"] = location }
        if let coordinate = coordinate { requestBody["coordinate"] = coordinate }
        if let language = language { requestBody["language"] = language }
        if let imageURL = imageURL { requestBody["imageURL"] = imageURL }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProfileEditionError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(UserProfileUpdateResponse.self, from: data)
            return response.user
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw ProfileEditionError.apiError(errorResponse?.error ?? "Unknown error")
        }
    }
    
    // MARK: - Dog Profile Updates
    
    /// Update dog basic profile (name, dob, breed, weight, etc.)
    /// Endpoint: PUT /profile/dog/:dogId/basic
    func updateDogBasicProfile(
        dogId: String,
        name: String? = nil,
        dob: Date? = nil,
        breed: String? = nil,
        weight: Double? = nil,
        gender: DogGenderOption? = nil,
        size: SizeOption? = nil,
        bio: String? = nil,
        coordinate: Coordinate? = nil
    ) async throws -> DogModel {
        guard let user = Auth.auth().currentUser else {
            throw ProfileEditionError.notAuthenticated
        }
        
        let token = try await user.getIDToken()
        let url = URL(string: "\(baseURL)/dog/\(dogId)/basic")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare request body
        var requestBody: [String: Any] = [:]
        if let name = name { requestBody["name"] = name }
        if let dob = dob { requestBody["dob"] = ISO8601DateFormatter().string(from: dob) }
        if let breed = breed { requestBody["breed"] = breed }
        if let weight = weight { requestBody["weight"] = weight }
        if let gender = gender { requestBody["gender"] = gender.rawValue }
        if let size = size { requestBody["size"] = size.rawValue }
        if let bio = bio { requestBody["bio"] = bio }
        if let coordinate = coordinate { requestBody["coordinate"] = coordinate }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProfileEditionError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(DogProfileUpdateResponse.self, from: data)
            return response.dog
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw ProfileEditionError.apiError(errorResponse?.error ?? "Unknown error")
        }
    }
    
    /// Update dog behavior profile (behavior, neutered status only)
    /// Endpoint: PUT /profile/dog/:dogId/behavior
    /// Note: For health status updates, use updateFleaTreatmentDate() or updateWormingTreatmentDate()
    func updateDogBehaviorProfile(
        dogId: String,
        isNeutered: Bool? = nil,
        behavior: DogBehavior? = nil
    ) async throws -> DogModel {
        guard let user = Auth.auth().currentUser else {
            throw ProfileEditionError.notAuthenticated
        }
        
        let token = try await user.getIDToken()
        let url = URL(string: "\(baseURL)/dog/\(dogId)/behavior")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare request body
        var requestBody: [String: Any] = [:]
        
        if let isNeutered = isNeutered {
            requestBody["isNeutered"] = isNeutered
        }
        
        if let behavior = behavior {
            // Convert behavior to dictionary (same as DogModeService)
            let encoder = JSONEncoder()
            let behaviorData = try encoder.encode(behavior)
            if let behaviorDict = try JSONSerialization.jsonObject(with: behaviorData) as? [String: Any] {
                requestBody["behavior"] = behaviorDict
            }
        }
        
        // Encode the body as JSON
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        print("📦 Behavior Profile Update Request:", requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProfileEditionError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(DogBehaviorUpdateResponse.self, from: data)
            return response.dog
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw ProfileEditionError.apiError(errorResponse?.error ?? "Unknown error")
        }
    }
    
    /// Update dog images
    /// Endpoint: PUT /profile/dog/:dogId/images
    func updateDogImages(
        dogId: String,
        imageURLs: [String]
    ) async throws -> DogModel {
        guard let user = Auth.auth().currentUser else {
            throw ProfileEditionError.notAuthenticated
        }
        
        let token = try await user.getIDToken()
        let url = URL(string: "\(baseURL)/dog/\(dogId)/images")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "imageURLs": imageURLs
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProfileEditionError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(DogImagesUpdateResponse.self, from: data)
            return response.dog
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw ProfileEditionError.apiError(errorResponse?.error ?? "Unknown error")
        }
    }
    
    // MARK: - Convenience Methods for Health Status
    
    /// Update flea treatment date only
    func updateFleaTreatmentDate(dogId: String, date: Date) async throws -> DogModel {
        guard let user = Auth.auth().currentUser else {
            throw ProfileEditionError.notAuthenticated
        }
        
        let token = try await user.getIDToken()
        let url = URL(string: "\(baseURL)/dog/\(dogId)/behavior")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Send only the specific field we're updating (following DogModeService pattern)
        let requestBody: [String: Any] = [
            "fleaTreatmentDate": ISO8601DateFormatter().string(from: date)
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        print("📦 Flea Treatment Update Request:", requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProfileEditionError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(DogBehaviorUpdateResponse.self, from: data)
            return response.dog
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw ProfileEditionError.apiError(errorResponse?.error ?? "Unknown error")
        }
    }
    
    /// Update worming treatment date only
    func updateWormingTreatmentDate(dogId: String, date: Date) async throws -> DogModel {
        guard let user = Auth.auth().currentUser else {
            throw ProfileEditionError.notAuthenticated
        }
        
        let token = try await user.getIDToken()
        let url = URL(string: "\(baseURL)/dog/\(dogId)/behavior")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Send only the specific field we're updating (following DogModeService pattern)
        let requestBody: [String: Any] = [
            "wormingTreatmentDate": ISO8601DateFormatter().string(from: date)
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        print("📦 Worming Treatment Update Request:", requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProfileEditionError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(DogBehaviorUpdateResponse.self, from: data)
            return response.dog
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw ProfileEditionError.apiError(errorResponse?.error ?? "Unknown error")
        }
    }
}



// MARK: - Response Models

struct UserProfileUpdateResponse: Codable {
    let message: String
    let user: UserModel
}

struct DogProfileUpdateResponse: Codable {
    let message: String
    let dog: DogModel
}

struct DogBehaviorUpdateResponse: Codable {
    let message: String
    let dog: DogModel
}

struct DogImagesUpdateResponse: Codable {
    let message: String
    let dog: DogModel
}

// MARK: - Errors
enum ProfileEditionError: Error, LocalizedError {
    case notAuthenticated
    case invalidResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User not authenticated"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return message
        }
    }
}


