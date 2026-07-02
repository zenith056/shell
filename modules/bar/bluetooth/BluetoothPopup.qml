// Bluetooth popup — PanelWindow with keyboard focus.
// Shows toggle, paired devices, and available devices.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../Commons"
import "../../../services"
import "../../../utils"
import "../../../Ui"

PanelWindow {
    id: root

    property bool isOpen: PopupControl.isOpen("bluetooth")
    property int deviceIndex: -1
    property bool cursorActive: false
    property string pendingRemoveAddress: ""
    property string pendingRemoveName: ""
    property bool _closing: false

    visible: isOpen || _closing
    implicitWidth: 400
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "bluetooth-popup"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors { top: false; bottom: true; left: true; right: true }
    implicitHeight: screen ? screen.height - BarConfig.height : 1000
    color: "transparent"

    onIsOpenChanged: {
        if (isOpen) {
            Bluetooth.startScan()
            deviceIndex = -1; cursorActive = false
            pendingRemoveAddress = ""; pendingRemoveName = ""
            _closing = false
            enterAnim.restart()
            Qt.callLater(() => card.forceActiveFocus())
        } else {
            Bluetooth.stopScan()
            exitAnim.restart()
        }
    }

    function deviceCount() { return Bluetooth.pairedDevices.length + Bluetooth.availableDevices.length }
    function getDevice(idx) {
        if (idx < Bluetooth.pairedDevices.length) return Bluetooth.pairedDevices[idx]
        return Bluetooth.availableDevices[idx - Bluetooth.pairedDevices.length]
    }
    function isPaired(idx) { return idx < Bluetooth.pairedDevices.length }

    SequentialAnimation {
        id: enterAnim
        ParallelAnimation {
            Anim { target: card; property: "opacity"; from: 0; to: 1; type: Anim.DefaultEffects }
            Anim { target: cardTranslate; property: "y"; from: -34; to: 0; type: Anim.DefaultSpatial }
            Anim { target: card; property: "scale"; from: 0.95; to: 1; type: Anim.DefaultSpatial }
        }
    }

    SequentialAnimation {
        id: exitAnim
        ParallelAnimation {
            Anim { target: card; property: "opacity"; from: 1; to: 0; type: Anim.DefaultEffects }
            Anim { target: cardTranslate; property: "y"; from: 0; to: -34; type: Anim.DefaultSpatial }
            Anim { target: card; property: "scale"; from: 1; to: 0.95; type: Anim.DefaultSpatial }
        }
        ScriptAction { script: _closing = false }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: function(mouse) {
            var inside = mouse.x >= card.x && mouse.x <= card.x + card.width &&
                         mouse.y >= card.y && mouse.y <= card.y + card.height;
            if (!inside) {
                PopupControl.close()
            }
        }
    }

    Rectangle {
        id: card
        width: 380; height: 520
        x: Math.max(8, Math.min(PopupControl.anchorX + PopupControl.anchorWidth - width, parent.width - width - 8))
        y: 4
        color: Color.background; radius: 8
        clip: true
        opacity: 0
        transformOrigin: Item.Top

        transform: Translate {
            id: cardTranslate
            y: -34
        }

        HoverHandler {
            id: cardHover
            onHoveredChanged: {
                PopupControl.cardHovered = hovered
                if (!hovered) {
                    PopupControl.checkClose()
                }
            }
        }

        Keys.onEscapePressed: PopupControl.close()
        Keys.onPressed: function(event) {
            const k = event.key; const t = event.text
            if (t === "j" || k === Qt.Key_Down) {
                cursorActive = true
                deviceIndex = Math.min(deviceCount() - 1, deviceIndex + 1)
                event.accepted = true
            } else if (t === "k" || k === Qt.Key_Up) {
                deviceIndex = Math.max(0, deviceIndex - 1)
                event.accepted = true
            } else if (k === Qt.Key_Return || k === Qt.Key_Space) {
                if (cursorActive && deviceIndex >= 0) {
                    var dev = getDevice(deviceIndex)
                    if (dev.connected) Bluetooth.disconnect(dev.address)
                    else Bluetooth.connect(dev.address)
                }
                event.accepted = true
            } else if (t === "x" || t === "X") {
                if (cursorActive && deviceIndex >= 0 && isPaired(deviceIndex)) {
                    var dev2 = getDevice(deviceIndex)
                    pendingRemoveAddress = dev2.address
                    pendingRemoveName = dev2.name
                }
                event.accepted = true
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // Header
            PopupHeader {
                icon: Icons.bluetooth
                iconColor: Bluetooth.enabled ? (Bluetooth.connectedDevice ? Color.success : Color.text) : Color.textMuted
                title: "Bluetooth"
                subtitle: Bluetooth.connectedDevice ? Bluetooth.connectedDevice.name : (Bluetooth.enabled ? "No device connected" : "Disabled")
                Layout.fillWidth: true
            }

            PanelSeparator { foreground: Color.text }

            // Bluetooth toggle switch
            PopupToggleRow {
                text: "Bluetooth"
                checked: Bluetooth.enabled
                onClicked: Bluetooth.toggle()
                Layout.fillWidth: true
            }

            // Error display
            Rectangle {
                visible: Bluetooth.lastError !== ""
                Layout.fillWidth: true
                height: 28
                radius: 6
                color: Color.divider
                Text { anchors.centerIn: parent; text: Bluetooth.lastError; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body }
            }

            // Remove device confirmation dialog
            Rectangle {
                visible: pendingRemoveAddress !== ""
                Layout.fillWidth: true
                height: 40
                radius: 6
                color: Color.divider
                
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
                    
                    Rectangle {
                        width: 48; height: 24; radius: 4; color: "transparent"
                        Text { anchors.centerIn: parent; text: "Cancel"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.caption }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { pendingRemoveAddress = ""; pendingRemoveName = "" } }
                    }
                    
                    Rectangle {
                        width: 48; height: 24; radius: 4; color: "transparent"
                        Text { anchors.centerIn: parent; text: "Remove"; color: Color.lowBattery; font.family: Style.font.family; font.pixelSize: Style.font.caption; font.bold: true }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { Bluetooth.remove(pendingRemoveAddress); pendingRemoveAddress = ""; pendingRemoveName = "" } }
                    }
                }
            }

            PanelSectionHeader {
                text: "DEVICES"
                foreground: Color.text
                Layout.fillWidth: true
            }

            // Devices list Box (scrollable list)
            PopupListBox {
                id: listContainer
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: devicesListView
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 4
                    model: ListModel {
                        id: deviceModel
                    }

                    Component.onCompleted: devicesListView.rebuildModel()
                    Connections {
                        target: Bluetooth
                        function onPairedDevicesChanged() { devicesListView.rebuildModel() }
                        function onAvailableDevicesChanged() { devicesListView.rebuildModel() }
                    }

                    function rebuildModel() {
                        deviceModel.clear()
                        for (var i = 0; i < Bluetooth.pairedDevices.length; i++) {
                            var d = Bluetooth.pairedDevices[i]
                            deviceModel.append({ name: d.name, connected: d.connected, address: d.address, paired: true })
                        }
                        for (var i = 0; i < Bluetooth.availableDevices.length; i++) {
                            var d = Bluetooth.availableDevices[i]
                            deviceModel.append({ name: d.name, connected: false, address: d.address, paired: false })
                        }
                    }

                    highlightFollowsCurrentItem: true
                    highlight: Rectangle { color: Color.divider; radius: 6 }

                    delegate: Rectangle {
                        width: devicesListView.width
                        height: 40
                        radius: 6
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 8

                            Text {
                                text: model.paired ? Icons.headphones : Icons.bluetooth
                                color: model.connected ? Color.success : Color.text
                                font.family: Style.font.family
                                font.pixelSize: Style.font.title
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true
                                Text {
                                    text: model.name
                                    color: model.connected ? Color.success : Color.text
                                    font.family: Style.font.family
                                    font.pixelSize: Style.font.body
                                    font.bold: model.connected
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: model.paired ? (model.connected ? "Connected" : "Paired") : "Available"
                                    color: Color.textMuted
                                    font.family: Style.font.family
                                    font.pixelSize: Style.font.caption
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                width: 28; height: 28; radius: 14; color: "transparent"
                                Text { anchors.centerIn: parent; text: model.connected ? Icons.times : (model.paired ? Icons.link : Icons.plus); color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (model.connected) Bluetooth.disconnect(model.address)
                                        else if (model.paired) Bluetooth.connect(model.address)
                                        else Bluetooth.pair(model.address)
                                    }
                                }
                            }

                            Rectangle {
                                visible: model.paired
                                width: 28; height: 28; radius: 14; color: "transparent"
                                Text { anchors.centerIn: parent; text: Icons.trash; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        pendingRemoveAddress = model.address
                                        pendingRemoveName = model.name
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Scan/Stop Scan Button
            PopupActionButton {
                icon: Bluetooth.scanning ? Icons.times : Icons.refresh
                text: Bluetooth.scanning ? "Stop Scan" : "Scan"
                onClicked: Bluetooth.scanning ? Bluetooth.stopScan() : Bluetooth.startScan()
                Layout.fillWidth: true
            }
        }
    }
}
