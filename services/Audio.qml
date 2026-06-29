// Audio service singleton.
// Manages volume level, mute state, and provides volume icons.
// TODO: Integrate with PipeWire for real volume control.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property real volume: 0.5        // Current volume level (0.0 - 1.0)
    property bool muted: false       // Whether audio is muted
    property string sinkName: ""     // Name of the active audio sink

    // Clamp volume to valid range [0, 1]
    function setVolume(v: real): void {
        root.volume = Math.max(0, Math.min(1, v))
    }

    // Toggle mute state on/off
    function toggleMute(): void {
        root.muted = !root.muted
    }

    // Returns an icon name based on current volume level
    function volumeIcon(): string {
        if (muted || volume === 0) return "audio-volume-muted"    // Muted or zero
        if (volume < 0.33) return "audio-volume-low"              // Low volume
        if (volume < 0.66) return "audio-volume-medium"           // Medium volume
        return "audio-volume-high"                                 // High volume
    }
}
