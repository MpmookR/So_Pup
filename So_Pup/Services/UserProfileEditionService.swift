import Foundation
import FirebaseAuth

//
//  - Wrap all /profile endpoints for updating users & dogs
//  - Use unified JSONCoder (tolerant ISO-8601 with/without ms) for both
//    encoding and decoding to avoid iOS 18 date edge cases.
//  - Omit nil fields automatically (DTOs with Optionals) so the backend
//    receives only fields the user actually changed.
//

// MARK: - User Profile Edition Service
// Handles API requests for updating user and dog profiles
// Aligns with the backend /profile controller endpoints
final class UserProfileEditionService {
    static let shared = UserProfileEditionService()

    private let baseURL = URL(string: "https://api-2z4snw37ba-uc.a.run.app/profile")!
    private init() {}

    // MARK: - Public: User Profile Updates

    /// Update user profile (name, bio, location, etc.)
    /// Endpoint: PUT /profile/user/:userId
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
        // Build DTO with only the changed fields (Optionals -> omitted when nil)
        let body = UserUpdateDTO(
            name: name,
            bio: bio,
            location: location,
            coordinate: coordinate.map { .init(latitude: $0.latitude, longitude: $0.longitude) },
            languages: languages,
            customLanguage: customLanguage,
            imageURL: imageURL
        )

        // Execute request and decode typed response
        let data = try await send(path: "/user/\(userId)", method: "PUT", body: body)
        let resp = try JSONCoder.decoder().decode(UserProfileUpdateResponse.self, from: data)
        return resp.user
    }

    // MARK: - Public: Dog Profile Updates

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
        let body = DogBasicUpdateDTO(
            name: name,
            dob: dob,
            breed: breed,
            weight: weight,
            gender: gender?.rawValue,
            size: size?.rawValue,
            bio: bio,
            coordinate: coordinate.map { .init(latitude: $0.latitude, longitude: $0.longitude) }
        )

        let data = try await send(path: "/dog/\(dogId)/basic", method: "PUT", body: body)
        return try JSONCoder.decoder().decode(DogProfileUpdateResponse.self, from: data).dog
    }

    /// Update dog behavior profile (behavior, neutered status only)
    /// Endpoint: PUT /profile/dog/:dogId/behavior
    func updateDogBehaviorProfile(
        dogId: String,
        isNeutered: Bool? = nil,
        behavior: DogBehavior? = nil
    ) async throws -> DogModel {
        let body = DogBehaviorUpdateDTO(isNeutered: isNeutered, behavior: behavior)
        let data = try await send(path: "/dog/\(dogId)/behavior", method: "PUT", body: body)
        return try JSONCoder.decoder().decode(DogBehaviorUpdateResponse.self, from: data).dog
    }

    /// Update dog images
    /// Endpoint: PUT /profile/dog/:dogId/images
    func updateDogImages(dogId: String, imageURLs: [String]) async throws -> DogModel {
        let body = DogImagesUpdateDTO(imageURLs: imageURLs)
        let data = try await send(path: "/dog/\(dogId)/images", method: "PUT", body: body)
        return try JSONCoder.decoder().decode(DogImagesUpdateResponse.self, from: data).dog
    }

    // MARK: - Public: Health
    /// PATCH-like update for health dates. Sends only the fields user pass.
    /// Endpoint: PUT /profile/dog/:dogId/health
    func updateDogHealth(
        dogId: String,
        fleaTreatmentDate: Date? = nil,
        wormingTreatmentDate: Date? = nil
    ) async throws -> DogModel {
        // Must send at least one field
        precondition(fleaTreatmentDate != nil || wormingTreatmentDate != nil,
                     "Provide at least one treatment date")

        let body = DogHealthUpdateDTO(
            fleaTreatmentDate: fleaTreatmentDate,
            wormingTreatmentDate: wormingTreatmentDate
        )

        let data = try await send(path: "/dog/\(dogId)/health", method: "PUT", body: body)
        return try JSONCoder.decoder().decode(DogHealthUpdateResponse.self, from: data).dog
    }

    // MARK: - Core request helper (Encodable bodies)
    /// Generic sender that encodes any Encodable body with JSONCoder and returns raw Data.
    private func send<T: Encodable>(path: String, method: String, body: T) async throws -> Data {
        // Ensure authenticated and fetch fresh ID token
        guard let user = Auth.auth().currentUser else { throw ProfileEditionError.notAuthenticated }
        let token = try await user.getIDToken()

        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.cachePolicy = .reloadIgnoringLocalCacheData
        req.timeoutInterval = 30
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        // Encode via JSONCoder (ISO8601 tolerant, omits nils)
        req.httpBody = try JSONCoder.encoder().encode(body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw ProfileEditionError.invalidResponse }

        // Success: 2xx
        guard (200..<300).contains(http.statusCode) else {
            // Try to surface typed error if backend returned JSON
            if let err = try? JSONCoder.decoder().decode(ErrorResponse.self, from: data) {
                throw ProfileEditionError.apiError(err.error)
            }
            let snippet = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ProfileEditionError.apiError("HTTP \(http.statusCode): \(snippet)")
        }
        return data
    }
}

