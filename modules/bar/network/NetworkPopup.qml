// Network popup — PanelWindow with keyboard focus.
// Shows WiFi toggle and available networks.
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

    property bool isOpen: PopupControl.isOpen("network")
    property int networkIndex: -1
    property bool cursorActive: false
    property string pendingPasswordSsid: ""
    property bool _closing: false

    visible: isOpen || _closing
    implicitWidth: 400
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "network-popup"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors { top: false; bottom: true; left: true; right: true }
    implicitHeight: screen ? screen.height - BarConfig.height : 1000
    color: "transparent"

    onIsOpenChanged: {
        if (isOpen) {
            Network.scanNetworks()
            networkIndex = -1; cursorActive = false; pendingPasswordSsid = ""
            _closing = false
            enterAnim.restart()
            Qt.callLater(() => card.forceActiveFocus())
        } else {
            exitAnim.restart()
        }
    }

    function selectNetwork(idx) {
        if (idx < 0 || idx >= Network.availableNetworks.length) return
        var net = Network.availableNetworks[idx]
        if (net.connected) return
        if (net.security !== "Open" && net.security !== "Unknown") {
            pendingPasswordSsid = net.ssid
        } else {
            Network.connect(net.ssid, "")
        }
    }

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
            if (pendingPasswordSsid !== "") return
            if (t === "j" || k === Qt.Key_Down) {
                cursorActive = true
                networkIndex = Math.min(Network.availableNetworks.length - 1, networkIndex + 1)
                event.accepted = true
            } else if (t === "k" || k === Qt.Key_Up) {
                networkIndex = Math.max(0, networkIndex - 1)
                event.accepted = true
            } else if (k === Qt.Key_Return || k === Qt.Key_Space) {
                if (cursorActive && networkIndex >= 0) selectNetwork(networkIndex)
                event.accepted = true
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // Header
            PopupHeader {
                icon: Icons.signalIcon(Network.signalStrength)
                iconColor: Network.connected ? Color.success : Color.textMuted
                title: "Network"
                subtitle: Network.connected ? (Network.wifi ? Network.ssid : "Ethernet") : "Disconnected"
                Layout.fillWidth: true
            }

            PanelSeparator { foreground: Color.text }

            // WiFi Switch
            PopupToggleRow {
                text: "WiFi"
                checked: Network.wifiEnabled
                onClicked: Network.toggleWifi()
                Layout.fillWidth: true
            }

            // Connection Password Prompt
            Rectangle {
                visible: root.pendingPasswordSsid !== ""
                Layout.fillWidth: true
                height: 120
                radius: 6
                color: Color.divider
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    Text {
                        text: "Connect to " + root.pendingPasswordSsid
                        color: Color.text
                        font.family: Style.font.family
                        font.pixelSize: Style.font.heading
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 32
                        radius: 4
                        color: Color.background
                        
                        TextInput {
                            id: pwInput
                            anchors.fill: parent
                            anchors.margins: 6
                            color: Color.text
                            font.family: Style.font.family
                            font.pixelSize: Style.font.body
                            echoMode: TextInput.Password
                            clip: true
                            focus: root.pendingPasswordSsid !== ""
                            Keys.onReturnPressed: {
                                Network.connect(root.pendingPasswordSsid, text)
                                root.pendingPasswordSsid = ""
                                text = ""
                            }
                        }
                    }
                    
                    RowLayout {
                        spacing: 8
                        Layout.fillWidth: true
                        
                        Rectangle {
                            width: 60; height: 24; radius: 4; color: "transparent"
                            Text { anchors.centerIn: parent; text: "Cancel"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.caption }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.pendingPasswordSsid = ""; pwInput.text = "" } }
                        }
                        
                        Rectangle {
                            width: 60; height: 24; radius: 4; color: Color.text
                            Text { anchors.centerIn: parent; text: "Connect"; color: Color.background; font.family: Style.font.family; font.pixelSize: Style.font.caption; font.bold: true }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { Network.connect(root.pendingPasswordSsid, pwInput.text); root.pendingPasswordSsid = ""; pwInput.text = "" } }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
            }

            PanelSectionHeader {
                text: "NETWORKS"
                foreground: Color.text
                Layout.fillWidth: true
            }

            // Network list Box (scrollable list)
            PopupListBox {
                id: listContainer
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: networksListView
                    anchors.fill: parent
                    anchors.margins: 4
                    model: Network.availableNetworks
                    currentIndex: root.networkIndex
                    highlightFollowsCurrentItem: true
                    highlight: Rectangle { color: Color.divider; radius: 6 }

                    delegate: Rectangle {
                        width: networksListView.width
                        height: 36
                        radius: 6
                        color: "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 8
                            Text {
                                text: Icons.signalIcon(modelData.signal)
                                color: modelData.connected ? Color.success : Color.text
                                font.family: Style.font.family
                                font.pixelSize: Style.font.body
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: modelData.ssid
                                color: modelData.connected ? Color.success : Color.text
                                font.family: Style.font.family
                                font.pixelSize: Style.font.body
                                font.bold: modelData.connected
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 60
                                elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.security !== "Open" && modelData.security !== "Unknown" ? Icons.lock : ""
                                color: Color.textMuted
                                font.family: Style.font.family
                                font.pixelSize: Style.font.body
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: {
                                root.cursorActive = true
                                root.networkIndex = index
                                networksListView.currentIndex = index
                            }
                            onClicked: root.selectNetwork(index)
                        }
                    }
                }
            }

            // Scan Button
            PopupActionButton {
                icon: Icons.refresh
                text: "Scan"
                onClicked: Network.scanNetworks()
                Layout.fillWidth: true
            }
        }
    }
}
