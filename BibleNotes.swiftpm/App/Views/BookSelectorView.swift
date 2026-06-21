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
                    HStack(alignment: .top, spacing: 20) {
                        // LEFT COLUMN: Old Testament
                        VStack(alignment: .leading, spacing: 10) {
                            Text("OLD TESTAMENT")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(AppTheme.goldShadow)
                                .tracking(1)
                                .padding(.bottom, 5)
                            
                            ForEach(BibleData.books.prefix(39), id: \.self) { book in
                                bookRow(for: book)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // RIGHT COLUMN: New Testament
                        VStack(alignment: .leading, spacing: 10) {
                            Text("NEW TESTAMENT")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(AppTheme.goldShadow)
                                .tracking(1)
                                .padding(.bottom, 5)
                            
                            ForEach(BibleData.books.suffix(27), id: \.self) { book in
                                bookRow(for: book)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 60)
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
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(
                        viewModel.currentBook == book
                        ? AppTheme.darkSepia
                        : AppTheme.parchmentText
                    )
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                Spacer()
                
                if viewModel.currentBook == book {
                    Image(systemName: "checkmark")
                        .foregroundColor(AppTheme.darkSepia)
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background(
                viewModel.currentBook == book
                ? AppTheme.goldAccent
                : AppTheme.lighterSepia
            )
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
