import SwiftUI
import UIKit

// MARK: - API Configuration
struct AppConstants {
    static let esvApiKey = "df1d8522f129eddc01196ec59b33baaf082c7f9a"
    static let esvApiBaseURL = "https://api.esv.org/v3/passage/text/"
}

// MARK: - App Theme
struct AppTheme {
    // Core Palette
    static let goldAccent = Color(hex: "D4AF37")
    static let darkSepia = Color(hex: "F9F6EE")
    static let lighterSepia = Color(hex: "F4EFE6")
    static let parchmentText = Color(hex: "222222")
    
    // Splash Screen / Leather Cover
    static let leatherRed = Color(hex: "4A0404")
    static let leatherShadow = Color(hex: "1A0101")
    static let goldHighlight = Color(hex: "F9E076")
    static let goldShadow = Color(hex: "CCA43B")
    
    // UIKit equivalents (cached for PDF export performance)
    static let uiDarkSepia = UIColor(hex: "F9F6EE")
    static let uiGoldHighlight = UIColor(hex: "F9E076")
    static let uiGoldAccent = UIColor(hex: "D4AF37")
    static let uiParchmentText = UIColor(hex: "222222")
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
