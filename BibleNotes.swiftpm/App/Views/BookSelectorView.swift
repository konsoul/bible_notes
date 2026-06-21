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
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.goldAccent)
                    }
                }
                .padding()
                .background(AppTheme.lighterSepia)
                
                // Two-column book list
                ScrollView {
                    HStack(alignment: .top, spacing: 20) {
                        bookColumn(title: "OLD TESTAMENT", books: Array(BibleData.books.prefix(39)))
                        bookColumn(title: "NEW TESTAMENT", books: Array(BibleData.books.suffix(27)))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 60)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private func bookColumn(title: String, books: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .serif))
                .foregroundColor(AppTheme.goldShadow)
                .tracking(1)
                .padding(.bottom, 5)
            
            ForEach(books, id: \.self) { book in
                bookRow(for: book)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func bookRow(for book: String) -> some View {
        let isSelected = viewModel.currentBook == book
        
        Button { selectBook(book) } label: {
            HStack {
                Text(book)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(isSelected ? AppTheme.darkSepia : AppTheme.parchmentText)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(AppTheme.darkSepia)
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background(isSelected ? AppTheme.goldAccent : AppTheme.lighterSepia)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.goldAccent.opacity(0.2), lineWidth: 1)
            )
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
