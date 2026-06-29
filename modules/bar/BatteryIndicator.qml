import QtQuick
import "../../config"
import "../../services"

Row {
    id: battery

    property bool available: Battery.available
    property real percentage: Battery.percentage
    property bool charging: Battery.charging

    spacing: 4

    Text {
        text: Battery.statusIcon()
        color: BarConfig.textColor
        font.pixelSize: 14
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        text: available ? Math.round(percentage * 100) + "%" : "N/A"
        color: BarConfig.textColor
        font.pixelSize: 12
        font.family: "monospace"
        verticalAlignment: Text.AlignVCenter
        visible: available
    }
}
