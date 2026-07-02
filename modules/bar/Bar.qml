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
import "../launcher"

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
            onClicked: {
                LauncherState.hide();
                PopupControl.close();
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8

        LauncherButton {
            barWindow: bar
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Clock {
            anchors.centerIn: parent
        }

        WorkspaceIndicator {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Style.font.indicator + 2 + 8
        }

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16

            SystemTrayIndicator { Layout.alignment: Qt.AlignVCenter }
            AudioIndicator { Layout.alignment: Qt.AlignVCenter }
            BluetoothIndicator { Layout.alignment: Qt.AlignVCenter }
            NetworkIndicator { Layout.alignment: Qt.AlignVCenter }
            BatteryIndicator { Layout.alignment: Qt.AlignVCenter }
        }
    }
}
