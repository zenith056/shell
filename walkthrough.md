# Walkthrough - Lockscreen, Audio & Brightness OSD Refactoring, and Notification System

We have successfully integrated secure password authentication using PAM, added a reactive display brightness service, built a unified OSD popups window, resolved status bar popups Wayland hover flickering, and implemented a full native Desktop Notification Daemon stacked cleanly in the top-right corner.

## Changes Made

### 1. Desktop Notification Daemon (`Notifications` Service)
- **File created:** [Notifications.qml](file:///home/zenith/projects/shell/services/Notifications.qml)
  - Created a reactive singleton service wrapping Quickshell's native `NotificationServer`.
  - Configured capabilities: `bodyMarkupSupported: true`, `actionsSupported: true`, `imageSupported: true`, and `actionIconsSupported: true` to ensure external apps send all text layouts, images, and action buttons.
  - Set `keepOnReload: true` so notifications persist seamlessly during shell configuration reloads, marking reload-carried notifications with the `lastGeneration` flag.
- **File modified:** [qmldir](file:///home/zenith/projects/shell/services/qmldir)
  - Registered `singleton Notifications 1.0 Notifications.qml`.

### 2. Notification Overlay & Stack Layout (`NotificationOverlay.qml`)
- **File created:** [NotificationOverlay.qml](file:///home/zenith/projects/shell/modules/notifications/NotificationOverlay.qml)
  - Created a `PanelWindow` container anchored to the top-right of the screen (`margins.top: BarConfig.height + 8`, `margins.right: 8`).
  - **Dynamic Dimensioning & Mapping Guard:** Set `implicitWidth: 320` and bound `implicitHeight: screen ? screen.height - BarConfig.height - 16 : 1000`. Kept the window mapped with `visible: true` and `exclusionMode: Ignore` to bypass compositor mapping race conditions. Clicks pass through empty areas automatically.
  - **Premium GPU Transitions:** Implemented fluid transition animations for stacking layout:
    - **Add (Enter):** New cards slide in smoothly from the right edge (`320px` to `0`) and fade in.
    - **Remove (Exit):** Dismissed cards slide out to the right and fade out.
    - **Displaced:** Existing cards slide vertically with custom Emphasized elastic Bezier curves when cards above them are dismissed.

### 3. Glassmorphic Notification Cards (`NotificationCard.qml`)
- **File created:** [NotificationCard.qml](file:///home/zenith/projects/shell/modules/notifications/NotificationCard.qml)
  - Styled individual notification cards with a `320px` width, `radius: 12`, `border.color: Color.divider`, and background `Color.surface`.
  - **Header:** Displays the sending application's name, its icon (if a valid path/URL is sent in `notification.image`), or a fallback Nerd Font bell icon (`Icons.bell` in `Color.accent`). Includes a close button (`Icons.times`) calling `notification.dismiss()`.
  - **Body Content:** Renders the notification title (summary) and message body wrapping text safely.
  - **Actions Row:** Detects if the notification contains action buttons (e.g. "Accept/Reject", "Open Link"). Renders them dynamically as interactive, hover-active buttons that call `action.invoke()` on click.
  - **Hover-Debounced Timeout:** Features a timeout timer reading `notification.expireTimeout` (defaulting to 5 seconds). Hovering the cursor over the card pauses the timer, and leaving the card resumes the countdown.

### 4. Shell Integration
- **File modified:** [Icons.qml](file:///home/zenith/projects/shell/utils/Icons.qml)
  - Centralized the Nerd Font bell icon glyph `\uf0f3`.
- **File modified:** [qmldir](file:///home/zenith/projects/shell/modules/notifications/qmldir)
  - Registered notification types under `qs.modules.notifications`.
- **File modified:** [shell.qml](file:///home/zenith/projects/shell/shell.qml)
  - Imported `"modules/notifications"` and instantiated the global `NotificationOverlay` anchored to the bar.

---

## Verification Results

We verified that the configuration compiles and runs correctly by running the shell locally:
```bash
quickshell -p /home/zenith/projects/shell
```
- No syntax warnings or loader errors were reported.
- Confirmed that `NotificationServer` loads and is ready to claim the `org.freedesktop.Notifications` DBus endpoint.
