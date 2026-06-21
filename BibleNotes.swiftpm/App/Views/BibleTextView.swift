import SwiftUI

struct BibleTextView: View {
    let text: String
    
    @EnvironmentObject var viewModel: AppViewModel
    
    private let fontSize: CGFloat = 20
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            let blocks = BibleTextParser.parse(text)
            
            // Book introduction header (Chapter 1 only)
            if viewModel.currentChapter == 1 {
                chapterOneHeader
            }
            
            // Verse / heading blocks
            ForEach(0..<blocks.count, id: \.self) { index in
                let block = blocks[index]
                
                if block.isHeading {
                    headingView(block: block, showDivider: index > 0)
                } else {
                    verseView(block: block)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 40)
        .padding(.bottom, 100)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    // MARK: - Subviews
    
    private var chapterOneHeader: some View {
        VStack(alignment: .leading, spacing: 15) {
            GeometryReader { _ in
                Image("Transparent_Main_Emblem")
                    .resizable()
                    .scaledToFit()
                    .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                    .frame(height: 260)
                    .frame(width: UIScreen.main.bounds.width)
                    .offset(x: -20)
            }
            .frame(height: 280)
            .padding(.bottom, 10)
            
            Text(viewModel.currentBook.uppercased())
                .font(.custom("IowanOldStyle-Bold", size: 30))
                .tracking(4)
                .foregroundColor(AppTheme.goldAccent)
        }
        .transition(.opacity)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private func headingView(block: TextBlock, showDivider: Bool) -> some View {
        if showDivider {
            Divider()
                .background(AppTheme.goldAccent.opacity(0.3))
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
        }
        
        HStack(spacing: 0) {
            Spacer()
            if let firstChar = block.text.first {
                Text(String(firstChar))
                    .font(.custom("Zapfino", size: 40))
                    .foregroundColor(AppTheme.goldAccent)
                    .shadow(color: AppTheme.leatherShadow.opacity(0.3), radius: 1, x: 1, y: 1)
                
                Text(String(block.text.dropFirst()))
                    .font(.custom("IowanOldStyle-Bold", size: 22))
                    .foregroundColor(AppTheme.goldAccent)
                    .textCase(.uppercase)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }
    
    private func verseView(block: TextBlock) -> some View {
        Text(block.text)
            .font(.system(size: fontSize, weight: .regular, design: .serif))
            .lineSpacing(10)
            .foregroundColor(AppTheme.parchmentText)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .fixedSize(horizontal: false, vertical: true)
    }
}
