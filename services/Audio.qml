// Audio service singleton.
// Manages volume level and mute state.
// Uses Quickshell.Services.Pipewire for native, reactive audio control.
pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    // Reference to the default audio playback sink
    readonly property PwNode sink: Pipewire.defaultAudioSink

    // Reactive volume property (0.0 to 1.0)
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0.0

    // Reactive mute state property
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false

    // Device description or name
    readonly property string sinkName: sink ? (sink.description || sink.name || "") : ""

    // Track the default sink object to ensure its properties remain active
    PwObjectTracker {
        id: sinkTracker
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire
        ignoreUnknownSignals: true
        function onDefaultAudioSinkChanged() {
            sinkTracker.objects = [Pipewire.defaultAudioSink]
        }
    }

    // Set the default playback sink volume safely
    function setVolume(v: real): void {
        var clamped = Math.max(0, Math.min(1, v));
        if (sink && sink.audio) {
            sink.audio.volume = clamped;
        }
    }

    // Toggle the mute state of the default playback sink safely
    function toggleMute(): void {
        if (sink && sink.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }
}