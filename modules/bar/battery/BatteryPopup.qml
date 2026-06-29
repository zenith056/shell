// Battery popup component.
// Displays detailed battery information when indicator is clicked.
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
    implicitWidth: 280
    implicitHeight: 320

    // Background color matching bar
    color: Color.background

    // Close when clicking outside
    onVisibleChanged: {
        if (!visible) {
            isOpen = false;
        }
    }

    // Content container
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Escape key handler inside content
        Keys.onEscapePressed: {
            batteryPopup.hide();
        }

        // Battery info section (icon, percentage, status)
        BatteryInfo {
            Layout.fillWidth: true
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Color.divider
        }

        // Power section (watts)
        BatteryWatts {
            Layout.fillWidth: true
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Color.divider
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

    // Function to show the popup anchored to an item
    function show(anchorItem) {
        anchor.item = anchorItem;
        isOpen = true;
        visible = true;
    }

    // Function to hide the popup
    function hide() {
        isOpen = false;
        visible = false;
    }
}