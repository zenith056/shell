// Battery service singleton.
// Wraps UPower to expose battery state and charge-level icons.
pragma Singleton
import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    id: root

    // Battery presence check
    property bool available: UPower.displayDevice ? UPower.displayDevice.isPresent : false
    // Charge percentage (0.0 - 1.0)
    property real percentage: UPower.displayDevice ? UPower.displayDevice.percentage : 0
    // Whether the battery is currently charging
    property bool charging: UPower.displayDevice ? UPower.displayDevice.state === UPowerDeviceState.Charging : false
    // Human-readable state string (e.g., "charging", "discharging")
    property string status: UPower.displayDevice ? UPowerDeviceState.toString(UPower.displayDevice.state) : "unknown"
    // Estimated seconds until fully charged
    property int timeToFull: UPower.displayDevice ? UPower.displayDevice.timeToFull : 0
    // Estimated seconds until empty
    property int timeToEmpty: UPower.displayDevice ? UPower.displayDevice.timeToEmpty : 0
    // Rate of energy change in watts (positive when charging, negative when discharging)
    property real changeRate: UPower.displayDevice ? UPower.displayDevice.changeRate : 0
    // Current energy level in watt-hours
    property real energy: UPower.displayDevice ? UPower.displayDevice.energy : 0
    // Maximum energy capacity in watt-hours
    property real energyCapacity: UPower.displayDevice ? UPower.displayDevice.energyCapacity : 0
    // Battery health percentage
    property real healthPercentage: UPower.displayDevice ? UPower.displayDevice.healthPercentage : 0
    // Device model name
    property string model: UPower.displayDevice ? UPower.displayDevice.model : "Unknown"

    // Returns a Nerd Font glyph based on current charge level
    function statusIcon(): string {
        if (!available)
            return "󱃌"; // nf-md-battery_outline — no battery detected
        if (charging)
            return ""; // nf-md-battery_charging — charging state
        if (percentage > 0.75)
            return ""; // nf-md-battery — full/high charge
        if (percentage > 0.50)
            return ""; // nf-md-battery_60 — medium charge
        if (percentage > 0.25)
            return ""; // nf-md-battery_10 — critical charge
        return ""; // nf-md-battery_10 — critical charge
    }
}
