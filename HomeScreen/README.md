# vamora-homescreen

Pre-alpha placeholder homescreen for VamoraOS — a maximized, fully transparent,
always-bottom window (like an Android launcher layer) that reads `.desktop`
entries from `~/Desktop/` and shows them across 3 swipeable pages.

Design language matches `vamora-statusbar-x11`: dark zinc palette, Inter font,
same cxx-qt bridge pattern (`AppList` QObject).

## What it does (and doesn't) do

- Scans `~/Desktop/*.desktop`, parses `Name=` / `Icon=` / `Exec=`, same rules
  as the statusbar project (skips `NoDisplay`/`Hidden`, resolves icon names
  against the standard hicolor/Adwaita/pixmaps paths).
- Chunks apps into 3 fixed pages (6 cols × 4 rows = 24 slots/page).
- Polls the folder every 3s and re-renders (no fs watcher yet — intentionally
  minimal for this pass).
- Launches an app on tap via `Command::spawn`.
- Nothing else. No drag-and-drop, no widgets, no reordering, no persistence —
  this is the visual/design pass before it gets wired deeper into the WM.

## Window behavior

- `flags: Qt.FramelessWindowHint | Qt.WindowStaysOnBottomHint`
- `color: "transparent"`, sized to `Screen.width x Screen.height`, `x/y: 0`
- Sits behind every other window so the wallpaper shows straight through.
  Note: `WindowStaysOnBottomHint` is a hint — actual stacking still depends
  on the window manager honoring it (works fine under Openbox, same as the
  statusbar's `WindowStaysOnTopHint` counterpart).

## Structure

```
src/
  main.rs                       loads layouts/homescreen/window.qml
  applist.rs                    AppList QObject (~/Desktop scanner + launcher)
  qml/
    layouts/homescreen/
      window.qml                fullscreen window, page indicator, SwipeView
      HomePage.qml               one page's app grid
      AppTile.qml                icon + label tile (drop-shadowed for wallpaper legibility)
    assets/                      shared icons (unknown.svg, star.svg, ...)
```

## Page indicator

Dots row anchored to the top (`z: 10`, above the grid). The active dot widens
into a short pill (7px → 22px) with an `OutQuart` width animation instead of
just changing color/opacity — tap a dot to jump to that page directly.

## Building

Same toolchain as `vamora-statusbar-x11` (cxx-qt / Qt6). From this directory:

```
cargo build
cargo run
```

## Next steps (not done here)

- Real drag/reorder + persisted layout
- App icon long-press context menu (remove from homescreen, app info — mirror
  the statusbar's context menu style)
- Replace the polling `Timer` with an actual filesystem watcher on `~/Desktop`
- Decide page count dynamically instead of the fixed `pageCount: 3`
