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
    // Battery health percentage (0-100)
    property real healthPercentage: {
        if (!UPower.displayDevice) return 0;
        var health = UPower.displayDevice.healthPercentage;
        if (health > 0) return health;
        if (energyCapacity > 0) return (energy / energyCapacity) * 100;
        return 100;
    }
    // Device model name
    property string model: UPower.displayDevice ? (UPower.displayDevice.model || UPower.displayDevice.nativePath || "Unknown") : "Unknown"

    // Returns a Nerd Font glyph based on current charge level
    function statusIcon(): string {
        if (!available)
            return "\uf590";     // nf-md-battery_outline
        if (charging)
            return "\uf0e7";     // nf-md-battery_charging
        if (percentage > 0.75)
            return "\uf578";     // nf-md-battery
        if (percentage > 0.50)
            return "\uf577";     // nf-md-battery_60
        if (percentage > 0.25)
            return "\uf576";     // nf-md-battery_40
        return "\uf575";         // nf-md-battery_20
    }
}