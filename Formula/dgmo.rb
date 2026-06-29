class Dgmo < Formula
  desc "DGMO diagram markup language — render .dgmo files to PNG/SVG"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-0.43.0.tgz"
  sha256 "5c809bdf512de2bcce5c86b1c2ac7face3389c71957c1e6a0e485bfb4ae33b18"
  license "MIT"

  depends_on "node"

  # Vendor the MCP server so `brew upgrade dgmo` upgrades BOTH as a tested pair —
  # the user never installs or updates it separately. `dgmo mcp` finds this
  # `dgmo-mcp` on PATH and execs it. The dgmo release workflow bumps this
  # resource's url + sha256 to the latest dgmo-mcp at each release.
  resource "dgmo-mcp" do
    url "https://registry.npmjs.org/@diagrammo/dgmo-mcp/-/dgmo-mcp-0.6.0.tgz"
    sha256 "03ee9d8d02bc035f5c4a173ad6ccc622075a40d1001e6db1d2e0cbc6608411f6"
  end

  def install
    # Homebrew's std_npm_args injects `--min-release-age 1`, a 24h supply-chain
    # embargo that refuses any npm package published in the last day. Our own
    # freshly-cut releases can't satisfy that on release day, and the dgmo-mcp
    # resource re-resolves `@diagrammo/dgmo` from the registry — so a same-day
    # `brew upgrade dgmo` would fail with ETARGET until the tarballs aged out.
    # CLI flags are last-wins in npm, so appending `--min-release-age=0`
    # overrides the embargo. (sed in the release workflow rewrites only the
    # url/sha lines, so this stays put across every bump.)
    no_embargo = "--min-release-age=0"

    # The dgmo CLI.
    system "npm", "install", *std_npm_args, no_embargo

    # The bundled MCP server, into the same prefix.
    resource("dgmo-mcp").stage do
      system "npm", "install", *std_npm_args(prefix: libexec), no_embargo
    end

    bin.install_symlink libexec.glob("bin/*")

    # cli.cjs externalizes @resvg/resvg-js and jsdom; both load assets via fs
    # at runtime and pull in transitive deps, so the full node_modules tree
    # must remain intact. Only strip library build artifacts not needed by
    # the CLI.
    pkg = libexec/"lib/node_modules/@diagrammo/dgmo"
    rm_r pkg/"src" if (pkg/"src").exist?
    Dir[pkg/"dist/index.*"].each { |f| rm f }
  end

  def caveats
    <<~EOS
      To set up AI assistants (Claude Code, Codex, Claude Desktop, Cursor, …),
      run one command — it auto-detects what you have, no prompts:
        dgmo install

      The MCP server is bundled and upgrades automatically with this formula.
      Re-run `dgmo install` after upgrading only to refresh the skill files.

      The 'diagrammo' command is now installed automatically by the Diagrammo
      desktop app on first launch. Get the app at https://diagrammo.app/download
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dgmo --version")
    # The bundled MCP server binary is present.
    assert_path_exists bin/"dgmo-mcp"
  end
end
