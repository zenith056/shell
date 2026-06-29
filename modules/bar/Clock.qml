import QtQuick
import "../../services" as Services
import "../../config" as Config

Text {
    id: clock

    property string time: Services.Time.time
    property string date: Services.Time.date

    text: time
    color: Config.BarConfig.textColor
    font.pixelSize: 14
    font.family: "monospace"
    verticalAlignment: Text.AlignVCenter

    ToolTip.text: date
    ToolTip.visible: mouse.containsMouse

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
    }
}
