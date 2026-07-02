import QtQuick
import qs.Commons
import qs.Ui

Row {
    id: root
    width: parent.width
    spacing: 8

    property string text: ""
    property bool checked: false
    signal clicked()

    Text {
        text: root.text
        color: Color.text
        font.family: Style.font.family
        font.pixelSize: Style.font.title
        font.bold: true
        anchors.verticalCenter: parent.verticalCenter
    }

    Item {
        width: parent.width - this.x - 44
        height: 1
    }

    Rectangle {
        width: 44
        height: 24
        radius: 12
        color: root.checked ? Color.success : Color.divider
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
            ColorAnimation { duration: Style.anim.expressiveFastEffects }
        }

        Rectangle {
            x: root.checked ? 22 : 2
            y: 2
            width: 20
            height: 20
            radius: 10
            color: Color.text

            Behavior on x {
                NumberAnimation {
                    duration: Style.anim.expressiveFastSpatial
                    easing.type: Easing.OutQuad
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}
