// Bluetooth service singleton.
// Uses Quickshell.Bluetooth native API for reactive state.
pragma Singleton
import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property bool scanning: adapter ? adapter.discovering : false
    property var pairedDevices: []
    property var availableDevices: []
    property var connectedDevice: null
    property string lastError: ""

    function clearPending(error: string) {
        root.lastError = error;
        errorClearTimer.restart();
    }

    Timer {
        id: errorClearTimer
        interval: 4000
        onTriggered: root.lastError = ""
    }

    // Poll paired devices and connected state every 3 seconds
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshPaired()
    }

    // Build device list from adapter.devices using values property
    function buildDeviceList(): var {
        if (!adapter) return [];
        var devs = adapter.devices.values;
        if (!devs) return [];
        var devices = [];
        for (var i = 0; i < devs.length; i++) {
            var d = devs[i];
            devices.push({
                name: d.name || d.deviceName || "Unknown",
                address: d.address,
                connected: d.connected,
                paired: d.paired,
                pairing: d.pairing,
                battery: d.batteryAvailable ? Math.round(d.battery * 100) : -1,
                icon: d.icon
            });
        }
        return devices;
    }

    // Refresh paired devices list
    function refreshPaired(): void {
        var all = buildDeviceList();
        var paired = [];
        var connected = null;
        for (var i = 0; i < all.length; i++) {
            if (all[i].paired) {
                paired.push(all[i]);
                if (all[i].connected && !connected) {
                    connected = all[i];
                }
            }
        }
        root.pairedDevices = paired;
        root.connectedDevice = connected;
    }

    // Refresh available (unpaired) devices from scan results
    function refreshAvailable(): void {
        if (!adapter) return;
        var devs = adapter.devices.values;
        if (!devs) return;
        var devices = [];
        for (var i = 0; i < devs.length; i++) {
            var d = devs[i];
            if (!d.paired) {
                devices.push({
                    name: d.name || d.deviceName || "Unknown",
                    address: d.address
                });
            }
        }
        root.availableDevices = devices;
    }

    // Toggle Bluetooth on/off
    function toggle(): void {
        if (!adapter) return;
        adapter.enabled = !adapter.enabled;
    }

    // Start scanning for devices
    function startScan(): void {
        if (!adapter) return;
        adapter.discoverable = true;
        adapter.pairable = true;
        adapter.discovering = true;
        scanPollTimer.restart();
    }

    // Stop scanning
    function stopScan(): void {
        if (!adapter) return;
        adapter.discovering = false;
        refreshAvailable();
    }

    // Continuously refresh available devices while scanning
    Timer {
        id: scanPollTimer
        interval: 2000
        running: root.scanning
        repeat: true
        onTriggered: root.refreshAvailable()
    }

    // Pair with device
    function pair(address: string): void {
        root.lastError = "";
        // Ensure pairable before pairing
        if (adapter) {
            adapter.pairable = true;
        }
        var device = root.findDevice(address);
        if (device) {
            device.pair();
            pairWatchTimer.address = address;
            pairWatchTimer.restart();
        }
    }

    // Watch for pairing result
    Timer {
        id: pairWatchTimer
        interval: 1000
        repeat: true
        property string address: ""
        onTriggered: {
            var device = root.findDevice(address);
            if (device && !device.pairing) {
                pairWatchTimer.stop();
                if (device.paired) {
                    root.refreshPaired();
                    root.refreshAvailable();
                } else {
                    root.clearPending("Pairing failed");
                }
            }
        }
    }

    // Connect to paired device
    function connect(address: string): void {
        root.lastError = "";
        var device = root.findDevice(address);
        if (device) {
            device.connect();
            connectWatchTimer.address = address;
            connectWatchTimer.restart();
        }
    }

    // Watch for connection result
    Timer {
        id: connectWatchTimer
        interval: 1000
        repeat: true
        property string address: ""
        onTriggered: {
            var device = root.findDevice(address);
            if (device) {
                if (device.connected) {
                    connectWatchTimer.stop();
                    root.refreshPaired();
                } else if (device.state === BluetoothDeviceState.Disconnected) {
                    connectWatchTimer.stop();
                    root.clearPending("Connection failed");
                }
            }
        }
    }

    // Disconnect from device
    function disconnect(address: string): void {
        var device = root.findDevice(address);
        if (device) {
            device.disconnect();
            disconnectRefreshTimer.restart();
        }
    }

    Timer {
        id: disconnectRefreshTimer
        interval: 1000
        onTriggered: root.refreshPaired()
    }

    // Remove paired device
    function remove(address: string): void {
        var device = root.findDevice(address);
        if (device) {
            device.forget();
            removeRefreshTimer.restart();
        }
    }

    Timer {
        id: removeRefreshTimer
        interval: 1000
        onTriggered: {
            root.refreshPaired();
            root.refreshAvailable();
        }
    }

    // Find device by address from adapter's device model
    function findDevice(address: string) {
        if (!adapter) return null;
        var devs = adapter.devices.values;
        if (!devs) return null;
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].address === address) return devs[i];
        }
        return null;
    }
}
