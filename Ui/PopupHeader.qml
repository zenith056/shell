import QtQuick
import qs.Commons

Row {
    id: root
    spacing: 14
    width: parent.width

    property string icon: ""
    property color iconColor: Color.text
    property string title: ""
    property string subtitle: ""

    Text {
        text: root.icon
        color: root.iconColor
        font.family: Style.font.family
        font.pixelSize: Style.font.iconLarge
        anchors.verticalCenter: parent.verticalCenter
        
        Behavior on color {
            ColorAnimation { duration: Style.anim.expressiveFastEffects }
        }
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        
        Text {
            text: root.title
            color: Color.text
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
        }
        
        Text {
            text: root.subtitle
            color: Color.textMuted
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 1.2
            
            Behavior on color {
                ColorAnimation { duration: Style.anim.expressiveFastEffects }
            }
        }
    }
}
