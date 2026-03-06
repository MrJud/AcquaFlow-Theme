.pragma library

// Map: Pegasus collection shortName → RA Console ID
var toConsoleId = {
    "megadrive": 1,
    "genesis": 1,
    "n64": 2,
    "snes": 3,
    "gb": 4,
    "gba": 5,
    "gbc": 6,
    "nes": 7,
    "pcengine": 8,
    "segacd": 9,
    "sega32x": 10,
    "mastersystem": 11,
    "psx": 12,
    "atari2600": 25,
    "gc": 16,
    "nds": 18,
    "ps2": 21,
    "wii": 24,
    "psp": 41,
    "3ds": 76,
    "dreamcast": 40,
    "saturn": 39,
    "atari7800": 51,
    "atarilynx": 13,
    "neogeo": 14,
    "wonderswan": 53,
    "virtualboy": 28,
    "sg1000": 33,
    "gamegear": 15,
    "arcade": 27
};

// Map: RA Console Name → Pegasus shortName
var fromConsoleName = {
    "Mega Drive":            "megadrive",
    "Mega Drive/Genesis":    "megadrive",
    "Genesis":               "megadrive",
    "Nintendo 64":           "n64",
    "SNES":                  "snes",
    "SNES/Super Famicom":    "snes",
    "Super Nintendo":        "snes",
    "Game Boy":              "gb",
    "Game Boy Advance":      "gba",
    "Game Boy Color":        "gbc",
    "NES":                   "nes",
    "NES/Famicom":           "nes",
    "PC Engine":             "pcengine",
    "PC Engine/TurboGrafx-16": "pcengine",
    "Sega CD":               "segacd",
    "32X":                   "sega32x",
    "Sega 32X":              "sega32x",
    "Master System":         "mastersystem",
    "PlayStation":           "psx",
    "Atari 2600":            "atari2600",
    "GameCube":              "gc",
    "Nintendo DS":           "nds",
    "PlayStation 2":         "ps2",
    "Wii":                   "wii",
    "PSP":                   "psp",
    "PlayStation Portable":  "psp",
    "Nintendo 3DS":          "3ds",
    "Dreamcast":             "dreamcast",
    "Saturn":                "saturn",
    "Sega Saturn":           "saturn",
    "Atari 7800":            "atari7800",
    "Atari Lynx":            "atarilynx",
    "Neo Geo":               "neogeo",
    "Neo Geo Pocket":        "neogeo",
    "WonderSwan":            "wonderswan",
    "Virtual Boy":           "virtualboy",
    "SG-1000":               "sg1000",
    "Game Gear":             "gamegear",
    "Arcade":                "arcade"
};

// Short console label for UI badges
var shortLabel = {
    "Mega Drive":            "MD",
    "Mega Drive/Genesis":    "MD",
    "Genesis":               "MD",
    "Nintendo 64":           "N64",
    "SNES":                  "SNES",
    "SNES/Super Famicom":    "SNES",
    "Super Nintendo":        "SNES",
    "Game Boy":              "GB",
    "Game Boy Advance":      "GBA",
    "Game Boy Color":        "GBC",
    "NES":                   "NES",
    "NES/Famicom":           "NES",
    "PC Engine":             "PCE",
    "PC Engine/TurboGrafx-16": "PCE",
    "Sega CD":               "SCD",
    "32X":                   "32X",
    "Sega 32X":              "32X",
    "Master System":         "SMS",
    "PlayStation":           "PSX",
    "Atari 2600":            "2600",
    "GameCube":              "GC",
    "Nintendo DS":           "NDS",
    "PlayStation 2":         "PS2",
    "Wii":                   "Wii",
    "PSP":                   "PSP",
    "PlayStation Portable":  "PSP",
    "Nintendo 3DS":          "3DS",
    "Dreamcast":             "DC",
    "Saturn":                "SAT",
    "Sega Saturn":           "SAT",
    "Atari 7800":            "7800",
    "Atari Lynx":            "LYNX",
    "Neo Geo":               "NG",
    "WonderSwan":            "WS",
    "Virtual Boy":           "VB",
    "SG-1000":               "SG",
    "Game Gear":             "GG",
    "Arcade":                "ARC"
};

function getPegasusShortName(raConsoleName) {
    return fromConsoleName[raConsoleName] || raConsoleName.toLowerCase().replace(/[^a-z0-9]/g, "");
}

function getConsoleId(pegasusShortName) {
    return toConsoleId[pegasusShortName.toLowerCase()] || 0;
}

function getShortLabel(raConsoleName) {
    return shortLabel[raConsoleName] || raConsoleName;
}
