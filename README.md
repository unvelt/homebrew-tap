# unvelt/homebrew-tap

The Homebrew tap for [unvelt](https://unvelt.co).

```sh
brew tap unvelt/tap
brew trust unvelt/tap      # see below
brew install --cask unvelt
```

## Why `brew trust` is needed

The cask runs a command during install (`xattr`, to clear the quarantine flag
-- see below), and Homebrew will not run arbitrary commands from a third-party
tap without being told to. That prompt is doing its job: a tap that can run
commands on install can run any command, so trusting one should be a decision
rather than a default. This one is ours, and the only thing it runs is the
`xattr` call in `Casks/unvelt.rb`, which you can read before agreeing.

## Why a tap

unvelt is signed with its own certificate and is not notarized by Apple, so it
is installed from here rather than from Homebrew's own cask repository.

## Why the cask clears the quarantine flag

macOS attaches `com.apple.quarantine` to anything downloaded, and Gatekeeper
refuses to open a quarantined app it cannot check with Apple. Sequoia removed
the old Control-click bypass, so without this the install ends at a dialog
with no obvious way past it — the honest fix is to clear the flag as part of
an install the person explicitly asked for, and to say plainly that it is
happening.

`--no-quarantine` is not used: Homebrew is removing that flag, so the cask
does it in `postflight` instead, which keeps working.

## What is not solved

macOS may ask again for Accessibility, Automation or Screen Recording after
an update. Whether it keeps those grants across updates hasn't been measured
yet. If it asks, allow it again in System Settings > Privacy & Security.
