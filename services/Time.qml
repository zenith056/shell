// Time service singleton.
// Provides a live clock that updates every second.
// Supports 12-hour and 24-hour format.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property string time: ""       // Formatted time string (e.g., "14:30" or "2:30 PM")
    property string date: ""       // Formatted date string (e.g., "Mon Jun 28")
    property int hour: 0           // Current hour (0-23)
    property int minute: 0         // Current minute (0-59)
    property bool is24Hour: true   // Toggle between 24h and 12h format

    // Returns formatted time based on current format setting
    function formattedTime(): string {
        if (is24Hour) {
            return Qt.formatDateTime(new Date(), "HH:mm")
        }
        return Qt.formatDateTime(new Date(), "h:mm AP")
    }

    // Returns formatted date (e.g., "Mon Jun 28")
    function formattedDate(): string {
        return Qt.formatDateTime(new Date(), "ddd MMM d")
    }

    // 1-second timer that triggers clock updates
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._update()
    }

    // Internal: refresh all time properties from current system time
    function _update(): void {
        const now = new Date()
        root.hour = now.getHours()
        root.minute = now.getMinutes()
        root.time = formattedTime()
        root.date = formattedDate()
    }
}
