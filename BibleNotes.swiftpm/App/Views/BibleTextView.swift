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
                    VStack(alignment: .leading, spacing: 15) {
                        GeometryReader { geo in
                            Image("Transparent_Main_Emblem")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 260)
                                .blendMode(.multiply) // Makes the white background match the app's sepia background
                                .frame(width: UIScreen.main.bounds.width)
                                .offset(x: -20) // Counteract the LEFT_MARGIN of 20 to strictly center on screen
                        }
                        .frame(height: 280) // GeometryReader needs a fixed height to not collapse
                        .padding(.bottom, 10)
                        
                        Text(viewModel.currentBook.uppercased())
                            .font(.custom("IowanOldStyle-Bold", size: 30))
                            .tracking(4)
                            .foregroundColor(AppTheme.darkSepia)
                    }
                    .transition(.opacity)
                    .padding(.bottom, 20)
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
                        Text(block.text)
                            .font(.system(size: fontSize, weight: .regular, design: .serif))
                            .lineSpacing(10)
                            .foregroundColor(AppTheme.parchmentText)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.clear)
                            .cornerRadius(4)
                            .fixedSize(horizontal: false, vertical: true)
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
