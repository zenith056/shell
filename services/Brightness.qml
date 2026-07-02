// Brightness service singleton.
// Manages display brightness using sysfs and brightnessctl.
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // File views to read brightness values reactively from sysfs
    FileView {
        id: brightnessFile
        path: "file:///sys/class/backlight/intel_backlight/brightness"
    }

    FileView {
        id: maxBrightnessFile
        path: "file:///sys/class/backlight/intel_backlight/max_brightness"
    }

    // Current and max brightness levels
    readonly property int current: {
        var txt = brightnessFile.text();
        return txt ? parseInt(txt.trim()) : 0;
    }
    readonly property int max: {
        var txt = maxBrightnessFile.text();
        return txt ? parseInt(txt.trim()) : 456;
    }

    // Normalized brightness level (0.0 to 1.0)
    readonly property real level: max > 0 ? (current / max) : 0.0

    // Poll sysfs for changes every 250ms
    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: brightnessFile.reload()
    }

    // Set brightness using brightnessctl utility
    function setBrightness(l: real): void {
        var clamped = Math.max(0, Math.min(1, l));
        var target = Math.round(clamped * max);
        setBrightnessProc.command = ["brightnessctl", "set", target.toString()];
        setBrightnessProc.running = true;
    }

    property Process setBrightnessProc: Process {
        id: setBrightnessProc
    }
}
