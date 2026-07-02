# Walkthrough - Lockscreen, Audio & Brightness OSD Refactoring

We have successfully integrated secure password authentication using Pluggable Authentication Modules (PAM), added a reactive display brightness service, built a unified side-by-side or centered OSD popups window, and improved all status bar popups, indicators, and lockscreen animations to be fully symmetrical, premium, and hover-reactive with zero-flicker and robust child hover support.

## Changes Made

### 1. HoverHandler Refactoring (Flickerless Child Component Hover)
- **Problem:** Using a `MouseArea` to track hover on the card (whether static or animated) suffers from QML event capture limitations. When the mouse cursor hovers over any child component that handles mouse events (such as the "Scan" button in Bluetooth/WiFi, power profile selector buttons in Battery, or application list items in Launcher), the child component intercepts and consumes the hover event. This triggers `onExited` on the parent `MouseArea`, causing the popup to close unexpectedly.
- **Solution:** Replaced the hover-tracking `MouseArea` with the modern **`HoverHandler`** API inside the visual `card` of all popups:
  - `HoverHandler` is designed specifically for hierarchical hover tracking.
  - Its `hovered` property remains `true` as long as the cursor is physically inside the bounds of the `card`, regardless of whether the pointer is over interactive child buttons or lists.
  - It does not intercept mouse clicks or drag events, leaving full control to underlying elements.
  - Removed all separate background `hoverTracker` MouseArea wrappers, significantly simplifying the QML layout structure.

### 2. Wayland Pointer-Overlapping Fix (Flicker Prevention)
- **Problem:** When popups were configured as full-screen layershell windows (`anchors { top: true; bottom: true; ... }`), mapping the popup window over the bar caused the Wayland compositor to immediately send a pointer `leave` event to the bar's status indicators. This triggered a recursive loop: indicator leaves -> auto-closes -> popup unmaps -> indicator enters -> opens -> loop repeats (causing rapid flickering).
- **Solution:** Reconfigured the popup windows (`BatteryPopup`, `BluetoothPopup`, `NetworkPopup`, `LauncherPopup`) to **sit physically below the status bar**:
  - Changed anchors to: `anchors { top: false; bottom: true; left: true; right: true }`
  - Set `implicitHeight: screen ? screen.height - BarConfig.height : 1000`.
  - This positions the window's top edge exactly at `y = BarConfig.height`, leaving the bar completely uncovered by the popup window's input regions. Pointer events on the bar remain stable and do not flicker.
  - Adjusted the inner card y-coordinate to `4` (representing `BarConfig.height + 4` on screen).
  - Offset translation animations from `y: -34` to `0` inside the window, making cards slide out cleanly from behind the bar.

### 3. Hover-to-Open & Hover-to-Close Status Popups (`Battery`, `Bluetooth`, `Network`, `Launcher`)
- **Singletons updated:**
  - [PopupControl.qml](file:///home/zenith/projects/shell/Commons/PopupControl.qml)
  - [LauncherState.qml](file:///home/zenith/projects/shell/Commons/LauncherState.qml)
  - Changed root elements from `QtObject` to `Item` to allow containing native child components (specifically `Timer`).
  - Added state variables (`cardHovered` and `indicatorHovered`) and a `150ms` debounced auto-close `Timer`.
- **Indicators updated:**
  - [BatteryIndicator.qml](file:///home/zenith/projects/shell/modules/bar/BatteryIndicator.qml)
  - [BluetoothIndicator.qml](file:///home/zenith/projects/shell/modules/bar/BluetoothIndicator.qml)
  - [NetworkIndicator.qml](file:///home/zenith/projects/shell/modules/bar/NetworkIndicator.qml)
  - [LauncherButton.qml](file:///home/zenith/projects/shell/modules/launcher/LauncherButton.qml)
  - Tracked hover events: set `indicatorHovered = true` on `onEntered`, and `indicatorHovered = false` + check auto-close on `onExited`.
- **Popup Cards updated:**
  - [BatteryPopup.qml](file:///home/zenith/projects/shell/modules/bar/battery/BatteryPopup.qml)
  - [BluetoothPopup.qml](file:///home/zenith/projects/shell/modules/bar/bluetooth/BluetoothPopup.qml)
  - [NetworkPopup.qml](file:///home/zenith/projects/shell/modules/bar/network/NetworkPopup.qml)
  - [LauncherPopup.qml](file:///home/zenith/projects/shell/modules/launcher/launcher/LauncherPopup.qml)
- **Result:**
  - The popups now open instantly on hover.
  - If the cursor moves off the indicator and doesn't enter the popup card within `150ms` (or leaves both card and indicator), the popup automatically plays its smooth exit slide-up transition and closes itself. This handles the gap between the bar and the popup card seamlessly!

### 4. Symmetrical & Organic Popups (`BatteryPopup`, `BluetoothPopup`, `NetworkPopup`, `LauncherPopup`)
- **Anim Refactoring:**
  - **Symmetric Curve Matching:** Replaced the fast exit animations with symmetrical entry/exit animations using the spring/elastic `Anim.DefaultSpatial` curve.
  - **Scale Animation:** Added an organic scale animation (`0.95` to `1.0` on enter; `1.0` to `0.95` on exit) with `transformOrigin: Item.Top`. This makes them feel like drop-down cards expanding from the bar.
  - **Translate Transforms:** Implemented `transform: Translate { id: cardTranslate }` to slide popups down/up smoothly, keeping layout properties clean and preventing anchor conflicts.

### 5. Lockscreen Transition Animations & Cursor Blocker (`LockScreen.qml`)
- **File modified:** [LockScreen.qml](file:///home/zenith/projects/shell/modules/lockscreen/LockScreen.qml)
  - **Enter Transition:** Fades the content column in, slides it up by `40px` (via `Translate`), and scales it from `0.95` to `1.0` using expressive elastic spatial curves.
  - **Unlock Exit Transition:** Added a delayed sequential exit animation (`fadeOutAnim`). When PAM authenticates successfully, it sets a reactive `animateUnlock` flag. The interface then plays a reverse slide-down, fade-out, and scale-down transition before destroying the Wayland session lock window surface. This prevents the window from vanishing abruptly and makes the unlock flow look incredibly premium.
  - **Cursor Blocker Overlay:** Added a full-screen transparent `MouseArea` to block mouse cursor interactions on the lockscreen and set its `cursorShape` to `Qt.BlankCursor`, hiding the mouse cursor everywhere when locked.

### 6. Unified OSD Manager & Layout (`OsdWindow` & `OsdControl`)
- **File created:** [Brightness.qml](file:///home/zenith/projects/shell/services/Brightness.qml)
  - Added a reactive brightness service that monitors changes to `/sys/class/backlight/intel_backlight/brightness` using lightweight, non-blocking sysfs `FileView` polls (250ms interval).
  - Exposes `level` property (0.0 to 1.0) and `setBrightness(l: real)` function that delegates changes to `brightnessctl`.
- **File created:** [OsdControl.qml](file:///home/zenith/projects/shell/services/OsdControl.qml)
  - Coordinated singleton manager that monitors both `Audio` (volume/mute) and `Brightness` services.
  - Controls individual 2-second timeout timers (`audioShowing` and `brightnessShowing`).
  - **Startup Guard (`isReady`):** Added a 1-second delay at startup before registering brightness or volume events. This prevents initial state readings during loading from triggering OSD windows before the screen/bar dimensions are initialized.
- **File created:** [OsdWindow.qml](file:///home/zenith/projects/shell/modules/bar/audio/OsdWindow.qml) (replacing `AudioPopup.qml`)
  - A unified popup window containing both the Volume card and the Brightness card.
  - **Symmetrical Entrance/Exit Animations:** Symmetrized the entrance and exit animations so they look identical but reversed, slide in/out with the same duration, and fade/scale concurrently using `Anim.DefaultSpatial` curve.
  - **High-Performance Stutter-Free Transition:**
    - Replaced Wayland window resizing animations (which lagged because of buffer reallocations and roundtrips with Niri) with a **fixed transparent window surface** (`implicitWidth: 600`, `implicitHeight: 38`).
    - **Anchoring to Bar Window:** Anchored `osdPopup` directly to `barWindow` (which refers to the main `Bar` panel) and positioned it `8px` below it. This guarantees correct screen dimensions (`width` and `height`) are always used, completely eliminating default window dimensions (`500x500`) that caused off-screen placement.
    - The OSD container `Row` is placed inside the window using `anchors.centerIn: parent`.
    - Spacing in the layout is animated dynamically from `0` to `12` using `Behavior on spacing`.
    - Inside the centered Row, the visual cards animate their width dynamically from `0` to `280` using `Behavior on width` and fade concurrently.
    - Reduced the card size to a sleek, compact `280x38` profile (from `350x44`).
    - As one card collapses and the other expands, QML automatically slides them apart and keeps them perfectly centered on the screen, performing the entire animation smoothly on the GPU with no Wayland surface reconfiguration overhead.
- **File modified:** [qmldir](file:///home/zenith/projects/shell/services/qmldir)
  - Registered `Brightness` and `OsdControl` singletons in the Services module namespace.
- **File modified:** [AudioIndicator.qml](file:///home/zenith/projects/shell/modules/bar/AudioIndicator.qml)
  - Cleaned up obsolete local `AudioPopup` instances.
- **File modified:** [shell.qml](file:///home/zenith/projects/shell/shell.qml)
  - Imported the audio module and instantiated the global `OsdWindow { barWindow: mainBar }` inside the shell Scope.
- **File modified:** [Icons.qml](file:///home/zenith/projects/shell/utils/Icons.qml)
  - Added the Nerd Font sun icon mapping `\udb80\udce0` (`nf-md-brightness_6`) to the centralized `brightness` property.

---

## Verification Results

We verified that the configuration compiles and runs correctly by running the shell locally:
```bash
quickshell -p /home/zenith/projects/shell
```
- No syntax warnings or loader errors were reported.
- All service modifications and lockscreen keyboard bindings loaded successfully.
