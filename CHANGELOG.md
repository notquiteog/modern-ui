## 0.2.2 — 2026-10-05

Add optional shared menu/dialogue panels and Gen3 party roster cards while retaining native input, status and navigation behavior. Inspected native battle-independent panels across four games and Emerald/LeafGreen party flows. Gen1/2 roster redesign remains in progress and is excluded.

## 0.2.1 — 2026-10-05

Polish projected status-card spacing and per-card styles; preserve native tutorials, wide commands, move PP and scripted menus; avoid duplicate Crystal backplates. Verified native battle transitions and two-client room battles across generations on engine 0.3.52, including representative targeting, switching, Safari, capture/naming and evolution flows. Exhaustive internet latency/disconnect and special-move coverage remains unverified.

# Unreleased

- Modern Gen3 party roster cards, health tracks and localized action buttons retain native icons, status/HP animations, selection and Summary flow. Gen1/2 roster layouts and alternate native delegates remain pending.

- Add independent MODERN MENU PANELS for shared dialogue, pause and menu frame chrome. Native content, controls and clipping remain owned by each generation.
- Add optional interface panel API for region/quest/companion surfaces, with safe OFF/unload fallback. Dedicated summary/PC/storage and other screen redesigns remain pending.

- Projected status cards now avoid opposing-team overlaps as well as paired-partner overlaps, including clamped camera-edge positions.

- Gen1 WIDE now uses modern commands and its native grid move navigation; scoped visibility restores correctly after draw errors. PP maxima include PP Ups.
- Yellow WIDE ON/OFF, moves/cancel, attack/return passed. With Modern UI enabled, the existing local ENet Gen1 doubles fixture passed 12 turns, targets, switches/faints, state hashes, save-party integrity and retained room traffic; its scripted intro is not a full lobby/intro certification.

- Strong status-card target outline and pointer; selected menu panels retain readable white text.
- Target labels distinguish allies from foes with the same species name.
- Verified native trainer-double transitions in Emerald standalone/staged and LeafGreen standalone: party, bag, targeting/cancel, partner commands, attack and return. Crystal companion targeting/cancel/damage and encounter ownership also passed at 2560×1440.

# 0.2.0 — 2026-10-05

- Standalone window-resolution commands and move lists across all three generations; no scenery mod required. Native controllers retain battle decisions, targeting and prompts.
- Fight/PKMN/Items/Run directional layout, command emblems and visible focus outlines. Native OFF, unload, stage ownership, move sorting, special battles and animation transitions remain safe.
- Wider, aligned pixel labels, complete names/HP/levels, and small-window scaling. Shared theme also improves optional projected stage cards.
- Live Yellow/Crystal/Emerald move/cancel/attack/return and toggle checks; LeafGreen toggles; Emerald projected trainer doubles. Full online/special battle matrix remains unverified.

# 0.1.0 — 2026-10-05

Tested official Gen1Recomp v0.3.51 (latest release verified 2026-10-05). Modern UI runs independently and composes through optional public providers. Live single-battle ON/OFF checks: Yellow, Crystal, LeafGreen and Emerald, both standalone and with partner mods. Native Gen1/2 frames use palette-safe colors and do not extend above the original player HUD. Gen3 healthboxes retain native silhouettes, glyphs and HP animation. Battle Art's Gen3 menu guard now recognizes Emerald's regional bag/party/summary screens.

At that release, standalone commands remained native. This is a battle presentation mod, not a game-wide menu replacement. Full doubles/link/attack transition coverage was not certified.
