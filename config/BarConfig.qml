// Bar appearance configuration singleton.
// Controls height, position, fonts, and which modules are displayed.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property int height: 32                                       // Bar height in pixels
    property string position: "top"                               // Bar position: "top" or "bottom"
    property color backgroundColor: Colors.background             // Background color from palette
    property color textColor: Colors.text                         // Text color from palette
    property color accentColor: Colors.accent                     // Accent color from palette
    property real radius: 0                                       // Corner radius (0 = sharp)
    property string fontFamily: "FiraCode Nerd Font"              // Font family for all bar text
    property real fontSize: 14                                    // Font size in pixels
    property var modules: ["clock", "workspaces", "battery", "network"]  // Active bar modules
}
