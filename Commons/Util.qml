// Utility functions for the shell.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // Clamp alpha value between 0 and 1
    function clampAlpha(value) {
        var n = Number(value)
        if (!isFinite(n)) return 1
        return Math.max(0, Math.min(1, n))
    }

    // Apply alpha to a color
    function alpha(color, alphaValue) {
        var c = Qt.color(color)
        return Qt.rgba(c.r, c.g, c.b, clampAlpha(alphaValue))
    }

    // Parse hex color string to color
    function colorFromHex(hexString, fallback) {
        var s = String(hexString || "").replace(/^\s+|\s+$/g, "")
        var hex = s.match(/^#([0-9A-Fa-f]{6})([0-9A-Fa-f]{2})?$/)
        if (!hex) return fallback
        var h = hex[1]
        return Qt.rgba(
            parseInt(h.substr(0, 2), 16) / 255,
            parseInt(h.substr(2, 2), 16) / 255,
            parseInt(h.substr(4, 2), 16) / 255,
            hex[2] ? parseInt(hex[2], 16) / 255 : 1)
    }
}