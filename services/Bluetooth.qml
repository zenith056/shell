// Bluetooth service singleton.
// Uses Quickshell.Bluetooth native API for fully reactive, timer-free state.
pragma Singleton
import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    // Reactive reference to default Bluetooth adapter
    readonly property var adapter: Bluetooth.defaultAdapter

    // Reactive status properties
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property bool scanning: adapter ? adapter.discovering : false

    // Reactive list of all paired devices
    readonly property var pairedDevices: {
        if (!adapter) return [];
        var devs = adapter.devices.values;
        if (!devs) return [];
        var list = [];
        for (var i = 0; i < devs.length; i++) {
            var d = devs[i];
            if (d.paired) {
                list.push({
                    name: d.name || d.deviceName || "Unknown",
                    address: d.address,
                    connected: d.connected,
                    paired: d.paired,
                    pairing: d.pairing,
                    battery: d.batteryAvailable ? Math.round(d.battery * 100) : -1,
                    icon: d.icon,
                    deviceObj: d
                });
            }
        }
        return list;
    }

    // Reactive reference to the currently connected device (first connected paired device)
    readonly property var connectedDevice: {
        var devs = pairedDevices;
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].connected) {
                return devs[i];
            }
        }
        return null;
    }

    // Reactive list of available (unpaired) devices
    readonly property var availableDevices: {
        if (!adapter) return [];
        var devs = adapter.devices.values;
        if (!devs) return [];
        var list = [];
        for (var i = 0; i < devs.length; i++) {
            var d = devs[i];
            if (!d.paired) {
                list.push({
                    name: d.name || d.deviceName || "Unknown",
                    address: d.address,
                    deviceObj: d
                });
            }
        }
        return list;
    }

    // Track last error message
    property string lastError: ""

    Timer {
        id: errorClearTimer
        interval: 4000
        onTriggered: root.lastError = ""
    }

    // Toggle Bluetooth power state
    function toggle(): void {
        if (adapter) {
            adapter.enabled = !adapter.enabled;
        }
    }

    // Start scanning for devices
    function startScan(): void {
        if (adapter) {
            adapter.discoverable = true;
            adapter.pairable = true;
            adapter.discovering = true;
        }
    }

    // Stop scanning
    function stopScan(): void {
        if (adapter) {
            adapter.discovering = false;
        }
    }

    // Pair with a device by address
    function pair(address: string): void {
        root.lastError = "";
        if (adapter) {
            adapter.pairable = true;
        }
        var device = findDevice(address);
        if (device) {
            device.pair();
        }
    }

    // Connect to a device by address
    function connect(address: string): void {
        root.lastError = "";
        var device = findDevice(address);
        if (device) {
            device.connect();
        }
    }

    // Disconnect from a device by address
    function disconnect(address: string): void {
        var device = findDevice(address);
        if (device) {
            device.disconnect();
        }
    }

    // Remove (forget) a paired device by address
    function remove(address: string): void {
        var device = findDevice(address);
        if (device) {
            device.forget();
        }
    }

    // Helper: Find device object by address in adapter's devices list
    function findDevice(address: string): var {
        if (!adapter) return null;
        var devs = adapter.devices.values;
        if (!devs) return null;
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].address === address) return devs[i];
        }
        return null;
    }
}
