class Dgmo < Formula
  desc "DGMO diagram markup language — render .dgmo files to PNG/SVG"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-0.39.0.tgz"
  sha256 "1abdf27517c1803226643efdc1b75747d782aec87611615aaa6bb67ec0fa5642"
  license "MIT"

  depends_on "node"

  # Vendor the MCP server so `brew upgrade dgmo` upgrades BOTH as a tested pair —
  # the user never installs or updates it separately. `dgmo mcp` finds this
  # `dgmo-mcp` on PATH and execs it. The dgmo release workflow bumps this
  # resource's url + sha256 to the latest dgmo-mcp at each release.
  resource "dgmo-mcp" do
    url "https://registry.npmjs.org/@diagrammo/dgmo-mcp/-/dgmo-mcp-0.5.0.tgz"
    sha256 "d2a16023048884e166d6ed412027fe50b45f34bd770ffeb41940e4ec6800039e"
  end

  def install
    # The dgmo CLI.
    system "npm", "install", *std_npm_args

    # The bundled MCP server, into the same prefix.
    resource("dgmo-mcp").stage do
      system "npm", "install", *std_npm_args(prefix: libexec)
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
