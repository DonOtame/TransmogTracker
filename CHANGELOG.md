# Changelog

## Unreleased

- Fixed: missing-piece rows could get stuck showing "Item %d" instead of
  the real name when item data wasn't cached yet — now refreshes once the
  server delivers it.
- Fixed: dragging the tracker to a custom spot had no effect while the
  Objective Tracker was visible (nearly always) — it now stays where you
  put it. `/tt anchor` reverts to auto-anchoring under the Objective
  Tracker.
- Missing pieces now show which slot they are (Head, Shoulder, Cloak,
  etc.) alongside the item name.
- The tracker window now closes with Escape.

## v1.0.0

Track missing pieces of an official transmog set from **Collections →
Appearances → Sets** — a Track button appears next to the difficulty
selector, and a live-updating list anchors itself to your Objective
Tracker.

- Tracks the exact difficulty variant you select (LFR/Normal/Heroic/Mythic)
- Warns when a piece isn't wearable on this character (it still counts
  toward your account-wide collection)
- Saved per character
- English and Spanish
