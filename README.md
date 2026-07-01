# Shell

Modular Wayland status bar built with [Quickshell](https://quickshell.org) for Niri compositor.

## Project Structure

```
shell.qml                              # Entry point
shell.json                             # Runtime config (hot-reload)
Commons/                               # Shared singletons (qs.Commons)
  Color.qml                            # Global color palette
  Style.qml                            # Spacing, typography tokens
  Util.qml                             # Utility functions
  BarConfig.qml                        # Bar appearance settings
  ConfigLoader.qml                     # JSON config loader
  PopupControl.qml                     # Popup mutual exclusion
  LauncherState.qml                    # Launcher state mediator
services/                              # System integration singletons (Services)
  Audio.qml                            # PipeWire volume (wpctl)
  Battery.qml                          # UPower battery monitoring
  Bluetooth.qml                        # Quickshell.Bluetooth native API
  Network.qml                          # Quickshell.Networking native API
  PowerProfile.qml                     # Power profiles (D-Bus)
  Time.qml                             # Clock (12h/24h)
  Workspaces.qml                       # Niri workspace tracking (IPC)
  AppLauncherService.qml               # App filtering and launch
utils/                                 # Shared helpers (Utils)
  Icons.qml                            # Nerd Font glyphs
  Paths.qml                            # Filesystem paths
Ui/                                     # Reusable UI primitives (qs.Ui)
  PanelController.qml                  # Popup state machine singleton
  PopupCard.qml                        # Card container for popup content
  Toggle.qml                           # Toggle switch component
  PanelHero.qml                        # Hero section for popups
  PanelSectionHeader.qml               # Section header label
  PanelSeparator.qml                   # Horizontal divider
  Anim.qml                             # Animation primitives
  CAnim.qml                            # Composed animation component
  AnimLoader.qml                       # Lazy animation loader
modules/                               # UI feature modules
  bar/
    Bar.qml                            # Main bar (PanelWindow)
    Clock.qml                          # Time display
    AudioIndicator.qml                 # Volume icon + OSD trigger
    BluetoothIndicator.qml             # Bluetooth icon + popup
    NetworkIndicator.qml               # Network icon + popup
    BatteryIndicator.qml               # Battery icon + popup
    WorkspaceIndicator.qml             # Workspace numbers
    audio/
      AudioPopup.qml                   # Volume OSD (PanelWindow + PopupWindow)
    bluetooth/
      BluetoothPopup.qml               # Device list, scan, pair
    battery/
      BatteryPopup.qml                 # Battery info + power profiles
    network/
      NetworkPopup.qml                 # WiFi network list + password dialog
  launcher/
    LauncherButton.qml                 # Launcher button for status bar
    launcher/
      LauncherPopup.qml                # App launcher popup
      LauncherAppDelegate.qml          # App list delegate
      LauncherSearchBar.qml            # Search bar component
  lockscreen/
    LockScreen.qml                     # Wayland session lock (WlSessionLock)
```

## Install

```bash
ln -sf ~/projects/shell ~/.config/quickshell
```

## Run

```bash
quickshell -c ~/projects/shell
```

## Services

- **Audio** — PipeWire volume control via wpctl (polls 100ms)
- **Battery** — UPower battery monitoring with charge-level icons
- **Bluetooth** — Quickshell.Bluetooth native D-Bus API (pair/connect/disconnect/scan)
- **Network** — Quickshell.Networking native API (WiFi scan/connect, signal strength)
- **PowerProfile** — Power profiles via busctl D-Bus (power-saver/balanced/performance)
- **Time** — Live clock with 12/24hr format support
- **Workspaces** — Dynamic Niri workspace tracking via IPC (polls 500ms)

## Features

- Dynamic workspace indicators
- Bluetooth device management (pair, connect, disconnect, remove, scan)
- WiFi network scanning and connection (WPA/WPA2 support)
- Volume OSD with auto-hide
- Battery info with power profile selector
- Custom lockscreen (WlSessionLock)
- Mutual exclusion popups (only one open at a time)
- Click bar background to close all popups

## Configuration

Edit `shell.json` to customize bar appearance and enabled modules. Changes hot-reload automatically.

## Dependencies

- [quickshell](https://quickshell.org) (v0.3.0+)
- pipewire + wireplumber (audio)
- upower (battery)
- networkmanager (network)
- niri (compositor)

## Conventions

See [AGENTS.md](AGENTS.md) for coding conventions, architecture rules, and popup management patterns.
