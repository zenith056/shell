// Shared structural style tokens for the shell.
// Spacing, typography, and bar dimensions from shell.json via ConfigLoader.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // General
    readonly property int cornerRadius: 6

    // Spacing tokens
    readonly property QtObject spacing: QtObject {
        readonly property int xs: 3
        readonly property int sm: 4
        readonly property int md: 6
        readonly property int lg: 8
        readonly property int xl: 10
        readonly property int xxl: 12
    }

    // Animation tokens — durations and easing curves from shell.json
    readonly property QtObject anim: QtObject {
        readonly property real scale: Util.get(ConfigLoader.raw, "anim.durations.scale", 1.0)

        // Standard durations
        readonly property int small: Math.round(200 * scale)
        readonly property int normal: Math.round(400 * scale)
        readonly property int large: Math.round(600 * scale)
        readonly property int extraLarge: Math.round(1000 * scale)

        // Expressive spatial durations (movement)
        readonly property int expressiveFastSpatial: Math.round(150 * scale)
        readonly property int expressiveDefaultSpatial: Math.round(300 * scale)
        readonly property int expressiveSlowSpatial: Math.round(500 * scale)

        // Expressive effects durations (color, opacity)
        readonly property int expressiveFastEffects: Math.round(100 * scale)
        readonly property int expressiveDefaultEffects: Math.round(200 * scale)
        readonly property int expressiveSlowEffects: Math.round(300 * scale)

        // Expressive easing curves
        readonly property var expressiveFastSpatialCurve: Util.get(ConfigLoader.raw, "anim.curves.expressiveFastSpatial", [0.34, 1.56, 0.64, 1])
        readonly property var expressiveDefaultSpatialCurve: Util.get(ConfigLoader.raw, "anim.curves.expressiveDefaultSpatial", [0.34, 1.56, 0.64, 1])
        readonly property var expressiveSlowSpatialCurve: Util.get(ConfigLoader.raw, "anim.curves.expressiveSlowSpatial", [0.34, 1.56, 0.64, 1])
        readonly property var expressiveFastEffectsCurve: Util.get(ConfigLoader.raw, "anim.curves.expressiveFastEffects", [0.22, 1, 0.36, 1])
        readonly property var expressiveDefaultEffectsCurve: Util.get(ConfigLoader.raw, "anim.curves.expressiveDefaultEffects", [0.22, 1, 0.36, 1])
        readonly property var expressiveSlowEffectsCurve: Util.get(ConfigLoader.raw, "anim.curves.expressiveSlowEffects", [0.22, 1, 0.36, 1])

        // Standard and emphasized curves
        readonly property var standardCurve: Util.get(ConfigLoader.raw, "anim.curves.standard", [0.2, 0, 0, 1])
        readonly property var emphasizedCurve: Util.get(ConfigLoader.raw, "anim.curves.emphasized", [0.34, 1.56, 0.64, 1])
    }

    // Font tokens — read from ConfigLoader
    readonly property QtObject font: QtObject {
        readonly property string family: ConfigLoader.fontFamily
        readonly property int caption: ConfigLoader.fontCaption
        readonly property int bodySmall: 11
        readonly property int body: ConfigLoader.fontBody
        readonly property int subtitle: 13
        readonly property int title: ConfigLoader.fontTitle
        readonly property int indicator: ConfigLoader.fontIndicator
        readonly property int heading: ConfigLoader.fontHeading
        readonly property int large: ConfigLoader.fontLarge
        readonly property int icon: ConfigLoader.fontIcon
        readonly property int iconLarge: ConfigLoader.fontIconLarge
    }
}
