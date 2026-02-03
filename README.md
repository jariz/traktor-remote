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

Re-sign Traktor with these entitlements (one-time setup).  
Open a terminal (e.g. `Terminal.app`) and execute:

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

## Download

Grab the latest binaries from [Releases](https://github.com/jariz/traktor-remote/releases):

- `TraktorRemoteControl-arm64.zip` - Dylib (recommended)
- `traktor-remote-arm64.zip` - CLI tool

## Usage

### Option 1: Dylib (recommended)

```bash
DYLD_INSERT_LIBRARIES=/path/to/libTraktorRemoteControl.dylib "/Applications/Native Instruments/Traktor Pro 4/Traktor Pro 4.app/Contents/MacOS/Traktor Pro 4"
```

You should see something like:

```
2026-02-03 23:55:55.785 Traktor Pro 4[73355:1425966] [TraktorRemote] Patched feature_is_on at 0x102eeb210 - Robot server enabled on port 8080
```

### Option 2: CLI

```bash
sudo /path/to/traktor-remote
```

## Verification

Both methods enable the RPC server on port 8080. Test with:

```bash
curl -s http://127.0.0.1:8080 -d '<?xml version="1.0"?><methodCall><methodName>Get Property Double</methodName><params><param><value><string>app.traktor.masterclock.tempo</string></value></param></params></methodCall>'
```

If you get an XML response, you're all set.

## Building from source (optional)

```bash
swift build -c release
```

Binaries will be in `.build/release/`.
