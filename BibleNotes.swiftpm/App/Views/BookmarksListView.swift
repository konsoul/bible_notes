import SwiftUI

struct BookmarksListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    


    var body: some View {
        ZStack {
            AppTheme.darkSepia.ignoresSafeArea()
            
            VStack {
                // HEADER
                HStack {
                    Spacer()
                    Text("Bookmarks")
                        .font(.custom("IowanOldStyle-Bold", size: 24))
                        .foregroundColor(AppTheme.goldAccent)
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.goldAccent)
                    }
                }
                .padding()
                .background(AppTheme.lighterSepia)
                
                


                // BOOKMARKS LIST
                if viewModel.bookmarkManager.bookmarks.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 50))
                            .foregroundColor(AppTheme.parchmentText.opacity(0.5))
                        Text("No Bookmarks Yet")
                            .font(.headline)
                            .foregroundColor(AppTheme.parchmentText.opacity(0.7))
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.bookmarkManager.bookmarks) { bookmark in
                            Button(action: {
                                navigateToBookmark(bookmark)
                            }) {
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("\(bookmark.book) \(bookmark.chapter):\(bookmark.verseNumber)")
                                            .font(.headline)
                                            .foregroundColor(AppTheme.goldAccent)
                                        Spacer()
                                        Text(bookmark.dateCreated, style: .date)
                                            .font(.caption2)
                                            .foregroundColor(AppTheme.parchmentText.opacity(0.5))
                                    }
                                    
                                    Text(bookmark.textSnippet)
                                        .font(.body)
                                        .foregroundColor(AppTheme.parchmentText)
                                        .lineLimit(2)
                                        .italic()
                                }
                                .padding(.vertical, 5)
                            }
                            .listRowBackground(AppTheme.lighterSepia.opacity(0.5))
                        }
                        .onDelete(perform: deleteBookmark)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
    }
    
    private func deleteBookmark(at offsets: IndexSet) {
        // Need to enable editing or just remove from manager
        // This is a bit tricky with onDelete on generic list over published property
        // But since we are directly accessing viewModel array in ForEach, offsets match
        offsets.forEach { index in
            let bookmark = viewModel.bookmarkManager.bookmarks[index]
            viewModel.bookmarkManager.remove(id: bookmark.id)
        }
    }
    
    private func navigateToBookmark(_ bookmark: Bookmark) {
        if viewModel.currentBook != bookmark.book || viewModel.currentChapter != bookmark.chapter {
            viewModel.currentBook = bookmark.book
            viewModel.currentChapter = bookmark.chapter
        }
        dismiss()
    }
}
