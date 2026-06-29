// Clock widget for the status bar.
// Shows time by default, toggles to date on click.
import QtQuick
import "../../services"
import "../../Commons"

Text {
    id: clock

    property string time: Time.time
    property string date: Time.date
    property bool showDate: false

    text: showDate ? Time.expandedDate() : time
    color: BarConfig.textColor
    font.family: BarConfig.fontFamily
    font.pixelSize: BarConfig.fontSize
    verticalAlignment: Text.AlignVCenter

    MouseArea {
        anchors.fill: parent
        onClicked: clock.showDate = !clock.showDate
    }
}
