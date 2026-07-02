// Audio indicator widget for the status bar.
// Shows a volume icon; triggers OSD on volume change.
import QtQuick
import "../../Commons"
import "../../services"
import "../../utils"
import "../../Ui"

Item {
    id: audioIndicator

    implicitWidth: Style.font.indicator + 2
    height: BarConfig.height

    Component.onCompleted: PopupControl.audioIndicator = audioIndicator

    Text {
        anchors.centerIn: parent
        text: Icons.volumeIcon(Audio.muted, Audio.volume)
        color: BarConfig.textColor
        font.family: Style.font.family
        font.pixelSize: Style.font.title
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PopupControl.toggle("audio", audioIndicator)
        onEntered: {
            PopupControl.indicatorHovered = true
            PopupControl.open("audio", audioIndicator)
        }
        onExited: {
            PopupControl.indicatorHovered = false
            PopupControl.checkClose()
        }
    }
}
