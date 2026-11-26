---
name: duo-layout
description: Use when adapting a SwiftUI iOS app for the iPhone Duo or another foldable iPhone, when an app looks wrong folded or unfolded, when toolbar or tab items overflow or vanish in the side gutter (the system vertical bar), when a layout flips while the keyboard is up, when a page goes blank after a fold, or when pager pages show a sliver of the next page beside a side safe-area inset.
---

# Duo Layout

## Overview

The Duo's outer display is a phone and its inner display is an iPad. The one new thing is the gutter: the system's vertical bar beside the page. Build two layouts, choose between them by measured size, and decide on purpose what goes in the gutter.

The rules and their reasons are in `PLAYBOOK.md` in this folder. Read it before step 1. Code to adapt is in `snippets/`.

## When to use

- The app has never been run on a Duo.
- The app runs on a Duo and has one of the symptoms in the table below.

Not for UIKit-only apps, and not for Android foldables.

## Steps

Do them in order. Do not start a step before the one above it is done.

1. **Audit.** Search the app and write down every place it:
   - reads `userInterfaceIdiom`, `horizontalSizeClass` or `UIScreen` to choose a layout;
   - uses a fixed width, or `width - 2 * inset`;
   - builds a `TabView` or a `.toolbar`;
   - pages horizontally;
   - holds a web view, map or video player.
2. **Rank.** For each screen with a toolbar or tabs, write the primary actions in order of use, most used first, tabs at the top. Mark where the gutter cut falls: what stays, what goes to overflow. Then mark the same list for the no-gutter case: what goes in the bottom bar.
3. **Stop.** Show the audit and the ranked lists to the app's owner. Wait for approval. The lists are the design, and only the owner knows which actions are most used.
4. **Foundations.** Add `snippets/LayoutClass.swift` and `snippets/DuoAPIs.swift`. Put `.resolvesLayoutClass()` on each screen's root. Replace the layout decisions found in step 1 with `@Environment(\.layoutClass)`.
5. **Gutter.** Build each toolbar from its approved list using the wrappers in `DuoAPIs.swift`. Fix the tab count. Give every button a title. Paint behind the gutter with `snippets/GutterSurroundings.swift`.
6. **No gutter.** Where `gutterEdge` is nil on a wide layout, put the top of the list in a bottom bar.
7. **Insets and folding.** Apply `snippets/PagerSideInsets.swift` to pagers. Move selection, scroll and pager state above the two layouts.
8. **Verify.** Build. Run with `--layout compact` and `--layout wide`. Then on the Duo simulator check closed, open landscape, open portrait, and on an iPad. Take a screenshot of each. Fold with the keyboard up and on a pager's second page. Go through the checklist at the end of `PLAYBOOK.md` and report each item as done, not done, or not checked.

## Symptoms

| Symptom | Playbook rule |
| --- | --- |
| A tab is missing, or tabs sit on top of each other | 3, 6 |
| "…" in the gutter opens an empty menu | 2, 4 |
| A gutter button is a different colour from the one beside it | 8 |
| A strip of the wrong colour beside the page | 8 |
| Layout turns into the phone layout when the keyboard appears | 12 |
| Phone layout flashes at launch on a wide screen | 13 |
| Blank page or dead controls after unfolding | 15, 16, 18 |
| Pager shows a sliver of the next page | 20 |
| A chart that should run under the gutter stops at it | 9 |
| Scroll sticks near the top on the open Duo | 7 |
| Large iPhone in landscape gets the iPad layout | 11 |

## Common mistakes

- **Building a third layout for the Duo.** Use the phone layout and the iPad layout.
- **Skipping step 3.** A guessed ranking puts the wrong buttons in the gutter.
- **Reading the hinge angle for layout.** Measure the window.
- **Folding the simulator with `simctl`.** It has no fold command. Use Device Hub inside Xcode.
- **Reporting a simulator-only blank paint as a bug.** Confirm on a device first.
- **Calling Duo APIs outside `DuoAPIs.swift`.** A build without the iOS 27.1 SDK then fails.
