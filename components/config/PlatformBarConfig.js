.pragma library

var PlatformBarConfig = {
    // General sizes
    platformBarHeight: 180,
    platformSpacing: 122,
    platformLogoSize: 124,

    platformItemWidth: 185,  // Default: ~2.2 * platformLogoSize

    // Width of a selected platform item (larger).
    platformItemWidthCurrent: 268,  // Default: ~1.45 * platformItemWidth

    platformScale: 1.2,  // Increased for better visibility

    // Vertical offset
    platformCenterOffsetY: -15,

    fontSizeSmall: 14,  // Default: max(10, ~0.12 * platformBarHeight)

    fontSizeMedium: 22,  // Default: max(14, ~0.18 * platformBarHeight)

    // Each platform can have custom outline params
    // outlineColors: 3-color array [col1, col2, col3] for conical gradient animation
    platformOutlineConfigs: {
        "default": {
            outlineOpacity: 1.0,
            outlineSize: 1.0,
            outlineVerticalScale: 1.0,
            outlineHorizontalScale: 1.0,
            alphaThreshold: 0.08,
            soft: 0.04,
            enableOutline: true,
            outlineColors: null  // null = use animated rainbow fallback
        },

        "lastplayed": {
            outlineOpacity: 1.2,
            outlineSize: 1.2,
            outlineVerticalScale: 0.7,
            outlineHorizontalScale: 1.2,
            alphaThreshold: 0.06,
            soft: 0.03,
            enableOutline: true,
            outlineColors: null
        },

        // ── 3DO ──
        "3do": {
            outlineOpacity: 1.0,
            outlineSize: 1.0,
            outlineVerticalScale: 0.6,
            outlineHorizontalScale: 1.0,
            alphaThreshold: 0.08,
            soft: 0.02,
            enableOutline: true,
            outlineColors: ["#D4AF37", "#C0392B", "#1A1A1A"]  // Gold, dark red, black
        },

        // ── Arcade ──
        "arcade": {
            outlineOpacity: 1.1,
            outlineSize: 1.1,
            outlineVerticalScale: 0.6,
            outlineHorizontalScale: 1.2,
            alphaThreshold: 0.07,
            soft: 0.025,
            enableOutline: true,
            outlineColors: ["#FF0000", "#FFD700", "#0000FF"]  // Red, gold, blue (classic arcade)
        },

        // ── Atari 2600 ──
        "atari2600": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.5,
            outlineHorizontalScale: 2.0,
            alphaThreshold: 0.1,
            soft: 0.01,
            enableOutline: true,
            outlineColors: ["#C1440E", "#F5A623", "#4A2800"]  // Atari burnt orange, amber, dark brown
        },

        // ── Atari Jaguar ──
        "atarijaguar": {
            outlineOpacity: 1.0,
            outlineSize: 1.0,
            outlineVerticalScale: 0.55,
            outlineHorizontalScale: 1.2,
            alphaThreshold: 0.08,
            soft: 0.02,
            enableOutline: true,
            outlineColors: ["#E60000", "#1A1A1A", "#8B0000"]  // Jaguar red, black, dark red
        },

        // ── ColecoVision ──
        "colecovision": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.5,
            outlineHorizontalScale: 1.8,
            alphaThreshold: 0.09,
            soft: 0.015,
            enableOutline: true,
            outlineColors: ["#1B1B1B", "#B8860B", "#FFFFFF"]  // Black, dark gold, white
        },

        // ── Commodore 64 ──
        "c64": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.5,
            outlineHorizontalScale: 2.0,
            alphaThreshold: 0.09,
            soft: 0.015,
            enableOutline: true,
            outlineColors: ["#6C5EB5", "#A594E8", "#40347B"]  // C64 purple, light purple, dark purple
        },

        // ── Dreamcast ──
        "dreamcast": {
            outlineOpacity: 1.1,
            outlineSize: 1.1,
            outlineVerticalScale: 0.7,
            outlineHorizontalScale: 1.1,
            alphaThreshold: 0.07,
            soft: 0.025,
            enableOutline: true,
            outlineColors: ["#FF6600", "#003DA5", "#FFFFFF"]  // Dreamcast orange, Sega blue, white swirl
        },

        // ── Game Boy ──
        "gb": {
            outlineOpacity: 0.7,
            outlineSize: 0.7,
            outlineVerticalScale: 0.4,
            outlineHorizontalScale: 1.8,
            alphaThreshold: 0.12,
            soft: 0.005,
            enableOutline: true,
            outlineColors: ["#306230", "#8BAC0F", "#0F380F"]  // GB dark green, GB light green, GB darkest
        },

        // ── Game Boy Color ──
        "gbc": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.55,
            outlineHorizontalScale: 2.2,
            alphaThreshold: 0.09,
            soft: 0.015,
            enableOutline: true,
            outlineColors: ["#6B2FA0", "#2196F3", "#FFD700"]  // GBC purple, blue, gold (logo colors)
        },

        // ── Game Boy Advance ──
        "gba": {
            outlineOpacity: 0.8,
            outlineSize: 0.8,
            outlineVerticalScale: 0.4,
            outlineHorizontalScale: 2.0,
            alphaThreshold: 0.1,
            soft: 0.01,
            enableOutline: true,
            outlineColors: ["#2B0F7E", "#7B68EE", "#1A005C"]  // GBA indigo, medium slate blue, deep indigo
        },

        // ── Sega Genesis / Mega Drive ──
        "genesis": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.55,
            outlineHorizontalScale: 2.1,
            alphaThreshold: 0.09,
            soft: 0.015,
            enableOutline: true,
            outlineColors: ["#003DA5", "#D4AF37", "#1A1A1A"]  // Sega blue, gold ring, black
        },

        "megadrive": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.55,
            outlineHorizontalScale: 2.1,
            alphaThreshold: 0.09,
            soft: 0.015,
            enableOutline: true,
            outlineColors: ["#003DA5", "#D4AF37", "#1A1A1A"]  // Sega blue, gold ring, black
        },

        // ── Master System ──
        "mastersystem": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.5,
            outlineHorizontalScale: 1.8,
            alphaThreshold: 0.09,
            soft: 0.015,
            enableOutline: true,
            outlineColors: ["#CC0000", "#003DA5", "#FFFFFF"]  // SMS red, Sega blue, white
        },

        // ── Sega CD ──
        "segacd": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.5,
            outlineHorizontalScale: 1.8,
            alphaThreshold: 0.09,
            soft: 0.015,
            enableOutline: true,
            outlineColors: ["#004080", "#D4AF37", "#003DA5"]  // Sega CD dark blue, gold, Sega blue
        },

        // ── Sega 32X ──
        "sega32x": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.5,
            outlineHorizontalScale: 1.8,
            alphaThreshold: 0.09,
            soft: 0.015,
            enableOutline: true,
            outlineColors: ["#D04040", "#FFD700", "#003DA5"]  // 32X red, gold, Sega blue
        },

        // ── Game Gear ──
        "gamegear": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.5,
            outlineHorizontalScale: 1.8,
            alphaThreshold: 0.09,
            soft: 0.015,
            enableOutline: true,
            outlineColors: ["#003DA5", "#1A1A1A", "#4A90D9"]  // GG Sega blue, black, light blue
        },

        // ── MSX ──
        "msx": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.5,
            outlineHorizontalScale: 1.8,
            alphaThreshold: 0.09,
            soft: 0.015,
            enableOutline: true,
            outlineColors: ["#CC0000", "#F5F5F5", "#333333"]  // MSX red, white, dark gray
        },

        // ── Nintendo 3DS ──
        "3ds": {
            outlineOpacity: 1.2,
            outlineSize: 1.1,
            outlineVerticalScale: 0.35,
            outlineHorizontalScale: 1.1,
            alphaThreshold: 0.06,
            soft: 0.03,
            enableOutline: true,
            outlineColors: ["#CE0016", "#1C1C1C", "#808080"]  // 3DS red, black, gray
        },

        // ── Nintendo 64 ──
        "n64": {
            outlineOpacity: 1.1,
            outlineSize: 1.1,
            outlineVerticalScale: 0.35,
            outlineHorizontalScale: 1.3,
            alphaThreshold: 0.07,
            soft: 0.025,
            enableOutline: true,
            outlineColors: ["#009E42", "#FF0000", "#FFD700"]  // N64 green, red, gold (logo tricolor)
        },

        // ── GameCube ──
        "gc": {
            outlineOpacity: 1.0,
            outlineSize: 1.0,
            outlineVerticalScale: 0.45,
            outlineHorizontalScale: 1.2,
            alphaThreshold: 0.08,
            soft: 0.02,
            enableOutline: true,
            outlineColors: ["#6B5ECF", "#2A2060", "#9D93E0"]  // GC indigo, dark purple, light lavender
        },

        // ── Nintendo DS ──
        "nds": {
            outlineOpacity: 1.0,
            outlineSize: 1.0,
            outlineVerticalScale: 0.4,
            outlineHorizontalScale: 1.0,
            alphaThreshold: 0.08,
            soft: 0.02,
            enableOutline: true,
            outlineColors: ["#B0B0B0", "#4A4A4A", "#D0D0D0"]  // DS silver, dark gray, light silver
        },

        // ── Neo Geo ──
        "neogeo": {
            outlineOpacity: 1.0,
            outlineSize: 1.0,
            outlineVerticalScale: 0.55,
            outlineHorizontalScale: 1.2,
            alphaThreshold: 0.08,
            soft: 0.02,
            enableOutline: true,
            outlineColors: ["#D4AF37", "#1A1A1A", "#FFFFFF"]  // Neo Geo gold, black, white
        },

        // ── NES / Famicom ──
        "nes": {
            outlineOpacity: 0.8,
            outlineSize: 0.8,
            outlineVerticalScale: 0.5,
            outlineHorizontalScale: 2.0,
            alphaThreshold: 0.1,
            soft: 0.01,
            enableOutline: true,
            outlineColors: ["#E60012", "#B8B8B8", "#2C2C2C"]  // NES red, NES light gray, NES dark
        },

        // ── PC Engine / TurboGrafx-16 ──
        "pcengine": {
            outlineOpacity: 1.0,
            outlineSize: 1.0,
            outlineVerticalScale: 0.55,
            outlineHorizontalScale: 1.2,
            alphaThreshold: 0.08,
            soft: 0.02,
            enableOutline: true,
            outlineColors: ["#FF4500", "#FF8C00", "#FFDD00"]  // PC Engine red-orange, orange, yellow
        },

        // ── PlayStation 2 ──
        "ps2": {
            outlineOpacity: 1.1,
            outlineSize: 1.1,
            outlineVerticalScale: 0.65,
            outlineHorizontalScale: 1.1,
            alphaThreshold: 0.07,
            soft: 0.025,
            enableOutline: true,
            outlineColors: ["#003DA5", "#00A0E3", "#1C1C1C"]  // PS2 dark blue, PS2 cyan-blue, black tower
        },

        // ── PlayStation 3 ──
        "ps3": {
            outlineOpacity: 1.1,
            outlineSize: 1.1,
            outlineVerticalScale: 0.65,
            outlineHorizontalScale: 1.1,
            alphaThreshold: 0.07,
            soft: 0.025,
            enableOutline: true,
            outlineColors: ["#1C1C1C", "#003DA5", "#C0C0C0"]  // PS3 black, PlayStation blue, silver chrome
        },

        // ── PSP ──
        "psp": {
            outlineOpacity: 1.2,
            outlineSize: 1.2,
            outlineVerticalScale: 0.75,
            outlineHorizontalScale: 1.2,
            alphaThreshold: 0.06,
            soft: 0.03,
            enableOutline: true,
            outlineColors: ["#1C1C1C", "#4A4A4A", "#A0A0A0"]  // PSP piano black, dark gray, silver
        },

        // ── PS Vita ──
        "vita": {
            outlineOpacity: 1.3,
            outlineSize: 1.3,
            outlineVerticalScale: 0.8,
            outlineHorizontalScale: 1.3,
            alphaThreshold: 0.05,
            soft: 0.04,
            enableOutline: true,
            outlineColors: ["#003DA5", "#00C8FF", "#1C1C1C"]  // Vita PlayStation blue, Vita cyan, black
        },

        // ── PlayStation 1 ──
        "psx": {
            outlineOpacity: 1.0,
            outlineSize: 1.0,
            outlineVerticalScale: 0.4,
            outlineHorizontalScale: 1.0,
            alphaThreshold: 0.08,
            soft: 0.02,
            enableOutline: true,
            outlineColors: ["#EE1515", "#FFCD00", "#009DD9"]  // PS1 red, PS1 yellow, PS1 blue (logo colors)
        },

        // ── Sega Saturn ──
        "saturn": {
            outlineOpacity: 1.0,
            outlineSize: 1.0,
            outlineVerticalScale: 0.6,
            outlineHorizontalScale: 1.1,
            alphaThreshold: 0.08,
            soft: 0.02,
            enableOutline: true,
            outlineColors: ["#003DA5", "#B0B0B0", "#1A1A1A"]  // Saturn Sega blue, Saturn gray, black
        },

        // ── SNES / Super Famicom ──
        "snes": {
            outlineOpacity: 0.9,
            outlineSize: 0.9,
            outlineVerticalScale: 0.55,
            outlineHorizontalScale: 2.2,
            alphaThreshold: 0.09,
            soft: 0.015,
            enableOutline: true,
            outlineColors: ["#7B1FA2", "#B0B0B0", "#2C2C2C"]  // SNES purple, SNES light gray, SNES dark
        },

        // ── Nintendo Switch ──
        "switch": {
            outlineOpacity: 1.4,
            outlineSize: 1.4,
            outlineVerticalScale: 0.4,
            outlineHorizontalScale: 1.4,
            alphaThreshold: 0.04,
            soft: 0.05,
            enableOutline: true,
            outlineColors: ["#E60012", "#00C3E3", "#1C1C1C"]  // Switch red, Switch neon blue, black
        },

        // ── Wii ──
        "wii": {
            outlineOpacity: 1.1,
            outlineSize: 1.0,
            outlineVerticalScale: 0.7,
            outlineHorizontalScale: 1.0,
            alphaThreshold: 0.06,
            soft: 0.035,
            enableOutline: true,
            outlineColors: ["#009AC7", "#FFFFFF", "#B0B0B0"]  // Wii blue, white, light gray
        },

        // ── Wii U ──
        "wiiu": {
            outlineOpacity: 1.1,
            outlineSize: 1.1,
            outlineVerticalScale: 0.6,
            outlineHorizontalScale: 1.1,
            alphaThreshold: 0.06,
            soft: 0.03,
            enableOutline: true,
            outlineColors: ["#009AC7", "#1C1C1C", "#00E6D0"]  // Wii U blue, black, turquoise accent
        },

        // ── Windows / PC ──
        "windows": {
            outlineOpacity: 1.0,
            outlineSize: 1.0,
            outlineVerticalScale: 0.4,
            outlineHorizontalScale: 1.0,
            alphaThreshold: 0.08,
            soft: 0.02,
            enableOutline: true,
            outlineColors: ["#0078D4", "#FFB900", "#00A4EF"]  // Windows blue, Windows yellow, Windows light blue
        },

        // ── RetroAchievements ──
        "ra": {
            outlineOpacity: 1.0,
            outlineSize: 1.2,
            outlineVerticalScale: 0.5,
            outlineHorizontalScale: 1.2,
            alphaThreshold: 0.08,
            soft: 0.02,
            enableOutline: true,
            outlineColors: ["#FFD700", "#FFC107", "#FF8F00"]  // Gold, amber, dark amber
        }
    },

    getOutlineConfig: function(platformShortName) {
        var config = this.platformOutlineConfigs[platformShortName];
        if (!config) {
            config = this.platformOutlineConfigs["default"];
        }
        return config;
    }
};
