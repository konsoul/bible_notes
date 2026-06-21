import SwiftUI

struct ChapterSelectorView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
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
                
                // Chapter Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        let count = BibleData.chapterCounts[viewModel.currentBook] ?? 1
                        ForEach(1...count, id: \.self) { chapter in
                            Button(action: {
                                selectChapter(chapter)
                            }) {
                                Text("\(chapter)")
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                                    .frame(minWidth: 70, minHeight: 70)
                                    .foregroundColor(
                                        viewModel.currentChapter == chapter
                                        ? AppTheme.darkSepia
                                        : AppTheme.parchmentText
                                    )
                                    .background(
                                        viewModel.currentChapter == chapter
                                        ? AppTheme.goldAccent
                                        : AppTheme.lighterSepia
                                    )
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppTheme.goldAccent.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private func selectChapter(_ chapter: Int) {
        if viewModel.currentChapter != chapter {
            viewModel.currentChapter = chapter
        }
        dismiss()
    }
}
