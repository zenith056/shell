// Lock screen plugin — custom Wayland session lock.
// Uses WlSessionLock for secure session locking and PamContext for authentication.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../../Commons"
import "../../Ui"

Scope {
    id: root

    property bool isLocked: false
    property bool animateUnlock: false
    property string errorMessage: ""

    // Initiate locking sequence and start PAM session
    function lock() {
        isLocked = true
        animateUnlock = false
        lockObject.locked = true
        errorMessage = ""
    }

    // Initiate unlocking sequence (triggers exit animation first)
    function unlock() {
        animateUnlock = true
    }

    // Timer to clear the error message after 2 seconds
    Timer {
        id: errorMessageTimer
        interval: 2000
        onTriggered: root.errorMessage = ""
    }

    // Wayland session lock manager
    WlSessionLock {
        id: lockObject

        // Session lock surface covering the screen (opaque for security compatibility)
        surface: WlSessionLockSurface {
            id: lockSurface
            color: Color.background

            // FocusScope to capture all keyboard inputs securely
            FocusScope {
                anchors.fill: parent
                focus: true

                // Connect to root to listen for the unlock animation trigger
                Connections {
                    target: root
                    ignoreUnknownSignals: true
                    function onAnimateUnlockChanged() {
                        if (root.animateUnlock) {
                            fadeOutAnim.start()
                        }
                    }
                }

                // PAM authentication context declared inside FocusScope for direct UI access
                PamContext {
                    id: pam
                    config: "vlock"
                    user: Quickshell.env("USER")

                    // Handle PAM authentication lifecycle results
                    onCompleted: function(result) {
                        if (result === PamResult.Success) {
                            root.unlock()
                        } else {
                            root.errorMessage = "INCORRECT PASSWORD"
                            pwInput.text = ""
                            errorMessageTimer.restart()
                            Qt.callLater(pam.start)
                        }
                    }
                }

                // Centered Lock screen UI content layout
                Column {
                    id: contentColumn
                    anchors.centerIn: parent
                    spacing: 16
                    opacity: 0

                    transform: Translate {
                        id: contentTranslate
                        y: 40
                    }

                    // Huge digital clock
                    Text {
                        id: timeText
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Color.text
                        font.family: Style.font.family
                        font.pixelSize: 110
                        font.bold: true
                    }

                    // Elegant date representation
                    Text {
                        id: dateText
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Color.textMuted
                        font.family: Style.font.family
                        font.pixelSize: 20
                        font.letterSpacing: 1
                    }

                    // Spacing divider
                    Item {
                        width: 1
                        height: 16
                    }

                    // Styled password input container
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 280
                        height: 40
                        radius: 6
                        color: Color.surface

                        // Custom placeholder text
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            verticalAlignment: Text.AlignVCenter
                            text: "Enter Password..."
                            color: Color.textMuted
                            font.family: Style.font.family
                            font.pixelSize: 14
                            visible: pwInput.text === ""
                        }

                        // Native TextInput field
                        TextInput {
                            id: pwInput
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            verticalAlignment: Text.AlignVCenter
                            color: Color.text
                            font.family: Style.font.family
                            font.pixelSize: 14
                            echoMode: TextInput.Password
                            focus: true

                            // Submit response on Return key press
                            onAccepted: {
                                if (pam.responseRequired) {
                                    pam.respond(text)
                                }
                            }
                        }
                    }

                    // Dynamic error message label
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.errorMessage
                        color: Color.lowBattery
                        font.family: Style.font.family
                        font.pixelSize: 12
                        font.bold: true
                        font.letterSpacing: 1
                        visible: root.errorMessage !== ""
                    }

                    // Spacing divider
                    Item {
                        width: 1
                        height: 8
                    }

                    // Interactive instructions to unlock
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "PRESS ENTER TO UNLOCK"
                        color: Color.textMuted
                        font.family: Style.font.family
                        font.pixelSize: 11
                        font.letterSpacing: 2
                        font.bold: true
                    }
                }

                // Global mouse blocker and cursor blanker overlay
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.BlankCursor
                    acceptedButtons: Qt.AllButtons
                    onPressed: (mouse) => mouse.accepted = true
                    onReleased: (mouse) => mouse.accepted = true
                    onClicked: (mouse) => mouse.accepted = true
                    onDoubleClicked: (mouse) => mouse.accepted = true
                    onWheel: (wheel) => wheel.accepted = true
                }

                // Helper to update clock texts
                function updateTime() {
                    var now = new Date()
                    var h = now.getHours().toString().padStart(2, "0")
                    var m = now.getMinutes().toString().padStart(2, "0")
                    timeText.text = h + ":" + m

                    var days = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
                    var months = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
                                  "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
                    dateText.text = days[now.getDay()] + ", " + months[now.getMonth()] + " " + now.getDate()
                }

                // Periodic timer to keep clock updated
                Timer {
                    running: root.isLocked
                    interval: 1000
                    repeat: true
                    onTriggered: parent.updateTime()
                }

                Component.onCompleted: {
                    updateTime()
                    fadeInAnim.start()
                    pwInput.forceActiveFocus()
                    pam.start()
                }

                // Smooth fade-in animation on lock screen creation
                ParallelAnimation {
                    id: fadeInAnim
                    Anim { target: contentColumn; property: "opacity"; from: 0; to: 1; type: Anim.DefaultSpatial }
                    Anim { target: contentTranslate; property: "y"; from: 40; to: 0; type: Anim.DefaultSpatial }
                    Anim { target: contentColumn; property: "scale"; from: 0.95; to: 1; type: Anim.DefaultSpatial }
                }

                // Smooth fade-out animation on lock screen unlock
                SequentialAnimation {
                    id: fadeOutAnim
                    ParallelAnimation {
                        Anim { target: contentColumn; property: "opacity"; from: 1; to: 0; type: Anim.DefaultSpatial }
                        Anim { target: contentTranslate; property: "y"; from: 0; to: 40; type: Anim.DefaultSpatial }
                        Anim { target: contentColumn; property: "scale"; from: 1; to: 0.95; type: Anim.DefaultSpatial }
                    }
                    ScriptAction {
                        script: {
                            root.isLocked = false
                            lockObject.locked = false
                            root.errorMessage = ""
                        }
                    }
                }
            }
        }
    }
}
