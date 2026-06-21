import UIKit
import PencilKit

class SnapshotExporter {
    
    static func exportImage(canvasView: PKCanvasView, title: String, text: String) -> URL? {
        // 1. Capture the Full Content
        guard let image = captureFullContent(of: canvasView, text: text, title: title) else { return nil }
        
        // 2. Save to Temporary File
        let fileName = "BibleNotes_\(title).png"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            if let data = image.pngData() {
                try data.write(to: url)
                return url
            }
        } catch {
            print("Error saving image: \(error)")
        }
        
        return nil
    }
    
    private static func captureFullContent(of canvasView: PKCanvasView, text: String, title: String) -> UIImage? {
        let size = canvasView.contentSize
        // Ensure somewhat valid size
        let captureSize = CGSize(width: max(size.width, 768), height: max(size.height, 1024))
        
        let renderer = UIGraphicsImageRenderer(size: captureSize)
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 1. Draw Background
            let bgRect = CGRect(origin: .zero, size: captureSize)
            cgContext.setFillColor(UIColor(hex: "F9F6EE").cgColor) // AppTheme.darkSepia
            cgContext.fill(bgRect)
            
            // 2. Setup Text Width (65% of page, matching screen layout)
            let leftMargin: CGFloat = 20
            let textWidth = max(captureSize.width * 0.65, 350)
            

            
            // Check for Title/Emblem (From PDF logic)
            var textStartTop: CGFloat = 120
           
            // (Simplified Title Drawing for Snapshot - Reusing PDF Logic would be ideal but duplicated here for speed)
             let titleFont = UIFont(name: "IowanOldStyle-Bold", size: 30) ?? UIFont.boldSystemFont(ofSize: 30)
             let titleAttributes: [NSAttributedString.Key: Any] = [
                 .font: titleFont,
                 .foregroundColor: UIColor(hex: "F9E076") // AppTheme.goldHighlight
             ]
             let titleString = NSAttributedString(string: title, attributes: titleAttributes)
             titleString.draw(at: CGPoint(x: 40, y: 40))
             
             if title.hasSuffix(" 1") {
                 let bookName = title.dropLast(2).uppercased()
                 let headerFont = UIFont(name: "IowanOldStyle-Bold", size: 36) ?? UIFont.boldSystemFont(ofSize: 36)
                 let headerAttributes: [NSAttributedString.Key: Any] = [
                     .font: headerFont,
                     .foregroundColor: UIColor(hex: "E6DCC8"),
                     .kern: 4
                 ]
                 let headerString = NSAttributedString(string: bookName, attributes: headerAttributes)
                 let headerSize = headerString.size()
                 let headerX = (captureSize.width - headerSize.width) / 2
                 headerString.draw(at: CGPoint(x: headerX, y: 330))
                 textStartTop = 410
             }

            
            // Parse Blocks
            let blocks = BibleTextParser.parse(text)
            let finalAttribString = NSMutableAttributedString()
            
            for (index, block) in blocks.enumerated() {
                var attributes: [NSAttributedString.Key: Any] = [:]
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 10 
                
                if block.isHeading {
                    let headingFont = UIFont(name: "IowanOldStyle-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
                    attributes[.font] = headingFont
                    attributes[.foregroundColor] = UIColor(hex: "F9E076") 
                    paragraphStyle.paragraphSpacing = 90
                    paragraphStyle.paragraphSpacingBefore = index == 0 ? 0 : 50 
                } else {
                    let verseFont = UIFont.systemFont(ofSize: 20, weight: .regular)
                    attributes[.font] = verseFont
                    attributes[.foregroundColor] = UIColor(hex: "E6DCC8") 
                    paragraphStyle.paragraphSpacing = 20
                }
                attributes[.paragraphStyle] = paragraphStyle
                let blockString = NSAttributedString(string: block.text + "\n", attributes: attributes)
                finalAttribString.append(blockString)
            }
            
            // Draw Text
            let textRect = CGRect(x: leftMargin, y: textStartTop, width: textWidth, height: captureSize.height - 120)
            finalAttribString.draw(in: textRect)
            
            // 4. Draw PencilKit Drawing (Overlay)
            // Need to match PDF offset logic (approx 20pt down)
            let drawingYOffset: CGFloat = 20 
            let drawingRect = CGRect(x: 0, y: drawingYOffset, width: captureSize.width, height: captureSize.height)
            
            // Getting image from drawing is fast
            let image = canvasView.drawing.image(from: CGRect(origin: .zero, size: captureSize), scale: 1.0)
            image.draw(in: drawingRect)
        }
    }
}
