// Lock screen plugin — custom Wayland session lock.
// Uses WlSessionLock for secure session locking.
// Shows time and date with "Press Escape to unlock".
import QtQuick
import Quickshell
import Quickshell.Wayland

WlSessionLock {
    id: lock

    function lock() {
        locked = true
    }

    function unlock() {
        locked = false
    }

    // The surface shown on each screen when locked
    surface: WlSessionLockSurface {
        color: "#000000"

        // Keyboard input for unlock
        Keys.onEscapePressed: lock.unlock()
        Keys.onReturnPressed: lock.unlock()

        // Center content
        Item {
            anchors.centerIn: parent
            width: col.width
            height: col.height

            Column {
                id: col
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                // Time
                Text {
                    id: timeText
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#ffffff"
                    font.family: Style.font.family
                    font.pixelSize: 96
                    font.bold: true
                }

                // Date
                Text {
                    id: dateText
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#999999"
                    font.family: Style.font.family
                    font.pixelSize: 24
                }

                // Unlock hint
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Press Escape to unlock"
                    color: "#666666"
                    font.family: Style.font.family
                    font.pixelSize: 16
                    anchors.topMargin: 40
                }
            }
        }

        // Update time
        function updateTime() {
            var now = new Date()
            var h = now.getHours().toString().padStart(2, "0")
            var m = now.getMinutes().toString().padStart(2, "0")
            timeText.text = h + ":" + m

            var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            var months = ["January", "February", "March", "April", "May", "June",
                          "July", "August", "September", "October", "November", "December"]
            dateText.text = days[now.getDay()] + ", " + months[now.getMonth()] + " " + now.getDate()
        }

        Timer {
            running: lock.locked
            interval: 1000
            repeat: true
            onTriggered: parent.updateTime()
        }

        Component.onCompleted: {
            updateTime()
            forceActiveFocus()
        }
    }
}
