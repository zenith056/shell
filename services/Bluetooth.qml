// Bluetooth service singleton.
// Manages Bluetooth state, scanning, and device connections.
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool enabled: false
    property bool scanning: false
    property var pairedDevices: []
    property var availableDevices: []
    property var connectedDevice: null
    property int connectedBattery: -1

    // Polls Bluetooth state every 3 seconds
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            powerProc.exec(["bluetoothctl", "show"]);
            pairedProc.exec(["bluetoothctl", "devices", "Paired"]);
        }
    }

    // Get power state
    Process {
        id: powerProc
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.enabled = this.text.includes("Powered: yes");
            }
        }
    }

    // Get paired devices
    Process {
        id: pairedProc
        command: ["bluetoothctl", "devices", "Paired"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                var devices = [];
                for (var i = 0; i < lines.length; i++) {
                    var match = lines[i].match(/^Device ([\w:]+)\s+(.+)$/);
                    if (match) {
                        devices.push({
                            address: match[1],
                            name: match[2]
                        });
                    }
                }
                root.pairedDevices = devices;
                root.updateConnectedDevice();
            }
        }
    }

    // Update connected device info
    function updateConnectedDevice() {
        for (var i = 0; i < pairedDevices.length; i++) {
            infoProc.command = ["bluetoothctl", "info", pairedDevices[i].address];
            infoProc.running = true;
            break;
        }
    }

    Process {
        id: infoProc
        command: ["bluetoothctl", "info", ""]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var text = this.text;
                if (text.includes("Connected: yes")) {
                    var nameMatch = text.match(/Name:\s+(.+)/);
                    root.connectedDevice = nameMatch ? nameMatch[1] : "Unknown";
                } else {
                    root.connectedDevice = null;
                }
            }
        }
    }

    // Toggle Bluetooth on/off
    function toggle(): void {
        if (enabled) {
            toggleProc.command = ["bluetoothctl", "power", "off"];
        } else {
            toggleProc.command = ["bluetoothctl", "power", "on"];
        }
        toggleProc.running = true;
        enabled = !enabled;
    }

    Process {
        id: toggleProc
        command: ["bluetoothctl", "power", "off"]
    }

    // Start scanning
    function startScan(): void {
        scanning = true;
        scanProc.running = true;
        // Stop scan after 10 seconds
        scanTimer.start();
    }

    Process {
        id: scanProc
        command: ["bluetoothctl", "scan", "on"]
    }

    Timer {
        id: scanTimer
        interval: 10000
        onTriggered: {
            root.scanning = false;
            stopScanProc.running = true;
            root.refreshAvailable();
        }
    }

    Process {
        id: stopScanProc
        command: ["bluetoothctl", "scan", "off"]
    }

    // Refresh available devices
    function refreshAvailable(): void {
        availableProc.running = true;
    }

    Process {
        id: availableProc
        command: ["bluetoothctl", "devices", "Device"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                var devices = [];
                var pairedAddresses = {};
                for (var i = 0; i < root.pairedDevices.length; i++) {
                    pairedAddresses[root.pairedDevices[i].address] = true;
                }
                for (var i = 0; i < lines.length; i++) {
                    var match = lines[i].match(/^Device ([\w:]+)\s+(.+)$/);
                    if (match && !pairedAddresses[match[1]]) {
                        devices.push({
                            address: match[1],
                            name: match[2]
                        });
                    }
                }
                root.availableDevices = devices;
            }
        }
    }

    // Pair with device
    function pair(address: string): void {
        pairProc.command = ["bluetoothctl", "pair", address];
        pairProc.running = true;
    }

    Process {
        id: pairProc
        command: ["bluetoothctl", "pair", ""]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.refreshAvailable();
                pairedProc.exec(["bluetoothctl", "devices", "Paired"]);
            }
        }
    }

    // Connect to device
    function connect(address: string): void {
        connectProc.command = ["bluetoothctl", "connect", address];
        connectProc.running = true;
    }

    Process {
        id: connectProc
        command: ["bluetoothctl", "connect", ""]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                pairedProc.exec(["bluetoothctl", "devices", "Paired"]);
            }
        }
    }

    // Disconnect from device
    function disconnect(address: string): void {
        disconnectProc.command = ["bluetoothctl", "disconnect", address];
        disconnectProc.running = true;
    }

    Process {
        id: disconnectProc
        command: ["bluetoothctl", "disconnect", ""]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                pairedProc.exec(["bluetoothctl", "devices", "Paired"]);
            }
        }
    }

    // Remove paired device
    function remove(address: string): void {
        removeProc.command = ["bluetoothctl", "remove", address];
        removeProc.running = true;
    }

    Process {
        id: removeProc
        command: ["bluetoothctl", "remove", ""]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                pairedProc.exec(["bluetoothctl", "devices", "Paired"]);
                root.refreshAvailable();
            }
        }
    }

    // Get battery level for device
    function getBattery(address: string): void {
        batteryProc.command = ["bluetoothctl", "info", address];
        batteryProc.running = true;
    }

    Process {
        id: batteryProc
        command: ["bluetoothctl", "info", ""]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var match = this.text.match(/Battery Percentage:\s+\w+\s+\((\d+)%\)/);
                if (match) {
                    root.connectedBattery = parseInt(match[1]);
                } else {
                    root.connectedBattery = -1;
                }
            }
        }
    }

}