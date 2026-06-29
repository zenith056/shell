// Main status bar component.
// A Wayland PanelWindow anchored to the top of the screen.
// Arranges clock on the left, indicators on the right.
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../Commons"
import "../../services"
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import "."

PanelWindow {
    id: bar

    // Anchor bar to top edge, spanning full width
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: BarConfig.height   // Height from config
    color: "transparent"               // Transparent window, background drawn by Rectangle

    // Wayland layer shell: render above all other surfaces
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-bar"

    // Semi-transparent background rectangle
    Rectangle {
        anchors.fill: parent
        color: BarConfig.backgroundColor
        opacity: 1.0
    }

    // Content container with horizontal padding
    Item {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8

        // Clock widget — centered in the bar
        Clock {
            anchors.centerIn: parent
        }

        // Workspaces — left side
        Workspaces {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        // Right-side indicators — audio, network, battery
        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16

            AudioIndicator { Layout.alignment: Qt.AlignVCenter }
            NetworkIndicator { Layout.alignment: Qt.AlignVCenter }
            BatteryIndicator { Layout.alignment: Qt.AlignVCenter }
        }
    }
}
