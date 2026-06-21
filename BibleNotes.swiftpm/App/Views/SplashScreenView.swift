import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    @State private var showBookSelector = false
    @State private var showChapterSelector = false
    
    var body: some View {
        ZStack {
            // 1. LEATHER BACKGROUND
            GeometryReader { geo in
                Image("LeatherTexture")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
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
                
                // 4. ROBUST SELECTION BUTTONS
                VStack(spacing: 20) {
                    Divider()
                        .background(AppTheme.goldShadow)
                        .frame(width: 100)
                    
                    HStack(spacing: 15) {
                        // Book Button
                        Button(action: { showBookSelector = true }) {
                            VStack(spacing: 5) {
                                Text("BOOK")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.goldShadow)
                                    .tracking(2)
                                Text(viewModel.currentBook)
                                    .font(.title2.bold())
                                    .foregroundColor(AppTheme.goldHighlight)
                            }
                            .frame(width: 160, height: 80)
                            .background(AppTheme.leatherShadow.opacity(0.6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.goldShadow.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        // Chapter Button
                        Button(action: { showChapterSelector = true }) {
                            VStack(spacing: 5) {
                                Text("CHAPTER")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.goldShadow)
                                    .tracking(2)
                                Text("\(viewModel.currentChapter)")
                                    .font(.title2.bold())
                                    .foregroundColor(AppTheme.goldHighlight)
                            }
                            .frame(width: 120, height: 80)
                            .background(AppTheme.leatherShadow.opacity(0.6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.goldShadow.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                    
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
                        .padding(.vertical, 16)
                        .padding(.horizontal, 40)
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
                    .padding(.top, 10)
                }
                
                Spacer()
                
                Text("EST. 2024")
                    .font(.caption)
                    .foregroundColor(AppTheme.goldShadow.opacity(0.4))
                    .padding(.bottom, 30)
            }
        }
        .statusBar(hidden: true)
        .sheet(isPresented: $showBookSelector) {
            BookSelectorView()
        }
        .sheet(isPresented: $showChapterSelector) {
            ChapterSelectorView()
        }
    }
}
