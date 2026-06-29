pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property string time: ""
    property string date: ""
    property int hour: 0
    property int minute: 0
    property bool is24Hour: true

    function formattedTime(): string {
        if (is24Hour) {
            return Qt.formatDateTime(new Date(), "HH:mm")
        }
        return Qt.formatDateTime(new Date(), "h:mm AP")
    }

    function formattedDate(): string {
        return Qt.formatDateTime(new Date(), "ddd MMM d")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._update()
    }

    function _update(): void {
        const now = new Date()
        root.hour = now.getHours()
        root.minute = now.getMinutes()
        root.time = formattedTime()
        root.date = formattedDate()
    }
}
