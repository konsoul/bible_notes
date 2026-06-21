import SwiftUI
import PencilKit

struct ReaderView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var canvasView = PKCanvasView()
    @State private var previousFilename = "John_1.data"
    @State private var showBookSelector = false
    @State private var showChapterSelector = false
    @State private var pdfItem: PDFItem?
    @State private var isWritingMode = true
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // MARK: - Header Bar
                HStack {
                    // Writing/Reading mode toggle
                    Button { isWritingMode.toggle() } label: {
                        Image(systemName: isWritingMode ? "pencil.circle.fill" : "book.circle.fill")
                            .font(.title2)
                            .foregroundColor(isWritingMode ? AppTheme.goldAccent : AppTheme.parchmentText)
                    }
                    .padding(5)
                    
                    Spacer()
                    
                    // Book selector
                    Button { showBookSelector = true } label: {
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
                    
                    // Chapter selector
                    Button { showChapterSelector = true } label: {
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
                        .cornerRadius(8)
                    }
                    .padding(.leading, 5)
                    
                    Spacer()
                    
                    // Export PDF
                    Button { exportPDF() } label: {
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
                
                // MARK: - Canvas Content
                GeometryReader { geo in
                    ZStack(alignment: .topLeading) {
                        AppTheme.darkSepia.ignoresSafeArea()
                        
                        UnifiedCanvasView(
                            canvasView: $canvasView,
                            filename: currentFilename,
                            bibleText: viewModel.bibleText,
                            viewSize: geo.size,
                            isWritingMode: isWritingMode
                        )
                    }
                }
            }
        }
        .onAppear {
            previousFilename = currentFilename
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
    
    // MARK: - Helpers
    
    private var currentFilename: String {
        "\(viewModel.currentBook)_\(viewModel.currentChapter).data"
    }
    
    private func exportPDF() {
        let title = "\(viewModel.currentBook) \(viewModel.currentChapter)"
        let size = canvasView.contentSize
        if let url = PDFExporter.exportPDF(title: title, text: viewModel.bibleText, drawing: canvasView.drawing, size: size) {
            pdfItem = PDFItem(url: url)
        }
    }
    
    private func switchChapter() {
        guard previousFilename != currentFilename else { return }
        previousFilename = currentFilename
        viewModel.fetchChapter()
    }
}

// MARK: - Share Sheet Support

struct PDFItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let processedItems: [Any] = activityItems.map { item in
            if let url = item as? URL { return PDFItemSource(url: url) }
            return item
        }
        return UIActivityViewController(activityItems: processedItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

class PDFItemSource: NSObject, UIActivityItemSource {
    let url: URL
    
    init(url: URL) { self.url = url }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any { url }
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? { url }
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String { url.lastPathComponent }
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String { "com.adobe.pdf" }
}
