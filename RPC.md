# RPC API Reference

XML-RPC server on `http://127.0.0.1:8080`

## Methods

| Method | Arguments | Description |
|--------|-----------|-------------|
| `Get Property Boolean` | `path` | Read boolean |
| `Get Property Integer` | `path` | Read integer |
| `Get Property Double` | `path` | Read double |
| `Get Property String` | `path` | Read string |
| `Set Property Boolean` | `path`, `value` | Write boolean |
| `Set Property Integer` | `path`, `value` | Write integer |
| `Set Property Double` | `path`, `value` | Write double |
| `Set Property String` | `path`, `value` | Write string |
| `Run Action` | `path` | Trigger action |
| `robot.app.traktor.browser.add_track_to_collection` | `file_path` | Import track |
| `robot.app.traktor.browser.clear_collection` | - | Clear collection |
| `robot.app.traktor.quit` | - | Quit Traktor |

## Decks (N = 1-4)

| Property | Type | Description |
|----------|------|-------------|
| `app.traktor.decks.N.is_loaded` | Bool | Track loaded |
| `app.traktor.decks.N.play` | Bool | Play/pause |
| `app.traktor.decks.N.content.title` | String | Title |
| `app.traktor.decks.N.content.artist` | String | Artist |
| `app.traktor.decks.N.content.bpm` | Double | BPM |
| `app.traktor.decks.N.content.key` | String | Key |
| `app.traktor.decks.N.tempo.adjust` | Double | Tempo adjust |
| `app.traktor.decks.N.track.key.lock_enabled` | Bool | Keylock |
| `app.traktor.decks.N.sync.enabled` | Bool | Sync |
| `app.traktor.decks.N.load.selected` | Bool | Load selected track (Set Property Boolean) |

## Mixer (N = 1-4)

| Property | Type | Description |
|----------|------|-------------|
| `app.traktor.mixer.channels.N.volume` | Double | Volume (0-1) |
| `app.traktor.mixer.channels.N.eq.high` | Double | High EQ |
| `app.traktor.mixer.channels.N.eq.mid` | Double | Mid EQ |
| `app.traktor.mixer.channels.N.eq.low` | Double | Low EQ |
| `app.traktor.mixer.channels.N.filter.value` | Double | Filter |
| `app.traktor.mixer.channels.N.filter.on` | Bool | Filter enabled |
| `app.traktor.mixer.xfader.adjust` | Double | Crossfader (0-1) |

## FX (N = 1-4)

| Property | Type | Description |
|----------|------|-------------|
| `app.traktor.fx.N.dry_wet` | Double | Dry/wet (0-1) |
| `app.traktor.fx.N.enabled` | Bool | FX enabled |

## Browser

| Property | Type | Description |
|----------|------|-------------|
| `app.traktor.browser.favorites.select` | Int | Jump to favorite (0=Prep, 1=History, 2=Collection) |
| `app.traktor.browser.list.select_up_down` | Int | Move selection (+down, -up) |
| `app.traktor.browser.tree.select_up_down` | Int | Move tree selection |
| `app.traktor.browser.preparation.append` | Bool | Add to prep list (Set Property Boolean) |
| `app.traktor.browser.full_screen` | Bool | Fullscreen |

## Master

| Property | Type | Description |
|----------|------|-------------|
| `app.traktor.masterclock.tempo` | Double | Master tempo |

## Notes

- Use `Set Property Boolean` for `load.selected`, `play`, `preparation.append`
- `add_track_to_collection` only works for new files (duplicate detection)
- New tracks appear at bottom of collection - navigate there to load them
