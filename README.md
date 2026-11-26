# iPhone Duo Layout Playbook

A short guide to making a SwiftUI app feel at home on the iPhone Duo, written from three shipped apps.

- **[PLAYBOOK.md](PLAYBOOK.md)** is the guide for people: 23 rules, each with its reason, and a checklist.
- **[skills/duo-layout](skills/duo-layout/SKILL.md)** is the same guide as a workflow for a coding agent.
- **[snippets/](snippets/)** holds four small Swift files to copy and adapt.

## The idea

The outer display is a phone. The inner display is an iPad. The one new thing is the gutter, the system's vertical bar beside the page, which no iPad has. Most of the playbook is about using it well:

1. Rank each screen's primary actions by how often they are used.
2. The gutter takes them from the top of the list.
3. The last ones in the list drop into an overflow menu you declare yourself.

## Use it yourself

Read [PLAYBOOK.md](PLAYBOOK.md), then work down its checklist.

## Point your agent at it

Clone this repo, then link the skill into your agent's skills folder. For Claude Code:

```bash
ln -s "$(pwd)/skills/duo-layout" ~/.claude/skills/duo-layout
```

Then ask: "Use the duo-layout skill to adapt this app for the iPhone Duo."

The agent audits the app, writes a ranked list of actions for each screen, and stops for your approval before it changes any layout. That list is the design, so read it with care.

With no skills support, tell the agent to read `PLAYBOOK.md` and follow the steps in `skills/duo-layout/SKILL.md`.

## Snippets

| File | What it does |
| --- | --- |
| `LayoutClass.swift` | Chooses the phone or iPad layout from measured size, ignores the keyboard, swaps without animation |
| `DuoAPIs.swift` | One wrapper for every Duo-only API, with stand-ins for builds without the iOS 27.1 SDK |
| `GutterSurroundings.swift` | Paints the page colour behind the gutter and keeps its icons readable |
| `PagerSideInsets.swift` | Makes a full-width pager work beside the gutter |

They need iOS 17 or later and type-check against the iOS 27.2 SDK.

## Licence

MIT. See [LICENSE](LICENSE).
