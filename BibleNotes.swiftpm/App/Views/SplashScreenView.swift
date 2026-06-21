import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        ZStack {
            // 1. LEATHER BACKGROUND
            GeometryReader { geo in
                RadialGradient(
                    gradient: Gradient(colors: [AppTheme.leatherRed, AppTheme.leatherShadow]),
                    center: .center,
                    startRadius: 10,
                    endRadius: geo.size.height
                )
                .ignoresSafeArea()
            }
            
            // 2. GOLD TOOLING BORDER (The fancy 1600s frame)
            ZStack {
                // Outer Border
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [AppTheme.goldShadow, AppTheme.goldHighlight, AppTheme.goldShadow]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .padding(20)
                
                // Inner Border (Blind detailed)
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(AppTheme.goldShadow.opacity(0.5), lineWidth: 1)
                    .padding(30)
                
                // Corner Ornaments (SF Symbols acting as Gold Tooling)
                VStack {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .rotationEffect(.degrees(-45))
                        Spacer()
                        Image(systemName: "leaf.fill")
                            .rotationEffect(.degrees(45))
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "leaf.fill")
                            .rotationEffect(.degrees(-135))
                        Spacer()
                        Image(systemName: "leaf.fill")
                            .rotationEffect(.degrees(135))
                    }
                }
                .font(.system(size: 40))
                .foregroundColor(AppTheme.goldHighlight.opacity(0.8))
                .padding(40)
            }
            
            // 3. CENTRAL CONTENT (Embossed Text)
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 5) {
                    Text("HOLY BIBLE")
                        .font(.custom("IowanOldStyle-Bold", size: 52))
                        .foregroundColor(AppTheme.goldHighlight)
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 2, y: 2) // Look embossed
                    
                    Text("ENGLISH STANDARD VERSION")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundColor(AppTheme.goldShadow)
                        .tracking(4)
                }
                
                Spacer()
                
                // 4. MINIMAL SELECTION (No white box)
                VStack(spacing: 20) {
                    Divider()
                        .background(AppTheme.goldShadow)
                        .frame(width: 100)
                    
                    HStack(spacing: 0) {
                        Picker("Book", selection: $viewModel.currentBook) {
                            ForEach(viewModel.books, id: \.self) { book in
                                Text(book)
                                    .tag(book)
                                    .foregroundColor(AppTheme.goldHighlight) // Trying to style item
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 150, height: 120)
                        
                        Picker("Chapter", selection: $viewModel.currentChapter) {
                            ForEach(1...(BibleData.chapterCounts[viewModel.currentBook] ?? 1), id: \.self) { chapter in
                                Text("\(chapter)")
                                    .tag(chapter)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80, height: 120)
                    }
                    .onChange(of: viewModel.currentBook) { _, _ in
                        let maxChapter = BibleData.chapterCounts[viewModel.currentBook] ?? 1
                        if viewModel.currentChapter > maxChapter {
                            viewModel.currentChapter = 1
                        }
                    }
                    // Force the picker text to look "gold" by applying color scheme or mask
                    // Standard WheelPicker is stubborn, but ColorScheme.dark helps on dark bg
                    .colorScheme(.dark)
                    
                    Button(action: {
                        viewModel.openBible()
                    }) {
                        HStack {
                            Image(systemName: "book.closed.fill")
                            Text("Open Scripture")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .tracking(1)
                        }
                        .foregroundColor(AppTheme.leatherShadow)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [AppTheme.goldHighlight, AppTheme.goldShadow]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)
                    }
                }
                
                Spacer()
                
                Text("EST. 2024")
                    .font(.caption)
                    .foregroundColor(AppTheme.goldShadow.opacity(0.4))
                    .padding(.bottom, 30)
            }
        }
        .statusBar(hidden: true)
    }
}
