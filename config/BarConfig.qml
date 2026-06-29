pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property int height: 32
    property string position: "top"
    property color backgroundColor: "#cc1e1e2e"
    property color textColor: "#cdd6f4"
    property color accentColor: "#89b4fa"
    property real radius: 0
    property var modules: ["clock", "workspaces", "battery", "network"]
}
