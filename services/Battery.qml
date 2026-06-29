pragma Singleton
import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    id: root

    property bool available: UPower.displayDevice ? UPower.displayDevice.isPresent : false
    property real percentage: UPower.displayDevice ? UPower.displayDevice.percentage : 0
    property bool charging: UPower.displayDevice ? UPower.displayDevice.state === UPowerDeviceState.Charging : false
    property string status: UPower.displayDevice ? UPowerDeviceState.toString(UPower.displayDevice.state) : "unknown"
    property int timeToFull: UPower.displayDevice ? UPower.displayDevice.timeToFull : 0
    property int timeToEmpty: UPower.displayDevice ? UPower.displayDevice.timeToEmpty : 0

    function statusIcon(): string {
        if (!available) return "battery-missing"
        if (charging) return "battery-charging"
        if (percentage > 0.75) return "battery-full"
        if (percentage > 0.50) return "battery-good"
        if (percentage > 0.25) return "battery-low"
        return "battery-empty"
    }
}
