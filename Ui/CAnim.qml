// ColorAnimation primitive — wraps ColorAnimation with semantic easing.
// Uses slow-effects duration and bezier curve by default for smooth color transitions.
import QtQuick
import "../Commons"

ColorAnimation {
    id: root

    property int animType: Anim.DefaultEffects

    duration: {
        var d = Style.anim
        if (animType >= Anim.FastEffects && animType <= Anim.SlowEffects) {
            var effects = [d.expressiveFastEffects, d.expressiveDefaultEffects, d.expressiveSlowEffects]
            return effects[animType - Anim.FastEffects]
        }
        return d.expressiveDefaultEffects
    }

    function _applyCurve() {
        var c = Style.anim.expressiveDefaultEffectsCurve
        if (animType === Anim.FastEffects) {
            c = Style.anim.expressiveFastEffectsCurve
        } else if (animType === Anim.SlowEffects) {
            c = Style.anim.expressiveSlowEffectsCurve
        }
        if (c && c.length === 4) {
            easing.type = Easing.BezierSpline
            easing.bezierCurve = c
        }
    }

    onAnimTypeChanged: _applyCurve()
    Component.onCompleted: _applyCurve()
}
