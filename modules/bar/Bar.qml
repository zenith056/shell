import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../config" as Config
import "../../services" as Services
import "."

PanelWindow {
    id: bar

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Config.BarConfig.height
    color: Config.BarConfig.backgroundColor

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-bar"

    Row {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8

        spacing: 4

        Clock { }
        Item { Layout.fillWidth: true }
        BatteryIndicator { }
        NetworkIndicator { }
    }
}
