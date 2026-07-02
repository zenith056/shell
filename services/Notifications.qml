// Notifications service singleton.
// Manages DBus notification server and exposes tracked notifications.
pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    NotificationServer {
        id: server
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        bodyImagesSupported: true
        actionIconsSupported: true
        keepOnReload: true

        // Track incoming notifications so they appear in trackedNotifications
        onNotification: notification => {
            notification.tracked = true
        }
    }

    // Expose the read-only ObjectModel of active notifications
    readonly property alias trackedNotifications: server.trackedNotifications
}
