import Foundation

struct TextBlock: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isHeading: Bool
    let verseNumber: Int?
}

class BibleTextParser {
    static func parse(_ rawText: String) -> [TextBlock] {
        // Split by double newlines to get paragraphs
        let lines = rawText.components(separatedBy: "\n\n")
        
        return lines.compactMap { line in
            // DO NOT trim whitespace yet! We need to check it.
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return nil }
            
            // INDENTATION DETECTION:
            // The ESV API indents verses with 2 spaces ("  ").
            // Headings are NOT indented.
            let isVerse = line.hasPrefix("  ")
            
            // Now we can clean up the text for display
            let cleanText = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // EXTRACT VERSE NUMBER
            var verseNum: Int? = nil
            if isVerse {
                // Verses usually start with "1." or "12." due to our previous formatting in BibleAPIService
                let scanner = Scanner(string: cleanText)
                if let number = scanner.scanInt() {
                    verseNum = number
                    // We also remove the number and dot from the display text for a cleaner look?
                    // Actually, let's keep it so the user sees the verse number, but we just want to KNOW it.
                }
            }
            
            return TextBlock(text: cleanText, isHeading: !isVerse, verseNumber: verseNum)
        }
    }
}
