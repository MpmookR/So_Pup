import Foundation
import FirebaseAuth

// MARK: - User Profile Edition Service
// Handles API requests for updating user and dog profiles
// Aligns with the backend /profile controller endpoints
final class UserProfileEditionService {
    static let shared = UserProfileEditionService()
    private let baseURL = "https://api-2z4snw37ba-uc.a.run.app/profile"
    private init() {}

    // Shared formatters
    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    // MARK: - User Profile Updates

    /// Update user profile (name, bio, location, etc.)
    /// Endpoint: PUT /profile/user/:userId
    // Replace your existing updateUserProfile(...) with this version
    func updateUserProfile(
        userId: String,
        name: String? = nil,
        bio: String? = nil,
        location: String? = nil,
        coordinate: Coordinate? = nil,
        languages: [String]? = nil,     
        customLanguage: String? = nil,
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

        // Declare requestBody, then fill it
        var requestBody: [String: Any] = [:]
        if let name = name { requestBody["name"] = name }
        if let bio = bio { requestBody["bio"] = bio }
        if let location = location { requestBody["location"] = location }
        if let coordinate = coordinate { requestBody["coordinate"] = coordinate.asJSON }
        if let languages = languages { requestBody["languages"] = languages }
        if let customLanguage = customLanguage { requestBody["customLanguage"] = customLanguage }
        if let imageURL = imageURL { requestBody["imageURL"] = imageURL }

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProfileEditionError.invalidResponse
        }

        if (200..<300).contains(httpResponse.statusCode) {
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
        var body: [String: Any] = [:]
        if let name { body["name"] = name }
        if let dob { body["dob"] = Self.iso.string(from: dob) }
        if let breed { body["breed"] = breed }
        if let weight { body["weight"] = weight }
        if let gender { body["gender"] = gender.rawValue }
        if let size { body["size"] = size.rawValue }
        if let bio { body["bio"] = bio }
        if let coordinate { body["coordinate"] = coordinate.asJSON } 

        let data = try await send(
            path: "/dog/\(dogId)/basic",
            method: "PUT",
            jsonBody: body
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DogProfileUpdateResponse.self, from: data).dog
    }

    /// Update dog behavior profile (behavior, neutered status only)
    /// Endpoint: PUT /profile/dog/:dogId/behavior
    func updateDogBehaviorProfile(
        dogId: String,
        isNeutered: Bool? = nil,
        behavior: DogBehavior? = nil
    ) async throws -> DogModel {
        var body: [String: Any] = [:]
        if let isNeutered { body["isNeutered"] = isNeutered }
        if let behavior {
            let enc = JSONEncoder()
            enc.dateEncodingStrategy = .iso8601
            let behaviorData = try enc.encode(behavior)
            if let dict = try JSONSerialization.jsonObject(with: behaviorData) as? [String: Any] {
                body["behavior"] = dict
            }
        }

        let data = try await send(
            path: "/dog/\(dogId)/behavior",
            method: "PUT",
            jsonBody: body
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DogBehaviorUpdateResponse.self, from: data).dog
    }

    /// Update dog images
    /// Endpoint: PUT /profile/dog/:dogId/images
    func updateDogImages(dogId: String, imageURLs: [String]) async throws -> DogModel {
        let data = try await send(
            path: "/dog/\(dogId)/images",
            method: "PUT",
            jsonBody: ["imageURLs": imageURLs]
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DogImagesUpdateResponse.self, from: data).dog
    }

    // MARK: - Convenience Health Methods

    func updateFleaTreatmentDate(dogId: String, date: Date) async throws -> DogModel {
        let data = try await send(
            path: "/dog/\(dogId)/behavior",
            method: "PUT",
            jsonBody: ["fleaTreatmentDate": Self.iso.string(from: date)]
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DogBehaviorUpdateResponse.self, from: data).dog
    }

    func updateWormingTreatmentDate(dogId: String, date: Date) async throws -> DogModel {
        let data = try await send(
            path: "/dog/\(dogId)/behavior",
            method: "PUT",
            jsonBody: ["wormingTreatmentDate": Self.iso.string(from: date)]
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DogBehaviorUpdateResponse.self, from: data).dog
    }

    // MARK: - Core request helper

    private func send(path: String, method: String, jsonBody: [String: Any]) async throws -> Data {
        guard let user = Auth.auth().currentUser else { throw ProfileEditionError.notAuthenticated }
        let token = try await user.getIDToken()

        guard let url = URL(string: baseURL + path) else { throw ProfileEditionError.invalidResponse }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.cachePolicy = .reloadIgnoringLocalCacheData
        req.timeoutInterval = 30
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw ProfileEditionError.invalidResponse }

        // Accept 200..299 as success
        guard (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ProfileEditionError.apiError("HTTP \(http.statusCode): \(msg)")
        }
        return data
    }
}

// MARK: - Helpers

extension Coordinate {
    var asJSON: [String: Any] { ["latitude": latitude, "longitude": longitude] }
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
        case .notAuthenticated: return "User not authenticated"
        case .invalidResponse:  return "Invalid response from server"
        case .apiError(let m):  return m
        }
    }
}
