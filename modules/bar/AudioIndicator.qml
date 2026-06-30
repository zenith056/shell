// Audio indicator widget for the status bar.
// Shows a volume icon and OSD popup on volume change.
import QtQuick
import "../../Commons"
import "../../services"
import "../../utils"
import "audio"

Item {
    id: audio

    width: iconText.implicitWidth
    height: iconText.implicitHeight

    // Volume icon using centralized Icons
    Text {
        id: iconText
        text: Icons.volumeIcon(Audio.muted, Audio.volume)
        color: BarConfig.textColor
        font.family: Style.font.family
        font.pixelSize: Style.font.title
        verticalAlignment: Text.AlignVCenter
    }

    // Show OSD when volume changes
    Connections {
        target: Audio
        function onVolumeChangedSignal() {
            audioOsd.showOsd(bar);
        }
    }

    // Audio OSD instance
    AudioPopup {
        id: audioOsd
    }
}