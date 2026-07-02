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

    MouseArea { anchors.fill: parent; onClicked: PopupControl.close() }

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

        Column {
            id: headerColumn
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 14; spacing: 14

            Row {
                spacing: 14
                Text { text: Icons.signalIcon(Network.signalStrength); color: Network.connected ? Color.text : Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.iconLarge; anchors.verticalCenter: parent.verticalCenter }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 2
                    Text { text: "Network"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.title; font.bold: true }
                    Text {
                        text: Network.connected ? (Network.wifi ? Network.ssid : "Ethernet") : "Disconnected"
                        color: Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.caption
                        font.bold: true; font.letterSpacing: 1.2
                    }
                }
            }

            PanelSeparator { foreground: Color.text }

            Row {
                width: parent.width; spacing: 8
                Text { text: "WiFi"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.title; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                Item { width: parent.width - 120; height: 1 }
                Rectangle {
                    width: 44; height: 24; radius: 12
                    color: Network.wifiEnabled ? Color.success : Color.divider
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle { x: Network.wifiEnabled ? 22 : 2; y: 2; width: 20; height: 20; radius: 10; color: Color.text; Behavior on x { Anim { type: Anim.FastEffects } } }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Network.toggleWifi() }
                }
            }

            Rectangle {
                visible: root.pendingPasswordSsid !== ""
                width: parent.width; height: 120; radius: 6; color: Color.divider
                Column {
                    anchors.fill: parent; anchors.margins: 12; spacing: 8
                    Text { text: "Connect to " + root.pendingPasswordSsid; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.heading; font.bold: true; elide: Text.ElideRight; width: parent.width }
                    Rectangle {
                        width: parent.width; height: 32; radius: 4; color: Color.background
                        TextInput {
                            id: pwInput; anchors.fill: parent; anchors.margins: 6
                            color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body
                            echoMode: TextInput.Password; clip: true; focus: root.pendingPasswordSsid !== ""
                            Keys.onReturnPressed: { Network.connect(root.pendingPasswordSsid, text); root.pendingPasswordSsid = ""; text = "" }
                        }
                    }
                    Row {
                        spacing: 8
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
                    }
                }
            }

            PanelSectionHeader { text: "NETWORKS"; foreground: Color.text }
        }

        Rectangle {
            id: networkList
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: headerColumn.bottom
            anchors.bottom: scanButton.top; anchors.margins: 14
            color: Color.surface; radius: 6; clip: true

            ListView {
                id: listView
                anchors.fill: parent; anchors.margins: 4
                model: Network.availableNetworks
                currentIndex: root.networkIndex
                highlightFollowsCurrentItem: true
                highlight: Rectangle { color: Color.divider; radius: 6 }

                delegate: Rectangle {
                    width: listView.width; height: 40; radius: 6; color: "transparent"

                    Row {
                        anchors.fill: parent; anchors.margins: 8; spacing: 8
                        Text { text: Icons.signalIcon(modelData.signal); color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.title; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: modelData.ssid; color: modelData.connected ? Color.success : Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body; font.bold: modelData.connected; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 80; elide: Text.ElideRight }
                        Text { text: modelData.security !== "Open" && modelData.security !== "Unknown" ? Icons.lock : ""; color: Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.body; anchors.verticalCenter: parent.verticalCenter }
                    }

                    MouseArea {
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onPositionChanged: { root.cursorActive = true; root.networkIndex = index; listView.currentIndex = index }
                        onClicked: root.selectNetwork(index)
                    }
                }
            }
        }

        Rectangle {
            id: scanButton
            anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
            anchors.margins: 14; height: 32; radius: 6
            color: scanArea.containsMouse ? Color.divider : "transparent"

            Behavior on color {
                CAnim { animType: Anim.FastEffects }
            }

            Row { anchors.centerIn: parent; spacing: 6
                Text { text: Icons.refresh; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body }
                Text { text: "Scan"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body }
            }
            MouseArea { id: scanArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Network.scanNetworks() }
        }
    }
}
