// Audio control popup — PanelWindow with keyboard focus.
// Shows MPRIS media controls, audio output/input selectors, and volume slider.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import "../../../Commons"
import "../../../services"
import "../../../utils"
import "../../../Ui"

PanelWindow {
    id: root

    property bool isOpen: PopupControl.isOpen("audio")
    property var activePlayer: null
    readonly property var audioSinks: {
        var devs = Pipewire.nodes.values
        if (!devs) return []
        var sinks = []
        for (var i = 0; i < devs.length; i++) {
            var n = devs[i]
            if (n.isSink && !n.isStream && n.name && n.name.indexOf(".monitor") === -1) {
                var isDefault = Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.name === n.name
                sinks.push({
                    name: n.name,
                    description: n.description || n.name,
                    isDefault: isDefault
                })
            }
        }
        sinks.sort(function(a, b) {
            if (a.isDefault && !b.isDefault) return -1
            if (!a.isDefault && b.isDefault) return 1
            return 0
        })
        return sinks
    }
    property var audioSources: []
    property bool _closing: false
    property bool outputsExpanded: false

    visible: isOpen
    implicitWidth: 400
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "audio-popup"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors { top: false; bottom: true; left: true; right: true }
    implicitHeight: screen ? screen.height - BarConfig.height : 1000
    color: "transparent"

    onIsOpenChanged: {
        if (isOpen) {
            outputsExpanded = false
            refreshAudioDevices()
            _closing = false
            enterAnim.restart()
            Qt.callLater(() => card.forceActiveFocus())
        } else {
            exitAnim.restart()
        }
    }

    // Update anchor to the audio indicator when the audio popup opens via IPC
    onVisibleChanged: {
        if (visible && PopupControl.audioIndicator) {
            PopupControl.updateAnchor(PopupControl.audioIndicator)
        }
    }

    // Find the active MPRIS player
    function findActivePlayer() {
        var players = Mpris.players.values
        for (var i = 0; i < players.length; i++) {
            if (players[i].isPlaying) return players[i]
        }
        // No playing player, return first if available
        return players.length > 0 ? players[0] : null
    }

    // Refresh audio devices list
    function refreshAudioDevices() {}

    // Find active sink name from the sinks list or fallback to Audio.sinkName
    function getActiveSinkName() {
        for (var i = 0; i < audioSinks.length; i++) {
            if (audioSinks[i].isDefault) return audioSinks[i].description
        }
        return Audio.sinkName || "No device"
    }

    // Switch default sink
    function switchSink(sinkName) {
        _switchProc.command = ["pactl", "set-default-sink", sinkName]
        _switchProc.running = true
    }

    // Switch default source
    function switchSource(sourceName) {
        _switchProc.command = ["pactl", "set-default-source", sourceName]
        _switchProc.running = true
    }

    // Process for switching default devices
    Process {
        id: _switchProc
        onRunningChanged: {
            if (!running) {
                refreshAudioDevices()
            }
        }
    }

    // Timer to update MPRIS position for progress bar
    Timer {
        id: posTimer
        interval: 1000
        repeat: true
        running: activePlayer !== null && activePlayer.isPlaying
        onTriggered: activePlayer.positionChanged()
    }



    // Process for getting sources
    Process {
        id: _sourcesProc
        running: false
        onRunningChanged: {
            if (!running) {
                var output = _sourcesCollector.text
                var lines = output.split("\n")
                var sources = []
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line.length > 0) {
                        var parts = line.split("\t")
                        if (parts.length >= 2) {
                            sources.push({
                                name: parts[1],
                                description: parts.length >= 3 ? parts[2] : parts[1]
                            })
                        }
                    }
                }
                root.audioSources = sources
            }
        }
        stdout: StdioCollector {
            id: _sourcesCollector
        }
    }

    Component.onCompleted: {
        refreshAudioDevices()
        activePlayer = findActivePlayer()
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
        width: 380
        height: root.outputsExpanded ? 600 : (root.activePlayer !== null ? 370 : 240)
        
        Behavior on height {
            NumberAnimation {
                duration: Style.anim.expressiveDefaultSpatial
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Style.anim.expressiveDefaultSpatialCurve
            }
        }
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

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // Header
            PopupHeader {
                icon: Icons.volumeIcon(Audio.muted, Audio.volume)
                iconColor: Audio.muted ? Color.lowBattery : Color.text
                title: "Audio"
                subtitle: getActiveSinkName()
                Layout.fillWidth: true
            }

            PanelSeparator { foreground: Color.text }

            // Volume control (Slider Row)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: Icons.volumeIcon(Audio.muted, Audio.volume)
                    color: Color.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.title
                    Layout.alignment: Qt.AlignVCenter
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    radius: 4
                    color: Color.divider
                    Rectangle {
                        width: parent.width * Audio.volume
                        height: parent.height
                        radius: 4
                        color: Color.text
                    }
                    MouseArea {
                        id: volMouseArea
                        anchors.fill: parent
                        
                        function updateVolume(mouse) {
                            var clampedX = Math.max(0, Math.min(width, mouse.x))
                            var newVol = clampedX / width
                            Audio.setVolume(newVol)
                        }
                        
                        onPressed: updateVolume(mouse)
                        onPositionChanged: {
                            if (pressed) {
                                updateVolume(mouse)
                            }
                        }
                    }
                }
                Text {
                    text: Math.round(Audio.volume * 100)
                    color: Color.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            // Mute Switch (Toggle Row)
            PopupToggleRow {
                text: "Mute Output"
                checked: Audio.muted
                onClicked: Audio.toggleMute()
                Layout.fillWidth: true
            }

            // MPRIS Player section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: activePlayer !== null

                PanelSectionHeader { text: "MEDIA PLAYER"; foreground: Color.text }

                // Album art + track info
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // Album art
                    Rectangle {
                        width: 56; height: 56; radius: 6; color: Color.surface
                        clip: true
                        visible: activePlayer && activePlayer.trackArtUrl !== ""
                        Image {
                            anchors.fill: parent
                            source: activePlayer ? activePlayer.trackArtUrl : ""
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                    // Fallback icon when no art
                    Rectangle {
                        width: 56; height: 56; radius: 6; color: Color.surface
                        visible: !activePlayer || activePlayer.trackArtUrl === ""
                        Text {
                            anchors.centerIn: parent
                            text: Icons.volumeHigh
                            color: Color.textMuted
                            font.family: Style.font.family
                            font.pixelSize: Style.font.iconLarge
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: activePlayer ? (activePlayer.trackTitle || "Unknown Title") : ""
                            color: Color.text
                            font.family: Style.font.family
                            font.pixelSize: Style.font.subtitle
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: activePlayer ? (activePlayer.trackArtist || "Unknown Artist") : ""
                            color: Color.textMuted
                            font.family: Style.font.family
                            font.pixelSize: Style.font.body
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                // Progress Bar
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: _formatTime(activePlayer ? activePlayer.position : 0)
                        color: Color.textMuted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 12
                        
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 4
                            radius: 2
                            color: Color.divider
                            
                            Rectangle {
                                width: {
                                    if (!activePlayer || isNaN(activePlayer.position) || isNaN(activePlayer.length) || activePlayer.length <= 0) {
                                        return 0
                                    }
                                    var pos = activePlayer.position
                                    var len = activePlayer.length
                                    if (pos > 86400 || len > 86400) return 0
                                    var fraction = Math.max(0, Math.min(1, pos / len))
                                    return parent.width * fraction
                                }
                                height: parent.height
                                radius: 2
                                color: Color.text
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            
                            function updatePosition(mouse) {
                                if (activePlayer && activePlayer.length > 0 && activePlayer.length <= 86400) {
                                    var clampedX = Math.max(0, Math.min(width, mouse.x))
                                    var fraction = clampedX / width
                                    var newPos = fraction * activePlayer.length
                                    activePlayer.position = newPos
                                }
                            }
                            
                            onPressed: updatePosition(mouse)
                            onPositionChanged: {
                                if (pressed) {
                                    updatePosition(mouse)
                                }
                            }
                        }
                    }
                    Text {
                        text: _formatTime(activePlayer ? activePlayer.length : 0)
                        color: Color.textMuted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // Playback Controls
                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12
                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: prevArea.containsMouse ? Color.divider : "transparent"
                        Text { anchors.centerIn: parent; text: Icons.skipBack; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body }
                        MouseArea { id: prevArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: activePlayer && activePlayer.previous() }
                    }
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: playArea.containsMouse ? Color.divider : "transparent"
                        Text { anchors.centerIn: parent; text: activePlayer && activePlayer.isPlaying ? Icons.mute : Icons.unmute; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.title }
                        MouseArea { id: playArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: activePlayer && activePlayer.togglePlaying() }
                    }
                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: nextArea.containsMouse ? Color.divider : "transparent"
                        Text { anchors.centerIn: parent; text: Icons.skipForward; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.body }
                        MouseArea { id: nextArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: activePlayer && activePlayer.next() }
                    }
                }
            }

            PanelSeparator { foreground: Color.text; visible: activePlayer !== null }

            // Output Devices Section
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                
                RowLayout {
                    anchors.fill: parent
                    spacing: 8
                    
                    PanelSectionHeader {
                        text: "OUTPUT DEVICES"
                        foreground: Color.text
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: root.outputsExpanded ? "\uf106" : "\uf107"
                        color: Color.textMuted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.title
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.outputsExpanded = !root.outputsExpanded
                }
            }

            // Scrollable Output Devices List Box
            PopupListBox {
                visible: root.outputsExpanded || card.height > (root.activePlayer !== null ? 385 : 255)
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: sinksListView
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 4
                    model: root.audioSinks
                    clip: true
                    highlight: Rectangle { color: Color.divider; radius: 6 }
                    
                    delegate: Rectangle {
                        width: sinksListView.width
                        height: 36
                        radius: 6
                        color: sinkArea.containsMouse ? Color.hover : "transparent"
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 8
                            Text {
                                text: Icons.volumeHigh
                                color: modelData.isDefault ? Color.success : "transparent"
                                font.family: Style.font.family
                                font.pixelSize: Style.font.body
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: modelData.description
                                color: modelData.isDefault ? Color.success : Color.text
                                font.family: Style.font.family
                                font.pixelSize: Style.font.body
                                font.bold: modelData.isDefault
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                width: parent.width - 40
                            }
                        }
                        
                        MouseArea {
                            id: sinkArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: switchSink(modelData.name)
                        }
                    }
                }
            }

            // Refresh Button
            PopupActionButton {
                visible: root.outputsExpanded || card.height > (root.activePlayer !== null ? 385 : 255)
                icon: Icons.refresh
                text: "Refresh"
                onClicked: refreshAudioDevices()
                Layout.fillWidth: true
            }
        }
    }

    function _formatTime(seconds: real): string {
        if (isNaN(seconds) || !isFinite(seconds) || seconds < 0 || seconds > 86400) {
            return "0:00"
        }
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
