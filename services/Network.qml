// Network service singleton.
// Polls NetworkManager via nmcli to expose connection state and signal icons.
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool connected: false
    property bool wifi: false
    property bool wifiEnabled: true
    property string ssid: ""
    property string ipAddress: ""
    property int signalStrength: 0
    property string state: "disconnected"
    property var availableNetworks: []
    property var knownNetworks: []
    property bool hotspotActive: false
    property string hotspotSsid: ""
    property string hotspotPassword: ""

    // Polls every 2 seconds for network status changes
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stateProc.exec(["nmcli", "-t", "-f", "STATE", "general"]);
            deviceProc.exec(["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]);
            wifiProc.exec(["nmcli", "radio", "wifi"]);
            hotspotProc.exec(["nmcli", "-t", "-f", "ACTIVE,SSID", "connection", "show", "--active"]);
            knownProc.exec(["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]);
        }
    }

    Process {
        id: stateProc
        command: ["nmcli", "-t", "-f", "STATE", "general"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var val = this.text.trim();
                root.connected = val === "connected";
                root.state = val;
            }
        }
    }

    Process {
        id: deviceProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                root.wifi = false;
                root.ssid = "";

                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":");
                    if (parts.length >= 3 && parts[1] === "connected") {
                        if (parts[0] === "wifi") {
                            root.wifi = true;
                            root.ssid = parts[2];
                        }
                    }
                }

                if (root.wifi) {
                    signalProc.exec(["nmcli", "-t", "-f", "IN-USE,SIGNAL", "device", "wifi", "list"]);
                } else {
                    root.signalStrength = 0;
                }
            }
        }
    }

    Process {
        id: signalProc
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL", "device", "wifi", "list"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                root.signalStrength = 0;

                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":");
                    if (parts.length >= 2 && parts[0] === "*") {
                        root.signalStrength = parseInt(parts[1]) || 0;
                        break;
                    }
                }
            }
        }
    }

    Process {
        id: wifiProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.wifiEnabled = this.text.trim() === "enabled";
            }
        }
    }

    Process {
        id: hotspotProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID", "connection", "show", "--active"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                root.hotspotActive = false;
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":");
                    if (parts.length >= 2 && parts[0] === "yes" && parts[1].startsWith("Hotspot")) {
                        root.hotspotActive = true;
                        root.hotspotSsid = parts[1];
                        break;
                    }
                }
            }
        }
    }

    // Get known/saved WiFi networks
    Process {
        id: knownProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                var known = [];
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":");
                    if (parts.length >= 2 && parts[1] === "802-11-wireless") {
                        known.push(parts[0]);
                    }
                }
                root.knownNetworks = known;
            }
        }
    }

    // Toggle WiFi on/off
    function toggleWifi(): void {
        var newState = wifiEnabled ? "off" : "on";
        toggleWifiProc.command = ["nmcli", "radio", "wifi", newState];
        toggleWifiProc.running = true;
        wifiEnabled = !wifiEnabled;
    }

    Process {
        id: toggleWifiProc
        command: ["nmcli", "radio", "wifi", "off"]
    }

    // Scan available WiFi networks
    function scanNetworks(): void {
        scanProc.running = true;
    }

    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "yes"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                var networks = [];
                var seen = {};

                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":");
                    if (parts.length >= 3 && parts[0] !== "") {
                        var ssid = parts[0];
                        if (!seen[ssid]) {
                            seen[ssid] = true;
                            networks.push({
                                ssid: ssid,
                                signal: parseInt(parts[1]) || 0,
                                security: parts[2] || "None"
                            });
                        }
                    }
                }

                networks.sort(function(a, b) { return b.signal - a.signal; });
                root.availableNetworks = networks;
            }
        }
    }

    // Connect to a WiFi network
    function connect(ssid: string, password: string): void {
        if (password.length > 0) {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password];
        } else {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid];
        }
        connectProc.running = true;
    }

    Process {
        id: connectProc
        command: ["nmcli", "device", "wifi", "connect", ""]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.scanNetworks();
            }
        }
    }

    // Disconnect from current WiFi
    function disconnect(): void {
        disconnectProc.running = true;
    }

    Process {
        id: disconnectProc
        command: ["nmcli", "device", "disconnect", "wlp0s20f3"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.scanNetworks();
            }
        }
    }

    // Toggle hotspot
    function toggleHotspot(): void {
        if (hotspotActive) {
            hotspotToggleProc.command = ["nmcli", "connection", "down", "Hotspot"];
        } else {
            hotspotToggleProc.command = ["nmcli", "connection", "up", "Hotspot"];
        }
        hotspotToggleProc.running = true;
    }

    Process {
        id: hotspotToggleProc
        command: ["nmcli", "connection", "up", "Hotspot"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                hotspotProc.exec(["nmcli", "-t", "-f", "ACTIVE,SSID", "connection", "show", "--active"]);
            }
        }
    }
}