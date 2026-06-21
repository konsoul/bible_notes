import UIKit
import PDFKit
import PencilKit

class PDFExporter {
    static func exportPDF(title: String, text: String, drawing: PKDrawing, size: CGSize) -> URL? {
        // 1. Setup PDF Format
        let pdfMetaData = [
            kCGPDFContextCreator: "Bible Notes App",
            kCGPDFContextAuthor: "User"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // 2. Define Page Size
        // We use the passed 'size' (which comes from UnifiedCanvasView geometry)
        // OR we use a standard A4 if size is zero/weird.
        let pageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // 3. Create Renderer
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            // 4. Draw Background
            let bgContext = context.cgContext
            bgContext.setFillColor(UIColor(hex: "F9F6EE").cgColor) // AppTheme.darkSepia
            bgContext.fill(pageRect)
            
            // 5. Setup Text Width (65% of page, matching screen layout)
            let leftMargin: CGFloat = 20
            let textWidth = max(size.width * 0.65, 350)
            
            // 6. Draw Title (Standard Small Header)
            let titleFont = UIFont(name: "IowanOldStyle-Bold", size: 30) ?? UIFont.boldSystemFont(ofSize: 30)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor(hex: "F9E076") // AppTheme.goldHighlight
            ]
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: 40, y: 40))
            
            // 6. Check for Chapter 1 (Book Introduction)
            var textStartTop: CGFloat = 160 // Increased to match screen top padding + Zapfino height
            
            if title.hasSuffix(" 1") { // Detection for Chapter 1
                // Load Emblem
                if let emblem = UIImage(named: "Transparent_Main_Emblem") {
                    let emblemSize = CGSize(width: 300, height: 260) // Made bigger (was 250x220)
                    let emblemX = (size.width - emblemSize.width) / 2
                    let emblemRect = CGRect(x: emblemX, y: 50, width: emblemSize.width, height: emblemSize.height)
                    
                    // Draw Emblem (Tinted Gold manually or assuming asset is gold)
                    emblem.draw(in: emblemRect)
                }
                
                // Draw Book Name (Big, Centered)
                // Extract Book Name: "John 1" -> "JOHN"
                let bookName = title.dropLast(2).uppercased() // Remove " 1"
                
                let headerFont = UIFont(name: "IowanOldStyle-Bold", size: 36) ?? UIFont.boldSystemFont(ofSize: 36)
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: headerFont,
                    .foregroundColor: UIColor(hex: "D4AF37"), // Gold
                    .kern: 4 // Wide tracking
                ]
                
                let headerString = NSAttributedString(string: bookName, attributes: headerAttributes)
                let headerSize = headerString.size()
                let headerX = (size.width - headerSize.width) / 2
                // Push Title down below the bigger emblem
                headerString.draw(at: CGPoint(x: headerX, y: 350))
                
                // Push text down significantly to account for screen's Zapfino drop-cap bounding box
                textStartTop = 550 // Was 410
            }
            
            // 7. Draw Text (Using BibleTextParser for Rich Layout)
            
            // Parse Blocks
            let blocks = BibleTextParser.parse(text)
            let finalAttribString = NSMutableAttributedString()
            
            for (index, block) in blocks.enumerated() {
                var attributes: [NSAttributedString.Key: Any] = [:]
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 10 // Match Screen .lineSpacing(10)
                
                if block.isHeading {
                    // HEADING STYLE
                    let headingFont = UIFont(name: "IowanOldStyle-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
                    attributes[.font] = headingFont
                    attributes[.foregroundColor] = UIColor(hex: "F9E076") // Gold
                    
                    // Extra spacing for heading: Match Screen Zapfino Height (HUGE)
                    // The Zapfino font + Divider + Padding on screen takes up ~100pts
                    paragraphStyle.paragraphSpacing = 90
                    paragraphStyle.paragraphSpacingBefore = index == 0 ? 0 : 50 
                } else {
                    // VERSE STYLE
                    // Match Screen Font (20) exactly to preserve wrapping
                    let verseFont = UIFont.systemFont(ofSize: 20, weight: .regular)
                    attributes[.font] = verseFont
                    attributes[.foregroundColor] = UIColor(hex: "222222") // Dark Charcoal
                    
                    // Match Screen VStack(spacing: 20)
                    paragraphStyle.paragraphSpacing = 20
                }
                
                attributes[.paragraphStyle] = paragraphStyle
                
                let blockString = NSAttributedString(string: block.text + "\n", attributes: attributes)
                finalAttribString.append(blockString)
            }
            
            // Draw Text in Rect
            // Start at Calculated Top
            let textRect = CGRect(x: leftMargin, y: textStartTop, width: textWidth, height: size.height - 120)
            finalAttribString.draw(in: textRect)
            
            // 7. Draw PencilKit Drawing (Overlay)
            // Tuning: Previous 0 was VERY close.
            // Screenshot shows Drawing is slightly HIGH relative to text (Center vs Bottom of word).
            // Pushing drawing DOWN by 20pts to align perfectly.
            let drawingYOffset: CGFloat = 20 
            
            let image = drawing.image(from: pageRect, scale: 1.0)
            let drawingRect = CGRect(x: 0, y: drawingYOffset, width: pageRect.width, height: pageRect.height)
            image.draw(in: drawingRect)
        }
        
        // 8. Save to Temp File
        let fileName = "BibleNotes_\(title).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: url)
            return url
        } catch {
            print("Could not create PDF file: \(error)")
            return nil
        }
    }
}

