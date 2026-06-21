import UIKit
import PDFKit
import PencilKit

struct PDFExporter {
    
    // MARK: - Layout Constants (must match UnifiedCanvasView / BibleTextView)
    private static let leftMargin: CGFloat = 20
    private static let textWidthRatio: CGFloat = 0.65
    private static let minTextWidth: CGFloat = 350
    private static let drawingYOffset: CGFloat = -20
    
    // MARK: - Font Cache (avoid repeated font lookups per export)
    private static let titleFont = UIFont(name: "IowanOldStyle-Bold", size: 30) ?? .boldSystemFont(ofSize: 30)
    private static let headerFont = UIFont(name: "IowanOldStyle-Bold", size: 36) ?? .boldSystemFont(ofSize: 36)
    private static let headingFont = UIFont(name: "IowanOldStyle-Bold", size: 24) ?? .boldSystemFont(ofSize: 24)
    private static let verseFont = UIFont.systemFont(ofSize: 20, weight: .regular)
    
    // MARK: - Public API
    
    static func exportPDF(title: String, text: String, drawing: PKDrawing, size: CGSize) -> URL? {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextCreator as String: "Bible Notes App",
            kCGPDFContextAuthor as String: "User"
        ]
        
        let pageRect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Background
            context.cgContext.setFillColor(AppTheme.uiDarkSepia.cgColor)
            context.cgContext.fill(pageRect)
            
            let textWidth = max(size.width * textWidthRatio, minTextWidth)
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: AppTheme.uiGoldHighlight
            ]
            NSAttributedString(string: title, attributes: titleAttributes)
                .draw(at: CGPoint(x: 40, y: 40))
            
            // Chapter 1 header (emblem + book name)
            var textStartTop: CGFloat = 120
            
            if title.hasSuffix(" 1") {
                if let emblem = UIImage(named: "Transparent_Main_Emblem") {
                    let emblemSize = CGSize(width: 300, height: 260)
                    let emblemX = (size.width - emblemSize.width) / 2
                    emblem.draw(in: CGRect(x: emblemX, y: 50, width: emblemSize.width, height: emblemSize.height))
                }
                
                let bookName = String(title.dropLast(2)).uppercased()
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: headerFont,
                    .foregroundColor: AppTheme.uiGoldAccent,
                    .kern: 4
                ]
                let headerString = NSAttributedString(string: bookName, attributes: headerAttributes)
                let headerX = (size.width - headerString.size().width) / 2
                headerString.draw(at: CGPoint(x: headerX, y: 350))
                
                textStartTop = 510
            }
            
            // Bible text
            let attributedText = buildAttributedText(from: text)
            let textRect = CGRect(x: leftMargin, y: textStartTop, width: textWidth, height: size.height - 120)
            attributedText.draw(in: textRect)
            
            // PencilKit drawing overlay
            let drawingImage = drawing.image(from: pageRect, scale: 1.0)
            drawingImage.draw(in: CGRect(x: 0, y: drawingYOffset, width: pageRect.width, height: pageRect.height))
        }
        
        // Save to temp
        let fileName = "BibleNotes_\(title).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: url)
            return url
        } catch {
            print("[PDFExporter] Error saving PDF: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Helpers
    
    private static func buildAttributedText(from text: String) -> NSAttributedString {
        let blocks = BibleTextParser.parse(text)
        let result = NSMutableAttributedString()
        
        for (index, block) in blocks.enumerated() {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            
            var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]
            
            if block.isHeading {
                attributes[.font] = headingFont
                attributes[.foregroundColor] = AppTheme.uiGoldHighlight
                paragraphStyle.paragraphSpacing = 90
                paragraphStyle.paragraphSpacingBefore = index == 0 ? 0 : 50
            } else {
                attributes[.font] = verseFont
                attributes[.foregroundColor] = AppTheme.uiParchmentText
                paragraphStyle.paragraphSpacing = 20
            }
            
            result.append(NSAttributedString(string: block.text + "\n", attributes: attributes))
        }
        
        return result
    }
}
