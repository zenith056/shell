// Application launcher popup
// Shows a searchable list of installed applications.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../Commons"
import "../../../services"
import "../../../Ui"

PanelWindow {
    id: launcherPopup

    property int selectedIndex: 0
    property var filteredApps: []
    property int filteredCount: 0
    property bool _visible: false

    implicitWidth: 400
    color: "transparent"
    visible: _visible
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "quickshell-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: LauncherState.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: false; bottom: true; left: true; right: true }
    implicitHeight: screen ? screen.height - BarConfig.height : 1000

    onVisibleChanged: {
        if (visible) {
            filterApps("");
            searchBar.clear();
            selectedIndex = 0;
            enterAnim.restart()
            Qt.callLater(() => { if (visible) searchBar.input.forceActiveFocus(); });
        }
    }

    Connections {
        target: LauncherState
        function onIsOpenChanged() {
            if (LauncherState.isOpen) {
                _visible = true
            } else if (_visible) {
                exitAnim.restart()
            }
        }
    }

    SequentialAnimation {
        id: enterAnim
        ParallelAnimation {
            Anim { target: card; property: "opacity"; from: 0; to: 1; type: Anim.DefaultEffects }
            Anim { target: cardTranslate; property: "y"; from: -34; to: 0; type: Anim.DefaultSpatial }
            Anim { target: card; property: "scale"; from: 0.95; to: 1; type: Anim.DefaultSpatial }
        }
    }

    SequentialAnimation {
        id: exitAnim
        ParallelAnimation {
            Anim { target: card; property: "opacity"; from: 1; to: 0; type: Anim.DefaultEffects }
            Anim { target: cardTranslate; property: "y"; from: 0; to: -34; type: Anim.DefaultSpatial }
            Anim { target: card; property: "scale"; from: 1; to: 0.95; type: Anim.DefaultSpatial }
        }
        ScriptAction { script: _visible = false }
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

    function close(): void {
        LauncherState.isOpen = false;
    }

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
        y: 4
        width: cardWidth; height: cardHeight
        color: Color.background; radius: 8
        opacity: 0
        transformOrigin: Item.Top

        transform: Translate {
            id: cardTranslate
            y: -34
        }

        HoverHandler {
            id: cardHover
            onHoveredChanged: {
                LauncherState.cardHovered = hovered
                if (!hovered) {
                    LauncherState.checkClose()
                }
            }
        }

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
