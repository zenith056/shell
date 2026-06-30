// Battery indicator widget for the status bar.
// Shows a battery icon and opens a popup with detailed info on click.
import QtQuick
import "../../Commons"
import "../../services"
import "../../utils"
import "battery"

Item {
    id: battery

    implicitWidth: Style.font.indicator - 8
    height: BarConfig.height

    Text {
        id: iconText
        anchors.centerIn: parent
        text: Icons.batteryIcon(Battery.available, Battery.charging, Battery.percentage)
        color: Battery.percentage <= 0.2 && !Battery.charging ? Color.lowBattery : BarConfig.textColor
        font.family: Style.font.family
        font.pixelSize: Style.font.indicator
    }

    // Click target for the entire indicator
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (batteryPopup.isOpen) {
                batteryPopup.hide();
            } else {
                batteryPopup.show(bar, iconText);
            }
        }
    }

    // Battery popup instance
    BatteryPopup {
        id: batteryPopup
    }
}