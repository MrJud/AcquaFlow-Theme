.pragma library

var platformBoxConfigs = {

    "default": {
        aspectRatio: 0.7,
        backAspectRatio: 1.0,
        boxDepth: 42,
        boxSideColor: "#E8E8E8",
        reflectionFactors: {
            top: 0.32, bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            // Fallback width ratio relative to base height
            fallbackWidthRatio: 0.65,
            // Fallback height ratio relative to base height
            fallbackHeightRatio: 1.0,
            color1: "#65444444",
            // Secondary color for fallback gradient
            color2: "#55222222"
        },
        selectedCoverScale: null,
        selectedCoverPosition: null,

        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2,

        // REMOVED: frontCoverTransforms
    },

    "lastplayed": {
        aspectRatio: 0.7,
        backAspectRatio: 1.0,
        boxDepth: 42,
        boxSideColor: "#4A90E2",  // Distinctive blue for Last Played
        reflectionFactors: {
            top: 0.32, bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.2,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#654A90E2",  // Blue gradient for Last Played
            color2: "#55336BB3"
        },
        selectedCoverScale: null,
        selectedCoverPosition: null,
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "favourites": {
        aspectRatio: 0.7,
        backAspectRatio: 1.0,
        boxDepth: 42,
        boxSideColor: "#F5A623",  // Golden for Favourites
        reflectionFactors: {
            top: 0.32, bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.2,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65F5A623",  // Golden gradient for Favourites
            color2: "#55C47D0A"
        },
        selectedCoverScale: null,
        selectedCoverPosition: null,
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "nes": {
        aspectRatio: 0.88,
        backAspectRatio: 0.88,
        boxDepth: 50,
        boxSideColor: "#A0A0A0",
        reflectionFactors: {
            top: 0.32, bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65555555",
            color2: "#55333333"
        },
        selectedCoverScale: 1.3,
        selectedCoverPosition: { x: 0.15, y: 0.55 },
        darkenSideCovers: true,
        sideCoverDarkenStrength: 0.3
    },

    "snes": {
        aspectRatio: 0.72,
        backAspectRatio: 0.72,
        boxDepth: 55,
        boxSideColor: "#C0C0C0",
        reflectionFactors: {
            top: 0.35, bottom: -0.12
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.2,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: -0.05,
            carousel2: -0.05,
            carousel3: -0.10,
            carousel4: -0.05
        },
        carouselFrontYOffsets: {
            carousel1: -0.05,
            carousel2: -0.10,
            carousel3: -0.10,
            carousel4: -0.05
        },
        carouselPathSpreads: {
            carousel1: 1.05,
            carousel2: 1.40,
            carousel3: 1.05,
            carousel4: 1.05
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.55,
            carousel2: 0.55,
            carousel3: 0.55,
            carousel4: 0.55
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65 * 0.7,
            color1: "#654D465A",
            color2: "#552C2834"
        },
        selectedCoverScale: 1.8,
        selectedCoverPosition: { x: 0.4, y: 0.69 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "n64": {
        aspectRatio: 0.76,
        backAspectRatio: 0.6,
        boxDepth: 60,
        boxSideColor: "#B0B0B0",
        reflectionFactors: {
            top: 0.75, bottom: -0.38
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: -0.05,
            carousel2: -0.05,
            carousel3: -0.10,
            carousel4: -0.05
        },
        carouselFrontYOffsets: {
            carousel1: -0.05,
            carousel2: -0.10,
            carousel3: -0.15,
            carousel4: -0.10
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.1
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.55,
            carousel2: 0.55,
            carousel3: 0.55,
            carousel4: 0.55
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65 * 0.7,
            color1: "#65505050",
            color2: "#55303030"
        },
        selectedCoverScale: 1.7,
        selectedCoverPosition: { x: 0.4, y: 0.74 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "gc": {
        aspectRatio: 0.7,
        backAspectRatio: 0.7,
        boxDepth: 38,
        boxSideColor: "#404040",
        reflectionFactors: {
            top: 0.3,
            bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.25,
            carousel3: 1.15,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.55,
            carousel3: 0.50,
            carousel4: 1.00
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#653A315A",
            color2: "#551E1933"
        },
        selectedCoverScale: 1.7,
        selectedCoverPosition: { x: 0.4, y: 0.86 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "wii": {
        aspectRatio: 0.7,
        backAspectRatio: 0.67,
        boxDepth: 35,
        boxSideColor: "#FFFFFF",
        reflectionFactors: {
            top: 0.4, bottom: -0.2
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.15,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 0.80,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65325F8C",
            color2: "#55193550"
        },
        selectedCoverScale: 1.7,
        selectedCoverPosition: { x: 0.4, y: 0.87 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "switch": {
        aspectRatio: 0.59,
        backAspectRatio: 0.61,
        boxDepth: 22,
        boxSideColor: "#E60012",
        reflectionFactors: {
            top: 0.32, bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.15,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0.05,
            carousel2: 0.05,
            carousel3: 0.05,
            carousel4: 0.05
        },
        carouselFrontYOffsets: {
            carousel1: 0.05,
            carousel2: 0.05,
            carousel3: 0.05,
            carousel4: 0.05
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.1,
            carousel3: 1.0,
            carousel4: 1.1
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#658C1F1F",
            color2: "#55581313"
        },
        selectedCoverScale: 1.7,
        selectedCoverPosition: { x: 0.35, y: 0.95 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "gb": {
        aspectRatio: 0.75,
        backAspectRatio: 0.75,
        boxDepth: 42,
        boxSideColor: "#A0A0A0",
        reflectionFactors: {
            top: 0.72, bottom: -0.28
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65,
            color1: "#657A8450",
            color2: "#554A5030"
        },
        selectedCoverScale: 1.35,
        selectedCoverPosition: { x: 0.46, y: 0.73 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "gba": {
        aspectRatio: 0.75,
        backAspectRatio: 0.70,
        boxDepth: 42,
        boxSideColor: "#D0D0D0",
        reflectionFactors: {
            top: 0.72, bottom: -0.28
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.15,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: -0.05,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: -0.05,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.15,
            carousel3: 1.0,
            carousel4: 1.1
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 1.15,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65,
            color1: "#65585078",
            color2: "#5535304A"
        },
        selectedCoverScale: 1.7,
        selectedCoverPosition: { x: 0.4, y: 0.8 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "gbc": {
        aspectRatio: 0.75,
        backAspectRatio: 0.75,
        boxDepth: 42,
        boxSideColor: "#DAA520",
        reflectionFactors: {
            top: 0.72, bottom: -0.28
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65,
            color1: "#65785820",
            color2: "#554A3613"
        },
        selectedCoverScale: 1.35,
        selectedCoverPosition: { x: 0.46, y: 0.73 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "nds": {
        aspectRatio: 0.88,
        backAspectRatio: 0.88,
        boxDepth: 42,
        boxSideColor: "#A0A0A0",
        reflectionFactors: {
            top: 0.49, bottom: -0.2
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.15,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: -0.05,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: -0.05,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.2,
            carousel3: 1.0,
            carousel4: 1.1
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65,
            color1: "#65555555",
            color2: "#55333333"
        },
        selectedCoverScale: 1.7,
        selectedCoverPosition: { x: 0.4, y: 0.8 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "3ds": {
        aspectRatio: 0.88,
        backAspectRatio: 0.61,
        boxDepth: 30,
        boxSideColor: "#E0E0E0",
        reflectionFactors: {
            top: 0.45, bottom: -0.2
        },
        carouselScales: {
            carousel1: 1.25,
            carousel2: 1.25,
            carousel3: 1.25,
            carousel4: 1.25
        },
        carouselFrontCoverScales: {
            carousel1: 1.35,
            carousel2: 1.35,
            carousel3: 1.15,
            carousel4: 1.35
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: -0.05,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: -0.05,
            carousel4: -0.05
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 1.00
        },
        fallback: {
            fallbackWidthRatio: 0.6,
            fallbackHeightRatio: 0.6,
            color1: "#65555555",
            color2: "#55333333"
        },
        selectedCoverScale: 1.7,
        selectedCoverPosition: { x: 0.4, y: 0.8 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "mastersystem": {
        aspectRatio: 0.72,
        backAspectRatio: 0.72,
        boxDepth: 40,
        boxSideColor: "#303030",
        reflectionFactors: {
            top: 0.32,
            bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65444444",
            color2: "#55222222"
        },
        selectedCoverScale: 1.38,
        selectedCoverPosition: { x: 0.39, y: 0.58 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "megadrive": {
        aspectRatio: 0.7,
        backAspectRatio: 0.7,
        boxDepth: 45,
        boxSideColor: "#101010",
        reflectionFactors: {
            top: 0.32, bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65402850",
            color2: "#55201428"
        },
        selectedCoverScale: 1.4,
        selectedCoverPosition: { x: 0.40, y: 0.58 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "genesis": {
        aspectRatio: 0.7,
        backAspectRatio: 0.7,
        boxDepth: 45,
        boxSideColor: "#101010",
        reflectionFactors: {
            top: 0.32, bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65602020",
            color2: "#55301010"
        },
        selectedCoverScale: 1.4,
        selectedCoverPosition: { x: 0.40, y: 0.58 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "dreamcast": {
        aspectRatio: 0.85,
        backAspectRatio: 0.85,
        boxDepth: 20,
        boxSideColor: "#FF6600",
        reflectionFactors: {
            top: 0.25, bottom: -0.05
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65,
            color1: "#65305080",
            color2: "#55182840"
        },
        selectedCoverScale: 1.38,
        selectedCoverPosition: { x: 0.43, y: 0.59 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "segacd": {
        aspectRatio: 0.85,
        backAspectRatio: 0.85,
        boxDepth: 25,
        boxSideColor: "#004080",
        reflectionFactors: {
            top: 0.25,
            bottom: -0.05
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65,
            color1: "#65204060",
            color2: "#55102030"
        },
        selectedCoverScale: 1.25,
        selectedCoverPosition: { x: 0.44, y: 0.60 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "sega32x": {
        aspectRatio: 0.7,
        backAspectRatio: 0.7,
        boxDepth: 45,
        boxSideColor: "#D04040",
        reflectionFactors: {
            top: 0.32,
            bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65702020",
            color2: "#55401010"
        },
        selectedCoverScale: 1.42,
        selectedCoverPosition: { x: 0.39, y: 0.57 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "gamegear": {
        aspectRatio: 0.7,
        backAspectRatio: 0.7,
        boxDepth: 35,
        boxSideColor: "#202020",
        reflectionFactors: {
            top: 0.32,
            bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65444444",
            color2: "#55222222"
        },
        selectedCoverScale: 1.3,
        selectedCoverPosition: { x: 0.42, y: 0.57 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "psx": {
        aspectRatio: 0.84,
        backAspectRatio: 0.72,
        boxDepth: 20,
        boxSideColor: "#303030",
        reflectionFactors: {
            top: 0.25, bottom: -0.05
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.35,
            carousel3: 1.15,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.1
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65,
            color1: "#65444444",
            color2: "#55222222"
        },
        selectedCoverScale: 1.65,
        selectedCoverPosition: { x: 0.4, y: 0.78 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "ps2": {
        aspectRatio: 0.7,
        backAspectRatio: 0.7,
        boxDepth: 40,
        boxSideColor: "#1E1E1E",
        reflectionFactors: {
            top: 0.32, bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.15,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0.05,
            carousel2: 0.05,
            carousel3: 0,
            carousel4: 0.05
        },
        carouselFrontYOffsets: {
            carousel1: 0.05,
            carousel2: 0.05,
            carousel3: 0.05,
            carousel4: 0.05
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.15,
            carousel3: 1.0,
            carousel4: 1.1
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65202050",
            color2: "#55101028"
        },
        selectedCoverScale: 1.6,
        selectedCoverPosition: { x: 0.4, y: 0.87 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "psp": {
        aspectRatio: 0.58,
        backAspectRatio: 0.58,
        boxDepth: 28,
        boxSideColor: "#F0F0F0",
        reflectionFactors: {
            top: 0.32, bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.15,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0.1,
            carousel2: 0.1,
            carousel3: 0.05,
            carousel4: 0.1
        },
        carouselFrontYOffsets: {
            carousel1: 0.1,
            carousel2: 0.1,
            carousel3: 0.1,
            carousel4: 0.1
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.1,
            carousel3: 1.0,
            carousel4: 1.15
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65444444",
            color2: "#55222222"
        },
        selectedCoverScale: 1.65,
        selectedCoverPosition: { x: 0.37, y: 0.9 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "vita": {
        aspectRatio: 0.75,
        backAspectRatio: 0.7,
        boxDepth: 26,
        boxSideColor: "#004080",
        reflectionFactors: {
            top: 0.32, bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.15,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.1
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 1.0
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65204060",
            color2: "#55102030"
        },
        selectedCoverScale: 1.65,
        selectedCoverPosition: { x: 0.37, y: 0.87 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    "windows": {
        aspectRatio: 0.7,
        backAspectRatio: 0.7,
        boxDepth: 40,
        boxSideColor: "#D0D0D0",
        reflectionFactors: {
            top: 0.32, bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.15,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.1,
            carousel3: 1.0,
            carousel4: 1.1
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65285078",
            color2: "#5514283C"
        },
        selectedCoverScale: 1.7,
        selectedCoverPosition: { x: 0.4, y: 0.85 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── 3DO ──
    "3do": {
        aspectRatio: 0.85,
        backAspectRatio: 0.85,
        boxDepth: 20,
        boxSideColor: "#D4AF37",
        reflectionFactors: {
            top: 0.25,
            bottom: -0.05
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65,
            color1: "#65806020",
            color2: "#55403010"
        },
        selectedCoverScale: 1.3,
        selectedCoverPosition: { x: 0.42, y: 0.60 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── Arcade ──
    "arcade": {
        aspectRatio: 0.75,
        backAspectRatio: 0.75,
        boxDepth: 10,
        boxSideColor: "#333333",
        reflectionFactors: {
            top: 0.3,
            bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65801010",
            color2: "#55400808"
        },
        selectedCoverScale: 1.35,
        selectedCoverPosition: { x: 0.40, y: 0.58 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── Atari 2600 ──
    "atari2600": {
        aspectRatio: 0.78,
        backAspectRatio: 0.78,
        boxDepth: 30,
        boxSideColor: "#C1440E",
        reflectionFactors: {
            top: 0.32,
            bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65804020",
            color2: "#55402010"
        },
        selectedCoverScale: 1.3,
        selectedCoverPosition: { x: 0.42, y: 0.57 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── Atari Jaguar ──
    "atarijaguar": {
        aspectRatio: 0.72,
        backAspectRatio: 0.72,
        boxDepth: 40,
        boxSideColor: "#8B0000",
        reflectionFactors: {
            top: 0.32,
            bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65600808",
            color2: "#55300404"
        },
        selectedCoverScale: 1.35,
        selectedCoverPosition: { x: 0.40, y: 0.58 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── ColecoVision ──
    "colecovision": {
        aspectRatio: 0.75,
        backAspectRatio: 0.75,
        boxDepth: 30,
        boxSideColor: "#1B1B1B",
        reflectionFactors: {
            top: 0.32,
            bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65444444",
            color2: "#55222222"
        },
        selectedCoverScale: 1.3,
        selectedCoverPosition: { x: 0.42, y: 0.57 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── Commodore 64 ──
    "c64": {
        aspectRatio: 0.75,
        backAspectRatio: 0.75,
        boxDepth: 25,
        boxSideColor: "#6C5EB5",
        reflectionFactors: {
            top: 0.32,
            bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#654030A0",
            color2: "#55201850"
        },
        selectedCoverScale: 1.3,
        selectedCoverPosition: { x: 0.42, y: 0.57 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── MSX ──
    "msx": {
        aspectRatio: 0.75,
        backAspectRatio: 0.75,
        boxDepth: 25,
        boxSideColor: "#CC0000",
        reflectionFactors: {
            top: 0.32,
            bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65800808",
            color2: "#55400404"
        },
        selectedCoverScale: 1.3,
        selectedCoverPosition: { x: 0.42, y: 0.57 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── Neo Geo ──
    "neogeo": {
        aspectRatio: 0.72,
        backAspectRatio: 0.72,
        boxDepth: 40,
        boxSideColor: "#D4AF37",
        reflectionFactors: {
            top: 0.32,
            bottom: -0.1
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65806020",
            color2: "#55403010"
        },
        selectedCoverScale: 1.35,
        selectedCoverPosition: { x: 0.40, y: 0.58 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── PC Engine / TurboGrafx-16 ──
    "pcengine": {
        aspectRatio: 0.85,
        backAspectRatio: 0.85,
        boxDepth: 20,
        boxSideColor: "#FF4500",
        reflectionFactors: {
            top: 0.25,
            bottom: -0.05
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65,
            color1: "#65802000",
            color2: "#55401000"
        },
        selectedCoverScale: 1.25,
        selectedCoverPosition: { x: 0.44, y: 0.60 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── PlayStation 3 ──
    "ps3": {
        aspectRatio: 0.7,
        backAspectRatio: 0.7,
        boxDepth: 38,
        boxSideColor: "#1C1C1C",
        reflectionFactors: {
            top: 0.35,
            bottom: -0.15
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.15,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65102040",
            color2: "#55081020"
        },
        selectedCoverScale: 1.7,
        selectedCoverPosition: { x: 0.4, y: 0.85 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── Sega Saturn ──
    "saturn": {
        aspectRatio: 0.85,
        backAspectRatio: 0.85,
        boxDepth: 25,
        boxSideColor: "#303030",
        reflectionFactors: {
            top: 0.25,
            bottom: -0.05
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.3,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 0.65,
            color1: "#65204060",
            color2: "#55102030"
        },
        selectedCoverScale: 1.25,
        selectedCoverPosition: { x: 0.44, y: 0.60 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    },

    // ── Wii U ──
    "wiiu": {
        aspectRatio: 0.7,
        backAspectRatio: 0.7,
        boxDepth: 35,
        boxSideColor: "#009AC7",
        reflectionFactors: {
            top: 0.35,
            bottom: -0.15
        },
        carouselScales: {
            carousel1: 1.2,
            carousel2: 1.2,
            carousel3: 1.2,
            carousel4: 1.2
        },
        carouselFrontCoverScales: {
            carousel1: 1.3,
            carousel2: 1.3,
            carousel3: 1.15,
            carousel4: 1.3
        },
        carouselYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselFrontYOffsets: {
            carousel1: 0,
            carousel2: 0,
            carousel3: 0,
            carousel4: 0
        },
        carouselPathSpreads: {
            carousel1: 1.0,
            carousel2: 1.0,
            carousel3: 1.0,
            carousel4: 1.0
        },
        carouselPathSpreadsFewCovers: {
            carousel1: 0.50,
            carousel2: 0.50,
            carousel3: 0.50,
            carousel4: 0.50
        },
        fallback: {
            fallbackWidthRatio: 0.65,
            fallbackHeightRatio: 1.0,
            color1: "#65008090",
            color2: "#55004048"
        },
        selectedCoverScale: 1.7,
        selectedCoverPosition: { x: 0.4, y: 0.85 },
        darkenSideCovers: false,
        sideCoverDarkenStrength: 0.2
    }
};

var _originalPlatformBoxConfigs = JSON.parse(JSON.stringify(platformBoxConfigs));

function getOriginalDefaults(platform, mode, gameCount) {
    var config = _originalPlatformBoxConfigs[platform] || _originalPlatformBoxConfigs["default"];
    if (!config) config = _originalPlatformBoxConfigs["default"];

    var spread;
    if (gameCount > 0 && gameCount <= 6 && config.carouselPathSpreadsFewCovers && config.carouselPathSpreadsFewCovers[mode] !== undefined) {
        spread = config.carouselPathSpreadsFewCovers[mode];
    } else {
        spread = (config.carouselPathSpreads && config.carouselPathSpreads[mode] !== undefined) ? config.carouselPathSpreads[mode] : 1.0;
    }

    return {
        scale: (config.carouselScales && config.carouselScales[mode] !== undefined) ? config.carouselScales[mode] : 1.0,
        frontScale: (config.carouselFrontCoverScales && config.carouselFrontCoverScales[mode] !== undefined) ? config.carouselFrontCoverScales[mode] : 1.0,
        yOffset: (config.carouselYOffsets && config.carouselYOffsets[mode] !== undefined) ? config.carouselYOffsets[mode] : 0.0,
        centerYOffset: (config.carouselFrontYOffsets && config.carouselFrontYOffsets[mode] !== undefined) ? config.carouselFrontYOffsets[mode] : 0.0,
        spread: spread,
        centerSpacing: 0.142
    };
}

function restoreRuntimeDefaults(platform, mode, gameCount) {
    var config = platformBoxConfigs[platform];
    if (!config) return;

    var defaults = getOriginalDefaults(platform, mode, gameCount);

    if (config.carouselScales) config.carouselScales[mode] = defaults.scale;
    if (config.carouselFrontCoverScales) config.carouselFrontCoverScales[mode] = defaults.frontScale;
    if (config.carouselYOffsets) config.carouselYOffsets[mode] = defaults.yOffset;
    if (config.carouselFrontYOffsets) config.carouselFrontYOffsets[mode] = defaults.centerYOffset;
    if (config.carouselPathSpreads) config.carouselPathSpreads[mode] = defaults.spread;
}

function getPlatformBoxConfig(platform) {
    var finalConfig = JSON.parse(JSON.stringify(platformBoxConfigs.default));

    if (platform) {
        var platformKey = platform.toLowerCase();
        var specificConfig = platformBoxConfigs[platformKey];

        if (specificConfig) {
            // Merge specificConfig onto finalConfig
            for (var key in specificConfig) {
                if (specificConfig.hasOwnProperty(key)) {
                    if (typeof specificConfig[key] === 'object' && specificConfig[key] !== null && !Array.isArray(specificConfig[key])) {
                        // Deep merge for nested objects
                        finalConfig[key] = JSON.parse(JSON.stringify(finalConfig[key] || {}));
                        for (var subKey in specificConfig[key]) {
                            if (specificConfig[key].hasOwnProperty(subKey)) {
                                finalConfig[key][subKey] = specificConfig[key][subKey];
                            }
                        }
                    } else {
                        finalConfig[key] = specificConfig[key];
                    }
                }
            }
        }
    }

    if (!finalConfig.fallback) {
        finalConfig.fallback = JSON.parse(JSON.stringify(platformBoxConfigs.default.fallback));
    }
    // REMOVED: if (!finalConfig.frontCoverTransforms) { ... }

    finalConfig.platform = platform ? platform.toLowerCase() : "default";

    return finalConfig;
}