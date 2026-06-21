import SwiftUI
import PencilKit

struct UnifiedCanvasView: UIViewControllerRepresentable {
    @Binding var canvasView: PKCanvasView
    let filename: String
    let bibleText: String
    let viewSize: CGSize
    let isWritingMode: Bool
    
    // MARK: - Constants
    private static let textViewTag = 777
    private static let leftMargin: CGFloat = 20
    private static let textWidthRatio: CGFloat = 0.65
    private static let emptyDrawingThreshold = 60
    private static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: - Create
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        
        // Remove stale text views if canvas is reused
        canvasView.subviews
            .filter { $0.tag == Self.textViewTag }
            .forEach { $0.removeFromSuperview() }
        
        // Configure canvas
        canvasView.drawingPolicy = .pencilOnly
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.isScrollEnabled = true
        canvasView.alwaysBounceVertical = true
        canvasView.showsVerticalScrollIndicator = true
        canvasView.minimumZoomScale = 1.0
        canvasView.maximumZoomScale = 1.0
        canvasView.delegate = context.coordinator
        
        // Undo/Redo gestures
        let undoGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleUndo))
        undoGesture.numberOfTouchesRequired = 2
        undoGesture.numberOfTapsRequired = 2
        canvasView.addGestureRecognizer(undoGesture)
        
        let redoGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRedo))
        redoGesture.numberOfTouchesRequired = 3
        redoGesture.numberOfTapsRequired = 2
        canvasView.addGestureRecognizer(redoGesture)
        
        // Add canvas to VC with Auto Layout
        vc.view.addSubview(canvasView)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        // Embed Bible text as a child view controller
        let hostingController = UIHostingController(rootView: AnyView(
            BibleTextView(text: bibleText)
                .foregroundColor(AppTheme.parchmentText)
                .background(Color.clear)
        ))
        hostingController.view.backgroundColor = .clear
        hostingController.view.clipsToBounds = false
        hostingController.view.tag = Self.textViewTag
        
        vc.addChild(hostingController)
        canvasView.addSubview(hostingController.view)
        hostingController.didMove(toParent: vc)
        context.coordinator.textController = hostingController
        
        // Load saved drawing
        loadDrawing(into: canvasView)
        context.coordinator.lastFilename = filename
        
        // Setup tool picker
        context.coordinator.toolPicker = PKToolPicker()
        
        // Initial layout
        context.coordinator.updateLayout(canvas: canvasView)
        DispatchQueue.main.async {
            context.coordinator.updateLayout(canvas: canvasView)
        }
        
        return vc
    }

    // MARK: - Update
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.parent = self
        
        // Update text content
        if context.coordinator.lastText != bibleText {
            context.coordinator.lastText = bibleText
            context.coordinator.textController?.rootView = AnyView(
                BibleTextView(text: bibleText)
                    .foregroundColor(AppTheme.parchmentText)
                    .background(Color.clear)
            )
        }
        
        // Handle chapter change
        if context.coordinator.lastFilename != filename {
            if !context.coordinator.lastFilename.isEmpty {
                Self.saveDrawing(canvasView, filename: context.coordinator.lastFilename)
            }
            context.coordinator.lastFilename = filename
            loadDrawing(into: canvasView)
            canvasView.contentOffset = .zero
            canvasView.undoManager?.removeAllActions()
        }
        
        // Refresh layout
        DispatchQueue.main.async {
            context.coordinator.updateLayout(canvas: canvasView)
        }
        
        // Sync writing mode
        context.coordinator.updateWritingMode(isWriting: isWritingMode, canvas: canvasView)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: UnifiedCanvasView
        var toolPicker: PKToolPicker?
        var textController: UIHostingController<AnyView>?
        var lastText = ""
        var lastFilename = ""
        private var saveTimer: Timer?
        private var isCurrentlyWritingMode: Bool?
        
        init(_ parent: UnifiedCanvasView) {
            self.parent = parent
        }
        
        // MARK: Gestures
        
        @objc func handleUndo() {
            parent.canvasView.undoManager?.undo()
        }
        
        @objc func handleRedo() {
            parent.canvasView.undoManager?.redo()
        }
        
        // MARK: PKCanvasViewDelegate
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            saveTimer?.invalidate()
            saveTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                guard let self else { return }
                UnifiedCanvasView.saveDrawing(canvasView, filename: self.parent.filename)
            }
        }
        
        // MARK: Writing Mode
        
        func updateWritingMode(isWriting: Bool, canvas: PKCanvasView) {
            guard let toolPicker, let textContainer = textController?.view else { return }
            guard isCurrentlyWritingMode != isWriting else { return }
            isCurrentlyWritingMode = isWriting
            
            if isWriting {
                toolPicker.setVisible(true, forFirstResponder: canvas)
                toolPicker.addObserver(canvas)
                if canvas.window != nil {
                    canvas.becomeFirstResponder()
                } else {
                    DispatchQueue.main.async { canvas.becomeFirstResponder() }
                }
                canvas.sendSubviewToBack(textContainer)
                canvas.drawingGestureRecognizer.isEnabled = true
            } else {
                toolPicker.setVisible(false, forFirstResponder: canvas)
                toolPicker.removeObserver(canvas)
                canvas.resignFirstResponder()
                canvas.bringSubviewToFront(textContainer)
                canvas.drawingGestureRecognizer.isEnabled = false
            }
        }
        
        // MARK: Layout
        
        func updateLayout(canvas: PKCanvasView) {
            guard let textController, let textContainer = textController.view else { return }
            let canvasWidth = parent.viewSize.width
            guard canvasWidth > 0 else { return }
            
            let desiredTextWidth = max(canvasWidth * UnifiedCanvasView.textWidthRatio, 350)
            let textSize = textController.sizeThatFits(in: CGSize(width: desiredTextWidth, height: .greatestFiniteMagnitude))
            let drawingMaxY = canvas.drawing.bounds.isNull ? 0 : canvas.drawing.bounds.maxY
            let requiredHeight = max(textSize.height + 200, max(canvas.bounds.height, drawingMaxY + 200))
            
            textContainer.frame = CGRect(x: UnifiedCanvasView.leftMargin, y: 0, width: desiredTextWidth, height: requiredHeight)
            textContainer.setNeedsLayout()
            textContainer.layoutIfNeeded()
            
            if canvas.contentSize.height != requiredHeight || canvas.contentSize.width != canvasWidth {
                canvas.contentSize = CGSize(width: canvasWidth, height: requiredHeight)
            }
        }
    }
    
    // MARK: - Persistence
    
    private func loadDrawing(into canvas: PKCanvasView) {
        let url = Self.documentsDirectory.appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: url.path) else {
            canvas.drawing = PKDrawing()
            return
        }
        do {
            canvas.drawing = try PKDrawing(data: Data(contentsOf: url))
        } catch {
            print("[UnifiedCanvasView] Error loading '\(filename)': \(error)")
            canvas.drawing = PKDrawing()
        }
    }
    
    static func saveDrawing(_ canvas: PKCanvasView, filename: String) {
        let url = documentsDirectory.appendingPathComponent(filename)
        let data = canvas.drawing.dataRepresentation()
        
        // Don't overwrite a real drawing with an empty one
        if data.count < emptyDrawingThreshold && FileManager.default.fileExists(atPath: url.path) {
            if let existing = try? Data(contentsOf: url), existing.count > emptyDrawingThreshold {
                return
            }
        }
        
        do {
            try data.write(to: url)
        } catch {
            print("[UnifiedCanvasView] Error saving '\(filename)': \(error)")
        }
    }
    
    static func triggerSave(canvas: PKCanvasView, filename: String) {
        saveDrawing(canvas, filename: filename)
    }
}
