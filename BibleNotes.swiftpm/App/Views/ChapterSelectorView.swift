import SwiftUI

struct ChapterSelectorView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    private let columns = [GridItem(.adaptive(minimum: 80))]
    
    var body: some View {
        ZStack {
            AppTheme.darkSepia.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Text("\(viewModel.currentBook) Chapters")
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
                
                // Chapter grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        let count = BibleData.chapterCounts[viewModel.currentBook] ?? 1
                        ForEach(1...count, id: \.self) { chapter in
                            chapterCell(chapter)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private func chapterCell(_ chapter: Int) -> some View {
        let isSelected = viewModel.currentChapter == chapter
        
        return Button { selectChapter(chapter) } label: {
            Text("\(chapter)")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .frame(minWidth: 70, minHeight: 70)
                .foregroundColor(isSelected ? AppTheme.darkSepia : AppTheme.parchmentText)
                .background(isSelected ? AppTheme.goldAccent : AppTheme.lighterSepia)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.goldAccent.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private func selectChapter(_ chapter: Int) {
        if viewModel.currentChapter != chapter {
            viewModel.currentChapter = chapter
        }
        dismiss()
    }
}
