// Global color palette singleton.
// Defines all colors used across the shell theme.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property color background: "#cc000000"   // Semi-transparent black background
    property color surface: "#1a000000"       // Slightly opaque surface overlay
    property color text: "#ffffff"            // Primary white text
    property color textMuted: "#99ffffff"     // Dimmed text for secondary info
    property color accent: "#89b4fa"          // Blue accent color (Catppuccin blue)
}
