pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property real volume: 0.5
    property bool muted: false
    property string sinkName: ""

    function setVolume(v: real): void {
        root.volume = Math.max(0, Math.min(1, v))
    }

    function toggleMute(): void {
        root.muted = !root.muted
    }

    function volumeIcon(): string {
        if (muted || volume === 0) return "audio-volume-muted"
        if (volume < 0.33) return "audio-volume-low"
        if (volume < 0.66) return "audio-volume-medium"
        return "audio-volume-high"
    }
}
