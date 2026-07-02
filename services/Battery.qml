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
    property real healthPercentage: {        if (!UPower.displayDevice) return 0;
        var health = UPower.displayDevice.healthPercentage;
        if (health > 0) return health;
        if (energyCapacity > 0) return (energy / energyCapacity) * 100;
        return 100;
    }
}