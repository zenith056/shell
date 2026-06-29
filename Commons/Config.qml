// Runtime configuration loader.
// Loads shell.json and applies settings to singletons.
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Load settings from shell.json on startup
    Component.onCompleted: {
        loader.reload()
    }

    // File loader for shell.json
    property FileView loader: FileView {
        path: Qt.resolvedUrl("../../shell.json")
        watchChanges: true
        onLoaded: root.applySettings(text())
    }

    // Apply settings from JSON to singletons
    function applySettings(jsonString) {
        try {
            var config = JSON.parse(jsonString)

            // Apply bar settings
            if (config.bar) {
                if (config.bar.height !== undefined)
                    BarConfig.height = config.bar.height
                if (config.bar.position !== undefined)
                    BarConfig.position = config.bar.position
                if (config.bar.modules !== undefined)
                    BarConfig.modules = config.bar.modules
            }

            // Apply appearance settings
            if (config.appearance) {
                if (config.appearance.font !== undefined)
                    BarConfig.fontFamily = config.appearance.font
                if (config.appearance.fontSize !== undefined)
                    BarConfig.fontSize = config.appearance.fontSize
            }
        } catch (e) {
            console.log("Failed to parse shell.json:", e)
        }
    }
}