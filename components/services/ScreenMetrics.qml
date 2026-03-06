import QtQuick 2.15
import ".."

QtObject {
    id: screenMetrics

    // ── Input dimensions (bound from parent) ──────────────────────────────────
    property real sourceWidth:  1920
    property real sourceHeight: 1080

    // ── Screen-size detection ─────────────────────────────────────────────────
    // screenPixelDensity  → set from Screen.pixelDensity (pixels per mm)
    // screenSizeOverride  → "auto" | "small" | "medium" | "large" | "xlarge"  (persisted in settings)
    property real   screenPixelDensity: 3.78          // default ≈ 96 PPI (desktop)
    property string screenSizeOverride: "auto"

    // Threshold: ~6 px/mm ≈ 152 PPI.  Handhelds (Odin2 ~14.5, Steam Deck ~8.8) > 6
    //                                  Monitors/TVs (24" 1080p ~3.6, 55" 4K ~3.2) < 6
    //
    // sizeLevel:  0 = small  (piccolo  — handheld)          multiplier 1.00 / toolbar 1.00
    //             1 = medium (medio    — compact desktop)   multiplier 0.92 / toolbar 0.90
    //             2 = large  (grande   — standard monitor)  multiplier 0.82 / toolbar 0.78
    //             3 = xlarge (x-large  — large 4K/TV)       multiplier 0.70 / toolbar 0.64
    //
    // auto: handheld (density > 6) → piccolo (0), monitor → grande (2)
    readonly property int sizeLevel: {
        if (screenSizeOverride === "small")  return 0;
        if (screenSizeOverride === "medium") return 1;
        if (screenSizeOverride === "large")  return 2;
        if (screenSizeOverride === "xlarge") return 3;
        return screenPixelDensity > 6.0 ? 0 : 2;    // auto: handheld→piccolo, monitor→grande
    }

    // Kept for backward compatibility — true only when handheld (level 0)
    readonly property bool isSmallScreen: sizeLevel === 0

    // ── Scaling ───────────────────────────────────────────────────────────────
    // scaleRatio     → continuous, adapts to any resolution (1.0 at 1080p)
    // sizeMultiplier → coarse preset driven by sizeLevel
    readonly property real scaleRatio: sourceHeight / 1080.0
    readonly property real sizeMultiplier: {
        if (sizeLevel === 0) return 1.00;  // piccolo   — handheld base
        if (sizeLevel === 1) return 0.92;  // medio     — compact desktop
        if (sizeLevel === 2) return 0.82;  // grande    — standard monitor
        return 0.70;                       // x-large   — large 4K / TV
    }

    // Helper – apply both ratios and round
    function scaled(baseValue) {
        return Math.round(baseValue * scaleRatio * sizeMultiplier);
    }
    // Helper – toolbar icons use a more aggressive reduction on large screens
    function scaledToolbar(baseValue) {
        return Math.round(baseValue * scaleRatio * toolbarSizeMultiplier);
    }

    // ── Cover dimensions (scales with resolution AND sizeLevel preset) ──────────
    readonly property int baseCoverHeight: Math.max(200, Math.round(486 * scaleRatio * sizeMultiplier))
    readonly property int maxCoverWidth:   Math.max(280, Math.round(baseCoverHeight * 0.65))
    readonly property int maxCoverHeight:  Math.round(baseCoverHeight * 0.90)

    // ── Font sizes ────────────────────────────────────────────────────────────
    readonly property int fontPixelSizeSmall:     Math.max(12, scaled(12))    // 1080*0.022*0.5 ≈ 12
    readonly property int fontPixelSizeMedium:    Math.max(20, scaled(19))    // 1080*0.035*0.5 ≈ 19
    readonly property int fontPixelSizeLarge:     Math.max(28, scaled(27))    // 1080*0.050*0.5 ≈ 27
    readonly property int fontPixelSizeGameTitle: Math.max(16, scaled(15))    // 1080*0.028*0.5 ≈ 15

    // ── Loading indicator ─────────────────────────────────────────────────────
    readonly property int loadingImageSize: Math.max(64, scaled(178))         // 1080*0.15*1.1 ≈ 178

    // ── PathView position ─────────────────────────────────────────────────────
    readonly property real pathStartY: sourceHeight * 0.52

    // ── Title margin ──────────────────────────────────────────────────────────
    readonly property int titleMarginTop: scaled(25)

    // ── Toolbar / carousel icon sizes ─────────────────────────────────────────
    // All 6 buttons: RA, CarouselCustomizer, ViewSwitcher, Search, Favourite, Menu
    readonly property real toolbarSizeMultiplier: {
        if (sizeLevel === 0) return 1.00;  // piccolo
        if (sizeLevel === 1) return 0.90;  // medio
        if (sizeLevel === 2) return 0.78;  // grande
        return 0.64;                       // x-large
    }

    readonly property int toolbarButtonSize:    Math.max(36, scaledToolbar(80))   // root hitbox (RA, Customizer, Search, Fav, Menu)
    readonly property int toolbarIconSize:      Math.max(16, scaledToolbar(32))   // icon inside Search, Favourite, Menu
    readonly property int toolbarIconSizeLarge: Math.max(20, scaledToolbar(40))   // icon inside RA, CarouselCustomizer
    readonly property int viewSwitcherWidth:    Math.max(60, scaledToolbar(130))  // ViewSwitcher pill width
    readonly property int viewSwitcherFontLarge: Math.max(14, scaledToolbar(30))  // ViewSwitcher main text
    readonly property int viewSwitcherFontSmall: Math.max(8,  scaledToolbar(14))  // ViewSwitcher sub text

    // ── Legend bar sizes (PlatformBar selected-mode legend) ───────────────────
    readonly property int legendBadgeSize:     Math.max(16, scaled(22))       // circle badges (A/X/Y/B)
    readonly property int legendPillWidth:     Math.max(18, scaled(26))       // L2/R2 pill width
    readonly property int legendSelectWidth:   Math.max(36, scaled(56))       // SELECT pill width
    readonly property int legendFontSize:      Math.max(10, scaled(13))       // label text
    readonly property int legendBadgeFontSize: Math.max(9,  scaled(12))       // text inside badges
    readonly property int legendPillFontSize:  Math.max(8,  scaled(10))       // text inside L2/R2/SELECT
    readonly property int legendSeparatorH:    Math.max(10, scaled(16))       // separator height
    readonly property int legendBarHeight:     Math.max(24, scaled(36))       // legend bar height
    readonly property int legendBarMargin:     Math.max(14, scaled(22))       // bottom margin
}
