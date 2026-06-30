// Bluetooth popup component.
// Shows Bluetooth toggle, paired devices, and available devices.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Commons"
import "../../../services"
import "../../../utils"
import "../../../components"

BasePopup {
    id: bluetoothPopup

    implicitWidth: 360
    implicitHeight: 480

    property string pendingRemoveAddress: ""
    property string pendingRemoveName: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        anchors.bottomMargin: 24
        spacing: 12

        Keys.onEscapePressed: bluetoothPopup.hide()

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text { text: Icons.bluetooth; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.iconLarge }
            Text { text: Bluetooth.connectedDevice ? Bluetooth.connectedDevice.name : "Bluetooth"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.heading; font.bold: true }
        }

        Divider {}

        // Bluetooth toggle
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text { text: "Bluetooth"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.title; font.bold: true }
            Item { Layout.fillWidth: true }
            ToggleSwitch {
                active: Bluetooth.enabled
                onToggled: Bluetooth.toggle()
            }
        }

        // Error message
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            radius: 6
            color: Color.divider
            visible: Bluetooth.lastError !== ""

            Text {
                anchors.centerIn: parent
                text: Bluetooth.lastError
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.body
            }
        }

        // Remove confirmation bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            radius: 6
            color: Color.divider
            visible: pendingRemoveAddress !== ""

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Text {
                    text: "Remove " + pendingRemoveName + "?"
                    color: Color.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                // Cancel button
                Rectangle {
                    width: cancelRemove.implicitWidth + 12
                    height: 24
                    radius: 4
                    color: cancelRemoveArea.containsMouse ? Color.surface : "transparent"

                    Text {
                        id: cancelRemove
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Color.text
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                    }

                    MouseArea {
                        id: cancelRemoveArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            pendingRemoveAddress = "";
                            pendingRemoveName = "";
                        }
                    }
                }

                // Confirm remove button
                Rectangle {
                    width: confirmRemove.implicitWidth + 12
                    height: 24
                    radius: 4
                    color: confirmRemoveArea.containsMouse ? Color.lowBattery : "transparent"

                    Text {
                        id: confirmRemove
                        anchors.centerIn: parent
                        text: "Remove"
                        color: Color.lowBattery
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        font.bold: true
                    }

                    MouseArea {
                        id: confirmRemoveArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Bluetooth.remove(pendingRemoveAddress);
                            pendingRemoveAddress = "";
                            pendingRemoveName = "";
                        }
                    }
                }
            }
        }

        // Device list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 300
            color: Color.surface
            radius: 8
            clip: true

            Flickable {
                anchors.fill: parent
                anchors.margins: 8
                contentHeight: col.height
                clip: true
                flickableDirection: Flickable.VerticalFlick

                ColumnLayout {
                    id: col
                    width: parent.width
                    spacing: 4

                    // Scan toggle button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: scanArea.containsMouse ? Color.divider : "transparent"
                        radius: 6
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: Bluetooth.scanning ? Icons.times : Icons.refresh; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body }
                            Text { text: Bluetooth.scanning ? "Stop Scan" : "Scan"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body }
                        }
                        MouseArea { id: scanArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Bluetooth.scanning ? Bluetooth.stopScan() : Bluetooth.startScan() }
                    }

                    Text { text: "Paired Devices"; color: Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.caption; Layout.topMargin: 8 }

                    Repeater {
                        model: Bluetooth.pairedDevices
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            color: "transparent"
                            radius: 6
                            property bool isConnected: modelData.connected
                            property bool isConnecting: false

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                Text { text: Icons.headphones; color: isConnected ? Color.success : Color.text; font.family: Style.font.family; font.pixelSize: Style.font.title }
                                ColumnLayout {
                                    spacing: 2
                                    Layout.fillWidth: true
                                    Text { text: modelData.name; color: isConnected ? Color.success : Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body; font.bold: isConnected; elide: Text.ElideRight; Layout.fillWidth: true }
                                    RowLayout {
                                        spacing: 6
                                        Text { text: isConnected ? "Connected" : "Paired"; color: Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.caption }
                                        Text {
                                            text: modelData.battery >= 0 ? Icons.batteryOutline + " " + modelData.battery + "%" : ""
                                            color: Color.textMuted
                                            font.family: Style.font.family
                                            font.pixelSize: Style.font.caption
                                            visible: modelData.battery >= 0
                                        }
                                    }
                                }
                                // Connect/Disconnect button
                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 14
                                    color: linkArea.containsMouse ? Color.divider : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: isConnected ? Icons.times : Icons.link
                                        color: Color.text
                                        font.family: Style.font.family
                                        font.pixelSize: Style.font.body
                                    }
                                    MouseArea {
                                        id: linkArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (isConnected) Bluetooth.disconnect(modelData.address);
                                            else Bluetooth.connect(modelData.address);
                                        }
                                    }
                                }
                                IconButton { icon: Icons.trash; onClicked: { pendingRemoveAddress = modelData.address; pendingRemoveName = modelData.name; } }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; Layout.topMargin: 8; color: Color.divider; visible: Bluetooth.availableDevices.length > 0 }
                    Text { text: "Available Devices"; color: Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.caption; Layout.topMargin: 8; visible: Bluetooth.availableDevices.length > 0 }

                    Repeater {
                        model: Bluetooth.availableDevices
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            color: "transparent"
                            radius: 6

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                Text { text: Icons.bluetooth; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.title }
                                Text { text: modelData.name; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body; Layout.fillWidth: true; elide: Text.ElideRight }
                                // Pair button
                                IconButton {
                                    icon: Icons.plus
                                    onClicked: Bluetooth.pair(modelData.address)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Override show to also refresh available devices
    function show(anchorWindow, anchorButtonItem) {
        PopupManager.closeOthers(bluetoothPopup);
        Bluetooth.refreshAvailable();
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
        PopupManager.registerPopup(bluetoothPopup);
    }
}