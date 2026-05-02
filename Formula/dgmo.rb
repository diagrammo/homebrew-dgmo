class Dgmo < Formula
  desc "DGMO diagram markup language — render .dgmo files to PNG/SVG"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-0.10.1.tgz"
  sha256 "7004f33f0d8a60095f72732d02bc7203e1351ef386a4d26f1063ee93bd64aaeb"
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
      To add the dgmo skill to Claude Code (enables /dgmo in any project):
        dgmo --install-claude-skill
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dgmo --version")
  end
end
