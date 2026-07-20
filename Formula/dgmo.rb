class Dgmo < Formula
  desc "DGMO diagram markup language — render .dgmo files to PNG/SVG"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-0.54.0.tgz"
  sha256 "425e1d02452a948eb1fe2f5c0a3fc354ee3606dd4d8d1bbd8907afaaefe32645"
  license "MIT"

  depends_on "node"

  # Vendor the MCP server so `brew upgrade dgmo` upgrades BOTH as a tested pair —
  # the user never installs or updates it separately. It's staged as a sibling of
  # @diagrammo/dgmo under the same node_modules; `dgmo mcp` resolves it by
  # absolute path (see cli.ts `bundledMcpEntry`), so we deliberately do NOT put a
  # `dgmo-mcp` binary on PATH — that path used to collide with a stale
  # `npm i -g @diagrammo/dgmo-mcp` symlink and abort `brew link`, leaving `dgmo`
  # itself unlinked. The dgmo release workflow bumps this resource's url + sha256
  # to the latest dgmo-mcp at each release.
  resource "dgmo-mcp" do
    url "https://registry.npmjs.org/@diagrammo/dgmo-mcp/-/dgmo-mcp-0.14.0.tgz"
    sha256 "19c8e9f8297167e4bfe39895397b86494abb4a5727dae92d427b45306d53d674"
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

    # Link ONLY the dgmo CLI onto PATH. The bundled dgmo-mcp binary is left
    # unlinked on purpose (see the resource comment above) — `dgmo mcp` execs it
    # by absolute path, so a PATH symlink would only reintroduce the collision.
    bin.install_symlink libexec/"bin/dgmo"

    # cli.cjs externalizes @resvg/resvg-js and jsdom; both load assets via fs
    # at runtime and pull in transitive deps, so the full node_modules tree
    # must remain intact. Only strip library build artifacts not needed by
    # the CLI.
    pkg = libexec/"lib/node_modules/@diagrammo/dgmo"
    rm_r pkg/"src" if (pkg/"src").exist?
    Dir[pkg/"dist/index.*"].each { |f| rm f }
  end

  # Heal machines left broken by the old install path. A previous
  # `npm i -g @diagrammo/dgmo-mcp` (or an older formula that symlinked the
  # server onto PATH) leaves `<prefix>/bin/dgmo-mcp` pointing outside this keg.
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
    # The bundled MCP server is staged as a sibling (resolved by `dgmo mcp` via
    # absolute path), NOT symlinked onto PATH.
    assert_path_exists libexec/"lib/node_modules/@diagrammo/dgmo-mcp/dist/index.js"
    refute_path_exists bin/"dgmo-mcp"
  end
end
