class Dgmo < Formula
  desc "DGMO diagram markup language — render .dgmo files to PNG/SVG"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-0.3.2.tgz"
  sha256 "b987025c81b48a5b7999a4130190adf72d8e6f057a352ab730f9727fadb23790"
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
