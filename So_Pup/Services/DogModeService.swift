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

        let bodyDTO = VaccinationUpdateDTO(
            coreVaccination1Date: coreVaccination1Date,
            coreVaccination2Date: coreVaccination2Date
        )

        let encoder = JSONCoder.encoder()
        request.httpBody = try encoder.encode(bodyDTO)

        let (data, resp) = try await URLSession.shared.data(for: request)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        let decoder = JSONCoder.decoder()
        if (200..<300).contains(http.statusCode) {
            return try decoder.decode(VaccinationUpdateResponse.self, from: data)
        } else {
            if let err = try? decoder.decode(ErrorResponse.self, from: data) {
                throw NSError(domain: "DogModeService", code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: err.error])
            }
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Manual Mode Switch
    func switchDogMode(dogId: String, mode: DogMode, authToken: String) async throws -> DogModel {
        guard let url = URL(string: "\(baseURL)/\(dogId)/modeSwitch") else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        let encoder = JSONCoder.encoder()
        request.httpBody = try encoder.encode(ModeSwitchRequestDTO(mode: mode.rawValue))

        let (data, resp) = try await URLSession.shared.data(for: request)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        let decoder = JSONCoder.decoder()
        if (200..<300).contains(http.statusCode) {
            let payload = try decoder.decode(ModeSwitchResponse.self, from: data)
            return payload.dog
        } else {
            if let err = try? decoder.decode(ErrorResponse.self, from: data) {
                throw NSError(domain: "DogModeService", code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: err.error])
            }
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Update Social Dog Data
    func updateSocialDogData(
        dogId: String,
        isNeutered: Bool? = nil,
        behavior: DogBehavior? = nil,
        authToken: String
    ) async throws -> DogModel {
        guard let url = URL(string: "\(baseURL)/\(dogId)/behavior") else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        let encoder = JSONCoder.encoder()
        request.httpBody = try encoder.encode(
            SocialDogDataUpdateDTO(isNeutered: isNeutered, behavior: behavior)
        )

        let (data, resp) = try await URLSession.shared.data(for: request)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        let decoder = JSONCoder.decoder()
        if http.statusCode == 200 {
            let payload = try decoder.decode(SocialDataUpdateResponse.self, from: data)
            return payload.dog
        } else {
            if let err = try? decoder.decode(ErrorResponse.self, from: data) {
                throw NSError(domain: "DogModeService", code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: err.error])
            }
            throw URLError(.badServerResponse)
        }
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

private struct VaccinationUpdateDTO: Codable {
    let coreVaccination1Date: Date?
    let coreVaccination2Date: Date?
}

private struct ModeSwitchRequestDTO: Codable {
    let mode: String
}

private struct SocialDogDataUpdateDTO: Codable {
    let isNeutered: Bool?
    let behavior: DogBehavior?
}

struct ErrorResponse: Codable {
    let error: String
}
