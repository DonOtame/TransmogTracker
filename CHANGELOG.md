# Changelog

## v1.2.1

- Packaging: releases are now also published to CurseForge. No changes to
  the addon itself.

## v1.2.0

- Added: track several sets at once. Each set gets its own collapsible
  section with an X to stop tracking it. The Track button in the Wardrobe
  toggles to Untrack. `/tt stop <setID>` removes one set, `/tt stop` all.
- Changed: new look that matches the Objective Tracker — flat panel with
  no border, a progress bar per set and item icons with quality-colored
  borders. The missing slot (Head, Chest, Shoulder…) now comes first,
  larger and in white, with the item name in its rarity color after it.
  Click a set's header to collapse it; the X to stop tracking appears on
  hover.
- Fixed: tracked sets are restored reliably after login — restore now
  retries until the transmog data is ready instead of giving up, and a
  failed load never erases what you were tracking.
- Fixed: after login, pieces could show the "not wearable on this
  character" warning even though they were wearable — the transmog data
  wasn't settled yet. The restore now keeps refreshing until it is.
- Fixed: the tracker no longer fights you while dragging it.
- Fixed: missing pieces no longer reshuffle between refreshes.

## v1.1.0

- Fixed: missing-piece rows could get stuck showing "Item %d" instead of
  the real name when item data wasn't cached yet — now refreshes once the
  server delivers it.
- Fixed: dragging the tracker to a custom spot had no effect while the
  Objective Tracker was visible (nearly always) — it now stays where you
  put it. `/tt anchor` reverts to auto-anchoring under the Objective
  Tracker.
- Missing pieces now show which slot they are (Head, Shoulder, Cloak,
  etc.) alongside the item name.

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
