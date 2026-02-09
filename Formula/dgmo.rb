class Dgmo < Formula
  desc "DGMO diagram markup language — render .dgmo files to PNG/SVG"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-0.1.1.tgz"
  sha256 "7d487bcd2b516ba971a51b16b4c7abd1d3275fe65f2dcf2c7fb7a47274e48560"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dgmo --version")
  end
end
