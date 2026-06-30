// Network popup component.
// Shows WiFi, Ethernet, and hotspot controls.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Commons"
import "../../../services"
import "../../../utils"
import "../../../components"

BasePopup {
    id: networkPopup

    implicitWidth: 360
    implicitHeight: 480

    signal requestPassword(string ssid)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        anchors.bottomMargin: 24
        spacing: 12

        Keys.onEscapePressed: networkPopup.hide()

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: Icons.signalIcon(Network.signalStrength)
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.iconLarge
            }

            Text {
                text: Network.connected ? (Network.wifi ? Network.ssid : "Ethernet") : "Disconnected"
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.heading
                font.bold: true
            }
        }

        Divider {}

        // WiFi Section
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "WiFi"
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.title
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            ToggleSwitch {
                active: Network.wifiEnabled
                onToggled: Network.toggleWifi()
            }
        }

        // WiFi networks list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 240
            color: Color.surface
            radius: 8
            clip: true

            Flickable {
                anchors.fill: parent
                anchors.margins: 8
                contentHeight: networkColumn.height
                clip: true
                flickableDirection: Flickable.VerticalFlick

                ColumnLayout {
                    id: networkColumn
                    width: parent.width
                    spacing: 4

                    // Scan button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: scanArea.containsMouse ? Color.divider : "transparent"
                        radius: 6

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: Icons.refresh; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body }
                            Text { text: "Scan"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body }
                        }

                        MouseArea {
                            id: scanArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Network.scanNetworks()
                        }
                    }

                    Repeater {
                        model: Network.availableNetworks

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            color: netArea.containsMouse ? Color.divider : "transparent"
                            radius: 6

                            property bool isConnected: Network.ssid === modelData.ssid

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8

                                Text {
                                    text: Icons.signalIcon(modelData.signal)
                                    color: Color.text
                                    font.family: Style.font.family
                                    font.pixelSize: Style.font.title
                                }

                                Text {
                                    text: modelData.ssid
                                    color: isConnected ? Color.success : Color.text
                                    font.family: Style.font.family
                                    font.pixelSize: Style.font.body
                                    font.bold: isConnected
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: modelData.security !== "None" ? Icons.lock : ""
                                    color: Color.textMuted
                                    font.family: Style.font.family
                                    font.pixelSize: Style.font.body
                                }
                            }

                            MouseArea {
                                id: netArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.security !== "None") {
                                        networkPopup.requestPassword(modelData.ssid);
                                    } else {
                                        Network.connect(modelData.ssid, "");
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Divider {}

        // Hotspot Section
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Hotspot"
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.title
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            ToggleSwitch {
                active: Network.hotspotActive
                onToggled: Network.toggleHotspot()
            }
        }
    }

    // Override show to also trigger scan
    function show(anchorWindow, anchorButtonItem) {
        Network.scanNetworks();
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