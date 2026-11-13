cask "unvelt" do
  version "0.4.7"
  sha256 "0c4ab945943dff29aae773c33afcf6e64dc563939826737e8f6a183ba07abdb2"

  url "https://github.com/unvelt/unvelt-dist/releases/download/v#{version}/unvelt_#{version}_universal.dmg",
      verified: "github.com/unvelt/unvelt-dist/"

  name "unvelt"
  desc "Private record of your own computer activity"
  homepage "https://unvelt.co/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # unvelt updates itself on macOS: the app checks on start and every 6 h, and
  # the new version swaps in at the next start. Declaring that stops
  # `brew upgrade` reinstalling an older dmg over a newer bundle. It also
  # means a deliberate upgrade needs `--greedy`.
  auto_updates true
  depends_on macos: ">= :sonoma"
  # How a Mac sees what is playing in a browser tab. unvelt shells out to this
  # tool when it is present and covers the music apps alone otherwise, so
  # declaring it means a brew install sees browser audio out of the box. It is
  # in homebrew-core, so this is an ordinary formula dependency, not another
  # tap.
  depends_on formula: "media-control"

  app "unvelt.app"

  # unvelt is signed with its own certificate and is not notarized by Apple.
  # macOS attaches com.apple.quarantine to anything downloaded, and Gatekeeper
  # refuses to open a quarantined app that it cannot check with Apple -- and
  # Sequoia removed the Control-click bypass, so without this the install ends
  # at a dialog with no obvious way past it.
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
    macOS puts a quarantine flag on anything downloaded, and this cask clears
    it as part of the install so the app will open.

    Worth knowing before you grant anything:

      * If macOS asks again for Accessibility or Automation after an update,
        allow it again in System Settings > Privacy & Security.
      * unvelt updates itself, so `brew upgrade --cask unvelt` will say
        there is nothing to do. To update through Homebrew anyway, add
        `--greedy`.
      * The microphone grant is asked for at first launch. unvelt records
        which app is using the microphone, never any audio. Without the grant
        it sees no microphone activity at all.
      * Notifications need Full Disk Access, which macOS will ask you for the
        first time you turn them on.
      * Music and video covers your music apps, and what is playing in a
        browser tab when the companion tool installed alongside this is
        present.
      * Headsets and other audio devices are not recorded on macOS yet.

    Nothing is recorded until this Mac is linked to your account and you
    choose what it records.
  EOS
end
