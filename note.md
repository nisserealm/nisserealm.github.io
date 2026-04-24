# Nisserealm Notes

Current working idea for local development:

- Use `server.js` in the project root as the small proxy for functioning non-crossing read-only functions.
- The proxy sends `vm/qeval` requests to the local Gno node, so browser code can query realm state without signing.
- Keep signed transactions out of the simple browser proxy flow when possible.
- Use `gnokey` for most signed transactions, scripting, automation, and CLI-oriented tasks.

Practical split:

- Read-only queries: browser -> `server.js` -> `qeval`
- Frontend hosting: the root `index.html` through `server.js`
- Signed writes and automation: `gnokey`

Reasoning:

- Non-crossing functions are easy to expose through a local proxy.
- Signed transactions add wallet/origin/security complexity.
- `gnokey` is a cleaner tool for scripted writes, testing, and terminal-style workflows.
- Later on, use a wallet like Adena when the browser should sign directly.
