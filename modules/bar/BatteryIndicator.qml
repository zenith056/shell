// Battery indicator widget for the status bar.
// Shows a battery icon and percentage text.
// Displays "N/A" when no battery is detected.
import QtQuick
import "../../config"
import "../../services"

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
        font.pixelSize: BarConfig.fontSize
        verticalAlignment: Text.AlignVCenter
    }

    // Percentage text — hidden when no battery
    Text {
        text: available ? Math.round(percentage * 100) + "%" : "N/A"
        color: BarConfig.textColor
        font.family: BarConfig.fontFamily
        font.pixelSize: BarConfig.fontSize
        verticalAlignment: Text.AlignVCenter
        visible: available
    }
}
