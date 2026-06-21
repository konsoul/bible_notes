import SwiftUI
import PencilKit

struct ReaderView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var canvasView = PKCanvasView()
    // Track the filename of the *current* visible content so we save correctly when leaving
    @State private var previousFilename: String = "John_1.data" 
    
    @State private var showBookSelector: Bool = false
    @State private var showChapterSelector: Bool = false
    @State private var pdfItem: PDFItem?
    @State private var canvasSize: CGSize?
    @State private var isWritingMode: Bool = true // Default to Writing Mode
    


    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // MAIN CONTENT
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        // LEFT: Blank for balance (or could be Settings later)
                        // LEFT: Mode Toggle
                        Button(action: {
                            isWritingMode.toggle()
                        }) {
                            Image(systemName: isWritingMode ? "pencil.circle.fill" : "book.circle.fill")
                                .font(.title2)
                                .foregroundColor(isWritingMode ? AppTheme.goldAccent : AppTheme.parchmentText)
                        }
                        .padding(5)
                        
                        Spacer()
                        
                        // CENTER: Book Selector Trigger
                        Button(action: {
                            showBookSelector = true
                        }) {
                            HStack {
                                Text(viewModel.currentBook)
                                    .font(.title3.bold())
                                    .foregroundColor(AppTheme.goldAccent)
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.goldAccent.opacity(0.8))
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(AppTheme.lighterSepia.opacity(0.5))
                            .cornerRadius(8)
                        }
                        
                        // Chapter Selector Trigger
                        Button(action: {
                            showChapterSelector = true
                        }) {
                            HStack {
                                Text("\(viewModel.currentChapter)")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.parchmentText)
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.parchmentText.opacity(0.8))
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            //.background(AppTheme.lighterSepia.opacity(0.3)) // Optional bg
                            .cornerRadius(8)
                        }
                        .padding(.leading, 5)
                        
                        Spacer()
                        // Export Button
                        Button(action: {
                            exportPDF()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                                .foregroundColor(AppTheme.goldAccent)
                        }
                        .padding(5)
                    }
                    .padding()
                    .background(AppTheme.darkSepia)
                    .shadow(radius: 5)
                    .zIndex(1)


                    
                    // Unified Canvas Content
                    GeometryReader { geo in
                        ZStack(alignment: .topLeading) {
                            // Background (Applies to whole screen)
                            AppTheme.darkSepia
                                .ignoresSafeArea()
                            
                            // Unified Canvas (Holds Text + Drawing)
                            UnifiedCanvasView(
                                canvasView: $canvasView,
                                filename: currentFilename,
                                bibleText: viewModel.bibleText,
                                viewSize: geo.size,
                                isWritingMode: isWritingMode
                            )
                            .onAppear {
                                self.canvasSize = geo.size
                            }
                            .onChange(of: geo.size) { _, newSize in
                                self.canvasSize = newSize
                            }
                            // REMOVED .id(currentFilename) to allow UnifiedCanvasView to persist and update via updateUIView
                            // This keeps the ToolPicker and Coordinator alive.
                        }
                    }
                }
            }
        }
        .onAppear {
            // Initialize previousFilename to match startup state
            self.previousFilename = currentFilename
        }
        .onDisappear {
            UnifiedCanvasView.triggerSave(canvas: canvasView, filename: previousFilename)
        }
        .onChange(of: currentFilename) { _, _ in
            switchChapter()
        }
        .sheet(isPresented: $showBookSelector) {
            BookSelectorView()
        }
        .sheet(isPresented: $showChapterSelector) {
            ChapterSelectorView()
        }
        .sheet(item: $pdfItem) { item in
            ShareSheet(activityItems: [item.url])
        }

    }
    
    private func exportPDF() {
        let title = "\(viewModel.currentBook) \(viewModel.currentChapter)"
        
        let size = canvasView.contentSize
        if let url = PDFExporter.exportPDF(title: title, text: viewModel.bibleText, drawing: canvasView.drawing, size: size) {
            self.pdfItem = PDFItem(url: url)
        }
    }


    
    private func switchChapter() {
        // GUARD: Prevent redundant updates (e.g. when View loads or both book/chapter change)
        if previousFilename == currentFilename {
            return
        }
        
        // 1. Save and Undo clear are now handled safely inside UnifiedCanvasView.updateUIViewController
        // to prevent race conditions.
        
        // 2. Update previousFilename to the NEW one IMMEDIATELY
        // Accessing currentFilename here is safe as it relies on viewModel which is already updated
        self.previousFilename = self.currentFilename
        
        // 3. Fetch the NEW Bible Text
        viewModel.fetchChapter()
    }
    
    var currentFilename: String {
        "\(viewModel.currentBook)_\(viewModel.currentChapter).data"
    }
}

// Helper for Share Sheet
struct PDFItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
