class Dgmo < Formula
  desc "DGMO diagram markup language — render .dgmo files to PNG/SVG"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-0.10.4.tgz"
  sha256 "28a31da3ea4fd4add866c8f8c5ed8d152209ee21e973e6cb1a6034b86ee56464"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    # cli.cjs externalizes @resvg/resvg-js and jsdom; both load assets via fs
    # at runtime and pull in transitive deps, so the full node_modules tree
    # must remain intact. Only strip library build artifacts not needed by
    # the CLI.
    pkg = libexec/"lib/node_modules/@diagrammo/dgmo"
    rm_r pkg/"src" if (pkg/"src").exist?
    Dir[pkg/"dist/index.*"].each { |f| rm f }

    # Single-quoted heredoc so $VAR / $@ / $1 reach the shell unmolested
    # (Ruby would otherwise interpolate #{...}).
    (bin/"diagrammo").write <<~'EOS'
      #!/bin/sh
      # diagrammo — Diagrammo desktop app launcher
      # Distributed via homebrew-dgmo Formula. macOS only.

      set -u

      VERSION="0.1.1"
      DOWNLOAD_URL="https://diagrammo.app/download"

      case "${1:-}" in
        --help|-h)
          cat <<HELP
      Usage: diagrammo [path ...]

      Open files or directories in the Diagrammo desktop app.

        diagrammo .              Open current directory as workspace
        diagrammo foo.dgmo       Open a .dgmo file
        diagrammo foo.md         Open a markdown file (desktop app required)
        diagrammo                Just launch the app

      If Diagrammo.app is not installed, .dgmo files open in the web editor at
      online.diagrammo.app via a share link. Markdown and other formats require
      the desktop app — get it at $DOWNLOAD_URL.
      HELP
          exit 0
          ;;
        --version|-V)
          echo "diagrammo $VERSION"
          exit 0
          ;;
      esac

      APP=""
      if [ -d "/Applications/Diagrammo.app" ]; then
        APP="/Applications/Diagrammo.app"
      elif [ -d "$HOME/Applications/Diagrammo.app" ]; then
        APP="$HOME/Applications/Diagrammo.app"
      fi

      # Absolutize relative path args before exec'ing `open` — `open -a`
      # does not consistently absolutize, and a relative path arriving at
      # RunEvent::Opened fails std::fs::metadata against the app's cwd
      # and produces a blank app.
      if [ -n "$APP" ]; then
        n=$#
        while [ "$n" -gt 0 ]; do
          arg=$1
          shift
          case "$arg" in
            /*) ;;
            *) arg="$PWD/$arg" ;;
          esac
          set -- "$@" "$arg"
          n=$((n - 1))
        done
        exec open -a "$APP" "$@"
      fi

      echo "Diagrammo.app not installed locally."
      echo "Get the desktop app: $DOWNLOAD_URL"
      echo

      if [ "$#" -eq 0 ]; then
        exit 1
      fi

      if ! command -v dgmo >/dev/null 2>&1; then
        echo "dgmo CLI missing — reinstall via 'brew reinstall dgmo'" >&2
        exit 64
      fi

      EXIT=1
      for arg in "$@"; do
        if [ ! -e "$arg" ]; then
          echo "skipping: $arg (not found)" >&2
          continue
        fi

        if [ -d "$arg" ]; then
          echo "skipping: $arg (folder browsing requires the desktop app)" >&2
          continue
        fi

        case "$arg" in
          *.dgmo)
            url=$(dgmo "$arg" -o url) || {
              echo "skipped $arg" >&2
              continue
            }
            if [ -n "$url" ]; then
              echo "Opened $arg in web editor: $url"
              open "$url"
              EXIT=0
            fi
            ;;
          *.md|*.markdown)
            echo "skipping: $arg (markdown files require the desktop app — get it at $DOWNLOAD_URL)" >&2
            ;;
          *)
            echo "skipping: $arg (unsupported file type for web fallback)" >&2
            ;;
        esac
      done

      exit $EXIT
    EOS
    (bin/"diagrammo").chmod 0755
  end

  def caveats
    <<~EOS
      To add the dgmo skill to Claude Code (enables /dgmo in any project):
        dgmo --install-claude-skill

      The 'diagrammo' command launches the Diagrammo desktop app from the terminal:
        diagrammo .              Open current directory in the app
        diagrammo foo.dgmo       Open a file in the app

      If Diagrammo.app is not installed, 'diagrammo foo.dgmo' opens a web
      share link in your browser. Get the desktop app at
      https://diagrammo.app/download.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dgmo --version")
    assert_match "Usage: diagrammo", shell_output("#{bin}/diagrammo --help")
    assert_equal "diagrammo 0.1.1", shell_output("#{bin}/diagrammo --version").strip
  end
end
