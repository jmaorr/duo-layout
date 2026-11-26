# iPhone Duo Layout Playbook

How to make a SwiftUI app feel at home on the iPhone Duo. These rules come from shipping three apps on it: Torqa (training), Browsa (a browser) and Writa (notes). Each rule is followed by the reason, and where it helps, by what went wrong before the rule existed.

The short version:

1. The outer display is a phone. The inner display is an iPad. Build those two layouts and nothing else.
2. The one new thing is the **gutter**: the system's vertical bar beside the page. Decide what goes in it on purpose.
3. Choose the layout from the size of the window, never from the device or the hinge.

Sample code is in [`snippets/`](snippets/). Agents should start from [`skills/duo-layout/SKILL.md`](skills/duo-layout/SKILL.md).

---

## 1. The device

| Posture | What it is | Size class | Gutter |
| --- | --- | --- | --- |
| Closed, outer display | A small phone, about 466 × 678 pt | Compact width | Yes |
| Open, landscape | A small iPad, about 951 × 669 pt | Regular width | Yes |
| Open, portrait | A small iPad on its side | Regular width | No |

Point sizes were measured in the simulator, so check them against your own build before you rely on a number.

The gutter takes about 84 pt from one side of the screen. It is on one side only, so the side safe-area insets are not equal.

An iPad never has a gutter. Neither does an ordinary iPhone. That is why the gutter is the part of this work that an existing iPad layout does not already solve.

---

## 2. The gutter

The gutter is a column the system draws beside your page. It holds your tab bar (if you use the system's), your toolbar items, and sometimes another app's Live Activity. You do not control how much room you get.

### Rule 1: Rank your actions, and let the list decide

For each screen, list the primary actions in order of use, most used first. Navigation (your tabs) goes at the top of the list.

- The gutter takes items from the top of the list until it is full.
- The items at the bottom of the list are the ones that drop off.
- Dropped items go into one overflow menu that you declare yourself.

Write the list down before you build. It is the design. An agent should stop and get the list approved before it touches a layout.

### Rule 2: Declare the overflow, do not tune it

The system will move items into its own "…" menu when room runs out. Do not rely on that order, because the room changes when a Live Activity appears.

Put the items that must stay in the gutter there, and put the rest in your own `ToolbarOverflowMenu`. The layout then never depends on what fits.

```swift
ToolbarItem(placement: .topBarTrailing) { NotificationsButton() }
ToolbarOverflowMenu {
    Button("Export", systemImage: "square.and.arrow.up", action: export)
}
```

> **Torqa.** Home first tuned overflow priorities. A Live Activity from another app took part of the gutter and the order changed. Declaring the gutter (two buttons, the rest in a menu) fixed it.

### Rule 3: Keep the number of tabs fixed

The tab bar shares the gutter with the toolbar. A tab that appears and disappears with the layout changes the count, and one tab too many pushes the others out of their slots.

Pick a number that fits (five worked) and keep it the same in every posture. If a destination only makes sense on a wide screen, reach it from inside another tab.

> **Torqa.** An Analytics tab was shown only on wide layouts. On the Duo it became a sixth item: two tabs dropped over a third, and the rest collapsed into a "…" that opened nothing. Analytics is now a segment inside Home on the phone family.

### Rule 4: Give every toolbar button a title

When the system moves a button into its overflow menu, it builds the menu row from the button's title. A button with only an image leaves an empty row.

Use `Label` (or `Button("Title", systemImage:)`) and hide the title with `.labelStyle(.iconOnly)`.

### Rule 5: Say where each item lives

- Items that belong in the gutter: `.axisBehavior(.verticalPreferred)` with `.visibilityPriority(.high)`.
- Items that belong in the top bar (a profile avatar, for example): `.axisBehavior(.horizontalOnly)`.
- Items with `placement: .bottomBar` land at the far end of the gutter, next to the thumb. Use that for the most used action.
- If your toolbar items matter more than the tab bar, set `.toolbarVerticalCompressionBehavior(.prefersToolbarItems)` on the view.
- If you draw your own bar and do not want the gutter, set `.toolbarVerticalBehavior(.disabled)`.

> **Browsa.** Back, forward and the page menu sit at the top of the gutter. New tab and tabs use `.bottomBar` and land by the thumb. The address stays in a capsule at the bottom of the page.

### Rule 6: Nothing arrives late

Everything in the gutter must be there on the first layout. An item that appears a moment later pushes the others down.

> **Torqa.** The sidebar's footer (the rider's avatar) loaded after the tabs. On the Duo the footer dropped into the gutter and left one tab out of its slot. The footer is now iPad and Mac only.

### Rule 7: The gutter does not move

Stop the tab bar minimising on scroll on the phone family:

```swift
.tabBarMinimizeBehavior(UIDevice.current.userInterfaceIdiom == .phone ? .never : .automatic)
```

> **Torqa.** The bar minimised as Home scrolled, the page grew by 58 pt, a long list measured itself again, the bar came back, and the scroll stuck near the top.

### Rule 8: Paint behind the gutter

The gutter is see-through. It shows whatever your view draws behind it, so the colour there is your job.

- Run the page's own background under the gutter with `.background { color.ignoresSafeArea() }`.
- Set the bar's colour scheme to match, so icons stay readable: `.toolbarColorScheme(isLight ? .light : .dark, for: .navigationBar)`.
- Have a neutral colour ready for moments with no page (a tab grid, an empty state).
- If a docked sidebar has its own tint, let the sidebar win and turn the page colour off while it is open.
- Tint toolbar buttons with a neutral ink. An app-wide accent reaches gutter buttons unevenly.

See [`snippets/GutterSurroundings.swift`](snippets/GutterSurroundings.swift).

> **Browsa.** The web page's background colour runs under the gutter, as in Safari, and the status items flip between light and dark with it. While the tab gallery is up, the colour is the system's grouped background.
>
> **Torqa.** The tab shell's orange accent tinted "…" but not the bell beside it. Home's toolbar is now tinted with the primary text colour, and the page applies the accent again for its own content.

One limit: on iPad the system sidebar's grey is its own. No background and no `backgroundExtensionEffect` reaches it. Leave it alone, or build a custom sidebar.

### Rule 9: Content may run under the gutter, controls may not

A chart, a map or a hero image can bleed under the gutter. Anything a finger must reach stays inside the safe area.

There is one trap. A view that grows into the gutter no longer sees the gutter in its own safe area. It reads an inset of zero and shrinks back. Measure the inset higher up and pass it down. See section 6.

### Rule 10: Read the edge, do not assume it

`@Environment(\.toolbarVerticalEdge)` tells you which side the gutter is on, and is `nil` when there is none. Use it to:

- choose between the gutter layout and the no-gutter layout;
- put your own sidebar on the opposite edge, so the two never stack.

---

## 3. No gutter

On iPad, and on the Duo open in portrait, there is no gutter. The same ranked list still decides everything:

- The top items go in a bar at the bottom of the page, in reach of the thumbs.
- The rest go in the same overflow menu as before.

Do not leave the controls at the top of a big screen because that is where a navigation bar puts them. With no gutter, the tools belong at the bottom.

> **Browsa.** `NoGutterBar`: the sidebar button and plus at the edges, back and forward beside the address, and the page menu in the address sheet.

Every wide screen therefore needs two arrangements from one list: with a gutter, and without.

---

## 4. Choosing the layout

### Rule 11: Measure the window

Do not ask what device this is. Do not read the hinge angle. Ask how much room the content has.

```
wide    = width >= 700 pt and height >= 500 pt
compact = everything else
```

The height test matters. A large iPhone in landscape is regular width, but it is short, and it is still a phone.

This one rule covers the Duo opening, an iPad in Split View, a resized Mac window and rotation. See [`snippets/LayoutClass.swift`](snippets/LayoutClass.swift).

> **Browsa** uses the size classes instead: regular width and not compact height. That is fine for a full-screen app. Measure the container if your content can sit beside a sidebar or in a split.

### Rule 12: The keyboard must not change the layout

The keyboard shrinks the container. On an iPad in landscape the height can fall below 500 pt, the layout turns into the phone layout, the text field is rebuilt and loses focus, and the keyboard goes away again.

Keep the tallest height you have seen at the current width. Start again only when the width changes.

> **Torqa and Writa** both hit this, and both fixed it the same way.

### Rule 13: Draw nothing until you have measured

Before the first measurement the container is 0 pt wide. If you default to compact, you build the phone layout and then throw it away. Hold the resolved layout as an optional and draw a clear view until it has a value.

### Rule 14: Two layouts

Do not build a third layout for the Duo. The outer display uses your phone layout and the inner display uses your iPad layout. The differences are the gutter and the insets, and you handle those inside the two layouts.

---

## 5. Folding

### Rule 15: Swap the layout outright

When the posture changes, replace one layout with the other with no animation:

```swift
.transaction(value: layoutClass) { t in
    t.animation = nil
    t.disablesAnimations = true
}
```

A cross-fade keeps both layouts alive for a moment. If both hold the same heavy view (a web view, a map, a video player), one of them loses it.

> **Browsa.** Cross-fading left a blank page with dead controls after unfolding.

### Rule 16: A transition needs both ends in both layouts

Do not use a zoom or matched transition whose source view exists in only one layout.

> **Browsa.** A zoom from the new-tab button caused a blank page on the first unfold. Removing the zoom fixed it.

### Rule 17: State lives above the layouts

Selection, scroll position, the current page of a pager and any text being typed belong in a model above both layouts. Fold and unfold, and the user must be where they were.

> **Torqa.** Home's segment bar and pager now stay on the same page across a fold.

### Rule 18: One owner for a heavy view

If both layouts show the same web view or map, a host may only take it once the host is in a window. A host that takes it during creation can take it from the layout that is still on screen.

---

## 6. Insets

### Rule 19: Each edge on its own

The gutter makes the side insets unequal. Never write `width - 2 * inset`. Read leading and trailing separately.

### Rule 20: Full-width pagers span the insets

A paging `ScrollView` pages by its full width. If each page is sized to the width inside the safe area, pages come up short by the width of the gutter, and the next page shows at the edge.

Let the pager ignore the horizontal safe area, measure the side insets, and have each page put them back as safe-area padding. Pass the insets down in the environment for content that runs under the gutter (Rule 9).

See [`snippets/PagerSideInsets.swift`](snippets/PagerSideInsets.swift).

### Rule 21: Measure outside the navigation stack

Inside a `NavigationStack`, a bar that is being hidden still counts as safe area for a moment. Measure top insets outside the stack.

---

## 7. Keeping it buildable

### Rule 22: One file for the Duo's APIs

Put every call to a Duo-only API behind your own small wrapper, in one file. The rest of the app never names those APIs.

- Guard each call with `#available(iOS 27.1, *)`.
- Add a compile flag (`NO_DUO_SDK`) with no-op stand-ins, so a CI machine with an older Xcode still builds and type-checks the app.

See [`snippets/DuoAPIs.swift`](snippets/DuoAPIs.swift).

APIs used (iOS 27.0 and 27.1):

| API | Use |
| --- | --- |
| `EnvironmentValues.toolbarVerticalEdge` | Which side the gutter is on, or `nil` |
| `View.toolbarVerticalBehavior(.disabled)` | Turn the gutter off for a view |
| `View.toolbarVerticalCompressionBehavior(.prefersToolbarItems)` | Keep toolbar items, compress tabs first |
| `ToolbarContent.axisBehavior(.verticalPreferred / .horizontalOnly)` | Gutter or top bar |
| `ToolbarContent.visibilityPriority(.high)` | Keep out of overflow |
| `ToolbarOverflowMenu` | Your own "…" menu |

---

## 8. Testing

- **Add a launch argument that forces the layout** (`--layout compact` or `--layout wide`). UI tests and screenshots then need no real fold.
- **Fold the simulator from Device Hub**, the app inside Xcode. Its device window has Closed and Open buttons. `simctl` has no fold command, and forcing the display off with it crashed SpringBoard.
- **Check four states**: closed, open landscape, open portrait, and an iPad.
- **Fold while something is happening**: with the keyboard up, in the middle of a scroll, with a sheet open, on the second page of a pager.
- **Confirm on a device before you chase a simulator glitch.** Blank paints during a fold showed up in the simulator and not on the phone.
- **Start another app's Live Activity**, then look at your gutter.
- **Screenshot sizes** for the App Store: inner 2853 × 2007 px, outer 1398 × 2034 px.

---

## 9. Checklist

Gutter
- [ ] Each screen has a ranked list of primary actions
- [ ] Overflow is your own `ToolbarOverflowMenu`
- [ ] The number of tabs is the same in every posture
- [ ] Every toolbar button has a title
- [ ] Nothing loads into the gutter after first layout
- [ ] The tab bar does not minimise on the phone family
- [ ] The page background runs under the gutter and the bar's colour scheme matches
- [ ] Toolbar buttons use a neutral tint
- [ ] The no-gutter arrangement puts the top actions in a bottom bar

Layout
- [ ] Layout is chosen from measured size (700 × 500 pt), not from the device
- [ ] The keyboard cannot change the layout
- [ ] Nothing is drawn before the first measurement
- [ ] Two layouts only

Folding
- [ ] Layouts swap with no animation
- [ ] No transition has a source that exists in one layout only
- [ ] Selection, scroll and pager page survive a fold
- [ ] Heavy views have one owner

Insets
- [ ] No `2 * inset` anywhere
- [ ] Full-width pagers span the side insets and pages put them back
- [ ] Content under the gutter reads the inset from the environment

Build and test
- [ ] Duo APIs are in one file with `#available` and `NO_DUO_SDK` stand-ins
- [ ] A launch argument forces the layout
- [ ] Checked closed, open landscape, open portrait and iPad
