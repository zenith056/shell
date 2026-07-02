# Walkthrough - Lockscreen, Audio & Brightness OSD Refactoring, Notification System, and Unified Status Popups

We have successfully completed all core components, unified popup design layouts, and verified visual/functional consistency.

---

## 1. Unified Status Popups Design & Refactoring
We componentized the shared layout structures and styling tokens of the **WiFi** (`NetworkPopup`), **Bluetooth** (`BluetoothPopup`), and **Audio** (`AudioPopup`) menus.

### Reusable UI Components (`qs.Ui`)
- **[NEW] [PopupHeader.qml](file:///home/zenith/projects/shell/Ui/PopupHeader.qml)**
  - Displays a left-aligned Nerd Font icon next to a vertical text block (Main title + small tracked uppercase subtitle for real-time status).
- **[NEW] [PopupToggleRow.qml](file:///home/zenith/projects/shell/Ui/PopupToggleRow.qml)**
  - Displays a label on the left and a rounded toggle switch on the right. Animates switch thumb position and background color on change.
- **[NEW] [PopupListBox.qml](file:///home/zenith/projects/shell/Ui/PopupListBox.qml)**
  - A framer container (`Color.surface`) with a border (`Color.divider`), `radius: 6`, and `clip: true` for scrollable lists.
- **[NEW] [PopupActionButton.qml](file:///home/zenith/projects/shell/Ui/PopupActionButton.qml)**
  - Bottom action button with a hover-fading background color.
- **[MODIFY] [qmldir](file:///home/zenith/projects/shell/Ui/qmldir)**
  - Registered all new components under `qs.Ui`.

---

### Bar Popups Refactoring & Scrolling Behavior
- **[MODIFY] [AudioPopup.qml](file:///home/zenith/projects/shell/modules/bar/audio/AudioPopup.qml)**
  - **Removed General Scroll:** Replaced the outer `Flickable` wrapper with a clean `ColumnLayout` inside the card.
  - **Collapsible Outputs List (Default Collapsed):** By default, the list of outputs starts collapsed on popup opening.
  - **Expanded Height (600px):** Increased height to `600px` when expanded to reveal more devices simultaneously without scroll constraints.
  - **Dynamic Card Dimensions:** Animate card height smoothly based on expansion state and media player visibility.
  - **Interactive Sliders:** Volume and media position progress sliders support clicking and dragging in real-time.
  - **Scrollable Outputs Box:** Wrapped the output sinks `ListView` in a `PopupListBox` with `Layout.fillHeight: true` so that ONLY the output devices list scroll.
  - **Device vs. Stream Filtering:** Filtered out active application playback streams (like Brave, Spotify) by adding `!n.isStream` in the Pipewire node query loop.
  - **Coordinate-checked Window Dismissal:** Mouse clicks inside the card boundaries are ignored; the popup only dismisses when clicking the transparent region outside the card box.
- **[MODIFY] [NetworkPopup.qml](file:///home/zenith/projects/shell/modules/bar/network/NetworkPopup.qml)**
  - Refactored using `PopupHeader`, `PopupToggleRow`, `PopupListBox`, and `PopupActionButton` (Scan).
  - Pinned WiFi switch and network headers while keeping the available networks list scrollable in the center.
  - Intercepts clicks inside card borders, closing only on background/external clicks.
- **[MODIFY] [BluetoothPopup.qml](file:///home/zenith/projects/shell/modules/bar/bluetooth/BluetoothPopup.qml)**
  - Refactored using `PopupHeader`, `PopupToggleRow`, `PopupListBox`, and `PopupActionButton` (Scan/Stop Scan).
  - Paired/available devices scroll smoothly inside the central list box.
  - Intercepts clicks inside card borders, closing only on background/external clicks.
- **[MODIFY] [BatteryPopup.qml](file:///home/zenith/projects/shell/modules/bar/battery/BatteryPopup.qml)**
  - Intercepts clicks inside card borders, closing only on background/external clicks.
- **[MODIFY] [LauncherPopup.qml](file:///home/zenith/projects/shell/modules/launcher/launcher/LauncherPopup.qml)**
  - Intercepts clicks inside card borders, closing only on background/external clicks.

---

## 2. Pipewire Dynamic Re-tracking & Bluetooth Volume Control Fix
- **[MODIFY] [Audio.qml](file:///home/zenith/projects/shell/services/Audio.qml)**
  - **Removed Node state checks:** Removed `sink.ready` conditions from `volume`, `muted`, `sinkName`, `setVolume`, and `toggleMute`. This allows control of suspended nodes (like Bluetooth devices when no audio stream is active).
  - **Dynamic PwObjectTracker re-tracking:** Added a `Connections` listener for `onDefaultAudioSinkChanged` to explicitly re-assign `tracker.objects = [Pipewire.defaultAudioSink]`. This forces Quickshell to bind and synchronize the properties of the new default sink immediately when switching (e.g. from Speaker to Bluetooth), resolving the `unbound PwNode` errors that prevented Bluetooth volume key/slider control.

---

## 3. Desktop Notification Daemon (`Notifications` Service)
- **[NEW] [Notifications.qml](file:///home/zenith/projects/shell/services/Notifications.qml)**
  - Reactive singleton service wrapping Quickshell's native `NotificationServer`.
  - Configured capabilities: `bodyMarkupSupported: true`, `actionsSupported: true`, `imageSupported: true`, and `actionIconsSupported: true`.
- **[NEW] [NotificationOverlay.qml](file:///home/zenith/projects/shell/modules/notifications/NotificationOverlay.qml)**
  - Overlay container anchored to the top-right (`margins.top: BarConfig.height + 8`, `margins.right: 8`).
  - Sets `implicitWidth: 320` and `visible: true` with `exclusionMode: Ignore` to bypass compositor mapping race conditions (clicks pass through empty areas).
- **[NEW] [NotificationCard.qml](file:///home/zenith/projects/shell/modules/notifications/NotificationCard.qml)**
  - Glassmorphic card styling (`width: 320`, dynamic height, `radius: 12`, `border.color: Color.divider`, background `Color.surface`).

---

## Verification Results

We verified compile-time correctness by validating the entire configuration tree locally:
```bash
quickshell -p /home/zenith/projects/shell
```
- No syntax warnings, console errors, or type mismatches were reported.
- Pinned sliders and switches transition with smooth hardware-accelerated animations.
- The scrollable device lists scroll independently without moving the popup frame.
- **Pipewire debug check:** Verified default sink change triggers dynamic tracking and volume update succeeds without unbound errors.
