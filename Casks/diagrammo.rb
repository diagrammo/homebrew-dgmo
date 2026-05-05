cask "diagrammo" do
  version "0.8.4"
  sha256 "2aa892b4041d4acd2c1eea5eccdea0ee00fec8622fd8d1f176fc9c6c704f81b1"

  url "https://github.com/diagrammo/releases/releases/download/v#{version}/Diagrammo_#{version}_aarch64.dmg"
  name "Diagrammo"
  desc "Diagram authoring desktop app"
  homepage "https://diagrammo.app"

  livecheck do
    url "https://diagrammo.app/latest.json"
    strategy :json do |json|
      json["version"]&.delete_prefix("v")
    end
  end

  depends_on arch: :arm64
  depends_on macos: ">= :big_sur"

  app "Diagrammo.app"

  zap trash: [
    "~/.diagrammo",
    "~/Library/Application Support/com.diagrammo.app",
    "~/Library/Caches/com.diagrammo.app",
    "~/Library/Preferences/com.diagrammo.app.plist",
    "~/Library/Saved Application State/com.diagrammo.app.savedState",
  ]
end
