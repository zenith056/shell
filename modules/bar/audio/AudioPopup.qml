// Audio popup component.
// Displays volume control with large icon and level indicators.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Commons"
import "../../../services"

PopupWindow {
    id: audioPopup

    property bool isOpen: false
    property Item anchorItem: null

    visible: isOpen
    grabFocus: true
    implicitWidth: 240
    implicitHeight: 200

    color: Color.background

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

        Keys.onEscapePressed: {
            audioPopup.hide();
        }

        // Large volume icon
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 80

            Text {
                anchors.centerIn: parent
                text: Audio.muted || Audio.volume === 0 ? "\uf00d"
                    : Audio.volume < 0.33 ? "\uf026"
                    : Audio.volume < 0.66 ? "\uf027"
                    : "\uf028"
                color: Color.text
                font.family: BarConfig.fontFamily
                font.pixelSize: 48
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Color.divider
        }

        // Volume percentage
        Text {
            Layout.fillWidth: true
            text: Audio.muted ? "Muted" : Math.round(Audio.volume * 100) + "%"
            color: Color.text
            font.family: BarConfig.fontFamily
            font.pixelSize: BarConfig.fontSize + 2
            horizontalAlignment: Text.AlignHCenter
        }

        // Volume bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            radius: 3
            color: Color.divider

            Rectangle {
                width: parent.width * Audio.volume
                height: parent.height
                radius: parent.radius
                color: Audio.muted ? Color.divider : Color.accent
            }
        }

        // Volume buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            spacing: 8

            // Decrease button
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 6
                color: decreaseArea.containsMouse ? Color.divider : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "\uf068"  // nf-fa-minus
                    color: Color.text
                    font.family: BarConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize
                }

                MouseArea {
                    id: decreaseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Audio.setVolume(Audio.volume - 0.05)
                }
            }

            // Mute button
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 6
                color: muteArea.containsMouse ? Color.divider : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: Audio.muted ? "\uf04b" : "\uf04c"  // nf-fa-play / nf-fa-pause
                    color: Color.text
                    font.family: BarConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize
                }

                MouseArea {
                    id: muteArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Audio.toggleMute()
                }
            }

            // Increase button
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 6
                color: increaseArea.containsMouse ? Color.divider : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "\uf067"  // nf-fa-plus
                    color: Color.text
                    font.family: BarConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize
                }

                MouseArea {
                    id: increaseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Audio.setVolume(Audio.volume + 0.05)
                }
            }
        }
    }

    // Show popup centered below the bar
    function show(anchorWindow) {
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

    // Hide the popup
    function hide() {
        isOpen = false;
        visible = false;
    }
}