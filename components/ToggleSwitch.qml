// Reusable toggle switch widget.
// Shows a sliding circle between two states.
import QtQuick
import QtQuick.Layouts
import "../Commons"

Rectangle {
    id: toggle

    property bool active: false
    signal toggled()

    width: 44
    height: 24
    radius: 12
    color: active ? Color.success : Color.divider

    Rectangle {
        x: toggle.active ? 22 : 2
        y: 2
        width: 20
        height: 20
        radius: 10
        color: Color.text

        Behavior on x {
            NumberAnimation { duration: 150 }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: toggle.toggled()
    }
}