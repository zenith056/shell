// Battery power display component.
// Shows power consumption/charging rate in watts.
import QtQuick
import QtQuick.Layouts
import "../../../Commons"
import "../../../services"
import "../../../utils"

RowLayout {
    id: batteryWatts

    property real changeRate: Battery.changeRate
    property bool charging: Battery.charging

    spacing: 8

    Text {
        text: Icons.bolt
        color: Color.text
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
    }

    Text {
        text: {
            var watts = Math.abs(batteryWatts.changeRate);
            if (watts === 0) return "0.0 W";
            var sign = batteryWatts.charging ? "+" : "-";
            return sign + watts.toFixed(1) + " W";
        }
        color: Color.text
        font.family: Style.font.family
        font.pixelSize: Style.font.title
    }
}