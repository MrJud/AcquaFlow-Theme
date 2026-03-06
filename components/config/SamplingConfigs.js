.pragma library

// Per-platform sampling coordinates for ColorSampler.
// Each platform defines an array of sample points as normalized coordinates (0.0–1.0).
// 'weight' controls how much influence each sample has on the final color (default: 1.0).
// 'radius' is the sample area radius in pixels (default: 12).
//
// Design rationale per platform:
// - Points are placed on the box art's most colorful/representative regions
// - Avoid banner areas (PS stripe, Nintendo logos), spine text, rating badges
// - Multiple points improve accuracy on covers with varied layouts

var samplingConfigs = {

    // ── Default: Generic box art (tall, ~0.7 aspect ratio) ──
    // Sample top artwork area, left-mid, and right-bottom to get good gradient spread
    "default": {
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },   // Upper center (main artwork)
            { x: 0.25, y: 0.65, weight: 1.0, radius: 12 },   // Lower-left
            { x: 0.75, y: 0.65, weight: 1.0, radius: 12 },   // Lower-right
            { x: 0.50, y: 0.50, weight: 0.8, radius: 10 }    // Dead center
        ],
        // Minimum luminance and saturation thresholds for a "valid" color
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    // ── Nintendo ──

    "nes": {
        // NES covers: top ~15% is often a colored banner, art below
        points: [
            { x: 0.50, y: 0.08, weight: 1.5, radius: 14 },   // Top banner (characteristic color)
            { x: 0.50, y: 0.45, weight: 1.0, radius: 14 },   // Center artwork
            { x: 0.30, y: 0.75, weight: 0.8, radius: 12 },   // Lower-left art
            { x: 0.70, y: 0.75, weight: 0.8, radius: 12 }    // Lower-right art
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "snes": {
        // SNES: similar to NES, artwork centered
        points: [
            { x: 0.50, y: 0.20, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.50, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.70, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.70, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "n64": {
        // N64: artwork generally fills the front, top area often has logo
        points: [
            { x: 0.50, y: 0.35, weight: 1.2, radius: 14 },
            { x: 0.30, y: 0.55, weight: 1.0, radius: 12 },
            { x: 0.70, y: 0.55, weight: 1.0, radius: 12 },
            { x: 0.50, y: 0.80, weight: 0.8, radius: 10 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "gc": {
        // GameCube: tall case, artwork area is central
        points: [
            { x: 0.50, y: 0.25, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.50, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.70, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.70, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "wii": {
        // Wii: white border at top/bottom, art in center; side spine is at RIGHT edge
        points: [
            { x: 0.90, y: 0.03, weight: 1.8, radius: 10 },   // Top-right spine color (most representative)
            { x: 0.90, y: 0.50, weight: 1.5, radius: 10 },   // Mid-right spine
            { x: 0.50, y: 0.40, weight: 1.0, radius: 14 },   // Center artwork
            { x: 0.50, y: 0.65, weight: 0.8, radius: 12 }    // Lower center
        ],
        minLuminance: 0.06,
        minSaturation: 0.04   // Wii covers can be pale/white-heavy
    },

    "wiiu": {
        // Wii U: blue banner at top, artwork below
        points: [
            { x: 0.50, y: 0.04, weight: 1.5, radius: 10 },   // Blue Wii U banner
            { x: 0.50, y: 0.35, weight: 1.0, radius: 14 },   // Upper artwork
            { x: 0.30, y: 0.65, weight: 0.8, radius: 12 },   // Lower-left
            { x: 0.70, y: 0.65, weight: 0.8, radius: 12 }    // Lower-right
        ],
        minLuminance: 0.06,
        minSaturation: 0.04
    },

    "switch": {
        // Switch: red banner at very top, artwork below
        points: [
            { x: 0.50, y: 0.03, weight: 1.8, radius: 10 },   // Red Switch banner
            { x: 0.50, y: 0.35, weight: 1.0, radius: 14 },   // Upper artwork
            { x: 0.30, y: 0.60, weight: 0.8, radius: 12 },   // Lower-left
            { x: 0.70, y: 0.60, weight: 0.8, radius: 12 }    // Lower-right
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    // ── Nintendo Handheld ──

    "gb": {
        // Game Boy: usually simple pixel art covers
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.60, weight: 1.0, radius: 14 },
            { x: 0.30, y: 0.50, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "gbc": {
        // Game Boy Color: similar to GB but more colorful
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.60, weight: 1.0, radius: 14 },
            { x: 0.30, y: 0.50, weight: 0.8, radius: 12 },
            { x: 0.70, y: 0.50, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "gba": {
        // GBA: left edge has a distinct colored border (spine) — very important to sample
        points: [
            { x: 0.50, y: 0.15, weight: 1.8, radius: 10 },   // Left spine top
            { x: 0.50, y: 0.50, weight: 1.5, radius: 10 },   // Left spine center
            { x: 0.50, y: 0.80, weight: 1.2, radius: 10 },   // Left spine bottom
            { x: 0.50, y: 0.40, weight: 0.8, radius: 14 }    // Center artwork
        ],
        minLuminance: 0.06,
        minSaturation: 0.04
    },

    "nds": {
        // DS: artwork centered, sometimes white borders
        points: [
            { x: 0.50, y: 0.25, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.50, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.70, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.70, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "3ds": {
        // 3DS: similar layout to DS
        points: [
            { x: 0.50, y: 0.25, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.50, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.70, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.70, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    // ── SEGA ──

    "mastersystem": {
        // Master System: grid-style cover art
        points: [
            { x: 0.50, y: 0.15, weight: 1.2, radius: 14 },   // Top area
            { x: 0.50, y: 0.50, weight: 1.0, radius: 14 },
            { x: 0.30, y: 0.75, weight: 0.8, radius: 12 },
            { x: 0.70, y: 0.75, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "megadrive": {
        // Mega Drive / Genesis: bold artwork, distinct grid header
        points: [
            { x: 0.50, y: 0.10, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.45, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.70, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.70, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "genesis": {
        // Genesis (US): same structure as Mega Drive
        points: [
            { x: 0.50, y: 0.10, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.45, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.70, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.70, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "segacd": {
        // Sega CD: jewel case, art fills front
        points: [
            { x: 0.50, y: 0.25, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.55, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.75, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.75, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "sega32x": {
        points: [
            { x: 0.50, y: 0.25, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.55, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.75, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.75, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "dreamcast": {
        // Dreamcast: jewel case, prominent logo at top
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.55, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.75, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.75, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "saturn": {
        // Sega Saturn: jewel case artwork
        points: [
            { x: 0.50, y: 0.25, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.55, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.75, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.75, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "gamegear": {
        // Game Gear: small cartridge box art
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.60, weight: 1.0, radius: 14 },
            { x: 0.30, y: 0.50, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    // ── PlayStation ──

    "psx": {
        // PS1: black PlayStation banner at top (~8%), artwork below
        points: [
            { x: 0.50, y: 0.20, weight: 1.2, radius: 14 },   // Below PS banner
            { x: 0.50, y: 0.50, weight: 1.0, radius: 14 },   // Center artwork
            { x: 0.25, y: 0.75, weight: 0.8, radius: 12 },   // Lower-left
            { x: 0.75, y: 0.75, weight: 0.8, radius: 12 }    // Lower-right
        ],
        minLuminance: 0.06,  // PS1 covers can be dark
        minSaturation: 0.05
    },

    "ps2": {
        // PS2: blue PlayStation stripe at top, artwork below
        points: [
            { x: 0.50, y: 0.04, weight: 1.5, radius: 10 },   // Blue PS2 stripe (characteristic)
            { x: 0.50, y: 0.35, weight: 1.0, radius: 14 },   // Upper artwork
            { x: 0.30, y: 0.65, weight: 0.8, radius: 12 },   // Lower-left
            { x: 0.70, y: 0.65, weight: 0.8, radius: 12 }    // Lower-right
        ],
        minLuminance: 0.06,
        minSaturation: 0.05
    },

    "ps3": {
        // PS3: PlayStation stripe at top, artwork below
        points: [
            { x: 0.50, y: 0.04, weight: 1.5, radius: 10 },   // PS3 stripe
            { x: 0.50, y: 0.35, weight: 1.0, radius: 14 },
            { x: 0.30, y: 0.65, weight: 0.8, radius: 12 },
            { x: 0.70, y: 0.65, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.06,
        minSaturation: 0.05
    },

    "psp": {
        // PSP: UMD case, artwork fills front, top stripe
        points: [
            { x: 0.50, y: 0.20, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.50, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.75, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.75, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.06,
        minSaturation: 0.05
    },

    "vita": {
        // PS Vita: blue PS banner at top
        points: [
            { x: 0.50, y: 0.04, weight: 1.5, radius: 10 },   // Blue Vita stripe
            { x: 0.50, y: 0.35, weight: 1.0, radius: 14 },
            { x: 0.30, y: 0.65, weight: 0.8, radius: 12 },
            { x: 0.70, y: 0.65, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.06,
        minSaturation: 0.05
    },

    // ── Other / Retro ──

    "3do": {
        // 3DO: jewel case, artwork fills front
        points: [
            { x: 0.50, y: 0.25, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.55, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.75, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.75, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "arcade": {
        // Arcade: diverse flyer/marquee art
        points: [
            { x: 0.50, y: 0.25, weight: 1.0, radius: 16 },
            { x: 0.50, y: 0.50, weight: 1.0, radius: 16 },
            { x: 0.25, y: 0.70, weight: 0.8, radius: 14 },
            { x: 0.75, y: 0.70, weight: 0.8, radius: 14 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "atari2600": {
        // Atari 2600: bold, colorful artwork
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.60, weight: 1.0, radius: 14 },
            { x: 0.30, y: 0.50, weight: 0.8, radius: 12 },
            { x: 0.70, y: 0.50, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "atarijaguar": {
        // Atari Jaguar: bold cover art
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.60, weight: 1.0, radius: 14 },
            { x: 0.30, y: 0.50, weight: 0.8, radius: 12 },
            { x: 0.70, y: 0.50, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "colecovision": {
        // ColecoVision: retro box art
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.60, weight: 1.0, radius: 14 },
            { x: 0.30, y: 0.50, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "c64": {
        // Commodore 64: varied cover art
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.60, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.50, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.50, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "msx": {
        // MSX: Japanese micro covers
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.60, weight: 1.0, radius: 14 },
            { x: 0.30, y: 0.50, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "neogeo": {
        // Neo Geo: bold arcade-style art
        points: [
            { x: 0.50, y: 0.25, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.50, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.70, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.70, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "pcengine": {
        // PC Engine / TurboGrafx-16: small HuCard / jewel case
        points: [
            { x: 0.50, y: 0.25, weight: 1.2, radius: 14 },
            { x: 0.50, y: 0.55, weight: 1.0, radius: 14 },
            { x: 0.25, y: 0.75, weight: 0.8, radius: 12 },
            { x: 0.75, y: 0.75, weight: 0.8, radius: 12 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    // ── PC ──

    "windows": {
        // PC covers: very diverse layouts, sample broadly
        points: [
            { x: 0.50, y: 0.25, weight: 1.0, radius: 16 },
            { x: 0.50, y: 0.50, weight: 1.0, radius: 16 },
            { x: 0.25, y: 0.70, weight: 0.8, radius: 14 },
            { x: 0.75, y: 0.70, weight: 0.8, radius: 14 },
            { x: 0.50, y: 0.85, weight: 0.6, radius: 12 }    // Extra bottom sample
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    // ── Virtual/Meta ──

    "lastplayed": {
        // Uses the config of the original platform at runtime
        // This is a pass-through, handled in ColorSampler
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },
            { x: 0.25, y: 0.65, weight: 1.0, radius: 12 },
            { x: 0.75, y: 0.65, weight: 1.0, radius: 12 },
            { x: 0.50, y: 0.50, weight: 0.8, radius: 10 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    },

    "favourites": {
        points: [
            { x: 0.50, y: 0.30, weight: 1.2, radius: 14 },
            { x: 0.25, y: 0.65, weight: 1.0, radius: 12 },
            { x: 0.75, y: 0.65, weight: 1.0, radius: 12 },
            { x: 0.50, y: 0.50, weight: 0.8, radius: 10 }
        ],
        minLuminance: 0.08,
        minSaturation: 0.06
    }
};

/**
 * Returns the sampling config for a platform.
 * Falls back to "default" if platform is not found.
 */
function getSamplingConfig(platform) {
    if (!platform) return samplingConfigs["default"];
    var key = platform.toLowerCase();
    return samplingConfigs[key] || samplingConfigs["default"];
}
