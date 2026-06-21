import SwiftUI

struct BookSelectorView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.darkSepia.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Text("Select Book")
                        .font(.custom("IowanOldStyle-Bold", size: 20))
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
                
                // Book List
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(BibleData.books, id: \.self) { book in
                            Button(action: {
                                selectBook(book)
                            }) {
                                HStack {
                                    Text(book)
                                        .font(.system(size: 18, weight: .medium, design: .serif))
                                        .foregroundColor(
                                            viewModel.currentBook == book
                                            ? AppTheme.goldAccent
                                            : AppTheme.parchmentText
                                        )
                                    
                                    Spacer()
                                    
                                    if viewModel.currentBook == book {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(AppTheme.goldAccent)
                                    }
                                }
                                .padding()
                                .background(
                                    viewModel.currentBook == book
                                    ? AppTheme.lighterSepia
                                    : Color.clear
                                )
                            }
                            Divider().background(AppTheme.lighterSepia)
                        }
                    }
                }
            }
        }
    }
    
    private func selectBook(_ book: String) {
        if viewModel.currentBook != book {
            viewModel.currentBook = book
            viewModel.currentChapter = 1
        }
        dismiss()
    }
}
