// Battery popup component.
// Displays battery info with power profile selector.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Commons"
import "../../../services"
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
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: Battery.statusIcon()
                color: Color.text
                font.family: BarConfig.fontFamily
                font.pixelSize: 40
            }

            Item { Layout.fillWidth: true }

            Text {
                text: Math.round(Battery.percentage * 100) + "%"
                color: Color.text
                font.family: BarConfig.fontFamily
                font.pixelSize: 32
                font.bold: true
            }
        }

        // Battery bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            color: Color.divider

            Rectangle {
                width: parent.width * Battery.percentage
                height: parent.height
                color: Battery.charging ? "#888888" : "#ffffff"
            }
        }

        // Battery size and time left
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "Battery size " + Math.round(Battery.energyCapacity) + "Wh"
                color: Color.text
                font.family: BarConfig.fontFamily
                font.pixelSize: 14
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
                font.family: BarConfig.fontFamily
                font.pixelSize: 14
            }
        }

        // Threshold and status
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "Threshold 95-100%"
                color: Color.text
                font.family: BarConfig.fontFamily
                font.pixelSize: 14
            }

            Item { Layout.fillWidth: true }

            Text {
                text: (Battery.charging ? "Charging" : "Discharging") + " " + Math.abs(Battery.changeRate).toFixed(1) + "W"
                color: Color.text
                font.family: BarConfig.fontFamily
                font.pixelSize: 14
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
            font.family: BarConfig.fontFamily
            font.pixelSize: 16
            font.bold: true
        }

        // Power profile buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Repeater {
                model: [
                    { name: "power-saver", label: "Power Saver", icon: "\uf0e7" },
                    { name: "balanced", label: "Balanced", icon: "\uf0e8" },
                    { name: "performance", label: "Performance", icon: "\uf135" }
                ]

                Rectangle {
                    property string profileName: modelData.name
                    property bool isActive: PowerProfile.activeProfile === profileName

                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 8
                    color: isActive ? "#ffffff" : (btnArea.containsMouse ? "#333333" : "#1a1a1a")
                    border.color: "#444444"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: modelData.icon
                            color: isActive ? "#000000" : Color.text
                            font.family: BarConfig.fontFamily
                            font.pixelSize: 14
                        }

                        Text {
                            text: modelData.label
                            color: isActive ? "#000000" : Color.text
                            font.family: BarConfig.fontFamily
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        id: btnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PowerProfile.setProfile(profileName)
                    }
                }
            }
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