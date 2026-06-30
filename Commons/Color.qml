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
    property color divider: "#333333"          // Subtle divider lines
    property color activeWorkspace: "#ffffff"  // Active workspace indicator
    property color inactiveWorkspace: "#666666" // Inactive workspace indicator
    property color success: "#4ade80"          // Green for positive states (charging)
}