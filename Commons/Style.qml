// Shared structural style tokens for the shell.
// Spacing, typography, and bar dimensions.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // Font settings
    property string fontFamily: "FiraCode Nerd Font"
    property int fontBaseSize: 14

    // General
    readonly property int cornerRadius: 6
    readonly property QtObject spacing: QtObject {
        readonly property int xs: 3
        readonly property int sm: 4
        readonly property int md: 6
        readonly property int lg: 8
        readonly property int xl: 10
        readonly property int xxl: 12
    }

    // Font size tokens
    readonly property QtObject font: QtObject {
        readonly property string family: root.fontFamily
        readonly property int caption: 10
        readonly property int bodySmall: 11
        readonly property int body: 12
        readonly property int subtitle: 13
        readonly property int title: 14
        readonly property int indicator: 16
        readonly property int heading: 16
        readonly property int large: 20
        readonly property int icon: 24
        readonly property int iconLarge: 40
    }
}