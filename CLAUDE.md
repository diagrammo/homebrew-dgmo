# homebrew-dgmo — the tap

Not a codebase: two Ruby files. `Formula/dgmo.rb` installs the CLI from the npm tarball; `Casks/diagrammo.rb` installs the desktop `.dmg`. `.scratch/` is gitignored and ships nothing.

## The formula installs `@diagrammo/dgmo-cli`, not the library

🔴 **The package the formula points at is NOT `@diagrammo/dgmo`.** On 2026-08-06 the `dgmo` command moved out of the library into its own npm package, `@diagrammo/dgmo-cli`, and the formula followed the same day. The two are published from the same repo on separate versions and separate tags (`v*` for the library, `cli-v*` for the command), so "the latest dgmo release" is an ambiguous phrase here — the formula tracks the CLI's version, and the `version` Homebrew infers from the `url` is the CLI's.

## The formula is bumped by a workflow, not by hand

`diagrammo/dgmo`'s `.github/workflows/bump-homebrew.yml` waits for the npm tarball, computes its sha256, seds `Formula/dgmo.rb`, and opens a PR on this repo with `HOMEBREW_TAP_TOKEN`. It is `workflow_dispatch` with a **version input** — the CLI version to point at — because publishing is done locally and there is no tag trigger to read a version from.

That job used to live in `release.yml` and ride the *library's* release. It was moved out on 2026-08-06 for two reasons, both of which would have silently broken things: it bumped the formula to the library's version, and it sed'd a **second** `url`/`sha256` pair for a vendored `resource "dgmo-mcp"` block that no longer exists. The formula now holds exactly ONE pair. Bumping by hand: use Edit rather than a perl one-liner for the url — `@diagrammo` in a perl replacement interpolates as an empty array and yields `registry.npmjs.org//dgmo-cli`.

## `--min-release-age=0` must stay in `install`

Homebrew's `std_npm_args` injects `--min-release-age 1`, a 24h supply-chain embargo on freshly published npm packages. `@diagrammo/dgmo-mcp` is a dependency of the CLI package and is published in the same cascade, so a same-day `brew upgrade dgmo` failed with ETARGET until the tarballs aged out. The `npm install` appends `--min-release-age=0` (npm CLI flags are last-wins). It lives in the `install` method, which the bump sed never rewrites. If a fresh release's `brew upgrade` ETARGETs, check that flag first.

## dgmo-mcp arrives as a dependency, and is never on PATH

Until 2026-08-06 the MCP server was a vendored `resource` block staged as a sibling. It isn't any more: `@diagrammo/dgmo-mcp` is an ordinary dependency of `@diagrammo/dgmo-cli`, so npm brings it down, and `brew upgrade dgmo` still gets a tested CLI+server pair because the CLI pins the server it was released against.

**"Never on PATH" is the half that stayed true and is still load-bearing.** `dgmo mcp` resolves the server through `require.resolve` (`bundledMcpEntry` in dgmo's `cli.ts`), so no `dgmo-mcp` binary is linked — a PATH symlink collided with a stale `npm i -g @diagrammo/dgmo-mcp` and aborted `brew link`, leaving `dgmo` itself unlinked. `post_install` sweeps that orphan; the `test` block asserts `bin/dgmo-mcp` does **not** exist. Don't "fix" either by linking it.

⚠️ **Don't assert an npm layout path in `test`.** npm nests `@diagrammo/dgmo-mcp` under the CLI package today (`.../dgmo-cli/node_modules/@diagrammo/dgmo-mcp/`) and may hoist it beside it tomorrow; both are fine, and an `assert_path_exists` on either one is a test that fails on a working install. The block runs `require.resolve` from the CLI package directory instead — the same question the CLI itself asks.

## Stale, verified 2026-07-31

- The README's maintainer notes still describe the manual bump and say the formula points at v0.2.6; it is well past that. Treat the workflow as the source of truth.
- `Casks/diagrammo.rb` is pinned at app 0.8.4 from the single commit that added it (`16eb1f3`). Nothing bumps it — not the dgmo workflow, not `diagrammo-app/release.sh` — though its `livecheck` reads `diagrammo.app/latest.json`.

Local check: `brew install --build-from-source Formula/dgmo.rb` then `brew test dgmo`.
