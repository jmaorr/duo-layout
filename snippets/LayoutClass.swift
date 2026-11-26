import SwiftUI

// Chooses the phone or the iPad layout from the room the content has.
// Playbook rules 11 to 15. Needs iOS 17.

/// How much room a container has. Views read this, not the size classes and not the device.
public enum LayoutClass: Equatable, Sendable {
    /// The phone layout: the Duo's outer display, any iPhone, a narrow Split View.
    case compact
    /// The iPad layout: the Duo's inner display, an iPad, a Mac window.
    case wide
}

public enum LayoutThresholds {
    public static let wideMinWidth: CGFloat = 700
    /// A big iPhone in landscape is wide enough but short. Anything this short is a phone.
    public static let wideMinHeight: CGFloat = 500
}

/// Resolves the class as the container changes size, and ignores the keyboard.
///
/// The keyboard shrinks the container's height. Without this, an iPad in landscape drops under
/// `wideMinHeight` and turns into the phone layout while the user is typing. The height test only
/// exists to tell a phone in landscape from an iPad, so the tallest height seen at this width is
/// the one that counts. A new width (rotation, a fold, Split View) starts again.
public struct LayoutClassTracker: Sendable {
    private var width: CGFloat = -1
    private var tallest: CGFloat = 0

    public init() {}

    public mutating func measure(_ size: CGSize) -> LayoutClass {
        if abs(size.width - width) > 0.5 {
            width = size.width
            tallest = size.height
        } else {
            tallest = max(tallest, size.height)
        }
        let isWide = width >= LayoutThresholds.wideMinWidth && tallest >= LayoutThresholds.wideMinHeight
        return isWide ? .wide : .compact
    }
}

private struct LayoutClassKey: EnvironmentKey {
    static let defaultValue: LayoutClass = .compact
}

public extension EnvironmentValues {
    var layoutClass: LayoutClass {
        get { self[LayoutClassKey.self] }
        set { self[LayoutClassKey.self] = newValue }
    }
}

/// `--layout compact` or `--layout wide` on the command line picks the layout without a real fold.
/// For UI tests and screenshots.
enum LayoutOverride {
    static var forced: LayoutClass? {
        #if DEBUG
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--layout"), i + 1 < args.count else { return nil }
        switch args[i + 1] {
        case "compact": return .compact
        case "wide": return .wide
        default: return nil
        }
        #else
        return nil
        #endif
    }
}

private struct ResolvesLayoutClass: ViewModifier {
    @State private var tracker = LayoutClassTracker()
    /// nil until the first measurement, so the wrong layout is never built and thrown away.
    @State private var resolved: LayoutClass? = LayoutOverride.forced

    func body(content: Content) -> some View {
        Group {
            if let resolved {
                content.environment(\.layoutClass, resolved)
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            // Measured behind the content and under the keyboard, so the keyboard does not read as
            // a short window.
            Color.clear
                .ignoresSafeArea(.keyboard)
                .onGeometryChange(for: CGSize.self) { $0.size } action: { size in
                    guard LayoutOverride.forced == nil, size.width > 0 else { return }
                    let next = tracker.measure(size)
                    if next != resolved { resolved = next }
                }
        }
        // Swap layouts outright. A cross-fade keeps both alive, and two layouts holding the same
        // web view or map leave one of them blank.
        .transaction(value: resolved) { t in
            t.animation = nil
            t.disablesAnimations = true
        }
    }
}

public extension View {
    /// Put this on the root of each screen (each tab's content, each split column). The content
    /// then reads `@Environment(\.layoutClass)`.
    func resolvesLayoutClass() -> some View {
        modifier(ResolvesLayoutClass())
    }
}

// Use:
//
//     struct HomeScreen: View {
//         @Environment(\.layoutClass) private var layoutClass
//         var body: some View {
//             switch layoutClass {
//             case .compact: PhoneHome()
//             case .wide: WideHome()
//             }
//         }
//     }
//
//     HomeScreen().resolvesLayoutClass()
