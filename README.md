# iPhone Duo Layout Playbook

A short guide to making a SwiftUI app feel at home on the iPhone Duo, written from five apps that were taken through it.

- **[PLAYBOOK.md](skills/duo-layout/PLAYBOOK.md)** is the guide for people: 23 rules, each with its reason, and a checklist.
- **[SKILL.md](skills/duo-layout/SKILL.md)** is the same guide as a ten-step workflow for a coding agent.
- **[snippets/](skills/duo-layout/snippets/)** holds five small Swift files to copy and adapt.

Everything lives in one folder, `skills/duo-layout/`, so the skill still works when that folder is copied on its own.

## The idea

The outer display is a phone. The inner display is an iPad. The one new thing is the gutter, the system's vertical bar beside the page, which no iPad has. Most of the playbook is about using it well:

1. Rank each screen's primary actions by how often they are used.
2. The gutter takes them from the top of the list.
3. The last ones in the list drop into an overflow menu you declare yourself.
4. Main actions sit by the thumb. Accessories, such as search, sit at the top.

## Use it yourself

Read [PLAYBOOK.md](skills/duo-layout/PLAYBOOK.md), then work down its checklist.

## Point your agent at it

Clone this repo, then copy or link the skill folder into your agent's skills folder. For Claude Code:

```bash
cp -R skills/duo-layout ~/.claude/skills/duo-layout
```

Then ask: "Use the duo-layout skill to adapt this app for the iPhone Duo."

With no skills support, tell the agent to read `skills/duo-layout/PLAYBOOK.md` and follow the steps in `skills/duo-layout/SKILL.md`.

### What to expect

The agent stops twice for you:

1. After it has audited the app and run it unchanged. It shows you what is already wrong and a ranked list of actions for each screen. That list is the design, so read it with care.
2. With a first version running on a simulator. Use it for five minutes, folded and unfolded. What you notice here is what no code search finds.

It keeps a `DUO-NOTES.md` file in your project with its audit, the lists and its final checklist report.

## Snippets

| File | What it does |
| --- | --- |
| `LayoutClass.swift` | Chooses the phone or iPad layout from measured size, ignores the keyboard, swaps without animation |
| `DuoAPIs.swift` | One wrapper for every Duo-only API, search in the gutter, and stand-ins for builds without the iOS 27.1 SDK |
| `InkedToolbar.swift` | One neutral colour for toolbar icons beside the gutter or a sidebar, accent elsewhere |
| `GutterSurroundings.swift` | Paints the page colour behind the gutter and keeps its icons readable |
| `PagerSideInsets.swift` | Makes a full-width pager work beside the gutter |

They need iOS 17 or later and type-check against the iOS 27.2 SDK. They are iOS only.

## How it was tested

The rules came from three shipped apps. The skill was then run on a fourth app by the agent that wrote it, and on a fifth by a fresh agent that had seen none of that work and kept a log of every place the skill was unclear. That log was folded back in.

Point sizes in the playbook were measured in the simulator. Check them against your own build.

## Licence

MIT. See [LICENSE](LICENSE).
