# unvelt/homebrew-tap

The Homebrew tap for [unvelt](https://github.com/unvelt/unvelt-desktop).

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

## Why a tap and not the main Homebrew repo

Homebrew's official cask repository stopped accepting unsigned casks on
1 September 2026, and unvelt is unsigned — an Apple Developer certificate is
$99/yr and this project has no revenue yet. Third-party taps are unaffected by
that rule, so this is where it lives until signing is worth buying.

## Why the cask clears the quarantine flag

macOS attaches `com.apple.quarantine` to anything downloaded, and Gatekeeper
refuses to open an unsigned app carrying it. Sequoia removed the old
Control-click bypass, so without this the install ends at a dialog with no
obvious way past it — the honest fix is to clear the flag as part of an
install the person explicitly asked for, and to say plainly that it is
happening.

`--no-quarantine` is not used: Homebrew is removing that flag, so the cask
does it in `postflight` instead, which keeps working.

## What is not solved

Every update re-asks for Accessibility, Automation and Screen Recording
permissions. macOS keys those grants to the code signature, and an unsigned
app has a different one after every build. That is the accepted cost of
shipping at $0; buying the Apple Developer Program is what ends it.
