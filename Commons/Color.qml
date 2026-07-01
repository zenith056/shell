// Global color palette singleton.
// Defines all colors used across the shell theme.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // Core palette (black, white, gray)
    property color background: "#000000"       // Opaque black background
    property color surface: "#1a1a1a"          // Surface overlay
    property color text: "#ffffff"             // Primary white text
    property color textMuted: "#999999"        // Dimmed text for secondary info
    property color divider: "#333333"          // Subtle divider lines
    property color foreground: "#ffffff"       // Alias for text (used in Plugins/UI)
    property color muted: "#999999"            // Alias for textMuted
    property color hover: "#2a2a2a"            // Hover state background
    property color overlay: "#1a1a1a"          // Overlay background
    property color border: "#333333"           // Border color

    // Workspace indicators
    property color activeWorkspace: "#ffffff"   // Active workspace indicator
    property color inactiveWorkspace: "#666666" // Inactive workspace indicator

    // Status colors
    property color success: "#4ade80"          // Green for positive states (charging)
    property color lowBattery: "#ef4444"       // Red for low battery warning
    property color accent: "#ffffff"           // Accent (white, matches text)
}
