# Homebrew Tap for dgmo

[dgmo](https://github.com/diagrammo/dgmo) is a diagram markup language that renders `.dgmo` files to PNG and SVG.

## Install

```bash
brew tap diagrammo/dgmo
brew install dgmo
```

## Usage

```bash
# Render a .dgmo file to PNG (default)
dgmo diagram.dgmo

# Render to SVG
dgmo diagram.dgmo -o output.svg

# Render to PNG with explicit output path
dgmo diagram.dgmo -o output.png

# Pipe from stdin
cat diagram.dgmo | dgmo -o output.png

# With theme and palette options
dgmo diagram.dgmo --theme dark --palette catppuccin

# Show version
dgmo --version

# Show help
dgmo --help
```

## Available options

| Option | Values | Default |
|---|---|---|
| `theme` | `light`, `dark`, `transparent` | `light` |
| `palette` | `nord`, `solarized`, `catppuccin`, `rose-pine`, `gruvbox`, `tokyo-night`, `one-dark`, `bold` | `nord` |

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

## Maintainer: Updating the formula

When a new version of `@diagrammo/dgmo` is published to npm:

1. Get the new tarball URL and sha256:
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

Users will pick up the update on their next `brew update && brew upgrade dgmo`.
