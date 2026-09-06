cask "unvelt" do
  version "0.3.2"
  sha256 "6bd4f653238e2ea21dcc4c0d42b2d69e50a75d92a676ab4f9594730c6270581e"

  url "https://github.com/unvelt/unvelt-desktop/releases/download/v#{version}/unvelt_#{version}_aarch64.dmg",
      verified: "github.com/unvelt/unvelt-desktop/"

  name "unvelt"
  desc "Behavioural telemetry collector for your own data"
  homepage "https://github.com/unvelt/unvelt-desktop"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates false
  # Apple Silicon only, because that is the only macOS build that exists --
  # the Intel runner never got scheduled in CI. Declaring it is better than a
  # download that 404s on an Intel Mac and blames the network.
  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"
  # ungive/media-control is how a Mac sees what is playing in a browser tab.
  # Since macOS 15.4, MediaRemote answers only Apple-signed callers, so a
  # normal app gets nothing -- media-control reaches it through a code-signing
  # loophole in /usr/bin/perl that is Apple's to close. unvelt ships none of
  # that technique; it shells out to this tool when present and falls back to
  # Spotify/Music-only otherwise. Declaring it here means a brew install
  # collects browser tracks out of the box. It is in homebrew-core, so this is
  # an ordinary formula dependency, not another tap.
  depends_on formula: "media-control"

  app "unvelt.app"

  # unvelt is unsigned: no Apple Developer certificate, because this project
  # has no revenue and one costs $99/yr. macOS attaches com.apple.quarantine
  # to anything downloaded and Gatekeeper refuses to open an unsigned app that
  # carries it -- and Sequoia removed the Control-click bypass, so without this
  # the install ends at a dialog with no obvious way past it.
  #
  # Clearing the flag as part of an install the person explicitly asked for is
  # the honest version of what they would otherwise do by hand. It is said out
  # loud in the caveats below rather than done quietly.
  #
  # `--no-quarantine` would be the usual route, but Homebrew is removing that
  # flag, so this does it directly and keeps working.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/unvelt.app"],
                   sudo: false
  end

  uninstall quit: "com.unvelt.desktop"

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

  caveats <<~EOS
    unvelt is not signed by Apple, so this cask cleared the quarantine flag
    macOS puts on downloads. Without that, Gatekeeper would refuse to open it
    and Sequoia no longer offers the Control-click bypass.

    Worth knowing before you grant anything:

      * macOS ties Accessibility and Automation permissions to an app's code
        signature, and an unsigned app has a new one after every build. You
        will be asked again after each update until unvelt is signed.
      * Notifications need Full Disk Access, which macOS will ask you for the
        first time you turn them on.
      * Music and video covers Spotify and Music, and -- through the
        media-control tool installed alongside this -- what is playing in a
        browser tab too, with the track name. If Apple closes the loophole
        media-control relies on, that quietly narrows back to Spotify and
        Music; browser audio is still counted as time an app spent making
        sound either way.
      * Headsets and other audio devices are not tracked on macOS yet. Windows
        reports them; this build does not.

    Nothing is collected until you sign in and choose what to turn on.
  EOS
end
