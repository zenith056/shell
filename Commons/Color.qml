// Global color palette singleton.
// Colors loaded from shell.json via ConfigLoader.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // Core palette — read from ConfigLoader theme
    readonly property color background: ConfigLoader.themeBackground
    readonly property color surface: ConfigLoader.themeSurface
    readonly property color text: ConfigLoader.themeText
    readonly property color textMuted: ConfigLoader.themeTextMuted
    readonly property color divider: ConfigLoader.themeDivider
    readonly property color hover: "#2a2a2a"

    // Workspace indicators
    readonly property color activeWorkspace: "#ffffff"
    readonly property color inactiveWorkspace: "#666666"

    // Status colors
    readonly property color success: ConfigLoader.themeSuccess
    readonly property color lowBattery: ConfigLoader.themeLowBattery
    readonly property color accent: ConfigLoader.themeAccent
}
