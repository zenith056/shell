// Battery indicator widget for the status bar.
// Shows a battery icon and opens a popup with detailed info on click.
import QtQuick
import "../../Commons"
import "../../services"
import "battery"

Item {
    id: battery

    property bool available: Battery.available    // Battery present
    property real percentage: Battery.percentage  // Charge level (0-1)
    property bool charging: Battery.charging      // Charging state

    width: iconText.implicitWidth
    height: iconText.implicitHeight

    // Battery icon from Battery service
    Text {
        id: iconText
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
                batteryPopup.show(iconText);
            }
        }
    }

    // Battery popup instance
    BatteryPopup {
        id: batteryPopup
    }
}