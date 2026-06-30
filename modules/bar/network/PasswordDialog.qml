// Password input dialog for WiFi connection.
// Shows a text input field for entering WiFi password.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Commons"
import "../../../utils"
import "../../../components"

BasePopup {
    id: passwordDialog

    property string networkSsid: ""
    property string password: ""
    property Item anchorItem: null

    implicitWidth: 340
    implicitHeight: 180

    onVisibleChanged: if (!visible) passwordInput.text = ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Keys.onEscapePressed: passwordDialog.hide()

        Text {
            text: "Connect to " + networkSsid
            color: Color.text
            font.family: Style.font.family
            font.pixelSize: Style.font.heading
            font.bold: true
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Divider {}

        Text {
            text: "Password"
            color: Color.textMuted
            font.family: Style.font.family
            font.pixelSize: Style.font.body
        }

        // Password input
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: Color.surface
            radius: 6

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.margins: 8
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                echoMode: TextInput.Password
                clip: true
                focus: true

                Keys.onReturnPressed: passwordDialog.connectToNetwork()
                Keys.onEnterPressed: passwordDialog.connectToNetwork()
            }
        }

        // Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: cancelArea.containsMouse ? Color.divider : "transparent"
                radius: 6

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: Color.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                }

                MouseArea {
                    id: cancelArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: passwordDialog.hide()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: connectArea.containsMouse ? Color.textMuted : Color.text
                radius: 6

                Text {
                    anchors.centerIn: parent
                    text: "Connect"
                    color: Color.background
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    font.bold: true
                }

                MouseArea {
                    id: connectArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: passwordDialog.connectToNetwork()
                }
            }
        }
    }

    function connectToNetwork() {
        Network.connect(networkSsid, passwordInput.text);
        hide();
    }

    // Override show to accept ssid parameter
    function showDialog(anchorWindow, anchorButtonItem, ssid) {
        networkSsid = ssid;
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
}