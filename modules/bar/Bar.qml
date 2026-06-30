// Main status bar component.
// A Wayland PanelWindow anchored to the top of the screen.
// Arranges clock on the left, indicators on the right.
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../Commons"
import "../../services"
import "../../utils"

PanelWindow {
    id: bar

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: BarConfig.height
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-bar"

    Rectangle {
        anchors.fill: parent
        color: BarConfig.backgroundColor

        MouseArea {
            anchors.fill: parent
            onClicked: PopupManager.closeAll()
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8

        Clock {
            anchors.centerIn: parent
        }

        WorkspaceIndicator {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16

            AudioIndicator { Layout.alignment: Qt.AlignVCenter }
            BluetoothIndicator { Layout.alignment: Qt.AlignVCenter }
            NetworkIndicator { Layout.alignment: Qt.AlignVCenter }
            BatteryIndicator { Layout.alignment: Qt.AlignVCenter }
        }
    }
}
