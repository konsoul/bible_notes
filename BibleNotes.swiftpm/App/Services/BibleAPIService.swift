import Foundation
import Combine

struct ESVResponse: Codable {
    let query: String
    let canonical: String // e.g., "John 1"
    let passages: [String] // The actual text
}

class BibleAPIService {
    static let shared = BibleAPIService()
    
    private init() {}
    
    func fetchChapter(book: String, chapter: Int) -> AnyPublisher<String, Error> {
        let query = "\(book) \(chapter)"
        
        // Construct URL
        // Options: include-headings=false to keep it clean, or true depending on user pref.
        // We want plain text to match our "Simple and Elegant" vibe, but headings are nice.
        // Let's keep headings but indent them?
        // For simplicity: include-headings=true, include-verse-numbers=true
        
        // Validated against https://api.esv.org/docs/passage-text/
        // line-length=0 ensures the API doesn't insert hard newlines for wrapping, letting SwiftUI handle it.
        // include-short-copyright=true ensures we display the required (ESV) attribution.
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(AppConstants.esvApiBaseURL)?q=\(encodedQuery)&include-headings=true&include-footnotes=false&include-verse-numbers=true&include-short-copyright=true&include-passage-references=false&line-length=0") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Token \(AppConstants.esvApiKey)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { (data, response) -> Data in
                return data
            }
            .decode(type: ESVResponse.self, decoder: JSONDecoder())
            .map { response in
                let rawText = response.passages.joined(separator: "\n\n")
                return self.formatBibleText(rawText)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func formatBibleText(_ text: String) -> String {
        // 1. Replace [1] with 1. 
        // regex: \[(\d+)\]
        // replacement: $1.
        // NOTE: We do NOT insert extra newlines here anymore, as we want to respect the API's structure.
        var formatted = text
        
        do {
            let regex = try NSRegularExpression(pattern: "\\[(\\d+)\\]", options: [])
            let range = NSRange(location: 0, length: text.utf16.count)
            // MARK: Formatting Change
            // We use \n\n to split verses onto new lines for easier note taking.
            // We include "  " (two spaces) so our Parser knows it is a VERSE, not a Heading.
            formatted = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "\n\n  $1.")
        } catch {
            print("[BibleAPIService] Error creating regex: \(error)")
        }
        
        // 2. ONLY trim newlines from ends, preserve indentation!
        // The API returns verses indented by 2 spaces. We NEED those spaces to identify verses vs headings.
        return formatted.trimmingCharacters(in: .newlines)
    }
}
