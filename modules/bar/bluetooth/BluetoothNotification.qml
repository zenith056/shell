// Bluetooth connection notification popup.
// Shows a sleek green notification pill when a device connects, displaying name and battery level.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../Commons"
import "../../../services"
import "../../../utils"
import "../../../Ui"

Item {
    id: notificationRoot

    // Reference to the main bar window to obtain correct screen dimensions
    property PanelWindow barWindow: null
    property bool showing: false
    property bool isReady: false
    property string lastConnectedAddress: ""

    // Startup guard timer to prevent notifications on initial load
    Timer {
        id: startupTimer
        interval: 2000
        running: true
        onTriggered: notificationRoot.isReady = true
    }

    Timer {
        id: notificationTimer
        interval: 4000
        onTriggered: notificationRoot.showing = false
    }

    Connections {
        target: Bluetooth
        ignoreUnknownSignals: true
        function onConnectedDeviceChanged() {
            if (!notificationRoot.isReady) return
            var dev = Bluetooth.connectedDevice
            var addr = dev ? dev.address : ""
            if (addr !== notificationRoot.lastConnectedAddress) {
                notificationRoot.lastConnectedAddress = addr
                if (dev) {
                    notificationTimer.restart()
                    notificationRoot.showing = true
                } else {
                    notificationRoot.showing = false
                }
            }
        }
    }

    onShowingChanged: {
        if (showing) {
            if (barWindow) {
                btPopup.anchor.window = barWindow
                // Position popup centered at the bottom of the screen (20px margin)
                btPopup.anchor.rect = Qt.rect(
                    barWindow.width / 2 - btPopup.implicitWidth / 2,
                    (barWindow.screen ? barWindow.screen.height : 1080) - btPopup.implicitHeight - 20,
                    btPopup.implicitWidth,
                    btPopup.implicitHeight
                )
            }
            btPopup.visible = true
            enterAnim.start()
        } else {
            exitAnim.start()
        }
    }

    // Symmetrical scale, opacity, and slide-up/down animations from the bottom edge
    SequentialAnimation {
        id: enterAnim
        ParallelAnimation {
            Anim { target: card; property: "opacity"; from: 0; to: 1; type: Anim.DefaultSpatial }
            Anim { target: cardTranslate; property: "y"; from: 30; to: 0; type: Anim.DefaultSpatial }
            Anim { target: card; property: "scale"; from: 0.8; to: 1; type: Anim.DefaultSpatial }
        }
    }

    SequentialAnimation {
        id: exitAnim
        ParallelAnimation {
            Anim { target: card; property: "opacity"; from: 1; to: 0; type: Anim.DefaultSpatial }
            Anim { target: cardTranslate; property: "y"; from: 0; to: 30; type: Anim.DefaultSpatial }
            Anim { target: card; property: "scale"; from: 1; to: 0.8; type: Anim.DefaultSpatial }
        }
        ScriptAction { script: btPopup.visible = false }
    }

    PopupWindow {
        id: btPopup
        visible: false
        color: "transparent"
        implicitWidth: 300
        implicitHeight: 38
        grabFocus: false

        Rectangle {
            id: card
            anchors.fill: parent
            color: Color.background
            radius: 12
            opacity: 0
            scale: 0.8
            clip: true

            transform: Translate {
                id: cardTranslate
                y: 30
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Style.spacing.lg
                anchors.rightMargin: Style.spacing.lg
                spacing: Style.spacing.md

                Text {
                    text: Icons.bluetooth
                    color: Color.success
                    font.family: Style.font.family
                    font.pixelSize: Style.font.title
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: Bluetooth.connectedDevice ? Bluetooth.connectedDevice.name : ""
                    color: Color.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: {
                        if (!Bluetooth.connectedDevice) return ""
                        var bat = Bluetooth.connectedDevice.battery
                        return bat >= 0 ? (bat + "%") : "Connected"
                    }
                    color: Color.success
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
