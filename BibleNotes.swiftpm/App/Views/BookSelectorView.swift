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
                        // Old Testament Header
                        Text("OLD TESTAMENT")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundColor(AppTheme.goldShadow)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 5)
                            .tracking(2)
                        
                        Divider().background(AppTheme.goldShadow)
                        
                        ForEach(BibleData.books.prefix(39), id: \.self) { book in
                            bookRow(for: book)
                        }
                        
                        // New Testament Header
                        Text("NEW TESTAMENT")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundColor(AppTheme.goldShadow)
                            .padding(.horizontal)
                            .padding(.top, 30)
                            .padding(.bottom, 5)
                            .tracking(2)
                        
                        Divider().background(AppTheme.goldShadow)
                        
                        ForEach(BibleData.books.suffix(27), id: \.self) { book in
                            bookRow(for: book)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    @ViewBuilder
    private func bookRow(for book: String) -> some View {
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
    
    private func selectBook(_ book: String) {
        if viewModel.currentBook != book {
            viewModel.currentBook = book
            viewModel.currentChapter = 1
        }
        dismiss()
    }
}
