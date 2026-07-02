// Popup control singleton.
// Mediates between bar indicators and top-level PanelWindow popups.
// Stores the anchor position so popups appear below their trigger icon.
pragma Singleton
import Quickshell
import QtQuick

Item {
    id: root

    property string activePopup: ""
    property real anchorX: 0
    property real anchorWidth: 0

    // Stored references to bar indicators for IPC-triggered popups
    property Item bluetoothIndicator: null
    property Item networkIndicator: null
    property Item batteryIndicator: null
    property Item audioIndicator: null

    property bool cardHovered: false
    property bool indicatorHovered: false

    Timer {
        id: closeTimer
        interval: 150 // 150ms delay is responsive but allows crossing the gap
        onTriggered: {
            if (!cardHovered && !indicatorHovered) {
                close()
            }
        }
    }

    function checkClose() {
        closeTimer.restart()
    }

    function open(name, triggerItem) {
        if (triggerItem) updateAnchor(triggerItem)
        activePopup = name
        closeTimer.stop()
    }

    function close() {
        activePopup = ""
    }

    function toggle(name, triggerItem) {
        if (activePopup === name) {
            activePopup = ""
        } else {
            if (triggerItem) {
                updateAnchor(triggerItem)
            } else {
                // IPC call without trigger — look up stored indicator
                var ind = _getIndicator(name)
                if (ind) updateAnchor(ind)
            }
            activePopup = name
        }
    }

    function isOpen(name) {
        return activePopup === name
    }

    function updateAnchor(item) {
        var window = item.Window.window
        if (!window) return
        var pos = item.mapToItem(window.contentItem, 0, 0)
        anchorX = pos.x
        anchorWidth = item.width
    }

    function _getIndicator(name) {
        if (name === "bluetooth") return bluetoothIndicator
        if (name === "network") return networkIndicator
        if (name === "battery") return batteryIndicator
        if (name === "audio") return audioIndicator
        return null
    }
}
