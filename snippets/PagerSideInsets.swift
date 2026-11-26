import SwiftUI

// A horizontal pager on a screen with a side inset: the Duo's gutter, or any iPhone in landscape.
// Playbook rules 9, 20 and 21.
//
// A paging ScrollView pages by its full width. Pages sized to the width inside the safe area come
// up short by the inset, and the next page shows at the edge. So the pager spans the full width,
// and each page puts the side insets back.

private struct PagerSideInsetsKey: EnvironmentKey {
    static let defaultValue = EdgeInsets()
}

public extension EnvironmentValues {
    /// The side insets a pager page put back. A view that grows under the gutter stops seeing the
    /// gutter in its own safe area, so it reads the width from here.
    var pagerSideInsets: EdgeInsets {
        get { self[PagerSideInsetsKey.self] }
        set { self[PagerSideInsetsKey.self] = newValue }
    }
}

public extension View {
    /// On the pager's ScrollView: span the side insets and report them. Leading and trailing are
    /// read separately, because the gutter is on one side only.
    func pagerSpanningSideInsets(_ insets: Binding<EdgeInsets>) -> some View {
        self
            .ignoresSafeArea(.container, edges: .horizontal)
            .onGeometryChange(for: EdgeInsets.self) { proxy in
                EdgeInsets(top: 0, leading: proxy.safeAreaInsets.leading,
                           bottom: 0, trailing: proxy.safeAreaInsets.trailing)
            } action: { side in
                insets.wrappedValue = side
            }
    }

    /// On each page: the side insets back as safe area, so the page's content clears the gutter
    /// and its background still runs under it.
    func pagerPage(sideInsets: EdgeInsets) -> some View {
        safeAreaPadding(sideInsets)
            .environment(\.pagerSideInsets, sideInsets)
    }
}

// Use:
//
//     @State private var sideInsets = EdgeInsets()
//
//     ScrollView(.horizontal) {
//         LazyHStack(spacing: 0) {
//             ForEach(pages) { page in
//                 PageView(page)
//                     .pagerPage(sideInsets: sideInsets)
//                     .containerRelativeFrame(.horizontal)
//             }
//         }
//         .scrollTargetLayout()
//     }
//     .scrollTargetBehavior(.paging)
//     .pagerSpanningSideInsets($sideInsets)
