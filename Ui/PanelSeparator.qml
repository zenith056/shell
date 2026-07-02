// Simple 1px horizontal divider for panel layouts.
import QtQuick
import qs.Commons

Rectangle {
    property color foreground: Color.text
    width: parent.width
    height: 1
    color: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.15)

    Behavior on color {
        ColorAnimation { duration: Style.anim.expressiveFastEffects; easing.type: Easing.BezierSpline; easing.bezierCurve: Style.anim.expressiveFastEffectsCurve }
    }
}
