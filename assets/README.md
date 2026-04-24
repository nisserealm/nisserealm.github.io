Frontend asset layout for Nisserealm.

Structure:
- `scenarios/<scenario>/entry/` for the first scene or overview image.
- `scenarios/<scenario>/paths/` for path-specific visuals such as `tracks`, `brook`, or `thicket`.
- `scenarios/<scenario>/decisions/` for commitment moments such as `observe`, `press`, or `seize`.
- `scenarios/<scenario>/ui/` for scenario-specific overlays, buttons, or decorative pieces.
- `shared/` for reusable UI art such as icons, markers, frames, and textures.

Suggested first forest files:
- `assets/scenarios/forest/entry/forest-entry-01.png`
- `assets/scenarios/forest/paths/forest-path-tracks.png`
- `assets/scenarios/forest/paths/forest-path-brook.png`
- `assets/scenarios/forest/paths/forest-path-thicket.png`
- `assets/scenarios/forest/decisions/forest-decision-observe.png`
- `assets/scenarios/forest/decisions/forest-decision-press.png`
- `assets/scenarios/forest/decisions/forest-decision-seize.png`

This keeps the frontend art organized by scenario while still allowing shared art to stay separate.
