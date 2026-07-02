// OSD control service.
// Mediates visibility and timers for volume and brightness OSD popups.
pragma Singleton
import Quickshell
import QtQuick
import "."

Singleton {
    id: root

    property bool audioShowing: false
    property bool brightnessShowing: false
    
    // Ignore initial startup state changes to avoid OSD popups on shell load
    property bool isReady: false

    Timer {
        id: startupTimer
        interval: 1000
        running: true
        onTriggered: root.isReady = true
    }

    function triggerAudio(): void {
        if (!isReady) return;
        audioShowing = true;
        audioTimer.restart();
    }

    function triggerBrightness(): void {
        if (!isReady) return;
        brightnessShowing = true;
        brightnessTimer.restart();
    }

    Timer {
        id: audioTimer
        interval: 2000
        onTriggered: root.audioShowing = false
    }

    Timer {
        id: brightnessTimer
        interval: 2000
        onTriggered: root.brightnessShowing = false
    }

    // Trigger OSD on audio volume or mute changes
    Connections {
        target: Audio
        ignoreUnknownSignals: true
        function onVolumeChanged() { root.triggerAudio() }
        function onMutedChanged() { root.triggerAudio() }
    }

    // Trigger OSD on brightness level changes
    Connections {
        target: Brightness
        ignoreUnknownSignals: true
        function onLevelChanged() { root.triggerBrightness() }
    }
}
