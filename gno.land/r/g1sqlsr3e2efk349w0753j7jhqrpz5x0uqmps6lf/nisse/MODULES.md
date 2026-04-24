Nisse module split plan.

Target modules:
- `nisse.gno`: thin entry layer for top-level realm entrypoints.
- `nisse_core.gno`: shared naming, ownership, dice, and other generic helpers used across modules.
- `nisse_guide.gno`: realm guide text and high-level render output.
- `nisse_player.gno`: player stats, diary/history, companions, player-facing progression.
- `nisse_world.gno`: terrain, map, places, resources, travel, and shared world state.
- `nisse_treasury.gno`: pearls, ugnot, peddlers, pricing, transfers, and other economy logic.
- `nisse_pigeonpost.gno`: messages, inbox/outbox logic, encoding, and related read helpers.
- `nisse_monsters.gno`: shared monster handbook data for roaming adversaries and future placed monster stories.
- `nisse_story.gno`: tile-bound special story bindings and authoritative story resolution.

Rules of thumb:
- Shared player/accounting state should live in player/treasury modules.
- Shared place or world changes should live in world/story modules.
- Bound stories should call shared helpers in the core modules rather than duplicating reward or diary logic.

Preparation status:
- `pigeonpost` has been extracted into `nisse_pigeonpost.gno`.
- `treasury` has been extracted into `nisse_treasury.gno`.
- `world` has been extracted into `nisse_world.gno`.
- `monsters` has been extracted into `nisse_monsters.gno`.
- `player` has been extracted into `nisse_player.gno`.
- `core` helpers have been extracted into `nisse_core.gno`.
- `guide` text has been extracted into `nisse_guide.gno`.
- tile-bound story resolution now lives in `nisse_story.gno`.
- `nisse.gno` is now a thin coordinator/entry layer.

Suggested move order:
1. Keep `nisse.gno` as the stable entry layer while extractions continue.
2. Move terrain/map/resource/travel helpers into `nisse_world.gno`.
3. Move player diary/companion/progression helpers into `nisse_player.gno`.
4. Keep shared monster encounter tables in `nisse_monsters.gno`.
5. Leave story-specific reads and mutations in `nisse_story.gno` until a fuller story registry is extracted.
