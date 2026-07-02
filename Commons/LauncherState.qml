// Launcher state singleton.
// Mediates communication between launcher button and popup.
pragma Singleton
import QtQuick

Item {
    id: root
    
    property bool isOpen: false
    property Item anchorButtonItem: null
    property Item anchorWindow: null

    property bool cardHovered: false
    property bool indicatorHovered: false

    Timer {
        id: closeTimer
        interval: 150 // 150ms delay is responsive but allows crossing the gap
        onTriggered: {
            if (!cardHovered && !indicatorHovered) {
                hide()
            }
        }
    }

    function checkClose() {
        closeTimer.restart()
    }

    function show(btn: Item, win: Item): void {
        anchorButtonItem = btn;
        anchorWindow = win;
        isOpen = true;
        closeTimer.stop()
    }

    function hide(): void {
        isOpen = false;
    }
}
