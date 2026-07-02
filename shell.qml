// Entry point for the Quickshell Wayland shell.
// Instantiates global config, status bar, and top-level popups.
import Quickshell
import QtQuick
import Quickshell.Io
import "Commons"
import "services"
import "modules/bar"
import "modules/launcher/launcher"
import "modules/bar/battery"
import "modules/bar/bluetooth"
import "modules/bar/network"
import "modules/bar/audio"
import "modules/lockscreen"
import "modules/notifications"

Scope {
    id: root

    LauncherPopup { }
    BatteryPopup { }
    BluetoothPopup { }
    NetworkPopup { }
    AudioPopup { }
    Bar { id: mainBar }
    LockScreen { id: lockScreen }
    OsdWindow { barWindow: mainBar }
    NotificationToast { barWindow: mainBar }

    IpcHandler {
        target: "shell"

        function togglePopup(name: string): void {
            if (name === "bluetooth" || name === "network" || name === "battery" || name === "audio") {
                PopupControl.toggle(name, null);
            } else if (name === "launcher") {
                if (LauncherState.isOpen) {
                    LauncherState.hide();
                } else {
                    LauncherState.show(null, null);
                }
            }
        }

        function closeAll(): void {
            PopupControl.close();
            LauncherState.hide();
        }

        function closePopup(name: string): void {
            if (name === "launcher") LauncherState.hide();
            else if (PopupControl.activePopup === name) PopupControl.close();
        }

        function lock(): void {
            lockScreen.lock();
        }
    }
}
