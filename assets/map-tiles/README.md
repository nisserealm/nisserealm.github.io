# Map Tile Textures

Drop terrain texture PNG files in this folder as your source/master images for the click-client map.

Suggested filenames:

- `coastal.png`
- `coastal_seaup.png`
- `coastal_seadown.png`
- `moor.png`
- `meadow.png`
- `forest.png`
- `hills.png`
- `mountain.png`
- `farm.png`
- `farmland.png`
- `village.png`
- `monastery.png`
- `harbor.png`
- `citynorth.png`
- `citysouth.png`
- `ocean.png`

The click client now uses smaller generated web copies from:

- `/Users/gnosandbox/workspace/projects/nisserealm/assets/map-tiles-web/`

Keep your full-size originals in:

- `/Users/gnosandbox/workspace/projects/nisserealm/assets/map-tiles/`

To rebuild the web-sized copies on macOS:

```sh
/Users/gnosandbox/workspace/projects/nisserealm/scripts/build_map_tile_web.sh
```

Optional size override:

```sh
/Users/gnosandbox/workspace/projects/nisserealm/scripts/build_map_tile_web.sh 192
```

The default build size is `256px` on the longest edge.

If a texture is missing, the map falls back to the built-in terrain color.

For coastal tiles, the click client currently supports two simple vertical shoreline variants:

- `coastal_seaup.png`
  Used when the tile has ocean only above it.
- `coastal_seadown.png`
  Used when the tile has ocean only below it.

Mixed shorelines and horizontal shorelines still use the regular `coastal.png`.
