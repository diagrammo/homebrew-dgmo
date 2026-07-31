# homebrew-dgmo — the tap

Not a codebase: two Ruby files. `Formula/dgmo.rb` installs the CLI from the npm tarball; `Casks/diagrammo.rb` installs the desktop `.dmg`. `.scratch/` is gitignored and ships nothing.

## The formula is bumped by dgmo's release, not by hand

`diagrammo/dgmo`'s `.github/workflows/release.yml` has a `bump-homebrew` job: it waits for the npm tarball, computes both sha256s, seds `Formula/dgmo.rb`, and opens a PR on this repo with `HOMEBREW_TAP_TOKEN`. It picks up whatever `npm view @diagrammo/dgmo-mcp version` returns at the moment dgmo's release runs (`release.yml:81`).

⚠️ **This pulls against the workspace release order, and the workspace wins.** `dgmo` publishes before `dgmo-mcp`, because mcp depends on dgmo — so in a joint release the formula PR vendors the *previous* mcp version. Either re-bump the `resource "dgmo-mcp"` block by hand once mcp is on npm, or accept the lag for a release. The instruction that used to live here — "publish dgmo-mcp before dgmo" — inverts the dependency and should not be followed. Reconciled 2026-07-31.

🔴 The file holds **two** `url`/`sha256` pairs — the top-level dgmo one and the vendored `resource "dgmo-mcp"` block. The workflow anchors on indentation (`^  url` vs `^    url`). A global `sed 's|sha256 ".*"|…|'` overwrites the mcp sha with dgmo's; that happened during the dgmo 0.54.0 release on 2026-07-20. Bumping by hand: scope the edit per block, and use Edit rather than a perl one-liner for the url — `@diagrammo` in a perl replacement interpolates as an empty array and yields `registry.npmjs.org//dgmo-mcp`.

## `--min-release-age=0` must stay in `install`

Homebrew's `std_npm_args` injects `--min-release-age 1`, a 24h supply-chain embargo on freshly published npm packages, and the `dgmo-mcp` resource's `npm install` re-resolves `@diagrammo/dgmo` from the registry — so a same-day `brew upgrade dgmo` failed with ETARGET until the tarballs aged out. Both `npm install` calls append `--min-release-age=0` (npm CLI flags are last-wins). It lives in the `install` method, which the release sed only-touches-url/sha never rewrites. If a fresh release's `brew upgrade` ETARGETs, check that flag first.

## dgmo-mcp is vendored, never on PATH

The MCP server is staged as a sibling under the same `node_modules` so `brew upgrade dgmo` upgrades a tested CLI+server pair. `dgmo mcp` resolves it by absolute path (`bundledMcpEntry` in dgmo's `cli.ts`), so no `dgmo-mcp` binary is linked — a PATH symlink collided with a stale `npm i -g @diagrammo/dgmo-mcp` and aborted `brew link`, leaving `dgmo` itself unlinked. `post_install` sweeps that orphan; the `test` block asserts `bin/dgmo-mcp` does **not** exist. Don't "fix" either by linking it.

## Stale, verified 2026-07-31

- The README's maintainer notes still describe the manual bump and say the formula points at v0.2.6; it is at 0.57.0. Treat the workflow as the source of truth.
- `Casks/diagrammo.rb` is pinned at app 0.8.4 from the single commit that added it (`16eb1f3`). Nothing bumps it — not the dgmo workflow, not `diagrammo-app/release.sh` — though its `livecheck` reads `diagrammo.app/latest.json`.

Local check: `brew install --build-from-source Formula/dgmo.rb` then `brew test dgmo`.
