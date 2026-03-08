class Dgmo < Formula
  desc "DGMO diagram markup language — render .dgmo files to PNG/SVG"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-0.4.3.tgz"
  sha256 "bdad2e5fda451cf51585f1840b83d1f2a737a4248af5e5c93e6a74866d13f78b"
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

  test do
    assert_match version.to_s, shell_output("#{bin}/dgmo --version")
  end
end
