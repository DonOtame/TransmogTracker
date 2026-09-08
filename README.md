# TransmogTracker

> Track missing pieces of an official transmog set, anchored to your Objective Tracker.

A World of Warcraft (retail) addon that tracks one official transmog
(appearance) set at a time and shows which pieces you're still missing —
the same "track this recipe" experience professions already have, but for
transmog sets.

## Features

- Adds a **Track** button to the Sets tab of Collections → Appearances,
  right next to the difficulty selector, so it always tracks the exact
  difficulty variant you're looking at (LFR/Normal/Heroic/Mythic).
- Shows a small window anchored to your Objective (quest) Tracker listing
  only the pieces you're missing, with an icon and name for each.
- Updates live as you collect pieces — no need to reopen the Wardrobe.
- Flags a piece with a warning icon if it isn't wearable by your current
  character (it still counts toward your account-wide collection).
- Collapsible, draggable, remembers its position.
- Saved per character.
- English and Spanish (`esES`/`esMX`) locales; defaults to English
  elsewhere.

## Install

Copy the `TransmogTracker` folder into:

```
World of Warcraft/_retail_/Interface/AddOns/
```

Or install via CurseForge / Wago once published there.

## Usage

Open **Collections → Appearances → Sets**, pick a set and difficulty, and
click **Track**. A tracker window will appear anchored to your Objective
Tracker.

Slash command fallback (also useful if the in-game button ever fails to
hook, e.g. after a big Blizzard UI patch):

```
/tt track <setID>   -- track a set by its TransmogSetID
/tt stop             -- stop tracking
```

## Contributing / development

- `main` — release branch, tagged for CurseForge/Wago releases.
- `develop` — active development branch.

No external libraries; plain Lua + the WoW retail API
(`C_TransmogSets`, `C_TransmogCollection`). See `docs/` for the original
design spec and implementation plan.

## License

MIT — see [LICENSE](LICENSE).
