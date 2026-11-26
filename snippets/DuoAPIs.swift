import SwiftUI

// Every iPhone Duo API the app uses goes through this file. Playbook rules 5, 10 and 22.
//
// Build with the NO_DUO_SDK compilation condition on a machine whose Xcode has no iOS 27.1 SDK
// (CI, for example). The stand-ins below do nothing, and the rest of the app still compiles.
//
//     SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) NO_DUO_SDK'

// MARK: - Where the gutter is

#if NO_DUO_SDK
private struct GutterEdgeStandIn: EnvironmentKey {
    static let defaultValue: HorizontalEdge? = nil
}
#endif

public extension EnvironmentValues {
    /// The side the system put its vertical bar on. nil when there is none: an iPad, an ordinary
    /// iPhone, the Duo open in portrait.
    var gutterEdge: HorizontalEdge? {
        #if NO_DUO_SDK
        return self[GutterEdgeStandIn.self]
        #else
        if #available(iOS 27.1, *) {
            return toolbarVerticalEdge
        } else {
            return nil
        }
        #endif
    }
}

// MARK: - The view's side of the bargain

public extension View {
    /// Keep toolbar items in the gutter and compress the tab bar first.
    @ViewBuilder func gutterPrefersToolbarItems() -> some View {
        #if NO_DUO_SDK
        self
        #else
        if #available(iOS 27.1, *) {
            toolbarVerticalCompressionBehavior(.prefersToolbarItems)
        } else {
            self
        }
        #endif
    }

    /// Turn the gutter off for this view. For a screen that draws its own bar.
    @ViewBuilder func gutterDisabled() -> some View {
        #if NO_DUO_SDK
        self
        #else
        if #available(iOS 27.1, *) {
            toolbarVerticalBehavior(.disabled)
        } else {
            self
        }
        #endif
    }
}

// MARK: - Where each toolbar item lives

public extension ToolbarContent {
    /// In the gutter, and never in the overflow menu. For the top of the ranked list.
    @ToolbarContentBuilder func pinnedToGutter() -> some ToolbarContent {
        #if NO_DUO_SDK
        self
        #else
        if #available(iOS 27.1, *) {
            axisBehavior(.verticalPreferred).visibilityPriority(.high)
        } else {
            self
        }
        #endif
    }

    /// In the top bar, even when there is a gutter. For a profile avatar, which belongs top left
    /// on every phone.
    @ToolbarContentBuilder func pinnedToTopBar() -> some ToolbarContent {
        #if NO_DUO_SDK
        self
        #else
        if #available(iOS 27.1, *) {
            axisBehavior(.horizontalOnly)
        } else {
            self
        }
        #endif
    }
}

// MARK: - Your own overflow menu

/// The bottom of the ranked list: actions that do not earn a slot in the gutter. Before iOS 27
/// there is no gutter, so the same actions are ordinary toolbar buttons.
///
///     .toolbar {
///         ToolbarItem(placement: .topBarTrailing) { NotificationsButton() }.pinnedToGutter()
///         GutterOverflow {
///             Button("Export", systemImage: "square.and.arrow.up", action: export)
///         }
///     }
public struct GutterOverflow<Actions: View>: ToolbarContent {
    private let actions: Actions

    public init(@ViewBuilder actions: () -> Actions) {
        self.actions = actions()
    }

    public var body: some ToolbarContent {
        #if NO_DUO_SDK
        fallback
        #else
        if #available(iOS 27.0, *) {
            ToolbarOverflowMenu { actions }
        } else {
            fallback
        }
        #endif
    }

    private var fallback: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            // Titles stay on the buttons. A row built from an image alone comes up empty when the
            // system moves it into a menu.
            actions.labelStyle(.iconOnly)
        }
    }
}
