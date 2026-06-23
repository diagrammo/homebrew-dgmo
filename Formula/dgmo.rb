class Dgmo < Formula
  desc "DGMO diagram markup language — render .dgmo files to PNG/SVG"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-0.34.0.tgz"
  sha256 "1e96d92d08780a873c43c045114af89204c5b4427785864d7b98384f40d1a03d"
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

  end

  def caveats
    <<~EOS
      To set up AI assistants (Claude Code, Codex, Claude Desktop, Cursor, …),
      run one command — it auto-detects what you have, no prompts:
        dgmo install

      The 'diagrammo' command is now installed automatically by the Diagrammo
      desktop app on first launch. Get the app at https://diagrammo.app/download
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dgmo --version")
  end
end
