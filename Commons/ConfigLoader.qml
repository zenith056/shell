// Configuration loader singleton.
// Reads shell.json and exposes typed properties for bar, theme, and fonts.
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var raw: ({})

    // Theme config
    readonly property color themeBackground: Util.get(raw, "theme.background", "#000000")
    readonly property color themeSurface: Util.get(raw, "theme.surface", "#1a1a1a")
    readonly property color themeText: Util.get(raw, "theme.text", "#ffffff")
    readonly property color themeTextMuted: Util.get(raw, "theme.textMuted", "#999999")
    readonly property color themeDivider: Util.get(raw, "theme.divider", "#333333")
    readonly property color themeAccent: Util.get(raw, "theme.accent", "#ffffff")
    readonly property color themeSuccess: Util.get(raw, "theme.success", "#4ade80")
    readonly property color themeLowBattery: Util.get(raw, "theme.lowBattery", "#ef4444")

    // Font config
    readonly property string fontFamily: Util.get(raw, "fonts.family", "FiraCode Nerd Font")
    readonly property int fontCaption: Util.get(raw, "fonts.caption", 10)
    readonly property int fontBody: Util.get(raw, "fonts.body", 12)
    readonly property int fontTitle: Util.get(raw, "fonts.title", 14)
    readonly property int fontHeading: Util.get(raw, "fonts.heading", 16)
    readonly property int fontLarge: Util.get(raw, "fonts.large", 20)
    readonly property int fontIndicator: Util.get(raw, "fonts.indicator", 16)
    readonly property int fontIcon: Util.get(raw, "fonts.icon", 24)
    readonly property int fontIconLarge: Util.get(raw, "fonts.iconLarge", 40)

    // Plugin config
    property string _configPath: Qt.resolvedUrl("../shell.json").toString().replace("file://", "")

    FileView {
        id: fileView
        path: _configPath
        watchChanges: true
        onLoaded: root.applyConfig(text())
        onFileChanged: reload()
    }

    Component.onCompleted: fileView.reload()

    function applyConfig(jsonString) {
        try {
            var config = JSON.parse(jsonString)
            if (Util.isPlainObject(config)) {
                root.raw = config
            }
        } catch (e) {
            console.log("ConfigLoader: failed to parse shell.json:", e)
        }
    }
}
