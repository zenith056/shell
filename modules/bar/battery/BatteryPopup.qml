// Battery popup — PanelWindow with keyboard focus.
// Shows battery info, progress bar, stats, and power profile selector.
// Keyboard: Escape closes, j/k navigates profiles, Enter activates.
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

    property bool isOpen: PopupControl.isOpen("battery")
    property int profileIndex: 0
    property bool cursorActive: false
    property bool _closing: false

    visible: isOpen || _closing
    implicitWidth: 400
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "battery-popup"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors { top: false; bottom: true; left: true; right: true }
    implicitHeight: screen ? screen.height - BarConfig.height : 1000
    color: "transparent"

    onIsOpenChanged: {
        if (isOpen) {
            var idx = PowerProfile.profiles.indexOf(PowerProfile.activeProfile)
            profileIndex = idx >= 0 ? idx : 0
            cursorActive = false
            _closing = false
            enterAnim.restart()
            Qt.callLater(() => card.forceActiveFocus())
        } else {
            exitAnim.restart()
        }
    }

    function selectProfileByDelta(delta) {
        var n = PowerProfile.profiles.length
        if (n === 0) return
        profileIndex = (profileIndex + delta + n) % n
    }

    function activateProfile() {
        if (profileIndex < 0 || profileIndex >= PowerProfile.profiles.length) return
        PowerProfile.setProfile(PowerProfile.profiles[profileIndex])
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
        width: 380; height: column.implicitHeight + 28
        x: Math.max(8, Math.min(PopupControl.anchorX + PopupControl.anchorWidth - width, parent.width - width - 8))
        y: 4
        color: Color.background; radius: 8
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
                selectProfileByDelta(1); event.accepted = true
            } else if (t === "k" || k === Qt.Key_Up) {
                cursorActive = true
                selectProfileByDelta(-1); event.accepted = true
            } else if (k === Qt.Key_Return || k === Qt.Key_Space) {
                if (cursorActive) activateProfile()
                event.accepted = true
            }
        }

        Column {
            id: column
            anchors.fill: parent; anchors.margins: 14
            spacing: 14

            Item {
                width: parent.width
                implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight)

                Text {
                    id: heroIcon
                    text: Icons.batteryIcon(Battery.available, Battery.charging, Battery.percentage)
                    color: Battery.charging ? Color.success : (Battery.percentage <= 0.2 ? Color.lowBattery : Color.text)
                    font.family: Style.font.family; font.pixelSize: Style.font.iconLarge
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    id: heroLabels
                    anchors.left: heroIcon.right; anchors.leftMargin: 14
                    anchors.right: heroPercent.left; anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter; spacing: 2

                    Text { text: "Battery"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.title; font.bold: true; elide: Text.ElideRight; width: parent.width }

                    Text {
                        text: {
                            if (Battery.charging) return "CHARGING"
                            if (Battery.percentage <= 0.2) return "LOW BATTERY"
                            return "DISCHARGING"
                        }
                        color: Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.caption
                        font.bold: true; font.letterSpacing: 1.2; elide: Text.ElideRight; width: parent.width
                    }
                }

                Text {
                    id: heroPercent
                    text: Math.round(Battery.percentage * 100) + "%"
                    color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.large; font.bold: true
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                width: parent.width; implicitHeight: 8
                Rectangle { id: barTrack; anchors.fill: parent; radius: height / 2; color: Qt.rgba(Color.text.r, Color.text.g, Color.text.b, 0.12) }
                Rectangle {
                    anchors.left: barTrack.left; anchors.verticalCenter: barTrack.verticalCenter
                    height: barTrack.height; radius: barTrack.radius
                    color: Battery.charging ? Color.success : (Battery.percentage <= 0.2 ? Color.lowBattery : Color.text)
                    width: Math.max(barTrack.height, barTrack.width * Battery.percentage)
                    Behavior on width { Anim { type: Anim.DefaultEffects } }
                }
            }

            Row {
                width: parent.width; spacing: 20
                Column {
                    width: (parent.width - parent.spacing) / 2; spacing: 4
                    Text { text: "Capacity"; color: Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.caption }
                    Text { text: Battery.energy.toFixed(1) + " / " + Battery.energyCapacity.toFixed(1) + " Wh"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall }
                    Text { text: "Health"; color: Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.caption }
                    Text { text: Math.round(Battery.healthPercentage) + "%"; color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall }
                }
                Column {
                    width: (parent.width - parent.spacing) / 2; spacing: 4
                    Text { text: "Time left"; color: Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.caption }
                    Text {
                        text: {
                            if (Battery.timeToFull > 0) { var h = Math.floor(Battery.timeToFull / 3600); var m = Math.floor((Battery.timeToFull % 3600) / 60); return h + "h " + m + "m" }
                            if (Battery.timeToEmpty > 0) { var h = Math.floor(Battery.timeToEmpty / 3600); var m = Math.floor((Battery.timeToEmpty % 3600) / 60); return h + "h " + m + "m" }
                            return "--"
                        }
                        color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall
                    }
                    Text { text: "Rate"; color: Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.caption }
                    Text {
                        text: { var w = Math.abs(Battery.changeRate).toFixed(1); return (Battery.charging ? "+" : "-") + w + " W" }
                        color: Color.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall
                    }
                }
            }

            PanelSeparator { foreground: Color.text }

            PanelSectionHeader { text: "POWER PROFILE"; foreground: Color.text }

            Row {
                width: parent.width; spacing: 6

                Repeater {
                    model: PowerProfile.profiles

                    Rectangle {
                        required property string modelData
                        required property int index
                        readonly property bool isActive: PowerProfile.activeProfile === modelData
                        readonly property bool isCursor: root.cursorActive && root.profileIndex === index

                        width: (parent.width - parent.parent.spacing * 2) / 3; height: 36
                        color: isActive ? Color.text : (isCursor ? Color.divider : "transparent")
                        radius: 6

                        Behavior on color {
                            CAnim { animType: Anim.FastEffects }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                            color: isActive ? Color.background : Color.text
                            font.family: Style.font.family; font.pixelSize: Style.font.body
                        }

                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onEntered: { root.cursorActive = true; root.profileIndex = index }
                            onClicked: PowerProfile.setProfile(modelData)
                        }
                    }
                }
            }
        }
    }
}
