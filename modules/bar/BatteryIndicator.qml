// Battery indicator widget for the status bar.
// Shows a battery icon and opens a popup with detailed info on click.
import QtQuick
import "../../config"
import "../../services"
import "battery"

Row {
    id: battery

    property bool available: Battery.available    // Battery present
    property real percentage: Battery.percentage  // Charge level (0-1)
    property bool charging: Battery.charging      // Charging state

    spacing: 4

    // Battery icon from Battery service
    Text {
        text: Battery.statusIcon()
        color: BarConfig.textColor
        font.family: BarConfig.fontFamily
        font.pixelSize: BarConfig.fontSize + 4
        verticalAlignment: Text.AlignVCenter
    }

    // Click target for the entire indicator
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (batteryPopup.isOpen) {
                batteryPopup.hide();
            } else {
                // Calculate position below the indicator
                var globalPos = mapToItem(null, width / 2, height);
                batteryPopup.show(bar, globalPos.x - batteryPopup.width / 2, globalPos.y + 4);
            }
        }
    }

    // Battery popup instance
    BatteryPopup {
        id: batteryPopup
    }
}
