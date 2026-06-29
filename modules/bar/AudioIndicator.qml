// Audio indicator widget for the status bar.
// Shows a volume icon based on current level and mute state.
import QtQuick
import "../../Commons"
import "../../services"

Row {
    id: audio

    property real volume: Audio.volume
    property bool muted: Audio.muted

    spacing: 4

    // Volume icon using Nerd Font glyphs
    Text {
        text: audio.muted || audio.volume === 0 ? "\uf00d"     // nf-fa-volume_off
            : audio.volume < 0.33 ? "\uf026"                    // nf-fa-volume_down
            : audio.volume < 0.66 ? "\uf027"                    // nf-fa-volume_low
            : "\uf028"                                          // nf-fa-volume_high
        color: BarConfig.textColor
        font.family: BarConfig.fontFamily
        font.pixelSize: BarConfig.fontSize
        verticalAlignment: Text.AlignVCenter
    }
}