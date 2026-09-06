cask "unvelt" do
  version "0.1.0"

  # Filled in by the release workflow, which prints SHA256SUMS alongside the
  # artifacts. Left as :no_check only until the first tagged build exists --
  # a cask that does not verify is a cask that installs whatever it is handed.
  sha256 arm:   :no_check,
         intel: :no_check

  arch arm: "aarch64", intel: "x86_64"

  url "https://github.com/unvelt/unvelt-desktop/releases/download/v#{version}/unvelt_#{version}_#{arch}.dmg",
      verified: "github.com/unvelt/unvelt-desktop/"

  name "unvelt"
  desc "Behavioural telemetry collector for your own data"
  homepage "https://github.com/unvelt/unvelt-desktop"

  # The collector is meant to be running; leaving it alive during an upgrade
  # would mean the new copy fights the old one for the single-instance lock.
  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates false
  depends_on macos: ">= :sonoma"

  app "unvelt.app"
  binary "#{appdir}/unvelt.app/Contents/MacOS/unvelt-agent", target: "unvelt-agent"

  # unvelt is unsigned: no Apple Developer certificate, because this project
  # has no revenue and one costs $99/yr. macOS attaches com.apple.quarantine
  # to anything downloaded and Gatekeeper refuses to open an unsigned app that
  # carries it -- and Sequoia removed the Control-click bypass, so without
  # this the install ends at a dialog with no obvious way past it.
  #
  # Clearing the flag as part of an install the person explicitly asked for is
  # the honest version of what they would otherwise do by hand. It is said out
  # loud here and in the tap's README rather than done quietly.
  #
  # `--no-quarantine` would be the usual route, but Homebrew is removing that
  # flag, so this does it directly and keeps working.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/unvelt.app"],
                   sudo: false
  end

  uninstall quit:       "com.unvelt.desktop",
            launchctl:  "com.unvelt.desktop",
            delete:     "#{appdir}/unvelt.app"

  # Deliberately NOT removing the spool on uninstall. It holds events already
  # collected that have not been uploaded yet, and they are the person's own
  # data -- deleting them because an app was removed would lose something
  # nobody asked to lose. `zap` is the opt-in that says otherwise, which is
  # exactly what zap is for.
  zap trash: [
    "~/Library/Application Support/unvelt",
    "~/Library/Preferences/com.unvelt.desktop.plist",
    "~/Library/Saved Application State/com.unvelt.desktop.savedState",
  ]

  caveats do
    <<~EOS
      unvelt is not signed by Apple, so this cask cleared the quarantine flag
      macOS puts on downloads. Without that, Gatekeeper would refuse to open
      it and Sequoia no longer offers the Control-click bypass.

      One consequence worth knowing before you grant anything: macOS ties
      Accessibility and Automation permissions to an app's code signature, and
      an unsigned app has a new one after every build. You will be asked again
      after each update until unvelt is signed.

      Nothing is collected until you sign in and choose what to turn on.
    EOS
  end
end
