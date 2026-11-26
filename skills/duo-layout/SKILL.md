---
name: duo-layout
description: Use when adapting a SwiftUI iOS app for the iPhone Duo or another foldable iPhone, when an app looks wrong folded or unfolded, when toolbar or tab items overflow or vanish in the side gutter (the system vertical bar), when a layout flips while the keyboard is up, when a page goes blank or content goes missing after a fold, or when pager pages show a sliver of the next page beside a side safe-area inset.
---

# Duo Layout

## Overview

The Duo's outer display is a phone and its inner display is an iPad. The one new thing is the gutter: the system's vertical bar beside the page. Build two layouts, choose between them by measured size, and decide on purpose what goes in the gutter.

The rules and their reasons are in `PLAYBOOK.md` in this folder. Read it before step 1. Code to adapt is in `snippets/`.

## When to use

- The app has never been run on a Duo.
- The app runs on a Duo and has one of the symptoms in the table below.

Not for UIKit-only apps, and not for Android foldables.

**With Xcode's `app-resizability` skill.** If it is available, use it for two things only: its three project checks (step 1) and its search patterns (step 2). It is written for UIKit, so most of its tasks do not apply to a SwiftUI app. It also tells you to change code at once; this skill wins on that point. Change nothing before the step 5 stop.

## Steps

Do them in order. Do not start a step before the one above it is done.

Keep a notes file in the project (`DUO-NOTES.md`). The step 1 result, the audit, the faults and the ranked lists all go in it, and you show it to the owner at each stop.

1. **Check the project can resize.** Read, do not change: a launch screen is set, the iPad declaration lists all four orientations, and `UIRequiresFullScreen` is absent. Note the iPhone orientation list as well. Record any that fail.
2. **Audit the code.** Search the app and write down every place it:
   - reads `userInterfaceIdiom`, `horizontalSizeClass`, `UIScreen`, a window's safe-area insets, or orientation to choose a layout or a size;
   - sets a fixed width, or `width - 2 * inset`, on a page, a column, a card or a content cap (ignore icon and swatch sizes);
   - builds a `TabView` or a `.toolbar`, in pages and in sheets, and whether its buttons have titles or words;
   - attaches `.searchable`, and to which view;
   - declares selection, navigation path or search state, and inside which layout;
   - restores a remembered selection when a layout appears;
   - forces a rebuild with `.id(…)`;
   - pushes pages into a split view's detail column;
   - shows content only after a one-time launch or onboarding animation;
   - paints a background inside a tab or part of a screen, or behind one pushed page;
   - pages horizontally with `.scrollTargetBehavior(.paging)` or a page-style tab view (a row of chips that scrolls does not count);
   - uses a zoom, matched or `matchedGeometryEffect` transition;
   - holds a web view, map or video player.

   If the project has more than one target (a Mac app, for example), note which files each target compiles. The snippets are iOS only.
3. **Run what exists.** Build the app unchanged and signed. On a Duo simulator look at closed, half open, open landscape and open portrait. Look at an iPad and at an ordinary iPhone. List what is already wrong, using the playbook's checklist as the yardstick. These are old faults, not Duo bugs, but the open Duo will show them. Note what the app shows in open portrait today: Rule 11 may change it.
4. **Rank.** For each page with a toolbar or tabs, and for each column of a split view, write a table: rank, action, main or accessory, where it goes with a gutter, where it goes without. Most used first, tabs at the top. Count the system back button on pushed pages. Sheets need no ranking; list them, because their buttons need titles and ink later.
5. **Stop.** Show the owner the faults from step 3, the ranked lists from step 4, and any choice the playbook leaves open (open portrait: phone layout or iPad layout). Get a clear yes to the lists. For any question the owner leaves unanswered, say which default you will use, and use it.
6. **Foundations.** Add `snippets/LayoutClass.swift` and `snippets/DuoAPIs.swift` to the iOS target. Put `.resolvesLayoutClass()` where the layout is chosen: once at the app's root if the two layouts are a stack and a split view. Replace the layout decisions found in step 2 with `@Environment(\.layoutClass)`. Move selection, navigation and search state above the two layouts (Rule 17 shows the mapping), make each layout keep a value handed to it, and merge handlers that were written once per layout.
7. **Gutter, first pass.** Build each toolbar from its approved list using the wrappers in `DuoAPIs.swift`. Give every button a title, in sheets too. Main actions by the thumb, accessories at the top. Leave colour for step 9.
8. **Stop again, with a running build.** First check it yourself: every Duo posture, a fold and an unfold on a pushed page, the menus open, an iPad, and an ordinary iPhone. Then launch it on a Duo simulator and ask the owner to use it. Write down everything they say. Expect faults that no code search finds.
9. **Fix and polish.** Fix what the owner found. Then, for each item below that the audit found a use for: the toolbar ink on pages and sheets (`snippets/InkedToolbar.swift`), the colour behind the gutter (`snippets/GutterSurroundings.swift`), the no-gutter bottom bar, pagers (`snippets/PagerSideInsets.swift`), split-view navigation, the keyboard in a split view. Skip the ones that do not apply.
10. **Verify.** After the last fix, check the Duo closed, half open, open landscape, open portrait, and open landscape with the keyboard up. Check an iPad in both orientations and an ordinary iPhone. Take a screenshot of each. Go through the checklist at the end of `PLAYBOOK.md` and report each item as done, not done, not checked, or does not apply.

## Working on the simulator

- Use a Duo simulator of your own. Create one if another session is using the booted one. The Duo needs its own runtime: list the runtimes and pick the one made for it.
- Build signed. An app with iCloud or other entitlements crashes at launch when code signing is switched off.
- Fold with your simulator tool's posture control, or Device Hub inside Xcode. `simctl` cannot fold, and its screenshot needs `--display` because a Duo has two screens.
- Wait for the app to finish loading before you tap. Take a screenshot after the screen has settled, also after a rotate.
- If a sign-in screen blocks the way, stop and ask the owner to sign in on that simulator. Do not enter credentials. A first-run screen with nothing to type in, such as "Get Started", you may tap through.
- Find out where a debug build gets its data. A staging server or an empty iCloud account shows an empty app, which is not a layout bug, and hides screens that only look wrong with real data. Say what you could not see.
- After every fix, look at every posture again.
- Put the hinge back as you found it.

## Symptoms

| Symptom | Playbook rule |
| --- | --- |
| A tab is missing, or tabs sit on top of each other | 3, 6 |
| "…" in the gutter opens an empty menu | 2, 4 |
| A search field or a worded button runs out of the gutter | 5 |
| Search sits with the main actions by the thumb | 1, 5 |
| A gutter icon is a different colour from the one beside it | 8 |
| An icon ignores the colour set on it | 8 |
| A whole sheet has lost the accent colour | 8 |
| A strip, or one tab, has a different background from the rest | 8 |
| Split view turned into the phone layout in open portrait | 11 |
| Layout turns into the phone layout when the keyboard appears | 12 |
| A sidebar footer rides up beside the keyboard | 12 |
| Phone layout flashes at launch on a wide screen | 13 |
| Content is missing after a fold, but the title shows | 17 |
| A fold lands on the wrong item, or closes an open search | 17 |
| Blank page or dead controls after unfolding | 15, 16, 19 |
| Back button on a page chosen from the sidebar | 18 |
| A sidebar row only responds on its empty space | 18 |
| A sidebar destination closes as soon as it opens | 18 |
| Search field appears in the sidebar | 18 |
| Pager shows a sliver of the next page | 21 |
| A chart that should run under the gutter stops at it | 9 |
| Scroll sticks near the top on the open Duo | 7 |
| Large iPhone in landscape gets the iPad layout | 11 |
| App crashes at launch on the simulator before the first frame | Build signed |

## Common mistakes

- **Building a third layout for the Duo.** Use the phone layout and the iPad layout.
- **Skipping either stop.** A guessed ranking puts the wrong buttons in the gutter, and an unused build hides faults.
- **Polishing before the owner has used it.** Their first five minutes change the plan.
- **Treating an old iPad fault as a Duo bug**, or the other way round. Step 3 tells them apart.
- **Measuring a split view's column.** It is narrower than the window and calls itself compact. Measure at the root.
- **Reading the hinge angle for layout.** Measure the window.
- **Setting an icon's colour with a foreground style.** The bar follows `.tint` placed after `.toolbar`.
- **Forgetting sheets.** They have a gutter, toolbars and ink of their own.
- **Adding a tap gesture to list rows.** It swallows taps on the row's text and icon. After any change to a list, tap a row on its words.
- **Reporting a simulator-only blank paint as a bug.** Confirm on a device first.
- **Calling Duo APIs outside `DuoAPIs.swift`.** A build without the iOS 27.1 SDK then fails.
