// Audio OSD component.
// Shows a horizontal volume bar when volume changes.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Commons"
import "../../../services"

PopupWindow {
    id: audioOsd

    property bool isOpen: false

    visible: isOpen
    grabFocus: true
    implicitWidth: 120
    implicitHeight: 32

    color: "transparent"

    onVisibleChanged: {
        if (!visible) {
            isOpen = false;
        }
    }

    // Auto-hide timer
    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: audioOsd.hide()
    }

    // Background box
    Rectangle {
        anchors.fill: contentArea
        color: Color.background
        radius: 6
    }

    // Content container
    RowLayout {
        id: contentArea
        anchors.centerIn: parent
        width: 100
        height: 24
        spacing: 8
        anchors.margins: 8

        Keys.onEscapePressed: {
            audioOsd.hide();
        }

        // Volume icon
        Text {
            id: iconText
            text: Audio.muted || Audio.volume === 0 ? "\uf00d"
                : Audio.volume < 0.33 ? "\uf026"
                : Audio.volume < 0.66 ? "\uf027"
                : "\uf028"
            color: Color.text
            font.family: BarConfig.fontFamily
            font.pixelSize: 12
            Layout.alignment: Qt.AlignVCenter
        }

        // Horizontal bar background
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            radius: 3
            color: Color.divider

            // Filled portion
            Rectangle {
                width: parent.width * Audio.volume
                height: parent.height
                radius: parent.radius
                color: Audio.muted ? Color.divider : Color.accent
            }
        }
    }

    // Show OSD centered below the bar
    function show(anchorWindow) {
        hideTimer.restart();
        anchor.window = anchorWindow;
        anchor.rect = Qt.rect(
            anchorWindow.width / 2 - implicitWidth / 2,
            anchorWindow.height,
            implicitWidth,
            implicitHeight
        );
        isOpen = true;
        visible = true;
    }

    // Hide the OSD
    function hide() {
        isOpen = false;
        visible = false
    }
}