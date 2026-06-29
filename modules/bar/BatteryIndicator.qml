import QtQuick
import "../../services" as Services
import "../../config" as Config

Row {
    id: battery

    property bool available: Services.Battery.available
    property real percentage: Services.Battery.percentage
    property bool charging: Services.Battery.charging

    spacing: 4

    Text {
        text: Services.Battery.statusIcon()
        color: Config.BarConfig.textColor
        font.pixelSize: 14
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        text: available ? Math.round(percentage) + "%" : "N/A"
        color: Config.BarConfig.textColor
        font.pixelSize: 12
        font.family: "monospace"
        verticalAlignment: Text.AlignVCenter
        visible: available
    }
}
