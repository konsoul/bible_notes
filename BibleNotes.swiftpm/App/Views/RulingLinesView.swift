import SwiftUI

struct RulingLinesView: View {
    // Standard "College Rule" is about 7.1mm spacing. 
    // On iOS points, that's roughly 20-30 points depending on "feel".
    // Let's go with 28 points for a comfortable note-taking size.
    let lineSpacing: CGFloat = 40 
    let lineColor: Color = AppTheme.goldAccent.opacity(0.3) // Light golden color
    
    var body: some View {
        GeometryReader { geo in
            Path { path in
                for y in stride(from: lineSpacing, to: geo.size.height, by: lineSpacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(lineColor, lineWidth: 1)
        }
    }
}
