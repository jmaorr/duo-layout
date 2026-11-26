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

If Xcode's `app-resizability` skill is available, use it alongside this one for steps 1 and 2: it finds the legacy APIs to remove. This skill decides what the layout should be.

## Steps

Do them in order. Do not start a step before the one above it is done.

1. **Check the project can resize.** Read, do not change: a launch screen is set, the iPad declaration lists all four orientations, and `UIRequiresFullScreen` is absent. Report any that fail.
2. **Audit the code.** Search the app and write down every place it:
   - reads `userInterfaceIdiom`, `horizontalSizeClass`, `UIScreen` or orientation to choose a layout or a size;
   - uses a fixed width, or `width - 2 * inset`;
   - builds a `TabView` or a `.toolbar`, and whether its buttons have titles or words;
   - attaches `.searchable`, and to which view;
   - pushes pages into a split view's detail column;
   - shows content only after a one-time launch or onboarding animation;
   - paints a background inside a tab or section of a screen;
   - pages horizontally;
   - holds a web view, map or video player.
3. **Run what exists.** Build the app unchanged. Look at the existing iPad layout on an iPad simulator and at the app on a Duo simulator, closed and open. List what is already wrong. These are old faults, not Duo bugs, but the open Duo will show them.
4. **Rank.** For each screen with a toolbar or tabs, write the primary actions in order of use, most used first, tabs at the top. Mark each one main or accessory. Mark where the gutter cut falls: what stays, what goes to the menu. Then mark the same list for the no-gutter case: what goes in the bottom bar.
5. **Stop.** Show the owner the faults from step 3 and the ranked lists from step 4. Wait for approval. The lists are the design, and only the owner knows which actions are most used.
6. **Foundations.** Add `snippets/LayoutClass.swift` and `snippets/DuoAPIs.swift`. Put `.resolvesLayoutClass()` on each screen's root. Replace the layout decisions found in step 2 with `@Environment(\.layoutClass)`. Move selection and navigation state above the two layouts.
7. **Gutter, first pass.** Build each toolbar from its approved list using the wrappers in `DuoAPIs.swift`. Give every button a title. Main actions by the thumb, accessories at the top.
8. **Stop again, with a running build.** Launch it on a Duo simulator and ask the owner to use it: closed, open, and folding in the middle of a task. Write down everything they say. Expect faults that no code search finds.
9. **Fix and polish.** Fix what the owner found. Then: the no-gutter bottom bar, the colour behind the gutter and the toolbar ink (`snippets/GutterSurroundings.swift`), pagers (`snippets/PagerSideInsets.swift`), split-view navigation.
10. **Verify.** After the last fix, check closed, half open, open landscape, open portrait, and an iPad. Take a screenshot of each. Go through the checklist at the end of `PLAYBOOK.md` and report each item as done, not done, or not checked.

## Working on the simulator

- Use a Duo simulator of your own. Create one if another session is using the booted one. The Duo needs its own runtime: list the runtimes and pick the one made for it.
- Fold with your simulator tool's posture control, or Device Hub inside Xcode. `simctl` cannot fold.
- Wait for the app to finish loading before you tap. Take a screenshot after the screen has settled.
- If a sign-in screen blocks the way, stop and ask the owner to sign in on that simulator. Do not enter credentials.
- Find out which backend a debug build uses. A staging server shows an empty account, which is not a layout bug.
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
| A strip, or one tab, has a different background from the rest | 8 |
| Layout turns into the phone layout when the keyboard appears | 12 |
| Phone layout flashes at launch on a wide screen | 13 |
| Content is missing after a fold, but the title shows | 17 |
| Blank page or dead controls after unfolding | 15, 16, 19 |
| Back button on a page chosen from the sidebar | 18 |
| Search field appears in the sidebar | 18 |
| Pager shows a sliver of the next page | 21 |
| A chart that should run under the gutter stops at it | 9 |
| Scroll sticks near the top on the open Duo | 7 |
| Large iPhone in landscape gets the iPad layout | 11 |

## Common mistakes

- **Building a third layout for the Duo.** Use the phone layout and the iPad layout.
- **Skipping either stop.** A guessed ranking puts the wrong buttons in the gutter, and an unused build hides faults.
- **Polishing before the owner has used it.** Their first five minutes change the plan.
- **Treating an old iPad fault as a Duo bug**, or the other way round. Step 3 tells them apart.
- **Reading the hinge angle for layout.** Measure the window.
- **Setting an icon's colour with a foreground style.** The bar follows `.tint` placed after `.toolbar`.
- **Reporting a simulator-only blank paint as a bug.** Confirm on a device first.
- **Calling Duo APIs outside `DuoAPIs.swift`.** A build without the iOS 27.1 SDK then fails.
