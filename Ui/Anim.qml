// Animation primitive — wraps NumberAnimation with semantic types.
// Duration and easing driven by configurable tokens from Style.anim.
import QtQuick
import "../Commons"

NumberAnimation {
    id: root

    enum Type {
        StandardSmall = 0,
        Standard,
        StandardLarge,
        StandardExtraLarge,
        EmphasizedSmall,
        Emphasized,
        EmphasizedLarge,
        EmphasizedExtraLarge,
        FastSpatial,
        DefaultSpatial,
        SlowSpatial,
        FastEffects,
        DefaultEffects,
        SlowEffects
    }

    property int type: Anim.DefaultSpatial

    duration: {
        if (type < Anim.StandardSmall || type > Anim.SlowEffects)
            return Style.anim.normal;

        if (type === Anim.FastSpatial)
            return Style.anim.expressiveFastSpatial;
        if (type === Anim.DefaultSpatial)
            return Style.anim.expressiveDefaultSpatial;
        if (type === Anim.SlowSpatial)
            return Style.anim.expressiveSlowSpatial;
        if (type === Anim.FastEffects)
            return Style.anim.expressiveFastEffects;
        if (type === Anim.DefaultEffects)
            return Style.anim.expressiveDefaultEffects;
        if (type === Anim.SlowEffects)
            return Style.anim.expressiveSlowEffects;

        const types = ["small", "normal", "large", "extraLarge"];
        const idx = type % 4;
        return Style.anim[types[idx]];
    }

    easing: {
        if (type === Anim.FastSpatial)
            return Style.anim.expressiveFastSpatialCurve;
        if (type === Anim.DefaultSpatial)
            return Style.anim.expressiveDefaultSpatialCurve;
        if (type === Anim.SlowSpatial)
            return Style.anim.expressiveSlowSpatialCurve;
        if (type === Anim.FastEffects)
            return Style.anim.expressiveFastEffectsCurve;
        if (type === Anim.DefaultEffects)
            return Style.anim.expressiveDefaultEffectsCurve;
        if (type === Anim.SlowEffects)
            return Style.anim.expressiveSlowEffectsCurve;

        if (type >= Anim.EmphasizedSmall && type <= Anim.EmphasizedExtraLarge)
            return Style.anim.emphasizedCurve;
        return Style.anim.standardCurve;
    }
}
