import Foundation

struct Bookmark: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let book: String
    let chapter: Int
    let verseNumber: Int
    let textSnippet: String
    let dateCreated: Date
}
