// PathViewConfigs.js
// ARCHITECTURE:
// 7 key positions: 1(pivot left), 6(influence left), 7(adjacent left),
// 8(center), 9(adjacent right), 10(influence right), 15(pivot right)
// PROPERTIES:
// yOffset, scale, rotationY, rotationX, opacity, zIndex: standard properties
// Position 8 (center): no gap (always x=0)

.pragma library

// CAROUSEL 1 (Classic Coverflow)
var Carousel1 = {
    useAdaptiveOpacity: true,
    useAdaptiveSpacing: false,
    useDynamicBounce: true,
    spreadMultiplier: 1.0,
    globalYOffset: 0.0,

    // LEFT PIVOT (far anchor)
    position1:  { gap: 0.143, yOffset: 0.0, scale: 0.42, rotationY: 30,  rotationX: 0, opacity: "adaptive", zIndex: -200 },

    // LEFT INFLUENCE SOURCE
    position6:  { gap: 0.143, yOffset: 0.0, scale: 0.69, rotationY: 50,  rotationX: 0, opacity: 0.95, zIndex: -10 },

    // ADJACENT LEFT (free, independent)
    position7:  { gap: 0.142, yOffset: 0.0, scale: 0.72, rotationY: 53,  rotationX: 0, opacity: 1.0,  zIndex: 0 },

    // CENTER (free, independent)
    position8:  { yOffset: 0.0, scale: 1.0, rotationY: 0, rotationX: 0, opacity: 1.0, zIndex: 450 },

    // ADJACENT RIGHT (free, independent)
    position9:  { gap: 0.142, yOffset: 0.0, scale: 0.72, rotationY: -53, rotationX: 0, opacity: 1.0,  zIndex: 0 },

    // RIGHT INFLUENCE SOURCE
    position10: { gap: 0.143, yOffset: 0.0, scale: 0.69, rotationY: -50, rotationX: 0, opacity: 0.95, zIndex: -10 },

    // RIGHT PIVOT (far anchor)
    position15: { gap: 0.143, yOffset: 0.0, scale: 0.42, rotationY: -40, rotationX: 0, opacity: "adaptive", zIndex: -200 }
};

var Carousel2 = {
    useAdaptiveOpacity: true,
    useAdaptiveSpacing: false,
    useDynamicBounce: false,
    spreadMultiplier: 1.0,
    globalYOffset: 0.0,

    position1:  { gap: 0.143, yOffset: 0.0, scale: 0.82, rotationY: 0, rotationX: 0, opacity: "adaptive", zIndex: -200 },
    position6:  { gap: 0.143, yOffset: 0.0, scale: 0.85, rotationY: 0, rotationX: 0, opacity: 1.0,        zIndex: -10 },
    position7:  { gap: 0.142, yOffset: 0.0, scale: 0.92, rotationY: 0, rotationX: 0, opacity: 1.0,        zIndex: 0 },
    position8:  { yOffset: 0.0, scale: 1.0,  rotationY: 0, rotationX: 0, opacity: 1.0,        zIndex: 450 },
    position9:  { gap: 0.142, yOffset: 0.0, scale: 0.92, rotationY: 0, rotationX: 0, opacity: 1.0,        zIndex: 0 },
    position10: { gap: 0.143, yOffset: 0.0, scale: 0.85, rotationY: 0, rotationX: 0, opacity: 1.0,        zIndex: -10 },
    position15: { gap: 0.143, yOffset: 0.0, scale: 0.82, rotationY: 0, rotationX: 0, opacity: "adaptive", zIndex: -200 }
};

// CAROUSEL 3 (Perspective Tunnel)
var Carousel3 = {
    useAdaptiveOpacity: true,
    useAdaptiveSpacing: false,
    useDynamicBounce: false,
    spreadMultiplier: 0.6,
    globalYOffset: 0.0,

    position1:  { gap: 0.293, yOffset: 0.0125, scale: 1.15, rotationY: 45,  rotationX: 0, opacity: "adaptive", zIndex: 200 },
    // INTERPOLATE LEFT (formerly auto, now manual)
    position2:  { gap: 0.273, yOffset: 0.036,  scale: 0.98, rotationY: 48,  rotationX: 0, opacity: 1.0,        zIndex: 162 },
    position3:  { gap: 0.203, yOffset: 0.060,  scale: 0.81, rotationY: 51,  rotationX: 0, opacity: 1.0,        zIndex: 124 },
    position4:  { gap: 0.123, yOffset: 0.083,  scale: 0.64, rotationY: 54,  rotationX: 0, opacity: 1.0,        zIndex: 86 },
    position5:  { gap: 0.103, yOffset: 0.107,  scale: 0.47, rotationY: 57,  rotationX: 0, opacity: 1.0,        zIndex: 48 },
    // LEFT INFLUENCE
    position6:  { gap: 0.100, yOffset: 0.13,   scale: 0.30, rotationY: 60,  rotationX: 0, opacity: 1.0,        zIndex: 10 },
    // ADJACENT LEFT
    position7:  { gap: 0.142, yOffset: 0.13,   scale: 0.25, rotationY: 62,  rotationX: 0, opacity: 1.0,        zIndex: 0 },
    // CENTER
    position8:  { yOffset: 0.02, scale: 1.2,  rotationY: 0,   rotationX: 0, opacity: 1.0,        zIndex: 450 },
    // ADJACENT RIGHT
    position9:  { gap: 0.142, yOffset: 0.13,   scale: 0.25, rotationY: -62, rotationX: 0, opacity: 1.0,        zIndex: 0 },
    // RIGHT INFLUENCE
    position10: { gap: 0.100, yOffset: 0.13,   scale: 0.30, rotationY: -60, rotationX: 0, opacity: 1.0,        zIndex: 10 },
    // INTERPOLATE RIGHT (formerly auto, now manual)
    position11: { gap: 0.103, yOffset: 0.107,  scale: 0.47, rotationY: -57, rotationX: 0, opacity: 1.0,        zIndex: 48 },
    position12: { gap: 0.123, yOffset: 0.083,  scale: 0.64, rotationY: -54, rotationX: 0, opacity: 1.0,        zIndex: 86 },
    position13: { gap: 0.203, yOffset: 0.060,  scale: 0.81, rotationY: -51, rotationX: 0, opacity: 1.0,        zIndex: 124 },
    position14: { gap: 0.273, yOffset: 0.036,  scale: 0.98, rotationY: -48, rotationX: 0, opacity: 1.0,        zIndex: 162 },
    position15: { gap: 0.293, yOffset: 0.0125, scale: 1.15, rotationY: -45, rotationX: 0, opacity: "adaptive", zIndex: 200 }
};

// CAROUSEL 4 (Compact Fan)
var Carousel4 = {
    useAdaptiveOpacity: true,
    useAdaptiveSpacing: false,
    useDynamicBounce: true,
    spreadMultiplier: 1.0,
    globalYOffset: 0.0,

    position1:  { gap: 0.05,  yOffset: 0.0,  scale: 0.85, rotationY: 60,  rotationX: 0, opacity: "adaptive", zIndex: -200 },
    position6:  { gap: 0.052, yOffset: 0.0,  scale: 0.85, rotationY: 65,  rotationX: 0, opacity: 0.85,       zIndex: -10 },
    position7:  { gap: 0.092, yOffset: 0.0,  scale: 0.85, rotationY: 70,  rotationX: 0, opacity: 1.0,        zIndex: 0 },
    position8:  { yOffset: 0.03, scale: 1.0,  rotationY: 0,   rotationX: 0, opacity: 1.0,        zIndex: 450 },
    position9:  { gap: 0.092, yOffset: 0.0,  scale: 0.85, rotationY: -75, rotationX: 0, opacity: 1.0,        zIndex: 0 },
    position10: { gap: 0.052, yOffset: 0.0,  scale: 0.85, rotationY: -65, rotationX: 0, opacity: 0.85,       zIndex: -10 },
    position15: { gap: 0.05,  yOffset: 0.0,  scale: 0.85, rotationY: -60, rotationX: 0, opacity: "adaptive", zIndex: -200 }
};

// CORE FUNCTIONS

function _clonePos(pos) {
    var copy = {};
    for (var key in pos) {
        if (pos.hasOwnProperty(key)) copy[key] = pos[key];
    }
    return copy;
}

function _lerp(a, b, t) {
    return a + (b - a) * t;
}

// Interpolate all properties between two key positions
// gameCount: resolves "adaptive" opacity
function _lerpPosition(posA, posB, t, gameCount) {
    var result = {};

    // Gap
    result.gap = _lerp(posA.gap || 0.143, posB.gap || 0.143, t);

    // yOffset
    result.yOffset = _lerp(posA.yOffset || 0, posB.yOffset || 0, t);

    // Scale
    var scaleA = (typeof posA.scale === "number") ? posA.scale : 1.0;
    var scaleB = (typeof posB.scale === "number") ? posB.scale : 1.0;
    result.scale = _lerp(scaleA, scaleB, t);

    // Rotations
    result.rotationY = _lerp(posA.rotationY || 0, posB.rotationY || 0, t);
    result.rotationX = _lerp(posA.rotationX || 0, posB.rotationX || 0, t);

    var opA = (posA.opacity === "adaptive") ? getAdaptiveOpacity(gameCount, posA.opacity) : posA.opacity;
    var opB = (posB.opacity === "adaptive") ? getAdaptiveOpacity(gameCount, posB.opacity) : posB.opacity;
    result.opacity = _lerp(opA, opB, t);

    result.zIndex = Math.round(_lerp(posA.zIndex || 0, posB.zIndex || 0, t));

    return result;
}

// ARCHITECTURE:
// pos8 (center): independent
// pos7, pos9 (adjacent): independent
// pos6, pos10 (influence sources): independent
function interpolatePositions(config, gameCount) {
    var result = {};

    result.position1  = _clonePos(config.position1);
    result.position6  = _clonePos(config.position6);
    result.position7  = _clonePos(config.position7);
    result.position8  = _clonePos(config.position8);
    result.position9  = _clonePos(config.position9);
    result.position10 = _clonePos(config.position10);
    result.position15 = _clonePos(config.position15);

    for (var i = 2; i <= 5; i++) {
        var key = "position" + i;
        if (config[key]) {
            result[key] = _clonePos(config[key]);
        } else {
            var t = (i - 1) / 5;
            result[key] = _lerpPosition(config.position1, config.position6, t, gameCount);
        }
    }

    for (var i = 11; i <= 14; i++) {
        var key = "position" + i;
        if (config[key]) {
            result[key] = _clonePos(config[key]);
        } else {
            var t = (i - 10) / 5;
            result[key] = _lerpPosition(config.position10, config.position15, t, gameCount);
        }
    }

    return result;
}

// Returns: { position1: xValue, position2: xValue, ..., position15: xValue }
function calculatePositionsFromGaps(allPositions) {
    var xPositions = {};

    xPositions.position8 = 0.0;

    var currentX = 0.0;
    for (var i = 7; i >= 1; i--) {
        var gap = allPositions["position" + i].gap || 0.143;
        currentX -= gap;
        xPositions["position" + i] = currentX;
    }

    currentX = 0.0;
    for (var i = 9; i <= 15; i++) {
        var gap = allPositions["position" + i].gap || 0.143;
        currentX += gap;
        xPositions["position" + i] = currentX;
    }

    return xPositions;
}

// Get config for a specific view mode
function getConfig(viewMode) {
    switch(viewMode) {
        case "main":
        case "coverflow":
        case "carousel1":
            return Carousel1;
        case "grid1":
        case "carouselOne":
        case "carousel2":
            return Carousel2;
        case "grid2":
        case "carouselTwo":
        case "carousel3":
            return Carousel3;
        case "grid3":
        case "carouselThree":
        case "carousel4":
            return Carousel4;
        default:
            return Carousel1;
    }
}

// Calculate adaptive opacity based on game count
function getAdaptiveOpacity(gameCount, positionOpacity) {
    if (positionOpacity !== "adaptive") {
        return positionOpacity;
    }
    if (gameCount === 1) return 0.9;
    else if (gameCount <= 25) return 0.7;
    else if (gameCount <= 150) return 0.6;
    else return 0.5;
}
