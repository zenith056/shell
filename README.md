# Shell

Modular Wayland status bar built with [Quickshell](https://quickshell.org).

## Project Structure

```
shell.qml              # Entry point
config/                # Configuration singletons
  Colors.qml           # Global color palette
  BarConfig.qml        # Bar appearance settings
  Config.qml           # JSON config loader (reads shell.json)
services/              # System integration singletons
  Battery.qml          # UPower battery monitoring
  Network.qml          # NetworkManager/WiFi status
  Audio.qml            # PipeWire volume control
  Time.qml             # Clock with 12/24hr support
modules/               # UI feature modules
  bar/                 # Status bar components
    Bar.qml            # Main bar container
    Clock.qml          # Time display
    BatteryIndicator.qml  # Battery icon + percentage
    NetworkIndicator.qml  # Network icon + SSID
    Workspaces.qml     # Workspace dot indicators
utils/                 # Shared helpers
  Paths.qml            # Filesystem path constants
  Icons.qml            # Icon theme resolver
components/            # Reusable QML primitives (empty)
assets/                # Static resources (empty)
```

## Install

```bash
ln -sf ~/projects/shell ~/.config/quickshell
```

## Run

```bash
quickshell
```

## Services

- **Battery** — UPower battery monitoring with charge-level icons
- **Network** — NetworkManager/WiFi status (polls every 10s)
- **Audio** — PipeWire volume control (stub)
- **Time** — Live clock with 12/24hr format support

## Configuration

Edit `shell.json` to customize bar appearance and enabled modules. Changes hot-reload automatically.

## Dependencies

- [quickshell](https://quickshell.org)
- upower (battery service)
- networkmanager (network service)
- pipewire (audio service)
