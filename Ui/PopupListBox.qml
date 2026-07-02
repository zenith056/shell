import QtQuick
import qs.Commons

Rectangle {
    id: root
    color: Color.surface
    radius: 6
    clip: true
    border.width: 1
    border.color: Color.divider

    Behavior on border.color {
        ColorAnimation { duration: Style.anim.expressiveFastEffects }
    }
}
