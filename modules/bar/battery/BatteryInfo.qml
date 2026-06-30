// Battery info display component.
// Shows large icon, percentage, and charging status.
import QtQuick
import QtQuick.Layouts
import "../../../Commons"
import "../../../services"
import "../../../utils"

ColumnLayout {
    id: batteryInfo

    property real percentage: Battery.percentage
    property bool charging: Battery.charging

    spacing: 4

    // Large battery icon
    Text {
        text: Icons.batteryIcon(Battery.available, Battery.charging, Battery.percentage)
        color: Battery.charging ? Color.success : Color.text
        font.family: Style.font.family
        font.pixelSize: Style.font.iconLarge
        Layout.alignment: Qt.AlignHCenter
    }

    // Percentage text
    Text {
        text: Math.round(percentage * 100) + "%"
        color: Color.text
        font.family: Style.font.family
        font.pixelSize: Style.font.large
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
    }

    // Charging status - fixed width to prevent layout shift
    Text {
        text: "● " + (charging ? "Charging" : "Discharging")
        color: Battery.charging ? Color.success : Color.text
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        Layout.alignment: Qt.AlignHCenter
        Layout.minimumWidth: 120
        horizontalAlignment: Text.AlignHCenter
    }
}