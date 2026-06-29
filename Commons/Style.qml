// Shared structural style tokens for the shell.
// Spacing, typography, and bar dimensions.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // Corner radius for rounded elements
    property int cornerRadius: 0

    // Spacing scale multiplier
    property real spacingScale: 1.0

    // Font settings
    property string fontFamily: "FiraCode Nerd Font"
    property int fontBaseSize: 14

    // Bar dimensions
    property int barHeight: 32

    // Calculate scaled spacing
    function space(px) {
        var n = Number(px)
        if (!isFinite(n) || n <= 0) return 0
        return Math.max(1, Math.round(n * spacingScale))
    }

    // Font size calculations
    function fontPx(mult) {
        return Math.max(1, Math.round(fontBaseSize * mult))
    }

    // Spacing tokens
    readonly property QtObject spacing: QtObject {
        readonly property int xs: root.space(3)
        readonly property int sm: root.space(4)
        readonly property int md: root.space(6)
        readonly property int lg: root.space(8)
        readonly property int xl: root.space(10)
        readonly property int xxl: root.space(12)
    }

    // Font size tokens
    readonly property QtObject font: QtObject {
        readonly property string family: root.fontFamily
        readonly property int caption: root.fontPx(0.833)    // 10
        readonly property int bodySmall: root.fontPx(0.917)  // 11
        readonly property int body: root.fontPx(1.0)         // 12
        readonly property int subtitle: root.fontPx(1.083)   // 13
        readonly property int title: root.fontPx(1.167)      // 14
        readonly property int heading: root.fontPx(1.333)    // 16
    }

    // Bar dimensions
    readonly property QtObject bar: QtObject {
        readonly property int height: root.barHeight
    }
}