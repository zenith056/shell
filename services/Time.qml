// Time service singleton.
// Provides a live clock that updates reactively using SystemClock.
// Supports 12-hour and 24-hour format.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // Toggle between 24h and 12h format
    property bool is24Hour: true

    // System clock source using Minute precision to minimize updates
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // Reactive time and date properties
    readonly property string time: formattedTime()

    // Returns formatted time based on current format setting
    function formattedTime(): string {
        if (is24Hour) {
            return Qt.formatDateTime(clock.date, "HH:mm")
        }
        return Qt.formatDateTime(clock.date, "h:mm AP")
    }

    // Returns expanded date for click display (e.g., "Monday - 06/28/26")
    function expandedDate(): string {
        return Qt.formatDateTime(clock.date, "dddd - MM/dd/yy")
    }
}
