// Audio indicator widget for the status bar.
// Shows a volume icon; triggers OSD on volume change.
import QtQuick
import "../../Commons"
import "../../services"
import "../../utils"


Item {
    id: audioIndicator

    implicitWidth: Style.font.indicator + 2
    height: BarConfig.height

    Text {
        anchors.centerIn: parent
        text: Icons.volumeIcon(Audio.muted, Audio.volume)
        color: BarConfig.textColor
        font.family: Style.font.family
        font.pixelSize: Style.font.title
    }



}
