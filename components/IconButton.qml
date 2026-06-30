// Reusable circular icon button.
// Shows a single Nerd Font glyph in a round hover-capable button.
import QtQuick
import QtQuick.Layouts
import "../Commons"

Rectangle {
    id: btn

    property string icon: ""
    signal clicked()

    width: 28
    height: 28
    radius: 14
    color: area.containsMouse ? Color.divider : "transparent"

    Text {
        anchors.centerIn: parent
        text: btn.icon
        color: Color.text
        font.family: Style.font.family
        font.pixelSize: Style.font.body
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}