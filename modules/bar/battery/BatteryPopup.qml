// Battery popup component.
// Displays detailed battery information when indicator is clicked.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../config"
import "../../../services"
import ".."

PopupWindow {
    id: batteryPopup

    property bool isOpen: false

    visible: isOpen
    grabFocus: true
    width: 280
    height: 320

    // Background color matching bar
    color: Colors.background

    // Close when clicking outside
    onVisibleChanged: {
        if (!visible) {
            isOpen = false;
        }
    }

    // Escape key dismissal
    Keys.onEscapePressed: {
        hide();
    }

    // Content container
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

            // Battery info section (icon, percentage, status)
            BatteryInfo {
                Layout.fillWidth: true
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.divider
            }

            // Power section (watts)
            BatteryWatts {
                Layout.fillWidth: true
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.divider
            }

            // Health section (health, capacity, model)
            BatteryHealth {
                Layout.fillWidth: true
            }

            // Spacer
            Item {
                Layout.fillHeight: true
            }
    }

    // Function to show the popup at a specific position
    function show(parentWindow, x, y) {
        anchor.window = parentWindow;
        anchor.rect.x = x;
        anchor.rect.y = y;
        isOpen = true;
        visible = true;
    }

    // Function to hide the popup
    function hide() {
        isOpen = false;
        visible = false;
    }
}