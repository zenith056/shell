// Battery popup component.
// Displays battery info with power profile selector.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Commons"
import "../../../services"
import "../../../utils"
import ".."

PopupWindow {
    id: batteryPopup

    property bool isOpen: false

    visible: isOpen
    grabFocus: true
    implicitWidth: 400
    implicitHeight: 320

    color: Color.background

    onVisibleChanged: {
        if (!visible) {
            isOpen = false;
        }
    }

    // Content container
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Keys.onEscapePressed: {
            batteryPopup.hide();
        }

        // Header: Icon + Percentage
        BatteryInfo {
            Layout.fillWidth: true
        }

        // Battery bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            color: Color.divider

            Rectangle {
                width: parent.width * Battery.percentage
                height: parent.height
                color: Battery.charging ? Color.success : Color.text
            }
        }

        // Battery size and time left
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "Battery size " + Math.round(Battery.energyCapacity) + "Wh"
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
            }

            Item { Layout.fillWidth: true }

            Text {
                text: {
                    if (Battery.timeToFull > 0) {
                        var h = Math.floor(Battery.timeToFull / 3600);
                        var m = Math.floor((Battery.timeToFull % 3600) / 60);
                        return "Time left: " + h + "h " + m + "m";
                    } else if (Battery.timeToEmpty > 0) {
                        var h = Math.floor(Battery.timeToEmpty / 3600);
                        var m = Math.floor((Battery.timeToEmpty % 3600) / 60);
                        return "Time left: " + h + "h " + m + "m";
                    }
                    return "Time left: --";
                }
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
            }
        }

        // Threshold and status
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "Threshold 95-100%"
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
            }

            Item { Layout.fillWidth: true }

            Text {
                text: {
                    var watts = Math.abs(Battery.changeRate).toFixed(1) + "W";
                    if (Battery.charging) return "● Charging " + watts;
                    return "○ Discharging " + watts;
                }
                color: Battery.charging ? Color.success : Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Color.divider
        }

        // Power profile label
        Text {
            text: "Power Profile"
            color: Color.text
            font.family: Style.font.family
            font.pixelSize: Style.font.heading
            font.bold: true
        }

        // Power profile buttons
        PowerProfileSelector {
            Layout.fillWidth: true
        }
    }

    // Show popup below the bar
    function show(anchorWindow, anchorButtonItem) {
        var pos = anchorButtonItem.mapToItem(anchorWindow.contentItem, 0, 0);
        anchor.window = anchorWindow;
        anchor.rect = Qt.rect(
            pos.x + anchorButtonItem.width / 2 - implicitWidth / 2,
            anchorWindow.height,
            implicitWidth,
            implicitHeight
        );
        isOpen = true;
        visible = true;
    }

    // Hide the popup
    function hide() {
        isOpen = false;
        visible = false
    }
}