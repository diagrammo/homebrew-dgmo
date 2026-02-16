# Homebrew Tap for dgmo

[dgmo](https://github.com/diagrammo/dgmo) is a diagram markup language CLI that renders `.dgmo` files to PNG and SVG. This tap lets you install it via Homebrew.

## Install

```bash
brew tap diagrammo/dgmo
brew install dgmo
```

Requires Node.js (installed automatically by Homebrew as a dependency).

## Usage

```bash
dgmo diagram.dgmo                    # Render to PNG (default)
dgmo diagram.dgmo -o output.svg      # Render to SVG
dgmo diagram.dgmo -o output.png      # Explicit PNG output path
cat diagram.dgmo | dgmo -o out.png   # Pipe from stdin
dgmo diagram.dgmo --theme dark --palette catppuccin
dgmo --version
dgmo --help
```

| Option | Values | Default |
|--------|--------|---------|
| `--theme` | `light`, `dark`, `transparent` | `light` |
| `--palette` | `nord`, `solarized`, `catppuccin`, `rose-pine`, `gruvbox`, `tokyo-night`, `one-dark`, `bold` | `nord` |
| `-o` | Output file path (`.svg` → SVG, otherwise PNG) | `<input>.png` |

## Update

```bash
brew update
brew upgrade dgmo
```

## Uninstall

```bash
brew uninstall dgmo
brew untap diagrammo/dgmo
```

---

## Maintainer notes

### How the formula works

The formula downloads the npm tarball from the registry and installs via `npm install`. The CLI binary (`dist/cli.cjs`) bundles all JS dependencies at build time, so the formula strips everything from `node_modules` except `@resvg/resvg-js` (native binary addon needed for PNG rasterization). It also removes `src/` and library build artifacts (`dist/index.*`) since only the CLI entry point is needed.

### Updating the formula

When a new version of `@diagrammo/dgmo` is published to npm:

1. Get the new tarball sha256:
   ```bash
   VERSION=0.2.7  # new version
   curl -sL "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-${VERSION}.tgz" | shasum -a 256
   ```

2. Update `Formula/dgmo.rb`:
   - `url` → new tarball URL with version
   - `sha256` → new hash from step 1

3. Test locally:
   ```bash
   brew install --build-from-source Formula/dgmo.rb
   dgmo --version    # should print new version
   brew test dgmo    # runs the formula test block
   ```

4. Commit and push:
   ```bash
   git add Formula/dgmo.rb
   git commit -m "Update dgmo to ${VERSION}"
   git push
   ```

Users pick up the update on their next `brew update && brew upgrade dgmo`.

### Current version

The formula currently points to `@diagrammo/dgmo` **v0.2.6**.
