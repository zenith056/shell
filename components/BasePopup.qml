// Base popup component.
// Provides common popup boilerplate: show/hide, positioning, escape key.
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

    onVisibleChanged: if (!visible) isOpen = false

    // Standard show: positions popup below the anchor button
    function show(anchorWindow, anchorButtonItem) {
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
    }

    function hide() {
        isOpen = false;
        visible = false;
    }
}