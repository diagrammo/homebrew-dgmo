class Dgmo < Formula
  desc "Render .dgmo diagram files to PNG or SVG from the terminal"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo-cli/-/dgmo-cli-0.79.0.tgz"
  sha256 "64649ebabcdbfb5ab8bef28eeb5578d59aac6e42e8cc1df44bc3852b61a40212"
  license "MIT"

  depends_on "node"

  def install
    # Homebrew's std_npm_args injects `--min-release-age 1`, a 24h supply-chain
    # embargo that refuses any npm package published in the last day. Our own
    # freshly-cut releases can't satisfy that on release day — @diagrammo/dgmo-mcp
    # is a dependency of this package and is published in the same cascade, so a
    # same-day `brew upgrade dgmo` would fail with ETARGET until the tarballs aged
    # out. CLI flags are last-wins in npm, so appending `--min-release-age=0`
    # overrides the embargo. (sed in the release workflow rewrites only the
    # url/sha lines, so this stays put across every bump.)
    no_embargo = "--min-release-age=0"

    # The dgmo CLI. @diagrammo/dgmo-mcp comes down with it as an ordinary
    # dependency — that is how `brew upgrade dgmo` still upgrades a tested
    # CLI+server pair, since the CLI pins the server it was released against.
    system "npm", "install", *std_npm_args, no_embargo

    # Link ONLY the dgmo CLI onto PATH. npm doesn't link a dependency's bin, and
    # we don't either: `dgmo mcp` resolves the server by absolute path (see
    # cli.ts `bundledMcpEntry`), and a PATH symlink used to collide with a stale
    # `npm i -g @diagrammo/dgmo-mcp` and abort `brew link`, leaving `dgmo` itself
    # unlinked.
    bin.install_symlink libexec/"bin/dgmo"
  end

  # Heal machines left broken by the old install path. A previous
  # `npm i -g @diagrammo/dgmo-mcp` (or an older formula that symlinked the
  # server onto PATH) leaves `<prefix>/bin/dgmo-mcp` pointing outside this keg.
  # (Also swept: the 0.60.0-and-earlier formula installed @diagrammo/dgmo, which
  # carried the `dgmo` bin itself; the keg is replaced wholesale on upgrade.)
  # That symlink is what used to abort `brew link` and leave `dgmo` itself
  # unlinked. We no longer put a dgmo-mcp binary on PATH — `dgmo mcp` resolves
  # the bundled server by absolute path — so any such symlink is now a stale
  # orphan (often dangling) that shadows nothing useful. Sweep it. Guarded to
  # only touch a foreign/dangling dgmo-mcp symlink, never a real file. Non-fatal
  # by design: Homebrew rescues post_install errors and `dgmo` is already linked.
  def post_install
    stale = HOMEBREW_PREFIX/"bin/dgmo-mcp"
    return unless stale.symlink?

    dangling = !stale.exist?
    npm_global = stale.readlink.to_s.include?("node_modules/@diagrammo/dgmo-mcp")
    stale.unlink if dangling || npm_global
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
    # The MCP server arrives as a dependency of the CLI package. Resolve it the
    # way `dgmo mcp` does (cli.ts `bundledMcpEntry`) instead of asserting an npm
    # layout path — npm nests it under the CLI package today and may hoist it
    # tomorrow, and either is fine so long as require.resolve finds it.
    cd libexec/"lib/node_modules/@diagrammo/dgmo-cli" do
      system "node", "-e", "require.resolve('@diagrammo/dgmo-mcp/dist/index.js')"
    end
    # Still never on PATH.
    refute_path_exists bin/"dgmo-mcp"
  end
end
