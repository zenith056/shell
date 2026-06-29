// Network service singleton.
// Polls network status and provides connection info and signal icons.
// TODO: Integrate with NetworkManager via nmcli process execution.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property bool connected: false         // Whether any network connection is active
    property bool wifi: false              // Whether connected via WiFi
    property string ssid: ""               // Current WiFi SSID
    property string ipAddress: ""          // Current IP address
    property int signalStrength: 0         // Signal strength percentage (0-100)
    property string state: "disconnected"  // Connection state string

    // Returns an icon name based on connection type and signal strength
    function statusIcon(): string {
        if (!connected) return "network-disconnected"            // No connection
        if (!wifi) return "network-wired"                        // Wired connection
        if (signalStrength > 75) return "network-wireless-excellent"  // Strong signal
        if (signalStrength > 50) return "network-wireless-good"       // Good signal
        if (signalStrength > 25) return "network-wireless-fair"       // Fair signal
        return "network-wireless-weak"                                 // Weak signal
    }

    // Polls every 10 seconds for network status changes
    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._update()
    }

    // Internal: read network state from NetworkManager via nmcli
    // FIXME: Not yet implemented — needs process execution
    function _update(): void {
        // Read from NetworkManager via nmcli
        // Will be populated by process execution
    }
}
