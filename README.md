# Traktor Remote Control

Traktor has a hidden RPC server used internally for automation testing.
It can control almost everything - decks, mixer, effects, browser, transport.
This project enables it.

macOS only for now.

## What can you do with it?

Once enabled, Traktor listens on port 8080 and you can:

- Load tracks to decks
- Control playback (play, pause, cue, sync)
- Adjust volume, EQ, filters
- Control effects and crossfader
- Navigate the browser
- Read/write hundreds of internal properties

See [RPC.md](RPC.md) for the full API.

## Prerequisites

Re-sign Traktor with these entitlements (one-time setup):

```bash
cat > /tmp/debug.entitlements << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.get-task-allow</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
</dict>
</plist>
EOF

sudo codesign -s - -f --entitlements /tmp/debug.entitlements "/Applications/Native Instruments/Traktor Pro 4/Traktor Pro 4.app"
```

You'll need to redo this after Traktor updates.

## Build

```bash
swift build -c release
```

## Usage

### Option 1: Dylib (recommended)

```bash
DYLD_INSERT_LIBRARIES=.build/release/libTraktorRemoteControl.dylib "/Applications/Native Instruments/Traktor Pro 4/Traktor Pro 4.app/Contents/MacOS/Traktor Pro 4"
```

### Option 2: CLI

```bash
sudo .build/release/traktor-remote
```

Both methods enable the RPC server on port 8080.
