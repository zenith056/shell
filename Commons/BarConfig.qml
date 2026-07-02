// Bar appearance configuration singleton.
// Controls height, position, fonts, and which modules are displayed.
// Reads from ConfigLoader (shell.json) when available.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property int height: ConfigLoader.raw !== undefined && ConfigLoader.raw.bar ? ConfigLoader.raw.bar.height : 32
    property string position: ConfigLoader.raw !== undefined && ConfigLoader.raw.bar ? ConfigLoader.raw.bar.position : "top"
    property color backgroundColor: ConfigLoader.themeBackground
    property color textColor: ConfigLoader.themeText
}
