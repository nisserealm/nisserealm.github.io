# Deploy Profiles

## Active Workspace

- Active source of truth: `/Users/gnosandbox/workspace/projects/nisserealm`
- Older helper worktrees may still exist on disk, but they are deprecated and should not lead new changes.

## Package manifests

- Full package: `deploy/nisse-package.full.json`
- Core staging package: `deploy/nisse-package.staging-core.json`
- Core local package: `deploy/nisse-package.local-core.json`
- Active/default package used by existing tooling: `deploy/nisse-package.json`

Set active package to full:

```bash
cp deploy/nisse-package.full.json deploy/nisse-package.json
```

Set active package to staging-core:

```bash
cp deploy/nisse-package.staging-core.json deploy/nisse-package.json
```

Set active package to local-core:

```bash
cp deploy/nisse-package.local-core.json deploy/nisse-package.json
```

## Notes

- `staging-core` and `local-core` are the main slim deployment targets.
- `market` is removed from the active upload sets.
- `pigeonpost_slim.gno` now carries the full messaging implementation on purpose, so redeploys can replace the old filename cleanly.
- `treasury_slim.gno` remains slim for pearls and boat support without the heavy economy systems.
- The old full-file versions of `pigeonpost.gno` and `treasury.gno` are archived under `archive/deprecated-full-files/` and are no longer part of the active package directory.
- Hosted staging uploads now target `.../nisse01` as the fresh package path.
- Local runtime continues to use `.../nisse`.
- Package source stays local under `gno.land/` and is no longer meant to be served by the public GitHub Pages UI.
- The hosted UI now stages a local `gnokey maketx addpkg` command instead of uploading package files directly from the browser.
