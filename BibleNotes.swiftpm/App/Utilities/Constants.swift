import SwiftUI

struct AppConstants {
    // WARNING: This API key is hardcoded for development convenience.
    // Do NOT commit this to a public repository. Move to environment variable or .plist for production.
    static let esvApiKey = "df1d8522f129eddc01196ec59b33baaf082c7f9a"
    static let esvApiBaseURL = "https://api.esv.org/v3/passage/text/"
}

struct AppTheme {
    static let bibleGreen = Color(hex: "013220") // Dark forest green
    static let goldAccent = Color(hex: "D4AF37") // Metallic gold
    static let paperBackground = Color(hex: "FDFBF7") // Off-white paper
    
    // New Sepia Theme
    static let darkSepia = Color(hex: "2B2218") // Deep warm brown/black
    static let lighterSepia = Color(hex: "3B2F22") // Slightly lighter for UI elements
    static let parchmentText = Color(hex: "E6DCC8") // Light cream text
    
    // Antique Cover Theme
    static let leatherRed = Color(hex: "4A0404") // Deep antique red/brown
    static let leatherShadow = Color(hex: "1A0101") // Very dark shadow
    static let goldHighlight = Color(hex: "F9E076") // Bright gold
    static let goldShadow = Color(hex: "CCA43B") // Darker gold
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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

// MARK: - UIKit Color Extension (used by PDFExporter and SnapshotExporter)
import UIKit

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
