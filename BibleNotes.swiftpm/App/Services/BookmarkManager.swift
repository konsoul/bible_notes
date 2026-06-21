import Foundation

class BookmarkManager: ObservableObject {
    @Published var bookmarks: [Bookmark] = []
    
    private let saveKey = "SavedBookmarks"
    
    init() {
        load()
    }
    
    func add(book: String, chapter: Int, verse: Int, text: String) {
        let newBookmark = Bookmark(
            book: book,
            chapter: chapter,
            verseNumber: verse,
            textSnippet: text,
            dateCreated: Date()
        )
        bookmarks.append(newBookmark)
        save()
    }
    
    func remove(id: UUID) {
        bookmarks.removeAll { $0.id == id }
        save()
    }
    
    func remove(book: String, chapter: Int, verse: Int) {
        bookmarks.removeAll { $0.book == book && $0.chapter == chapter && $0.verseNumber == verse }
        save()
    }
    
    func isBookmarked(book: String, chapter: Int, verse: Int) -> Bool {
        return bookmarks.contains { $0.book == book && $0.chapter == chapter && $0.verseNumber == verse }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Bookmark].self, from: data) {
            self.bookmarks = decoded
        }
    }
}
