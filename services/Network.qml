// Network service singleton.
// Uses Quickshell.Networking native API for reactive state.
pragma Singleton
import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    id: root

    property var wifiDevice: null
    readonly property bool connected: wifiDevice ? wifiDevice.connected : false
    readonly property bool wifi: wifiDevice !== null
    property bool wifiEnabled: Networking.wifiEnabled
    property string ssid: ""
    property int signalStrength: 0
    property var availableNetworks: []

    function findWifiDevice() {
        var devs = Networking.devices.values;
        if (!devs) return null;
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].type === DeviceType.Wifi) return devs[i];
        }
        return null;
    }

    function updateConnectedState() {
        if (!wifiDevice) { ssid = ""; signalStrength = 0; return; }
        var nets = wifiDevice.networks.values;
        if (!nets) return;
        for (var i = 0; i < nets.length; i++) {
            if (nets[i].connected) {
                ssid = nets[i].name;
                signalStrength = Math.round((nets[i].signalStrength || 0) * 100);
                return;
            }
        }
        ssid = ""; signalStrength = 0;
    }

    function updateAvailableNetworks() {
        if (!wifiDevice) { availableNetworks = []; return; }
        var nets = wifiDevice.networks.values;
        if (!nets) return;
        var networks = [];
        for (var i = 0; i < nets.length; i++) {
            var n = nets[i];
            networks.push({
                ssid: n.name,
                signal: Math.round((n.signalStrength || 0) * 100),
                security: WifiSecurityType.toString(n.security),
                connected: n.connected,
                known: n.known,
                networkObj: n
            });
        }
        networks.sort(function(a, b) { return b.signal - a.signal; });
        availableNetworks = networks;
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!root.wifiDevice) root.wifiDevice = root.findWifiDevice();
            root.wifiEnabled = Networking.wifiEnabled;
            root.updateConnectedState();
        }
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
        wifiEnabled = Networking.wifiEnabled;
    }

    function scanNetworks() {
        if (!wifiDevice) return;
        wifiDevice.scannerEnabled = true;
        scanRefreshTimer.restart();
    }

    Timer {
        id: scanRefreshTimer
        interval: 4000
        onTriggered: root.updateAvailableNetworks()
    }

    Timer {
        interval: 2000
        running: wifiDevice ? wifiDevice.scannerEnabled : false
        repeat: true
        onTriggered: root.updateAvailableNetworks()
    }

    function connect(ssid: string, password: string) {
        for (var i = 0; i < availableNetworks.length; i++) {
            if (availableNetworks[i].ssid === ssid) {
                var net = availableNetworks[i].networkObj;
                if (password.length > 0 && net instanceof WifiNetwork)
                    net.connectWithPsk(password);
                else
                    net.connect();
                return;
            }
        }
    }

    function disconnect() {
        if (wifiDevice) wifiDevice.disconnect();
    }
}
