// Power profile service singleton.
// Manages power profiles via power-profiles-daemon D-Bus API.
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string activeProfile: "balanced"
    property var profiles: ["power-saver", "balanced", "performance"]

    Component.onCompleted: updateProfile()

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.updateProfile()
    }

    function updateProfile() {
        getProfileProc.running = true;
    }

    property Process getProfileProc: Process {
        id: getProfileProc
        command: ["busctl", "get-property", "org.freedesktop.UPower.PowerProfiles",
                   "/org/freedesktop/UPower/PowerProfiles",
                   "org.freedesktop.UPower.PowerProfiles", "ActiveProfile"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var match = text.match(/s\s+"([^"]+)"/);
                if (match) {
                    root.activeProfile = match[1];
                }
            }
        }
    }

    function setProfile(profile: string): void {
        root.activeProfile = profile;
        setProfileProc.command = ["busctl", "set-property", "org.freedesktop.UPower.PowerProfiles",
                                   "/org/freedesktop/UPower/PowerProfiles",
                                   "org.freedesktop.UPower.PowerProfiles", "ActiveProfile", "s", profile];
        setProfileProc.running = true;
    }

    property Process setProfileProc: Process {
        id: setProfileProc
    }
}