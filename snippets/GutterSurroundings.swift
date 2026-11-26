import SwiftUI
import UIKit

// The gutter is see-through, so the colour behind it is yours to paint. Playbook rule 8.

public extension View {
    /// Runs the page's background colour under the system's bars and the gutter, and sets the
    /// bars' colour scheme so their icons stay readable.
    ///
    /// - Parameters:
    ///   - color: The page's own background. nil leaves the surroundings alone, which is what you
    ///     want while a docked sidebar with its own tint is open.
    ///   - fallback: Shown when there is no page to match (a tab grid, an empty state).
    func gutterSurroundings(_ color: Color?, fallback: Color? = nil) -> some View {
        let shown = color ?? fallback
        return self
            .background {
                if let shown { shown.ignoresSafeArea() }
            }
            .toolbarColorScheme(shown.map { $0.isLight ? .light : .dark }, for: .navigationBar)
    }

    /// One neutral ink for toolbar buttons. An app-wide accent reaches gutter buttons unevenly:
    /// one comes out tinted and the one beside it grey. Apply the accent again inside the page.
    func neutralToolbarTint(_ ink: Color = .primary) -> some View {
        tint(ink)
    }
}

private extension Color {
    /// Whether dark icons read on this colour.
    var isLight: Bool {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return true }
        return 0.2126 * red + 0.7152 * green + 0.0722 * blue > 0.5
    }
}

// Use:
//
//     ArticleView(article)
//         .toolbar { articleToolbar }
//         .gutterSurroundings(isSidebarOpen ? nil : article.paperColor, fallback: Color(.systemGroupedBackground))
//         .neutralToolbarTint()
