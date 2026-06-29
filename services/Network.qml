pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property bool connected: false
    property bool wifi: false
    property string ssid: ""
    property string ipAddress: ""
    property int signalStrength: 0
    property string state: "disconnected"

    function statusIcon(): string {
        if (!connected) return "network-disconnected"
        if (!wifi) return "network-wired"
        if (signalStrength > 75) return "network-wireless-excellent"
        if (signalStrength > 50) return "network-wireless-good"
        if (signalStrength > 25) return "network-wireless-fair"
        return "network-wireless-weak"
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._update()
    }

    function _update(): void {
        // Read from NetworkManager via nmcli
        // Will be populated by process execution
    }
}
