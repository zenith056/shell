// Application launcher popup.
// Shows a searchable list of installed applications.
// Uses PanelWindow with WlrKeyboardFocus.Exclusive for native keyboard focus.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../Commons"
import "../../../services"

PanelWindow {
    id: launcherPopup

    property int selectedIndex: 0
    property var filteredApps: []
    property int filteredCount: 0

    implicitWidth: 400
    implicitHeight: 500
    color: "transparent"
    visible: LauncherState.isOpen
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "quickshell-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: LauncherState.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }

    onVisibleChanged: {
        if (!visible && LauncherState.isOpen) LauncherState.isOpen = false;
        if (visible) {
            filterApps("");
            searchBar.clear();
            selectedIndex = 0;
            Qt.callLater(() => { if (visible) searchBar.input.forceActiveFocus(); });
        }
    }

    Timer {
        interval: 200; repeat: true; running: true
        onTriggered: {
            if (DesktopEntries.applications.values.length > 0) {
                filterApps("");
                stop();
            }
        }
    }

    Component.onCompleted: {
        if (DesktopEntries.applications.values.length > 0) filterApps("");
    }

    function filterApps(query: string): void {
        var all = DesktopEntries.applications.values;
        var result = [];
        var q = query.toLowerCase();
        for (var i = 0; i < all.length; i++) {
            var app = all[i];
            if (!app || !app.name || AppLauncherService.isExcluded(app)) continue;
            if (q !== "") {
                var nm = app.name.toLowerCase().includes(q);
                var cm = app.comment ? app.comment.toLowerCase().includes(q) : false;
                var gn = app.genericName ? app.genericName.toLowerCase().includes(q) : false;
                if (!nm && !cm && !gn) continue;
            }
            result.push(app);
        }
        result.sort((a, b) => a.name.localeCompare(b.name));
        filteredApps = result;
        filteredCount = result.length;
    }

    function moveSelection(delta: int): void {
        var ni = selectedIndex + delta;
        if (ni >= 0 && ni < filteredCount) {
            selectedIndex = ni;
            appList.currentIndex = ni;
            appList.positionViewAtIndex(ni, ListView.Contain);
        }
    }

    function launchSelected(): void {
        if (selectedIndex >= 0 && selectedIndex < filteredCount) {
            filteredApps[selectedIndex].execute();
            close();
        }
    }

    function close(): void { LauncherState.isOpen = false; }

    MouseArea { anchors.fill: parent; onClicked: launcherPopup.close() }

    Rectangle {
        id: card
        property real cardWidth: 400
        property real cardHeight: 500

        x: {
            var btn = LauncherState.anchorButtonItem;
            var win = LauncherState.anchorWindow;
            if (!btn || !win) return 8;
            var pos = btn.mapToItem(win.contentItem, 0, 0);
            return Math.max(8, Math.min(pos.x, parent.width - cardWidth - 8));
        }
        y: {
            var win = LauncherState.anchorWindow;
            if (!win) return 40;
            return win.height + 4;
        }
        width: cardWidth; height: cardHeight
        color: Color.background; radius: 8

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 12

            LauncherSearchBar {
                id: searchBar
                Layout.fillWidth: true
                onSearchChanged: { filterApps(query); selectedIndex = 0; }
                onEscapePressed: launcherPopup.close()
                input.Keys.onUpPressed: launcherPopup.moveSelection(-1)
                input.Keys.onDownPressed: launcherPopup.moveSelection(1)
                input.Keys.onReturnPressed: launcherPopup.launchSelected()
                input.Keys.onEnterPressed: launcherPopup.launchSelected()
            }

            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: Color.surface; radius: 8; clip: true

                ListView {
                    id: appList
                    anchors.fill: parent; anchors.margins: 8
                    model: filteredApps; currentIndex: selectedIndex
                    highlight: Rectangle { color: Color.divider; radius: 6 }
                    highlightFollowsCurrentItem: false

                    delegate: LauncherAppDelegate {
                        appData: modelData
                        isSelected: index === selectedIndex
                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { selectedIndex = index; launchSelected(); }
                            onEntered: { selectedIndex = index; appList.currentIndex = index; }
                        }
                    }
                }
            }

            Text {
                text: filteredCount + " applications"
                color: Color.textMuted; font.family: Style.font.family; font.pixelSize: Style.font.caption
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
