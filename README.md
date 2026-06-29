# Shell

Modular Wayland shell built with [Quickshell](https://quickshell.org).

## Structure

```
shell.qml          # Entry point
config/            # Configuration singletons
services/          # System integration singletons
modules/           # UI feature modules
  bar/             # Status bar
components/        # Reusable QML primitives
utils/             # Helpers (Paths, Icons)
assets/            # Static resources
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

- **Battery** - UPower battery monitoring
- **Network** - NetworkManager/WiFi status
- **Audio** - PipeWire volume control
- **Time** - Clock with 12/24hr support

## Dependencies

- quickshell
- upower (for battery service)
- networkmanager (for network service)
- pipewire (for audio service)
