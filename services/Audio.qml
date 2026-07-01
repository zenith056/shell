// Audio service singleton.
// Manages volume level, mute state, and provides volume icons.
// Uses wpctl (WirePlumber) for volume control.
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real volume: 0.5
    property bool muted: false
    property string sinkName: ""

    signal volumeChangedSignal()

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: root.updateVolume()
    }

    Component.onCompleted: updateVolume()

    function updateVolume() {
        volumeProc.running = true;
    }

    property Process volumeProc: Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var output = text.trim();
                var match = output.match(/Volume:\s+([\d.]+)/);
                if (match) {
                    var newVol = parseFloat(match[1]);
                    if (!isNaN(newVol) && newVol >= 0 && newVol <= 1 && Math.abs(newVol - root.volume) > 0.001) {
                        root.volume = newVol;
                        root.volumeChangedSignal();
                    }
                }
                var newMuted = output.includes("[MUTED]");
                if (newMuted !== root.muted) {
                    root.muted = newMuted;
                    root.volumeChangedSignal();
                }
            }
        }
    }

    function setVolume(v: real): void {
        var clamped = Math.max(0, Math.min(1, v));
        root.volume = clamped;
        setVolumeProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", clamped.toString()];
        setVolumeProc.running = true;
    }

    property Process setVolumeProc: Process {
        id: setVolumeProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0.5"]
    }

    function toggleMute(): void {
        root.muted = !root.muted;
        toggleMuteProc.running = true;
    }

    property Process toggleMuteProc: Process {
        id: toggleMuteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
    }
}