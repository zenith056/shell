// Volume OSD as a PopupWindow anchored to an invisible helper PanelWindow.
// Completely separate anchor system from the bar — no conflicts.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../Commons"
import "../../../services"
import "../../../utils"

Item {
    id: osdRoot

    // Invisible helper PanelWindow — provides anchor reference for the OSD
    PanelWindow {
        id: helper
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 0
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell-osd-helper"
    }

    // Actual OSD — PopupWindow anchored to the helper
    PopupWindow {
        id: osdPopup
        visible: false
        color: Color.background
        implicitWidth: 350
        implicitHeight: 35
        grabFocus: false

        Timer {
            id: hideTimer
            interval: 2000
            onTriggered: osdPopup.visible = false
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Style.spacing.lg
            spacing: Style.spacing.lg

            Text {
                text: Icons.volumeIcon(Audio.muted, Audio.volume)
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.title
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 3
                Layout.alignment: Qt.AlignVCenter
                color: Color.divider

                Rectangle {
                    width: parent.width * Audio.volume
                    height: parent.height
                    color: Audio.muted ? Color.divider : Color.text
                }
            }

            Text {
                text: Audio.muted ? "Mute" : Math.round(Audio.volume * 100) + "%"
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 36
            }
        }
    }

    function showOsd() {
        osdPopup.anchor.window = helper;
        osdPopup.anchor.rect = Qt.rect(
            helper.width / 2 - osdPopup.implicitWidth / 2,
            helper.height - 1,
            osdPopup.implicitWidth,
            osdPopup.implicitHeight
        );
        osdPopup.visible = true;
        hideTimer.restart();
    }
}
