pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string path: Qt.resolvedUrl("../../shell.json").toString().replace("file://", "")

    FileView {
        path: root.path
        watchChanges: true
        onLoaded: {
            const data = JSON.parse(text())
            root._apply(data)
        }
        Component.onCompleted: reload()
    }

    property var bar: ({})
    property var appearance: ({})

    function _apply(data: var): void {
        if (data.bar) root.bar = data.bar
        if (data.appearance) root.appearance = data.appearance
    }
}
