class Dgmo < Formula
  desc "DGMO diagram markup language — render .dgmo files to PNG/SVG"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-0.8.0.tgz"
  sha256 "63efab9f03019f3acbc3ea088d4de1f22ad11f7c7ff974d6f4ba6b2be756ae90"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    # cli.cjs bundles all JS deps; only @resvg/resvg-js (native binary) needed
    node_modules = libexec/"lib/node_modules/@diagrammo/dgmo/node_modules"
    node_modules.children.each do |child|
      child.rmtree unless child.basename.to_s == "@resvg"
    end

    # Strip library build artifacts not needed by the CLI
    pkg = libexec/"lib/node_modules/@diagrammo/dgmo"
    rm_r pkg/"src"
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
