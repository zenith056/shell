// Audio OSD component.
// Shows icon, volume slider, and percentage in one row.
// Completely independent — does not interact with PopupManager.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Commons"
import "../../../services"
import "../../../utils"
import "../../../components"

BasePopup {
    id: audioOsd

    implicitWidth: 300
    implicitHeight: 30

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: audioOsd.hide()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Style.spacing.lg
        spacing: Style.spacing.lg

        Keys.onEscapePressed: audioOsd.hide()

        Text {
            text: Icons.volumeIcon(Audio.muted, Audio.volume)
            color: Color.text
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 4
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

    // Center horizontally above the bar — uses anchor for Wayland, independent from other popups
    function showOsd(anchorWindow) {
        hideTimer.restart();
        anchor.window = anchorWindow;
        anchor.rect = Qt.rect(
            anchorWindow.width / 2 - implicitWidth / 2,
            -implicitHeight,
            implicitWidth,
            implicitHeight
        );
        if (!isOpen) {
            isOpen = true;
            visible = true;
        }
    }
}
