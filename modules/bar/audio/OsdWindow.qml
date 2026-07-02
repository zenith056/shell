// Combined OSD popup — volume and brightness OSD.
// Anchored below the bar, handles side-by-side or centered layout.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../Commons"
import "../../../services"
import "../../../utils"
import "../../../Ui"

Item {
    id: osdRoot

    // Reference to the main bar window to obtain correct screen dimensions
    property PanelWindow barWindow: null

    readonly property bool audioActive: OsdControl.audioShowing
    readonly property bool brightnessActive: OsdControl.brightnessShowing
    readonly property bool anyActive: audioActive || brightnessActive

    onAnyActiveChanged: {
        if (anyActive) {
            if (barWindow) {
                // Anchor popup to the active bar window, positioned 8px below it
                osdPopup.anchor.window = barWindow
                osdPopup.anchor.rect = Qt.rect(
                    barWindow.width / 2 - osdPopup.implicitWidth / 2,
                    barWindow.height + 8,
                    osdPopup.implicitWidth,
                    osdPopup.implicitHeight
                )
            }
            osdPopup.visible = true
            enterAnim.start()
        } else {
            exitAnim.start()
        }
    }

    SequentialAnimation {
        id: enterAnim
        ParallelAnimation {
            Anim { target: containerRow; property: "opacity"; from: 0; to: 1; type: Anim.DefaultSpatial }
            Anim { target: rowTranslate; property: "y"; from: -30; to: 0; type: Anim.DefaultSpatial }
            Anim { target: containerRow; property: "scale"; from: 0.8; to: 1; type: Anim.DefaultSpatial }
        }
    }

    SequentialAnimation {
        id: exitAnim
        ParallelAnimation {
            Anim { target: containerRow; property: "opacity"; from: 1; to: 0; type: Anim.DefaultSpatial }
            Anim { target: rowTranslate; property: "y"; from: 0; to: -30; type: Anim.DefaultSpatial }
            Anim { target: containerRow; property: "scale"; from: 1; to: 0.8; type: Anim.DefaultSpatial }
        }
        ScriptAction { script: osdPopup.visible = false }
    }

    PopupWindow {
        id: osdPopup
        visible: false
        color: "transparent"
        
        // Fixed window dimensions to avoid Wayland window resize lags
        implicitWidth: 600
        implicitHeight: 38
        grabFocus: false

        Item {
            anchors.fill: parent

            Row {
                id: containerRow
                height: parent.height // Explicitly set height to avoid circular layout dependencies
                anchors.centerIn: parent
                opacity: 0
                scale: 0.8
                
                // Animate spacing dynamically: 12 when both are active, 0 when single
                spacing: (audioActive && brightnessActive) ? 12 : 0

                // Use Translate transform to animate Y offset smoothly without conflicting with anchors
                transform: Translate {
                    id: rowTranslate
                    y: -30
                }

                Behavior on spacing {
                    NumberAnimation {
                        duration: Style.anim.expressiveSlowSpatial
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Style.anim.expressiveSlowSpatialCurve
                    }
                }

                Behavior on scale {
                    Anim { type: Anim.DefaultSpatial }
                }

                // Audio OSD Card (Left)
                Rectangle {
                    id: audioCard
                    width: audioActive ? 280 : 0
                    height: parent.height
                    color: Color.background
                    radius: 12
                    opacity: audioActive ? 1 : 0
                    clip: true // Mask contents as card collapses or expands

                    Behavior on width {
                        NumberAnimation {
                            duration: Style.anim.expressiveSlowSpatial
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Style.anim.expressiveSlowSpatialCurve
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Style.anim.expressiveSlowEffects
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Style.anim.expressiveSlowEffectsCurve
                        }
                    }

                    RowLayout {
                        width: 264 // 280 - Style.spacing.lg * 2
                        height: parent.height
                        anchors.left: parent.left
                        anchors.leftMargin: Style.spacing.lg
                        spacing: Style.spacing.lg

                        Text {
                            text: Icons.volumeIcon(Audio.muted, Audio.volume)
                            color: Audio.muted ? Color.lowBattery : Color.text
                            font.family: Style.font.family
                            font.pixelSize: Style.font.title
                            Layout.alignment: Qt.AlignVCenter

                            Behavior on color { CAnim { animType: Anim.FastEffects } }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 4
                            Layout.alignment: Qt.AlignVCenter
                            color: Color.divider
                            radius: 2

                            Rectangle {
                                width: parent.width * Audio.volume
                                height: parent.height
                                color: Audio.muted ? Color.lowBattery : Color.text
                                radius: 2

                                Behavior on width { Anim { type: Anim.DefaultSpatial } }
                                Behavior on color { CAnim { animType: Anim.FastEffects } }
                            }
                        }

                        Text {
                            text: Audio.muted ? "Mute" : Math.round(Audio.volume * 100)
                            color: Audio.muted ? Color.lowBattery : Color.text
                            font.family: Style.font.family
                            font.pixelSize: Style.font.bodySmall
                            font.bold: true
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: 20

                            Behavior on color { CAnim { animType: Anim.FastEffects } }
                        }
                    }
                }

                // Brightness OSD Card (Right)
                Rectangle {
                    id: brightnessCard
                    width: brightnessActive ? 280 : 0
                    height: parent.height
                    color: Color.background
                    radius: 12
                    opacity: brightnessActive ? 1 : 0
                    clip: true // Mask contents as card collapses or expands

                    Behavior on width {
                        NumberAnimation {
                            duration: Style.anim.expressiveSlowSpatial
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Style.anim.expressiveSlowSpatialCurve
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Style.anim.expressiveSlowEffects
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Style.anim.expressiveSlowEffectsCurve
                        }
                    }

                    RowLayout {
                        width: 264 // 280 - Style.spacing.lg * 2
                        height: parent.height
                        anchors.left: parent.left
                        anchors.leftMargin: Style.spacing.lg
                        spacing: Style.spacing.lg

                        Text {
                            text: Icons.brightness
                            color: Color.text
                            font.family: Style.font.family
                            font.pixelSize: Style.font.title
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 4
                            Layout.alignment: Qt.AlignVCenter
                            color: Color.divider
                            radius: 2

                            Rectangle {
                                width: parent.width * Brightness.level
                                height: parent.height
                                color: Color.text
                                radius: 2

                                Behavior on width { Anim { type: Anim.DefaultSpatial } }
                            }
                        }

                        Text {
                            text: Math.round(Brightness.level * 100)
                            color: Color.text
                            font.family: Style.font.family
                            font.pixelSize: Style.font.bodySmall
                            font.bold: true
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: 20
                        }
                    }
                }
            }
        }
    }
}
