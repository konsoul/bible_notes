import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var showSplashScreen: Bool = true
    @Published var currentBook: String = "John"
    @Published var currentChapter: Int = 1
    
    @Published var bibleText: String = "Loading..."
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Full Bible Book List
    let books = BibleData.books
    
    init() {
        // Initialization if needed
    }
    
    func openBible() {
        withAnimation {
            showSplashScreen = false
        }
        fetchChapter()
    }
    
    private var fetchTask: AnyCancellable?
    
    func fetchChapter() {
        self.isLoading = true
        self.errorMessage = nil
        
        fetchTask?.cancel()
        
        // Use the real service
        fetchTask = BibleAPIService.shared.fetchChapter(book: currentBook, chapter: currentChapter)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                    self?.bibleText = "Failed to load text."
                }
            }, receiveValue: { [weak self] text in
                self?.bibleText = text
            })
    }
    
    // MARK: - Navigation
    
    func nextChapter() {
        guard let maxChapters = BibleData.chapterCounts[currentBook],
              let currentBookIndex = BibleData.books.firstIndex(of: currentBook) else { return }
        
        if currentChapter < maxChapters {
            currentChapter += 1
            fetchChapter()
        } else if currentBookIndex + 1 < BibleData.books.count {
            // Next Book
            currentBook = BibleData.books[currentBookIndex + 1]
            currentChapter = 1
            fetchChapter()
        }
    }
    
    func previousChapter() {
        guard let currentBookIndex = BibleData.books.firstIndex(of: currentBook) else { return }
        
        if currentChapter > 1 {
            currentChapter -= 1
            fetchChapter()
        } else if currentBookIndex > 0 {
            // Previous Book
            let prevBook = BibleData.books[currentBookIndex - 1]
            currentBook = prevBook
            currentChapter = BibleData.chapterCounts[prevBook] ?? 1
            fetchChapter()
        }
    }
}
