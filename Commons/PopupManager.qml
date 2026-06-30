// Singleton that manages popup visibility.
// Ensures only one popup is open at a time.
pragma Singleton
import QtQuick
import Quickshell

QtObject {
    property var openPopups: []

    function registerPopup(popup) {
        if (openPopups.indexOf(popup) === -1)
            openPopups.push(popup);
    }

    function unregisterPopup(popup) {
        var idx = openPopups.indexOf(popup);
        if (idx !== -1) openPopups.splice(idx, 1);
    }

    // Close all popups
    function closeAll() {
        for (var i = openPopups.length - 1; i >= 0; i--) {
            openPopups[i].hide();
        }
    }

    // Close all except the given popup (used before opening one)
    function closeOthers(popup) {
        for (var i = openPopups.length - 1; i >= 0; i--) {
            if (openPopups[i] !== popup)
                openPopups[i].hide();
        }
    }
}
