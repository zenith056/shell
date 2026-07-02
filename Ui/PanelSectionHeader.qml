// Section header label for panel layouts.
// Shows uppercase text with letter spacing.
import QtQuick
import qs.Commons

Text {
    id: root

    property color foreground: Color.text
    property string fontFamily: Style.font.family

    color: Qt.darker(foreground, 1.4)
    font.family: fontFamily
    font.pixelSize: Style.font.caption
    font.bold: true
    font.letterSpacing: 1.2
    text: ""

    Behavior on color {
        ColorAnimation { duration: Style.anim.expressiveFastEffects; easing.type: Easing.BezierSpline; easing.bezierCurve: Style.anim.expressiveFastEffectsCurve }
    }
}
