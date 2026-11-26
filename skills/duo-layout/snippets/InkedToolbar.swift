import SwiftUI

// One ink for toolbar icons. Playbook rule 8. Needs DuoAPIs.swift and LayoutClass.swift.
//
// Beside the Duo's gutter or a sidebar, the system's own icons (search, back, the sidebar button,
// the "…" of an overflow menu) are black and cannot be tinted. Accent-coloured icons next to them
// look mismatched, so the app's own toolbar buttons turn neutral there. On an ordinary iPhone
// they keep the accent.

private struct InkedToolbar<Items: ToolbarContent>: ViewModifier {
    @Environment(\.gutterEdge) private var gutterEdge
    @Environment(\.layoutClass) private var layoutClass

    let accent: Color
    /// True for a page that sits beside the sidebar in the wide layout.
    let besideSidebar: Bool
    let items: Items

    private var isNeutral: Bool {
        gutterEdge != nil || (besideSidebar && layoutClass == .wide)
    }

    func body(content: Content) -> some View {
        // Order matters. The bar's icons follow the tint applied after `.toolbar`, and ignore a
        // foreground style set on the icon. The tint before it keeps the accent for the page.
        content
            .tint(accent)
            .toolbar { items }
            .tint(isNeutral ? Color.primary : accent)
    }
}

public extension View {
    /// Use in place of `.toolbar { }`.
    ///
    /// Attach sheets after this call, not before it. A sheet attached before it sits inside the
    /// ink and loses the accent throughout.
    func inkedToolbar<Items: ToolbarContent>(
        accent: Color = .accentColor,
        besideSidebar: Bool = false,
        @ToolbarContentBuilder _ items: () -> Items
    ) -> some View {
        modifier(InkedToolbar(accent: accent, besideSidebar: besideSidebar, items: items()))
    }
}

// Use:
//
//     ListPage(list)
//         .inkedToolbar(accent: theme.accent, besideSidebar: true) {
//             ToolbarItem(placement: .bottomBar) {
//                 Button("Add Item", systemImage: "plus", action: add)
//             }
//             .pinnedToGutter()
//         }
//         .sheet(isPresented: $showingSettings) { SettingsSheet() }   // after, so it keeps the accent
