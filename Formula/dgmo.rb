class Dgmo < Formula
  desc "DGMO diagram markup language — render .dgmo files to SVG"
  homepage "https://github.com/diagrammo/dgmo"
  url "https://registry.npmjs.org/@diagrammo/dgmo/-/dgmo-0.1.0.tgz"
  sha256 "3c2c517dba325493a3d2ebe124298daab052fee50380787207ed17d850ba6332"
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
