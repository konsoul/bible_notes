import Foundation

struct TextBlock: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isHeading: Bool
    let verseNumber: Int?
}

struct BibleTextParser {
    /// Parses raw ESV API text into structured TextBlocks.
    /// The ESV API indents verses with 2 spaces; headings are not indented.
    static func parse(_ rawText: String) -> [TextBlock] {
        return rawText
            .components(separatedBy: "\n\n")
            .compactMap { line in
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }
                
                let isVerse = line.hasPrefix("  ")
                
                // Extract verse number if present (e.g. "1." or "12.")
                var verseNum: Int? = nil
                if isVerse {
                    let scanner = Scanner(string: trimmed)
                    verseNum = scanner.scanInt()
                }
                
                return TextBlock(text: trimmed, isHeading: !isVerse, verseNumber: verseNum)
            }
    }
}
