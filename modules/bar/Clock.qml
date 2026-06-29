// Clock widget for the status bar.
// Displays current time and shows date tooltip on hover.
import QtQuick
import QtQuick.Controls
import "../../services"
import "../../config"

Text {
    id: clock

    property string time: Time.time   // Bind to Time service
    property string date: Time.date   // For tooltip display

    text: time
    color: BarConfig.textColor
    font.family: BarConfig.fontFamily
    font.pixelSize: BarConfig.fontSize
    verticalAlignment: Text.AlignVCenter

    // Tooltip shows formatted date on hover
    ToolTip.text: date
    ToolTip.visible: mouse.containsMouse

    // Invisible hover target covering the full text area
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
    }
}
