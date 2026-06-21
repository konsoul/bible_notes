import SwiftUI
import PencilKit

struct UnifiedCanvasView: UIViewControllerRepresentable {
    @Binding var canvasView: PKCanvasView
    let filename: String
    let bibleText: String
    let viewSize: CGSize
    let isWritingMode: Bool
    
    // CONSTANTS
    private static let TEXT_VIEW_TAG = 777
    private static let LEFT_MARGIN: CGFloat = 20
    private static let TEXT_WIDTH_RATIO: CGFloat = 0.65
    private static let EMPTY_DRAWING_THRESHOLD = 60
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        
        // 0. CLEANUP: If reusing the canvas, remove old Bible text views
        canvasView.subviews.forEach { subview in
            if subview.tag == Self.TEXT_VIEW_TAG {
                subview.removeFromSuperview()
            }
        }
        
        // 1. Configure the Canvas
        canvasView.drawingPolicy = .pencilOnly
        canvasView.backgroundColor = .clear 
        canvasView.isOpaque = false
        canvasView.isScrollEnabled = true 
        canvasView.alwaysBounceVertical = true
        canvasView.showsVerticalScrollIndicator = true
        canvasView.minimumZoomScale = 1.0
        canvasView.maximumZoomScale = 1.0
        canvasView.delegate = context.coordinator
        
        // Add Canvas to VC
        viewController.view.addSubview(canvasView)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
        ])
        
        // 2. Embed the Bible Text (Child VC)
        let textView = AnyView(
            BibleTextView(text: bibleText)
                .foregroundColor(AppTheme.parchmentText)
                .background(Color.clear)
        )
        
        let hostingController = UIHostingController(rootView: textView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.tag = Self.TEXT_VIEW_TAG
        
        viewController.addChild(hostingController)
        canvasView.addSubview(hostingController.view)
        
        hostingController.didMove(toParent: viewController)
        context.coordinator.textController = hostingController
        
        // 4. Load Drawing
        loadDrawing(into: canvasView)
        context.coordinator.lastFilename = filename
        
        // 5. Setup ToolPicker
        context.coordinator.setupToolPicker(for: canvasView)
        
        // Force Layout
        context.coordinator.updateLayout(canvas: canvasView)
        
        DispatchQueue.main.async {
            context.coordinator.updateLayout(canvas: canvasView)
        }
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // CRITICAL: Update Coordinator's parent so it sees the new 'viewSize'
        context.coordinator.parent = self
        
        // Update the textual content if it changed
        if context.coordinator.lastText != bibleText {
            context.coordinator.lastText = bibleText
            context.coordinator.textController?.rootView = AnyView(
                BibleTextView(text: bibleText)
                    .foregroundColor(AppTheme.parchmentText)
                    .background(Color.clear)
            )
        }
        
        // CHECK FILENAME CHANGE
        if context.coordinator.lastFilename != filename {
            if !context.coordinator.lastFilename.isEmpty {
                UnifiedCanvasView.saveDrawing(canvasView, filename: context.coordinator.lastFilename)
            }
            context.coordinator.lastFilename = filename
            loadDrawing(into: canvasView)
            
            // Scroll to top when chapter changes!
            canvasView.contentOffset = .zero
            
            canvasView.undoManager?.removeAllActions()
        }
        
        // Layout Update
        DispatchQueue.main.async {
            context.coordinator.updateLayout(canvas: canvasView)
        }
        
        // HANDLING WRITING MODE
        context.coordinator.updateWritingMode(isWriting: isWritingMode, canvas: canvasView)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: UnifiedCanvasView
        var toolPicker: PKToolPicker?
        var textController: UIHostingController<AnyView>?
        var lastText: String = ""
        var lastFilename: String = ""
        private var saveTimer: Timer?
        var isCurrentlyWritingMode: Bool? = nil
        
        init(_ parent: UnifiedCanvasView) {
            self.parent = parent
        }
        
        func setupToolPicker(for canvas: PKCanvasView) {
            let toolPicker = PKToolPicker()
            self.toolPicker = toolPicker
        }
        
        // MARK: - PKCanvasViewDelegate
        // Auto-save after every stroke with a 0.5s debounce
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            saveTimer?.invalidate()
            saveTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                let filename = self.parent.filename
                UnifiedCanvasView.saveDrawing(canvasView, filename: filename)
            }
        }
        
        func updateWritingMode(isWriting: Bool, canvas: PKCanvasView) {
            guard let toolPicker = toolPicker else { return }
            guard let textContainer = textController?.view else { return }
            
            // Prevent redundant responder updates which can interrupt active strokes and corrupt PencilKit state
            if isCurrentlyWritingMode == isWriting { return }
            isCurrentlyWritingMode = isWriting
            
            if isWriting {
                // WRITING MODE: Drawing surface on top, text behind
                toolPicker.setVisible(true, forFirstResponder: canvas)
                toolPicker.addObserver(canvas)
                
                if canvas.window != nil {
                    canvas.becomeFirstResponder()
                } else {
                    DispatchQueue.main.async {
                        canvas.becomeFirstResponder()
                    }
                }
                
                canvas.sendSubviewToBack(textContainer)
                canvas.drawingGestureRecognizer.isEnabled = true
            } else {
                // READING MODE: Text on top for interaction (context menus, etc.)
                toolPicker.setVisible(false, forFirstResponder: canvas)
                toolPicker.removeObserver(canvas)
                canvas.resignFirstResponder()
                canvas.bringSubviewToFront(textContainer)
                canvas.drawingGestureRecognizer.isEnabled = false
            }
        }
        
        func updateLayout(canvas: PKCanvasView) {
            guard let textController = textController, let textContainer = textController.view else { return }
            
            let canvasWidth = parent.viewSize.width
            guard canvasWidth > 0 else { return }
            
            // Text takes 65% of the width, leaving 35% open for handwritten notes
            let desiredTextWidth = max(canvasWidth * UnifiedCanvasView.TEXT_WIDTH_RATIO, 350)
            let xPosition: CGFloat = UnifiedCanvasView.LEFT_MARGIN
            
            let size = textController.sizeThatFits(in: CGSize(width: desiredTextWidth, height: .greatestFiniteMagnitude))
            let drawingBounds = canvas.drawing.bounds
            let drawingHeight = drawingBounds.isNull ? 0 : drawingBounds.maxY
            let requiredHeight = max(size.height + 200, max(canvas.bounds.height, drawingHeight + 200))
            
            // Layout Text (left side)
            textContainer.frame = CGRect(x: xPosition, y: 0, width: desiredTextWidth, height: requiredHeight)
            textContainer.setNeedsLayout()
            textContainer.layoutIfNeeded()
            
            if canvas.contentSize.height != requiredHeight || canvas.contentSize.width != canvasWidth {
                canvas.contentSize = CGSize(width: canvasWidth, height: requiredHeight)
            }
        }
    }
    
    // MARK: - Persistence
    private func loadDrawing(into canvas: PKCanvasView) {
        let url = UnifiedCanvasView.getDocumentsDirectory().appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                let drawing = try PKDrawing(data: data)
                canvas.drawing = drawing
            } catch {
                print("[UnifiedCanvasView] Error loading drawing '\(filename)': \(error)")
            }
        } else {
            canvas.drawing = PKDrawing()
        }
    }
    
    static func saveDrawing(_ canvas: PKCanvasView, filename: String) {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        let data = canvas.drawing.dataRepresentation()
        
        if data.count < UnifiedCanvasView.EMPTY_DRAWING_THRESHOLD && FileManager.default.fileExists(atPath: url.path) {
            do {
                let existingData = try Data(contentsOf: url)
                if existingData.count > UnifiedCanvasView.EMPTY_DRAWING_THRESHOLD { return }
            } catch {
                print("[UnifiedCanvasView] Error checking existing drawing: \(error)")
            }
        }
        
        do {
            try data.write(to: url)
        } catch {
            print("[UnifiedCanvasView] Error saving drawing '\(filename)': \(error)")
        }
    }
    
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func triggerSave(canvas: PKCanvasView, filename: String) {
        saveDrawing(canvas, filename: filename)
    }
}
