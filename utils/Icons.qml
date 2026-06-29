// Centralized icon mappings singleton.
// All Nerd Font glyphs in one place for easy reusability.
pragma Singleton
import QtQuick

QtObject {
    id: root

    // Audio icons
    readonly property string volumeOff: ""     // nf-fa-volume_off
    readonly property string volumeDown: ""    // nf-fa-volume_down
    readonly property string volumeLow: ""     // nf-fa-volume_low
    readonly property string volumeHigh: ""    // nf-fa-volume_high
    readonly property string mute: ""          // nf-fa-pause
    readonly property string unmute: ""        // nf-fa-play
    readonly property string plus: ""          // nf-fa-plus
    readonly property string minus: ""         // nf-fa-minus

    // Battery icons
    readonly property string batteryOutline: ""   // nf-md-battery_outline
    readonly property string batteryCharging: ""  // nf-md-battery_charging
    readonly property string battery: ""          // nf-md-battery
    readonly property string battery60: ""        // nf-md-battery_60
    readonly property string battery40: ""        // nf-md-battery_40
    readonly property string battery20: ""        // nf-md-battery_20
    readonly property string heart: ""            // nf-fa-heart
    readonly property string laptop: ""           // nf-fa-laptop

    // Power profile icons
    readonly property string powerSaver: ""    // nf-fa-bolt
    readonly property string balanced: ""      // nf-fa-toggle-on
    readonly property string performance: ""   // nf-fa-rocket

    // Network icons
    readonly property string wifi: ""          // nf-fa-wifi
    readonly property string wifiWeak: ""      // nf-fa-signal
    readonly property string wifiMedium: ""    // nf-fa-signal-1
    readonly property string wifiStrong: ""    // nf-fa-signal-2
    readonly property string wifiNone: ""      // nf-fa-signal-3
    readonly property string ethernet: ""      // nf-fa-globe

    // Returns volume icon based on level
    function volumeIcon(muted: bool, volume: real): string {
        if (muted || volume === 0) return volumeOff;
        if (volume < 0.33) return volumeDown;
        if (volume < 0.66) return volumeLow;
        return volumeHigh;
    }

    // Returns battery icon based on level
    function batteryIcon(available: bool, charging: bool, percentage: real): string {
        if (!available) return batteryOutline;
        if (charging) return batteryCharging;
        if (percentage > 0.75) return battery;
        if (percentage > 0.50) return battery60;
        if (percentage > 0.25) return battery40;
        return battery20;
    }
}
