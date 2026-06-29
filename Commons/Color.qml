// Global color palette singleton.
// Defines all colors used across the shell theme.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property color background: "#000000"       // Opaque black background
    property color surface: "#1a1a1a"          // Surface overlay
    property color text: "#ffffff"             // Primary white text
    property color textMuted: "#999999"        // Dimmed text for secondary info
    property color accent: "#89b4fa"           // Blue accent color (Catppuccin blue)
    property color success: "#a6e3a1"          // Green for positive states (charging)
    property color error: "#f38ba8"            // Red for negative states (discharging)
    property color divider: "#333333"          // Subtle divider lines
    property color activeWorkspace: "#ffffff"  // Active workspace indicator
    property color inactiveWorkspace: "#666666" // Inactive workspace indicator
}