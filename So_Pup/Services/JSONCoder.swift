import Foundation
//
//
//  This helper provides a consistent way to encode and decode dates across the app.
//  Instead of using `.iso8601` directly in every service, call `JSONCoder.decoder()`
//  and `JSONCoder.encoder()`.
//
//  Features:
//  Decodes both ISO8601 strings with and without fractional seconds
//    e.g. "2025-08-20T11:05:15Z" and "2025-08-20T11:05:15.699Z"
//  Encodes dates using ISO8601 with fractional seconds
//  Avoids capturing non-Sendable ISO8601DateFormatter instances (Swift 6 safe)
//  Keeps all encoding/decoding strategy logic in one place for easier maintenance
//
//  Usage:
//      let decoder = JSONCoder.decoder()
//      let model = try decoder.decode(MyModel.self, from: data)
//
//      let encoder = JSONCoder.encoder()
//      let body = try encoder.encode(dto)
//
//

enum JSONCoder {
    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let str = try decoder.singleValueContainer().decode(String.self)

            // Try with fractional seconds first
            let withMs = ISO8601DateFormatter()
            withMs.formatOptions = [
                .withInternetDateTime, .withDashSeparatorInDate,
                .withColonSeparatorInTime, .withTimeZone, .withFractionalSeconds
            ]
            if let d = withMs.date(from: str) { return d }

            // Fallback: no fractional seconds
            let noMs = ISO8601DateFormatter()
            noMs.formatOptions = [
                .withInternetDateTime, .withDashSeparatorInDate,
                .withColonSeparatorInTime, .withTimeZone
            ]
            if let d = noMs.date(from: str) { return d }

            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "Invalid ISO8601 date: \(str)"
            ))
        }

        return decoder
    }

    static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            // Build a fresh formatter to avoid capturing shared state
            let f = ISO8601DateFormatter()
            f.formatOptions = [
                .withInternetDateTime, .withDashSeparatorInDate,
                .withColonSeparatorInTime, .withTimeZone, .withFractionalSeconds
            ]
            var container = encoder.singleValueContainer()
            try container.encode(f.string(from: date))
        }
        return encoder
    }
}
