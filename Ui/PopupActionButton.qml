import QtQuick
import qs.Commons
import qs.Ui

Rectangle {
    id: root
    width: parent.width
    height: 32
    radius: 6
    color: mouseArea.containsMouse ? Color.divider : "transparent"

    property string icon: ""
    property string text: ""
    signal clicked()

    Behavior on color {
        ColorAnimation { duration: Style.anim.expressiveFastEffects }
    }

    Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            color: Color.text
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.text
            color: Color.text
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
