// Battery power display component.
// Shows power consumption/charging rate in watts.
import QtQuick
import QtQuick.Layouts
import "../../../config"
import "../../../services"

RowLayout {
    id: batteryWatts

    property real changeRate: Battery.changeRate

    spacing: 8

    // Power icon
    Text {
        text: "󰂄"  // nf-md-lightning_bolt
        color: BarConfig.textColor
        font.family: BarConfig.fontFamily
        font.pixelSize: 16
    }

    // Watts value
    Text {
        text: {
            var watts = Math.abs(batteryWatts.changeRate);
            var sign = batteryWatts.changeRate >= 0 ? "+" : "-";
            return sign + watts.toFixed(1) + " W";
        }
        color: BarConfig.textColor
        font.family: BarConfig.fontFamily
        font.pixelSize: 14
    }
}
