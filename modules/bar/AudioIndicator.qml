// Audio indicator widget for the status bar.
// Shows a volume icon and opens popup on click.
import QtQuick
import "../../Commons"
import "../../services"
import "audio"

Item {
    id: audio

    width: iconText.implicitWidth
    height: iconText.implicitHeight

    // Volume icon using Nerd Font glyphs
    Text {
        id: iconText
        text: Audio.muted || Audio.volume === 0 ? "\uf00d"     // nf-fa-volume_off
            : Audio.volume < 0.33 ? "\uf026"                    // nf-fa-volume_down
            : Audio.volume < 0.66 ? "\uf027"                    // nf-fa-volume_low
            : "\uf028"                                          // nf-fa-volume_high
        color: BarConfig.textColor
        font.family: BarConfig.fontFamily
        font.pixelSize: BarConfig.fontSize
        verticalAlignment: Text.AlignVCenter
    }

    // Click to open popup
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (audioPopup.isOpen) {
                audioPopup.hide();
            } else {
                audioPopup.show(bar);
            }
        }
    }

    // Audio popup instance
    AudioPopup {
        id: audioPopup
    }
}