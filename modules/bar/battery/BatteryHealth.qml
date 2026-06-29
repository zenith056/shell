// Battery health display component.
// Shows battery health percentage, energy capacity, and device model.
import QtQuick
import QtQuick.Layouts
import "../../../config"
import "../../../services"

ColumnLayout {
    id: batteryHealth

    property real healthPercentage: Battery.healthPercentage
    property real energy: Battery.energy
    property real energyCapacity: Battery.energyCapacity
    property string model: Battery.model

    spacing: 4

    // Health info row
    RowLayout {
        spacing: 8

        // Health icon
        Text {
            text: "󰂀"  // nf-md-heart
            color: BarConfig.textColor
            font.family: BarConfig.fontFamily
            font.pixelSize: 16
        }

        // Health label and value
        Text {
            text: "Health: " + Math.round(batteryHealth.healthPercentage) + "%"
            color: BarConfig.textColor
            font.family: BarConfig.fontFamily
            font.pixelSize: 14
        }
    }

    // Energy capacity row
    RowLayout {
        spacing: 8

        // Battery icon
        Text {
            text: "󰁹"  // nf-md-battery
            color: BarConfig.textColor
            font.family: BarConfig.fontFamily
            font.pixelSize: 16
        }

        // Energy label and value
        Text {
            text: "Capacity: " + batteryHealth.energy.toFixed(1) + " / " + batteryHealth.energyCapacity.toFixed(1) + " Wh"
            color: BarConfig.textColor
            font.family: BarConfig.fontFamily
            font.pixelSize: 14
        }
    }

    // Model row
    RowLayout {
        spacing: 8

        // Device icon
        Text {
            text: "󰦀"  // nf-md-laptop
            color: BarConfig.textColor
            font.family: BarConfig.fontFamily
            font.pixelSize: 16
        }

        // Model label and value
        Text {
            text: "Model: " + batteryHealth.model
            color: BarConfig.textColor
            font.family: BarConfig.fontFamily
            font.pixelSize: 14
        }
    }
}
