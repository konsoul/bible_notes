import SwiftUI

struct BibleTextView: View {
    let text: String
    let fontSize: CGFloat = 20
    
    @EnvironmentObject var viewModel: AppViewModel
    

    
    var body: some View {
        // ScrollView removal: UnifiedCanvasView handles scrolling
        VStack(alignment: .leading, spacing: 20) {
                // Parse text into blocks
                let blocks = BibleTextParser.parse(text)
                
                // BOOK INTRODUCTION HEADER (Chapter 1 Only)
                if viewModel.currentChapter == 1 {
                    VStack(spacing: 15) {
                        Image("Transparent_Main_Emblem")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 260) 
                            // Removed .foregroundColor to ensure transparency works
                        
                        Text(viewModel.currentBook.uppercased())
                            .font(.custom("IowanOldStyle-Bold", size: 30))
                            .tracking(4) // Wide letter spacing
                            .foregroundColor(AppTheme.darkSepia)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 40)
                    .transition(.opacity)
                }
                
                ForEach(0..<blocks.count, id: \.self) { index in
                    let block = blocks[index]
                    
                    if block.isHeading {
                        // FANCY HEADING SEPARATOR
                        if index > 0 {
                            Divider()
                                .background(AppTheme.goldAccent.opacity(0.3))
                                .padding(.horizontal, 40)
                                .padding(.vertical, 10)
                        }
                        
                        // FANCY HEADING
                        HStack(spacing: 0) {
                            Spacer()
                            // Fancy Drop Cap for Title
                            if let firstChar = block.text.first {
                                Text(String(firstChar))
                                    .font(.custom("Zapfino", size: 40)) // Very fancy script
                                    .foregroundColor(AppTheme.goldAccent)
                                    .shadow(color: AppTheme.leatherShadow.opacity(0.3), radius: 1, x: 1, y: 1)
                                
                                Text(String(block.text.dropFirst()))
                                    .font(.custom("IowanOldStyle-Bold", size: 22)) // Classic serif
                                    .foregroundColor(AppTheme.goldAccent)
                                    .textCase(.uppercase)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        
                    } else {
                        // VERSE TEXT
                        let verseNum = block.verseNumber
                        let isBookmarked: Bool = {
                            guard let v = verseNum else { return false }
                            return viewModel.bookmarkManager.isBookmarked(
                                book: viewModel.currentBook,
                                chapter: viewModel.currentChapter,
                                verse: v
                            )
                        }()
                        
                        Text(block.text)
                            .font(.system(size: fontSize, weight: .regular, design: .serif))
                            .lineSpacing(10)
                            .foregroundColor(AppTheme.parchmentText)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(
                                isBookmarked ? AppTheme.goldAccent.opacity(0.3) : Color.clear
                            )
                            .cornerRadius(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .contextMenu {
                                if let verseNumber = verseNum {
                                    Button {
                                        if isBookmarked {
                                            viewModel.bookmarkManager.remove(
                                                book: viewModel.currentBook,
                                                chapter: viewModel.currentChapter,
                                                verse: verseNumber
                                            )
                                        } else {
                                            viewModel.bookmarkManager.add(
                                                book: viewModel.currentBook,
                                                chapter: viewModel.currentChapter,
                                                verse: verseNumber,
                                                text: block.text
                                            )
                                        }
                                    } label: {
                                        Label(isBookmarked ? "Remove Bookmark" : "Bookmark Verse",
                                              systemImage: isBookmarked ? "bookmark.slash" : "bookmark")
                                    }
                                }
                            }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 40)
            .padding(.bottom, 100) // Space for scrolling
            .frame(maxWidth: .infinity, alignment: .topLeading)
            // Background moved to Parent View to allow transparency for layering
    }
}
