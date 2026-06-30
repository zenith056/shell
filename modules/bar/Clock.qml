// Clock widget for the status bar.
// Shows time by default, toggles to date on click.
import QtQuick
import "../../services"
import "../../Commons"

Text {
    id: clock

    property string time: Time.time
    property bool showDate: false

    text: showDate ? Time.expandedDate() : time
    color: BarConfig.textColor
    font.family: Style.font.family
    font.pixelSize: Style.font.title
    verticalAlignment: Text.AlignVCenter

    MouseArea {
        anchors.fill: parent
        onClicked: clock.showDate = !clock.showDate
    }
}