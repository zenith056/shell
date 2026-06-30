// Centralized icon mappings singleton.
// All Nerd Font glyphs in one place for easy reusability.
pragma Singleton
import QtQuick

QtObject {
    id: root

    // Audio icons
    readonly property string volumeOff: "\ueee8"     // nf-fa-volume_off
    readonly property string volumeDown: "\uf026"    // nf-fa-volume_down
    readonly property string volumeLow: "\uf027"     // nf-fa-volume_low
    readonly property string volumeHigh: "\uf028"    // nf-fa-volume_high
    readonly property string mute: "\uf04c"          // nf-fa-pause
    readonly property string unmute: "\uf04b"        // nf-fa-play
    readonly property string plus: "\uf067"          // nf-fa-plus
    readonly property string minus: "\uf068"         // nf-fa-minus

    // Battery icons
    readonly property string batteryOutline: "\udb80\udc8e"   // nf-md-battery_outline
    readonly property string batteryCharging: "\udb80\udc84"  // nf-md-battery_charging
    readonly property string battery100: "\udb85\udfe2"          // nf-md-battery
    readonly property string battery90: "\udb80\udc82"        // nf-md-battery_90
    readonly property string battery80: "\udb80\udc81"        // nf-md-battery_80
    readonly property string battery70: "\udb80\udc80"        // nf-md-battery_70
    readonly property string battery60: "\udb81\udc44"        // nf-md-battery_60
    readonly property string battery50: "\udb80\udc7e"        // nf-md-battery_50
    readonly property string battery40: "\udb80\udc7d"        // nf-md-battery_40
    readonly property string battery30: "\udb80\udc7c"        // nf-md-battery_30
    readonly property string battery20: "\udb80\udc7b"        // nf-md-battery_20
    readonly property string battery10: "\udb80\udc7a"      // nf-md-battery_empty
    readonly property string heart: "\uf004"            // nf-fa-heart
    readonly property string laptop: "\udb80\udf22"           // nf-fa-laptop

    // Power profile icons
    readonly property string powerSaver: "\udb84\ude0f"    // nf-fa-bolt
    readonly property string balanced: "\uf463"      // nf-fa-toggle-on
    readonly property string performance: "\udb81\udc63"   // nf-fa-rocket

    // Network icons
    readonly property string wifi: "\udb82\udd28"          // nf-md-wifi_strength_4
    readonly property string wifiWeak: "\udb82\udd1f"      // nf-md-wifi_strength_1
    readonly property string wifiMedium: "\udb82\udd22"    // nf-md-wifi_strength_3
    readonly property string wifiStrong: "\udb82\udd28"    // nf-md-wifi_strength_4
    readonly property string wifiNone: "\udb82\udd2d"      // nf-md-wifi_strength_outline
    readonly property string ethernet: "\uef44"      // nf-fa-ethernet

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
        if (percentage > 1.0) return battery100;
        if (percentage > 0.9) return battery100;
        if (percentage > 0.8) return battery90;
        if (percentage > 0.7) return battery80;
        if (percentage > 0.6) return battery70;
        if (percentage > 0.5) return battery60;
        if (percentage > 0.4) return battery50;
        if (percentage > 0.3) return battery40;
        if (percentage > 0.2) return battery30;
        if (percentage > 0.1) return battery20;
        return battery10;
    }
}
