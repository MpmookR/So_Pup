import SwiftUI

extension Color {
    // MARK: - Puppy Mode
    static let puppyLight = Color(hex: "#F6F9FE")
    static let puppyPrimary = Color(hex: "#91CFFE")
    static let puppyAccent = Color(hex: "#C7E6FF")
    static let puppyText = Color(hex: "#151D26")
    static let puppyButton = Color(hex: "#57B8FF")
    static let puppyBorder = Color(hex: "#DEF1FE")

    // MARK: - Social Mode
    static let socialLight = Color(hex: "#FFF5DC")
    static let socialPrimary = Color(hex: "#FFD443")
    static let socialAccent = Color(hex: "#FFE288")
    static let socialText = Color(hex: "#333333")
    static let socialButton = Color(hex: "#FFB800")
    static let socialBorder = Color(hex: "#F9DB5C")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: (r, g, b) = ((int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        default: (r, g, b) = (1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}


