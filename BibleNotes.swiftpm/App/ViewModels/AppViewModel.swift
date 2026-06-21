import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    // MARK: - Published State
    @Published var showSplashScreen = true
    @Published var currentBook = "John"
    @Published var currentChapter = 1
    @Published var bibleText = "Loading..."
    
    // MARK: - Private
    private var fetchTask: AnyCancellable?
    
    // MARK: - Actions
    
    func openBible() {
        withAnimation {
            showSplashScreen = false
        }
        fetchChapter()
    }
    
    func fetchChapter() {
        fetchTask?.cancel()
        
        fetchTask = BibleAPIService.shared
            .fetchChapter(book: currentBook, chapter: currentChapter)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.bibleText = "Failed to load text.\n\(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] text in
                    self?.bibleText = text
                }
            )
    }
    
    // MARK: - Navigation
    
    func nextChapter() {
        guard let maxChapters = BibleData.chapterCounts[currentBook],
              let bookIndex = BibleData.books.firstIndex(of: currentBook) else { return }
        
        if currentChapter < maxChapters {
            currentChapter += 1
        } else if bookIndex + 1 < BibleData.books.count {
            currentBook = BibleData.books[bookIndex + 1]
            currentChapter = 1
        }
        fetchChapter()
    }
    
    func previousChapter() {
        guard let bookIndex = BibleData.books.firstIndex(of: currentBook) else { return }
        
        if currentChapter > 1 {
            currentChapter -= 1
        } else if bookIndex > 0 {
            let prevBook = BibleData.books[bookIndex - 1]
            currentBook = prevBook
            currentChapter = BibleData.chapterCounts[prevBook] ?? 1
        }
        fetchChapter()
    }
}
