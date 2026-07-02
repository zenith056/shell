// Battery indicator widget for the status bar.
// Shows a battery icon and opens a popup with detailed info on click.
import QtQuick
import "../../Commons"
import "../../services"
import "../../utils"
import "../../Ui"

Item {
    id: battery

    implicitWidth: Style.font.indicator - 8
    height: BarConfig.height

    Component.onCompleted: PopupControl.batteryIndicator = battery

    Text {
        anchors.centerIn: parent
        text: Icons.batteryIcon(Battery.available, Battery.charging, Battery.percentage)
        color: Battery.percentage <= 0.2 && !Battery.charging ? Color.lowBattery : BarConfig.textColor
        font.family: Style.font.family
        font.pixelSize: Style.font.indicator

        Behavior on color {
            CAnim { animType: Anim.DefaultEffects }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PopupControl.toggle("battery", battery)
        onEntered: {
            PopupControl.indicatorHovered = true
            PopupControl.open("battery", battery)
        }
        onExited: {
            PopupControl.indicatorHovered = false
            PopupControl.checkClose()
        }
    }
}
