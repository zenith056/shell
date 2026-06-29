// Network indicator widget for the status bar.
// Shows a connection icon and SSID name when connected.
import QtQuick
import "../../services"
import "../../Commons"

Row {
    id: network

    property bool connected: Network.connected       // Connection active
    property string ssid: Network.ssid               // WiFi network name
    property int signal: Network.signalStrength      // Signal strength (0-100)

    spacing: 4

    // Network status icon from Network service
    Text {
        text: Network.statusIcon()
        color: BarConfig.textColor
        font.family: BarConfig.fontFamily
        font.pixelSize: BarConfig.fontSize + 2
        verticalAlignment: Text.AlignVCenter
    }

    // SSID text — only visible when connected
    //Text {
    //    text: network.ssid || "Disconnected"
    //    color: BarConfig.textColor
    //    font.family: BarConfig.fontFamily
    //    font.pixelSize: BarConfig.fontSize
    //    verticalAlignment: Text.AlignVCenter
    //    visible: network.connected
    //}
}
