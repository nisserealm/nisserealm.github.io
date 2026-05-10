Active Nisse module layout.

Active files:
- `nisse.gno`: shared realm entry types.
- `core.gno`: shared naming, ownership, dice, and generic helpers.
- `asset.gno`: asset registry and tile inventory helpers.
- `player.gno`: player stats, diary/history, companions, and progression.
- `world.gno`: terrain, map, travel, resources, and shared world state.
- `treasury_slim.gno`: slim pearl bookkeeping used by the active core game.
- `pigeonpost_slim.gno`: active messaging implementation under the stable slim filename.
- `story.gno`: tile-bound story bindings and story resolution.
- `place.gno`: tile naming and place-facing helpers.
- `tile_scene.gno`: place scene rendering helpers.
- `encounters.gno`: encounter and monster mark logic.
- `companion_mint.gno`: mintable companion claims and minting.
- `event.gno`: supporting event helpers.
- `watercraft.gno`: boat ownership and water travel.

Notes:
- Deprecated full economy and market files are no longer part of the active package directory.
- The active slim deployment keeps messaging fully enabled but leaves the heavy market/economy systems out.
