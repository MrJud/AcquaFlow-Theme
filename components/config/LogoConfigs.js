.pragma library

var platformLogoConfigs = {

    "default": {
        baseSize: 120,
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        // Additional rotation beyond the 90-degree base (in degrees)
        additionalRotation: 0,
        // Logo opacity (0.0-1.0)
        opacity: 1.0,
        enabled: true,

        isLeft: true,
        isRight: true,

        // ADVANCED PERSPECTIVE SYSTEM
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                // X offset based on angle (multiplier)
                offsetXFactor: 0.1,
                // Y offset based on angle (multiplier)
                offsetYFactor: 0.05
            },
            // Dynamic Z depth
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.4,
                tiltedShrink: 0.3
            },
            verticalDeformation: {
                enabled: true,
                frontalGrow: 0.2,
                tiltedShrink: 0.1
            }
        }
    },

    "lastplayed": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.07,
                tiltedShrink: 0.03
            },
            verticalDeformation: {
                enabled: true,
                frontalGrow: 0.05,
                tiltedShrink: 0.02
            }
        }
    },

    "favourites": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.07,
                tiltedShrink: 0.03
            },
            verticalDeformation: {
                enabled: true,
                frontalGrow: 0.05,
                tiltedShrink: 0.02
            }
        }
    },

    "nes": {
        scale: 0.9,
        positionX: 0.5,
        positionY: 0.4,
        additionalRotation: 15,
        opacity: 0.9,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.6,
                tiltedShrink: 0.4
            },
            verticalDeformation: {
                enabled: true,
                frontalGrow: 0.25,
                tiltedShrink: 0.15
            }
        }
    },

    "snes": {
        scale: 0.85,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.08,
                tiltedShrink: 0.05
            },
            verticalDeformation: {
                enabled: true,
                frontalGrow: 0.06,
                tiltedShrink: 0.03
            }
        }
    },

    "n64": {
        scale: 0.4,
        positionX: 0.45,
        positionY: 0.3,
        additionalRotation: 0,
        opacity: 0.95,
        enabled: true,
        isLeft: true,
        isRight: false,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.9,
            positionCompensation: {
                offsetXFactor: 0.15,
                offsetYFactor: 0.08
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 105,
                angleZVariation: 25
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.5,
                tiltedShrink: 0.05
            },
            verticalDeformation: {
                enabled: true,
                frontalGrow: 0.15,
                tiltedShrink: 0.08
            }
        }
    },

    "gc": {
        scale: 0.8,
        positionX: 0.5,
        positionY: 0.3,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: false,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.06,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.06,
                tiltedShrink: 0.05
            }
        }
    },

    "wii": {
        scale: 0.25,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 0.9,
        enabled: true,
        isLeft: true,
        isRight: false,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 1.09,
                tiltedShrink: 0.31
            },
            verticalDeformation: {
                enabled: true,
                frontalGrow: 0.25,
                tiltedShrink: 0.12
            }
        }
    },

    "psx": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.4,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.07,
                tiltedShrink: 0.03
            },
            verticalDeformation: {
                enabled: true,
                frontalGrow: 0.05,
                tiltedShrink: 0.02
            }
        }
    },

    "ps2": {
        scale: 0.9,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 0.95,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.08,
                tiltedShrink: 0.04
            },
            verticalDeformation: {
                enabled: true,
                frontalGrow: 0.06,
                tiltedShrink: 0.03
            }
        }
    },

    "gba": {
        scale: 0.25,
        positionX: 0.5,
        positionY: 0.7,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: false,
            scaleCompensation: 0.1,
            positionCompensation: {
                offsetXFactor: 0.05,
                offsetYFactor: 0.03
            },
            dynamicDepth: {
                enabled: false,
                baseZ: 200,
                angleZVariation: 10
            },
            horizontalDeformation: {
                enabled: false,
                frontalGrow: 0.8,
                tiltedShrink: 0.2
            },
            verticalDeformation: {
                enabled: false,
                frontalGrow: 0.3,
                tiltedShrink: 0.15
            }
        }
    },

    "gbc": {
        scale: 0.25,
        positionX: 0.5,
        positionY: 0.6,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.6,
            positionCompensation: {
                offsetXFactor: 0.05,
                offsetYFactor: 0.03
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 200,
                angleZVariation: 10
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.8,
                tiltedShrink: 0.2
            },
            verticalDeformation: {
                enabled: true,
                frontalGrow: 0.3,
                tiltedShrink: 0.15
            }
        }
    },

    "nds": {
        scale: 0.25,
        positionX: 0.5,
        positionY: 0.6,
        additionalRotation: 0,
        opacity: 0.9,
        enabled: true,
        isLeft: true,
        isRight: false,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.3,
                tiltedShrink: 0.06
            }
        }
    },

    "3ds": {
        scale: 0.2,
        positionX: 0.5,
        positionY: 0.55,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: false,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.4,
                tiltedShrink: 0.3
            }
        }
    },

    "mastersystem": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: false,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.06,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.09,
                tiltedShrink: 0.05
            }
        }
    },

    "megadrive": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.09,
                tiltedShrink: 0.05
            }
        }
    },

    "genesis": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.09,
                tiltedShrink: 0.05
            }
        }
    },

    "dreamcast": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.09,
                tiltedShrink: 0.05
            }
        }
    },

    "segacd": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: false,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.06,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.09,
                tiltedShrink: 0.05
            }
        }
    },

    "sega32x": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: false,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.06,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.09,
                tiltedShrink: 0.05
            }
        }
    },

    "gamegear": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: false,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.06,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalGrow: 0.09,
                tiltedShrink: 0.05
            }
        }
    },

    "psp": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: false,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalShrink: 0.05,
                tiltedStretch: 0.09
            }
        }
    },

    "vita": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: false,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalShrink: 0.05,
                tiltedStretch: 0.09
            }
        }
    },

    "windows": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: {
                offsetXFactor: 0.1,
                offsetYFactor: 0.05
            },
            dynamicDepth: {
                enabled: true,
                baseZ: 100,
                angleZVariation: 20
            },
            horizontalDeformation: {
                enabled: true,
                frontalShrink: 0.05,
                tiltedStretch: 0.09
            }
        }
    },

    // ── Game Boy ──
    "gb": {
        scale: 0.9,
        positionX: 0.5,
        positionY: 0.45,
        additionalRotation: 15,
        opacity: 0.9,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.5, tiltedShrink: 0.35 },
            verticalDeformation: { enabled: true, frontalGrow: 0.2, tiltedShrink: 0.12 }
        }
    },

    // ── Nintendo Switch ──
    "switch": {
        scale: 0.9,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.07, tiltedShrink: 0.03 },
            verticalDeformation: { enabled: true, frontalGrow: 0.05, tiltedShrink: 0.02 }
        }
    },

    // ── 3DO ──
    "3do": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.09, tiltedShrink: 0.05 }
        }
    },

    // ── Arcade ──
    "arcade": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.09, tiltedShrink: 0.05 }
        }
    },

    // ── Atari 2600 ──
    "atari2600": {
        scale: 0.9,
        positionX: 0.5,
        positionY: 0.45,
        additionalRotation: 15,
        opacity: 0.9,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.5, tiltedShrink: 0.35 },
            verticalDeformation: { enabled: true, frontalGrow: 0.2, tiltedShrink: 0.12 }
        }
    },

    // ── Atari Jaguar ──
    "atarijaguar": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.09, tiltedShrink: 0.05 }
        }
    },

    // ── ColecoVision ──
    "colecovision": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.09, tiltedShrink: 0.05 }
        }
    },

    // ── Commodore 64 ──
    "c64": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.09, tiltedShrink: 0.05 }
        }
    },

    // ── MSX ──
    "msx": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.09, tiltedShrink: 0.05 }
        }
    },

    // ── Neo Geo ──
    "neogeo": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.09, tiltedShrink: 0.05 }
        }
    },

    // ── PC Engine / TurboGrafx-16 ──
    "pcengine": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.09, tiltedShrink: 0.05 }
        }
    },

    // ── PlayStation 3 ──
    "ps3": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.07, tiltedShrink: 0.03 },
            verticalDeformation: { enabled: true, frontalGrow: 0.05, tiltedShrink: 0.02 }
        }
    },

    // ── Sega Saturn ──
    "saturn": {
        scale: 1.0,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.09, tiltedShrink: 0.05 }
        }
    },

    // ── Wii U ──
    "wiiu": {
        scale: 0.9,
        positionX: 0.5,
        positionY: 0.5,
        additionalRotation: 0,
        opacity: 1.0,
        enabled: true,
        isLeft: true,
        isRight: true,
        perspective: {
            enableCompensation: true,
            scaleCompensation: 0.8,
            positionCompensation: { offsetXFactor: 0.1, offsetYFactor: 0.05 },
            dynamicDepth: { enabled: true, baseZ: 100, angleZVariation: 20 },
            horizontalDeformation: { enabled: true, frontalGrow: 0.07, tiltedShrink: 0.03 },
            verticalDeformation: { enabled: true, frontalGrow: 0.05, tiltedShrink: 0.02 }
        }
    }
};

function getPlatformLogoConfig(platform) {
    var defaultLogoConfig = JSON.parse(JSON.stringify(platformLogoConfigs.default));

    if (!platform) return defaultLogoConfig;

    var platformKey = platform.toLowerCase();
    var specificConfig = platformLogoConfigs[platformKey];

    if (specificConfig) {
        for (var key in specificConfig) {
            if (specificConfig.hasOwnProperty(key)) {
                if (typeof specificConfig[key] === 'object' && specificConfig[key] !== null && !Array.isArray(specificConfig[key])) {
                    defaultLogoConfig[key] = JSON.parse(JSON.stringify(defaultLogoConfig[key] || {}));
                    for (var subKey in specificConfig[key]) {
                        if (specificConfig[key].hasOwnProperty(subKey)) {
                            defaultLogoConfig[key][subKey] = specificConfig[key][subKey];
                        }
                    }
                } else {
                    defaultLogoConfig[key] = specificConfig[key];
                }
            }
        }
    }

    if (typeof defaultLogoConfig.isLeft === 'undefined') { defaultLogoConfig.isLeft = platformLogoConfigs.default.isLeft; }
    if (typeof defaultLogoConfig.isRight === 'undefined') { defaultLogoConfig.isRight = platformLogoConfigs.default.isRight; }

    return defaultLogoConfig;
}

function calculateLogoPerspective(logoConfig, rotationAngle, sideDepth) {
    var perspective = logoConfig.perspective;
    if (!perspective || !perspective.enableCompensation) {
        return {
            scale: logoConfig.scale,
            offsetX: 0,
            offsetY: 0,
            opacity: logoConfig.opacity,
            zIndex: 100,
            deformation: { skewX: 0, skewY: 0, scaleX: 1.0, scaleY: 1.0 }
        };
    }

    var normalizedAngle = Math.abs(rotationAngle) / 90.0;
    var angleRadians = (Math.abs(rotationAngle) * Math.PI) / 180.0;

    var perspectiveScale = logoConfig.scale;
    if (perspective.scaleCompensation > 0) {
        var scaleReduction = normalizedAngle * perspective.scaleCompensation * 0.3;
        perspectiveScale *= (1.0 - scaleReduction);
    }

    var offsetX = 0, offsetY = 0;
    if (perspective.positionCompensation) {
        offsetX = Math.sin(angleRadians) * sideDepth * perspective.positionCompensation.offsetXFactor;
        offsetY = Math.cos(angleRadians) * sideDepth * perspective.positionCompensation.offsetYFactor;
    }

    var finalOpacity = logoConfig.opacity;

    var dynamicZ = perspective.dynamicDepth.baseZ;
    if (perspective.dynamicDepth && perspective.dynamicDepth.enabled) {
        dynamicZ += normalizedAngle * perspective.dynamicDepth.angleZVariation;
    }

    var deformation = {
        skewX: 0,
        skewY: 0,
        scaleX: 1.0,
        scaleY: 1.0
    };

    if (perspective.horizontalDeformation && perspective.horizontalDeformation.enabled) {
        var frontalGrowX = perspective.horizontalDeformation.frontalGrow || 0.0;
        var tiltedShrinkX = perspective.horizontalDeformation.tiltedShrink || 0.0;

        if (frontalGrowX === 0.0 && tiltedShrinkX === 0.0) {
            var frontalShrinkX = perspective.horizontalDeformation.frontalShrink || 0.0;
            var tiltedStretchX = perspective.horizontalDeformation.tiltedStretch || 0.0;
            deformation.scaleX = (1.0 - frontalShrinkX) + (tiltedStretchX + frontalShrinkX) * normalizedAngle;
        } else {
            deformation.scaleX = (1.0 + frontalGrowX) - (frontalGrowX + tiltedShrinkX) * normalizedAngle;
        }
    }

    if (perspective.verticalDeformation && perspective.verticalDeformation.enabled) {
        var frontalGrowY = perspective.verticalDeformation.frontalGrow || 0.0;
        var tiltedShrinkY = perspective.verticalDeformation.tiltedShrink || 0.0;

        if (frontalGrowY === 0.0 && tiltedShrinkY === 0.0) {
            var frontalShrinkY = perspective.verticalDeformation.frontalShrink || 0.0;
            var tiltedStretchY = perspective.verticalDeformation.tiltedStretch || 0.0;
            deformation.scaleY = (1.0 - frontalShrinkY) + (tiltedStretchY + frontalShrinkY) * normalizedAngle;
        } else {
            deformation.scaleY = (1.0 + frontalGrowY) - (frontalGrowY + tiltedShrinkY) * normalizedAngle;
        }
    }

    return {
        scale: perspectiveScale,
        offsetX: offsetX,
        offsetY: offsetY,
        opacity: finalOpacity,
        zIndex: Math.round(dynamicZ),
        deformation: deformation
    };
}
