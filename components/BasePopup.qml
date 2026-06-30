// Base popup component.
// Provides common popup boilerplate: show/hide, positioning, escape key.
// Registers with PopupManager for mutual exclusion.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../Commons"

PopupWindow {
    id: basePopup

    property bool isOpen: false

    visible: isOpen
    grabFocus: true
    color: Color.background

    onVisibleChanged: {
        if (!visible) {
            isOpen = false;
            PopupManager.unregisterPopup(basePopup);
        }
    }

    Keys.onEscapePressed: hide()

    // Position popup below the anchor button and close others
    function show(anchorWindow, anchorButtonItem) {
        PopupManager.closeOthers(basePopup);
        var pos = anchorButtonItem.mapToItem(anchorWindow.contentItem, 0, 0);
        anchor.window = anchorWindow;
        anchor.rect = Qt.rect(
            pos.x + anchorButtonItem.width / 2 - implicitWidth / 2,
            anchorWindow.height,
            implicitWidth,
            implicitHeight
        );
        isOpen = true;
        visible = true;
        PopupManager.registerPopup(basePopup);
    }

    function hide() {
        isOpen = false;
        visible = false;
    }
}
