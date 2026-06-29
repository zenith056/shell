import QtQuick
import "../../services" as Services
import "../../config" as Config

Row {
    id: network

    property bool connected: Services.Network.connected
    property string ssid: Services.Network.ssid
    property int signal: Services.Network.signalStrength

    spacing: 4

    Text {
        text: Services.Network.statusIcon()
        color: Config.BarConfig.textColor
        font.pixelSize: 14
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        text: network.ssid || "Disconnected"
        color: Config.BarConfig.textColor
        font.pixelSize: 12
        font.family: "monospace"
        verticalAlignment: Text.AlignVCenter
        visible: network.connected
    }
}
