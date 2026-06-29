// JSON configuration loader singleton.
// Reads shell.json at startup and hot-reloads on file changes.
import Quickshell
import Quickshell.Io
import QtQuick

FileView {
    id: config

    // Absolute path to shell.json relative to this file
    readonly property string path: Qt.resolvedUrl("../../shell.json").toString().replace("file://", "")

    property var bar: ({})         // Parsed bar config section
    property var appearance: ({})  // Parsed appearance config section

    watchChanges: true   // Auto-reload when shell.json is modified

    // Parse JSON on load and expose as typed properties
    onLoaded: {
        const data = JSON.parse(text())
        config.bar = data.bar || {}
        config.appearance = data.appearance || {}
    }

    Component.onCompleted: reload()  // Trigger initial load
}
