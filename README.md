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
