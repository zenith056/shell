// Battery power display component.
// Shows power consumption/charging rate in watts.
// Negative when discharging, positive when charging.
import QtQuick
import QtQuick.Layouts
import "../../../Commons"
import "../../../services"

RowLayout {
    id: batteryWatts

    property real changeRate: Battery.changeRate
    property bool charging: Battery.charging

    spacing: 8

    // Power icon
    Text {
        text: "󰂄"  // nf-md-lightning_bolt
        color: BarConfig.textColor
        font.family: BarConfig.fontFamily
        font.pixelSize: 16
    }

    // Watts value — negative when discharging, positive when charging
    Text {
        text: {
            var watts = Math.abs(batteryWatts.changeRate);
            if (watts === 0) return "0.0 W";
            var sign = batteryWatts.charging ? "+" : "-";
            return sign + watts.toFixed(1) + " W";
        }
        color: BarConfig.textColor
        font.family: BarConfig.fontFamily
        font.pixelSize: 14
    }
}