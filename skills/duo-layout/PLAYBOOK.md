# iPhone Duo Layout Playbook

How to make a SwiftUI app feel at home on the iPhone Duo. These rules come from shipping three apps on it: Torqa (training), Browsa (a browser) and Writa (notes). Each rule is followed by the reason, and where it helps, by what went wrong before the rule existed.

The short version:

1. The outer display is a phone. The inner display is an iPad. Build those two layouts and nothing else.
2. The one new thing is the **gutter**: the system's vertical bar beside the page. Decide what goes in it on purpose.
3. Choose the layout from the size of the window, never from the device or the hinge.

Sample code is in [`snippets/`](snippets/). Agents should start from [`SKILL.md`](SKILL.md) in this folder.

---

## 1. The device

| Posture | What it is | Size class | Gutter |
| --- | --- | --- | --- |
| Closed, outer display | A small phone, about 466 × 678 pt | Compact width | Yes |
| Open, landscape | A small iPad, about 951 × 669 pt | Regular width | Yes |
| Half open | The same window as open landscape, about 951 × 669 pt | Regular width | Yes |
| Open, portrait | A wide phone, about 669 × 951 pt | Regular width | No |

Point sizes were measured in the simulator, so check them against your own build before you rely on a number.

The gutter takes about 84 pt from one side of the screen. It is on one side only, so the side safe-area insets are not equal.

Half open, the hinge sits across the middle of the screen. A balanced split view moves its divider to the hinge by itself.

Open in portrait the screen is 669 pt wide. The size class says regular, but that is narrower than the 700 pt this playbook asks for a wide layout (Rule 11), so the Duo shows the **phone layout** there. That is what Torqa, Writa, Shopa and Tracka do. If your app shows a split view in that posture today, adopting Rule 11 changes it, so decide on purpose.

An iPad never has a gutter. Neither does an ordinary iPhone. That is why the gutter is the part of this work that an existing iPad layout does not already solve.

---

## 2. The gutter

The gutter is a column the system draws beside your page. It holds your tab bar (if you use the system's), your toolbar items, and sometimes another app's Live Activity. You do not control how much room you get.

### Rule 1: Rank your actions, and let the list decide

For each screen, list the primary actions in order of use, most used first. Navigation (your tabs) goes at the top of the list.

- The gutter takes items from the top of the list until it is full.
- The items at the bottom of the list are the ones that drop off.
- Dropped items go into one overflow menu that you declare yourself.

Mark each item as a **main action** (adding, the thing the screen is for) or an **accessory** (search, sort, the "…" menu). The order decides what stays; the mark decides where it sits (Rule 5).

Three things take a place in the gutter that are easy to forget:

- **The back button.** On a pushed page the system puts it at the top of the gutter. Count it.
- **Each column of a split view has its own list.** The gutter takes the detail column's items only. The sidebar's items stay in the sidebar's own top bar.
- **Sheets have a gutter too.** A sheet's Cancel and Done need no ranking, but they need titles (Rule 4) and the same ink (Rule 8).

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

Use `Button("Title", systemImage:)`. In a bar it draws the icon alone and still gives the menu row its title. A custom `Label` with its own font or colour needs `.labelStyle(.iconOnly)`.

### Rule 5: Say where each item lives

- Items that belong in the gutter: `.axisBehavior(.verticalPreferred)` with `.visibilityPriority(.high)`.
- Items that belong in the top bar (a profile avatar, for example): `.axisBehavior(.horizontalOnly)`.
- One item that must never overflow, whatever the room: `placement: .topBarPinnedTrailing` (iOS 27).
- Items with `placement: .bottomBar` land at the far end of the gutter, next to the thumb. Use that for the most used action, and pin it as well: the two work together.
- A toolbar that differs with and without a gutter branches inside `.toolbar`: `if gutterEdge != nil { … } else { … }`.
- If your toolbar items matter more than the tab bar, set `.toolbarVerticalCompressionBehavior(.prefersToolbarItems)` on the view.
- If you draw your own bar and do not want the gutter, set `.toolbarVerticalBehavior(.disabled)`.

> **Browsa.** Back, forward and the page menu sit at the top of the gutter. New tab and tabs use `.bottomBar` and land by the thumb. The address stays in a capsule at the bottom of the page.

**Main actions by the thumb, accessories at the top.** Adding an item is a main action. Search and the "…" menu are accessories: they sit together at the top of the gutter.

**The gutter is one icon wide.** Two things break that:

- A search field. Placed in the gutter it draws at full width and runs off the screen. Make it a button when there is a gutter. `GutterSearchItem` and `.gutterSearchBehavior()` in [`snippets/DuoAPIs.swift`](snippets/DuoAPIs.swift) do both halves.
- A button with words ("Add to Shop"). It spills out over the content. Show the icon alone when there is a gutter, and keep the title for the menu.

> **Shopa.** Search sat with Add and Categories at the thumb end. It moved up beside "…" as `DefaultToolbarItem(kind: .search, placement: .topBarTrailing)` with the minimised behaviour. The planner's "Add to Shop" became icon-only in the gutter.

### Rule 6: Nothing arrives late

Everything in the gutter must be there on the first layout. An item that appears a moment later pushes the others down.

> **Torqa.** The sidebar's footer (the rider's avatar) loaded after the tabs. On the Duo the footer dropped into the gutter and left one tab out of its slot. The footer is now iPad and Mac only.

### Rule 7: The gutter does not move

Stop the tab bar minimising on scroll on the phone family:

```swift
.tabBarMinimizeBehavior(UIDevice.current.userInterfaceIdiom == .phone ? .never : .automatic)
```

> **Torqa.** The bar minimised as Home scrolled, the page grew by 58 pt, a long list measured itself again, the bar came back, and the scroll stuck near the top.

This is the one place the shipped code asks which device it is, and it is a behaviour choice, not a layout choice. Apple's guidance is to keep the device idiom out of layout decisions. If you would rather not read it at all, key the same line on the gutter: `gutterEdge != nil ? .never : .automatic`. That form is not yet proven in a shipped app.

### Rule 8: Paint behind the gutter

The gutter is see-through. It shows whatever your view draws behind it, so the colour there is your job.

- Run the page's own background under the gutter with `.background { color.ignoresSafeArea() }`.
- Set the bar's colour scheme to match, so icons stay readable: `.toolbarColorScheme(isLight ? .light : .dark, for: .navigationBar)`.
- Have a neutral colour ready for moments with no page (a tab grid, an empty state).
- If a docked sidebar has its own tint, let the sidebar win and turn the page colour off while it is open.
- The system's own icons cannot be tinted. Search, back, the sidebar button and the "…" of `ToolbarOverflowMenu` are black, whatever tint you set. Where you keep the accent (an ordinary iPhone), a black "…" will sit beside accent icons; use an ordinary `Menu` there if that bothers you.
- So tint your own toolbar buttons with the same neutral ink. Accent icons beside black ones look mismatched, and an app-wide accent reaches gutter buttons unevenly in any case.
- Set that ink with `.tint`, placed after `.toolbar`. The bar's icons follow the tint at the point where the toolbar is attached; a `.foregroundStyle` on the icon is ignored. Put the accent back for the page with a second `.tint` placed before `.toolbar`:

```swift
content
    .tint(accent)          // the page keeps the accent
    .toolbar { items }
    .tint(toolbarInk)      // the bar's icons: neutral beside a gutter or sidebar
```

- Keep the accent on a plain iPhone if that is the app's look: make the ink neutral only when there is a gutter or a sidebar.
- Attach sheets after the second `.tint`, not before it. A sheet attached inside the ink loses the accent throughout.
- [`snippets/InkedToolbar.swift`](snippets/InkedToolbar.swift) wraps all of this as `.inkedToolbar { }`, used in place of `.toolbar { }`.
- A page on a photo or a gradient has no single colour to paint or to judge. If the image already runs under the gutter, leave it, and check the icons are readable on it in light and dark.

See [`snippets/GutterSurroundings.swift`](snippets/GutterSurroundings.swift).

> **Browsa.** The web page's background colour runs under the gutter, as in Safari, and the status items flip between light and dark with it. While the tab gallery is up, the colour is the system's grouped background.
>
> **Shopa.** Orange "…", plus and categories sat beside a black search and a black sidebar button. All toolbar icons are now black beside the gutter or the sidebar, and orange on an ordinary iPhone. Buttons, chips and the calendar's plus keep the accent.
>
> **Torqa.** The tab shell's orange accent tinted "…" but not the bell beside it. Home's toolbar is now tinted with the primary text colour, and the page applies the accent again for its own content.

One background per screen. A tab or section inside the screen should not paint its own fill with `ignoresSafeArea()`, or the header keeps the screen's colour while the body, and the strip under the gutter, turn another.

> **Shopa.** The planner tab filled itself with the system grey. The header stayed in the list's colour and the calendar went grey. Removing the fill let the list's wallpaper show through, as on the other tabs.

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

On an iPad there is no gutter. The same holds on the Duo open in portrait if you chose the wide layout there (Rule 11). The same ranked list still decides everything:

- The top items go in a bar at the bottom of the page, in reach of the thumbs.
- The rest go in the same overflow menu as before.

Do not leave the controls at the top of a big screen because that is where a navigation bar puts them. With no gutter, the tools belong at the bottom.

> **Browsa.** `NoGutterBar`: the sidebar button and plus at the edges, back and forward beside the address, and the page menu in the address sheet.

Every wide screen therefore needs two arrangements from one list: with a gutter, and without.

Two limits. The system decides where a search item goes on an iPad: it stays at the top trailing corner even when you ask for the bottom bar, so search at the bottom of an iPad needs a bar you build yourself. And an ordinary iPhone is not part of this section: it keeps the arrangement it has today.

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

Measure where the choice is made. If your two layouts are a navigation stack and a split view, measure once, at the app's root. A split view's own column is about 615 pt wide on the open Duo, so a column that measured itself would call itself compact.

The open Duo in portrait is 669 pt wide, so this rule gives it the phone layout (section 1). To give it the iPad layout, lower the width to 660 and build the no-gutter arrangement in section 3.

> **Browsa** uses the size classes instead: regular width and not compact height. That is fine for a full-screen app. Measure the container if your content can sit beside a sidebar or in a split.

### Rule 12: The keyboard must not change the layout

The keyboard shrinks the container. On an iPad in landscape the height can fall below 500 pt, the layout turns into the phone layout, the text field is rebuilt and loses focus, and the keyboard goes away again.

Keep the tallest height you have seen at the current width. Start again only when the width changes.

> **Torqa and Writa** both hit this, and both fixed it the same way.

In a split view the keyboard belongs to one column but moves both. A footer in the sidebar rides up beside a search field in the detail. Put `.ignoresSafeArea(.keyboard)` on the column that is not being typed in.

> **Tracka.** With search active on the open Duo, the sidebar's Settings row rose above the keyboard.

### Rule 13: Draw nothing until you have measured

Before the first measurement the container is 0 pt wide. If you default to compact, you build the phone layout and then throw it away. Hold the resolved layout as an optional and draw a clear view until it has a value.

### Rule 14: Two layouts

Do not build a third layout for the Duo. The outer display uses your phone layout and the inner display uses your iPad layout. The differences are the gutter and the insets, and you handle those inside the two layouts.

This means the open Duo shows every fault your iPad layout already has, to people who never owned an iPad. Run the iPad layout first and list what is wrong with it before you start. Otherwise old iPad faults look like new Duo bugs.

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

The two layouts hold navigation in different shapes: a stack has a path, a split view has a selection. Keep one value above both and derive the other from it:

```swift
@State private var selectedID: Item.ID?          // owned above both layouts

private var path: Binding<[Item.ID]> {           // the stack's path, derived
    Binding(get: { selectedID.map { [$0] } ?? [] },
            set: { selectedID = $0.last })
}
```

Then look for what undoes it:

- **"Restore my last selection" code inside one layout.** It runs when a fold builds that layout and overwrites the value just handed over. Make it keep a valid incoming value.
- **Handlers written twice,** one per layout, each behind a size check (deep links, onboarding). With the state above the layouts there is one copy.
- **Search.** The text is state; move it up. Whether search is open is state as well: hold `searchable(text:isPresented:)`'s flag above the layouts, or an active search closes on a fold.
- **Forced rebuilds** such as `.id(refreshTrigger)`, which throw away everything below them.

The layouts also rest differently. A split view always has something selected; a stack can rest on its root list. Unfold from the root and fold again, and the user lands inside an item. Decide whether that is acceptable for your app.

A fold builds the other layout for the first time, long after launch. So a layout must not wait for a launch event to show itself.

> **Shopa.** The phone dashboard faded in when onboarding finished. Built later by a fold, it never saw that moment and stayed invisible: the title showed and the lists did not. It now shows at once if onboarding is already done.

### Rule 18: In a split view, the sidebar is the navigation

The iPad layout often comes from pushing phone pages into the detail column. On the open Duo that leaves three faults:

- A destination chosen in the sidebar has a back button. Hide it: the sidebar already leads everywhere it would.
- `.searchable` on the split view puts the field in the sidebar. Put it on the page being searched.
- Tapping the row that is already selected does nothing, so the user cannot leave the pushed page. Clear the pushed page on the tap.

> **Shopa.** Community was a page pushed over the selected list. It is now treated as a sidebar choice: highlighted while open, no back button, its own search, and any list row leaves it.

### Rule 19: One owner for a heavy view

If both layouts show the same web view or map, a host may only take it once the host is in a window. A host that takes it during creation can take it from the layout that is still on screen.

---

## 6. Insets

### Rule 20: Each edge on its own

The gutter makes the side insets unequal. Never write `width - 2 * inset`. Read leading and trailing separately.

### Rule 21: Full-width pagers span the insets

A paging `ScrollView` pages by its full width. If each page is sized to the width inside the safe area, pages come up short by the width of the gutter, and the next page shows at the edge.

Let the pager ignore the horizontal safe area, measure the side insets, and have each page put them back as safe-area padding. Pass the insets down in the environment for content that runs under the gutter (Rule 9).

This is an exception. Everywhere else, do not read an inset and apply it yourself: a view's frame already starts inside the inset, so padding by the number you read counts it twice. Use `safeAreaInset(edge:)`, `safeAreaBar(edge:)` or `safeAreaPadding` and let the system place the content. The pager reads the insets only because it has stepped outside the safe area on purpose.

See [`snippets/PagerSideInsets.swift`](snippets/PagerSideInsets.swift).

### Rule 22: Measure outside the navigation stack

Inside a `NavigationStack`, a bar that is being hidden still counts as safe area for a moment. Measure top insets outside the stack.

---

## 7. Keeping it buildable

### Rule 23: One file for the Duo's APIs

Put every call to a Duo-only API behind your own small wrapper, in one file. The rest of the app never names those APIs.

- Guard each call with `#available(iOS 27.1, *)`.
- Add a compile flag (`NO_DUO_SDK`) with no-op stand-ins, so a CI machine with an older Xcode still builds and type-checks the app.
- These files are iOS only. If a Mac target compiles some of the same views, keep the snippets out of it and do not call them from shared files.

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

- **Get it running early, then let the owner use it.** Reading the code finds some faults. Five minutes of use finds others that no search will: a control in the wrong place, a colour that is off, a page that never loads. Build a rough version, hand it over, and polish after.
- **Check the project can resize at all.** It needs a launch screen, all four orientations on iPad, and no `UIRequiresFullScreen`. Xcode's `app-resizability` skill runs these three checks.
- **Check every posture again after each fix.** A fix made for the open screen often leaves the closed one behind.
- **Wait for the app to finish loading before you tap.** A tap that lands on a loading screen looks like a broken button.
- **Add a launch argument that forces the layout** (`--layout compact` or `--layout wide`). UI tests and screenshots then need no real fold.
- **Build signed.** An app with iCloud or other entitlements crashes at launch when built with code signing switched off.
- **Expect a first-run screen.** Onboarding or sign-in stands between you and the screens you changed.
- **`simctl io screenshot` needs `--display` on a Duo.** It has two screens and will not choose. Fold with Device Hub or a simulator tool, not `simctl`.
- **Check an ordinary iPhone too.** A toolbar that branches on the gutter can break the phone that has none.
- **Fold the simulator from Device Hub**, the app inside Xcode. Its device window has Closed and Open buttons. `simctl` has no fold command, and forcing the display off with it crashed SpringBoard. An agent whose simulator tool can set the posture should use that.
- **Give each job its own Duo simulator.** Two sessions folding one simulator ruin each other's screenshots. The Duo needs its own runtime: list runtimes and pick the one made for it.
- **Know which backend a test build uses.** A debug build that points at a staging server shows an empty account. That is not a layout bug, but it hides the screens that only look wrong with real data.
- **Plan for the sign-in screen.** An agent cannot sign in to a real account. Add a debug launch argument that opens the app on sample data, or sign in on the simulator yourself before the agent checks the screens behind it.
- **Check five states** on the Duo: closed, half open, open landscape, open portrait, and open landscape with the keyboard up. Then an iPad in both orientations, and an ordinary iPhone.
- **Use Apple's own skill as well.** Xcode ships an `app-resizability` agent skill that finds `UIScreen.main`, idiom checks, orientation checks and symmetric-inset code. This playbook covers what to design; that skill covers what to remove.
- **Fold while something is happening**: with the keyboard up, in the middle of a scroll, with a sheet open, on the second page of a pager.
- **Confirm on a device before you chase a simulator glitch.** Blank paints during a fold showed up in the simulator and not on the phone.
- **Start another app's Live Activity**, then look at your gutter.
- **Screenshot sizes** for the App Store: inner 2853 × 2007 px, outer 1398 × 2034 px.

---

## 9. Checklist

Before you start
- [ ] The project has a launch screen, all four iPad orientations, and no `UIRequiresFullScreen`
- [ ] The existing iPad layout has been run and its faults listed

Gutter
- [ ] Each screen has a ranked list of primary actions, each marked main or accessory
- [ ] Main actions sit by the thumb; search and "…" sit together at the top
- [ ] Overflow is your own menu
- [ ] The number of tabs is the same in every posture
- [ ] Every toolbar button has a title, in sheets as well
- [ ] Search is a button, not a field, when there is a gutter
- [ ] No button with words in the gutter
- [ ] Nothing loads into the gutter after first layout
- [ ] The tab bar does not minimise on the phone family
- [ ] The page background runs under the gutter and the bar's colour scheme matches
- [ ] One background per screen; no section paints its own
- [ ] Toolbar icons use one neutral ink beside a gutter or sidebar, set with `.tint` after `.toolbar`
- [ ] The no-gutter arrangement puts the top actions in a bottom bar

Layout
- [ ] Layout is chosen from measured size (700 × 500 pt), not from the device
- [ ] You have decided what the open Duo shows in portrait
- [ ] The keyboard cannot change the layout
- [ ] Nothing is drawn before the first measurement
- [ ] Two layouts only

Folding
- [ ] Layouts swap with no animation
- [ ] No transition has a source that exists in one layout only
- [ ] Selection, scroll, pager page and an open search survive a fold
- [ ] No layout restores its own remembered selection over the one handed to it
- [ ] A layout built by a fold shows at once; it waits for no launch event
- [ ] Heavy views have one owner

Split view
- [ ] A destination chosen in the sidebar has no back button
- [ ] Search is attached to the page it searches, not to the split view
- [ ] Tapping the selected sidebar row leaves a pushed page

Insets
- [ ] No `2 * inset` anywhere
- [ ] Full-width pagers span the side insets and pages put them back
- [ ] Content under the gutter reads the inset from the environment

Build and test
- [ ] Duo APIs are in one file with `#available` and `NO_DUO_SDK` stand-ins
- [ ] A launch argument forces the layout
- [ ] The owner has used a running build
- [ ] Sheets are attached after the toolbar ink, and keep the accent
- [ ] Checked closed, half open, open landscape, open portrait and keyboard up, again after the last fix
- [ ] Checked an iPad in both orientations and an ordinary iPhone
