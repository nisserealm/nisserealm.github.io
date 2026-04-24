# Nisse Realm Click Client

This is now the main frontend for Nisse Realm.

The older terminal-oriented browser client has been archived in [`archive/legacy-click-ui/`](/Users/gnosandbox/workspace/projects/nisserealm/archive/legacy-click-ui).

## Current shape

- `index.html`
  Main entry page for the current client.
- `app.js`
  Main UI wiring and rendering.
- `styles.css`
  Layout and visual styling.
- `api/gno_game_api.js`
  Live readonly adapter for qeval reads and staged write commands.
- `api/map_data.js`
  Shared terrain map data and travel cost helpers.
- `state/store.js`
  Tiny frontend state store.

## Goal

The UI should only talk to the adapter layer, not directly to realm queries from the view layer.

That lets us:

- keep reads consistent
- stage writes cleanly
- swap staged commands for wallet integration later

## First milestone

The current scaffold supports:

- map rendering
- place panel rendering
- player panel rendering
- readonly travel planning
- staged travel and naming commands
- event log

## Current backend

The main client now uses a single readonly Gno-backed path through the local qeval proxy.

Writes are still staged as terminal commands rather than executed from the browser.

## Next likely steps

- add tile actions and contextual buttons
- improve travel highlighting and route feedback
- add dialogs for services like post and peddlers
- replace staged commands with wallet-backed writes later
