// Battery info display component.
// Shows large icon, percentage, and charging status.
import QtQuick
import QtQuick.Layouts
import "../../../Commons"
import "../../../services"

ColumnLayout {
    id: batteryInfo

    property real percentage: Battery.percentage
    property bool charging: Battery.charging

    spacing: 4

    // Large battery icon
    Text {
        text: Battery.statusIcon()
        color: BarConfig.textColor
        font.family: BarConfig.fontFamily
        font.pixelSize: 48
        Layout.alignment: Qt.AlignHCenter
    }

    // Percentage text
    Text {
        text: Math.round(percentage * 100) + "%"
        color: BarConfig.textColor
        font.family: BarConfig.fontFamily
        font.pixelSize: 24
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
    }

    // Charging status
    Text {
        text: charging ? "Charging" : "Discharging"
        color: Color.text
        font.family: BarConfig.fontFamily
        font.pixelSize: 12
        Layout.alignment: Qt.AlignHCenter
    }
}
