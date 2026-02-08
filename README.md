# Homebrew Tap for dgmo

[dgmo](https://github.com/diagrammo/dgmo) is a diagram markup language that renders `.dgmo` files to SVG.

## Install

```bash
brew tap diagrammo/dgmo
brew install dgmo
```

## Usage

```bash
# Render a .dgmo file to SVG
dgmo render diagram.dgmo -o output.svg

# Write to stdout
dgmo render diagram.dgmo

# With theme and palette options
dgmo render diagram.dgmo -o output.svg --theme dark --palette catppuccin

# Show version
dgmo --version

# Show help
dgmo --help
```

## Available options

| Option | Values | Default |
|---|---|---|
| `--theme` | `light`, `dark`, `transparent` | `light` |
| `--palette` | `nord`, `solarized`, `catppuccin`, `rose-pine`, `gruvbox`, `tokyo-night`, `one-dark`, `bold` | `nord` |

## Update

```bash
brew upgrade dgmo
```

## Uninstall

```bash
brew uninstall dgmo
brew untap diagrammo/dgmo
```
