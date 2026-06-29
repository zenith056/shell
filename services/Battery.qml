pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property bool available: false
    property real percentage: 0
    property bool charging: false
    property string status: "unknown"
    property int timeToFull: 0
    property int timeToEmpty: 0

    function statusIcon(): string {
        if (!available) return "battery-missing"
        if (charging) return "battery-charging"
        if (percentage > 75) return "battery-full"
        if (percentage > 50) return "battery-good"
        if (percentage > 25) return "battery-low"
        return "battery-empty"
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._update()
    }

    function _update(): void {
        // Read from UPower via /sys/class/power_supply
        var proc = "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null"
        // Will be populated by process execution
    }
}
