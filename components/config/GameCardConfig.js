.pragma library

var gameCardConfig = {

    // Debug
    debugMode: false,

    containerWidthPercent: 0.57,
    containerHeightPercent: 0.93,
    containerXPercent: 0.42,
    containerYPercent: 0.07,  // 7% from top

    // Logo (% of container)
    logoXPercent: 0.51,  // 51% of container width
    logoYPercent: 0.15,  // 15% of container height
    logoWidthPercent: 0.36,  // 36% of container width
    logoHeightPercent: 0.25,  // 25% of container height
    logoScale: 1.2,

    // Buttons (% of container)
    playXPercent: 0.22,  // 22% of container width
    playYPercent: 0.85,  // 85% of container height
    playSizePercent: 0.29,  // 29% of container width
    playOpacity: 1.0,

    infoXPercent: 0.43,  // 43% of container width
    infoYPercent: 0.85,  // 85% of container height
    infoSizePercent: 0.29,  // 29% of container width
    infoOpacity: 1.0,

    selectXPercent: 0.54,  // 54% of container width (closer to info)
    selectYPercent: 0.85,  // 85% of container height
    selectSizePercent: 0.29,  // 29% of container width
    selectOpacity: 1.0,

    favouriteXPercent: 0.83,  // 83% of container width
    favouriteYPercent: 0.85,  // 85% of container height
    favouriteSizePercent: 0.29,  // 29% of container width
    favouriteOpacity: 1.0,

    // Legend bar (% of container)
    legendYPercent: 0.96,
    legendFontSize: 11,
    legendSpacing: 16,
    legendBadgeSize: 18,

    // Description (% of container)
    descriptionXPercent: 0.5,  // 50% of container width (centered)
    descriptionYPercent: 0.4,
    descriptionWidthPercent: 0.7,  // 80% of container width
    descriptionMaxLines: 15,  // Max 4 lines
    descriptionFontSize: 30,  // Font size in px
    descriptionOpacity: 0.9,  // Text opacity
    descriptionLineHeight: 1.2,
    descriptionLetterSpacing: 0,
    descriptionMaxHeightPercent: 0.35,
    descriptionBottomMarginPercent: 0.06,
    descriptionScrollSpeed: 20,  // Scroll speed in px/s (slower)
    descriptionScrollPause: 5000,
    descriptionScrollEndPause: 2000,
    descriptionFadeInDuration: 800,
    descriptionFadeOutDuration: 600,
    descriptionFadeInEasing: "OutQuad",  // Easing type for fade in
    descriptionFadeOutEasing: "InQuad",  // Easing type for fade out

    // Last played (% of container)
    lastPlayedXPercent: 0.23,  // 50% of container width (centered)
    lastPlayedYPercent: 0.32,  // 32% of container height
    lastPlayedWidthPercent: 0.8,  // 80% of container width

    // Label "Last played:" - separate config
    lastPlayedLabelFontSize: 24,  // Label font size (smaller)
    lastPlayedLabelOpacity: 0.75,  // Label opacity (more transparent)
    lastPlayedLabelColor: "#AAAAAA",  // Label color (darker grey)
    lastPlayedLabelWeight: "Normal",
    lastPlayedLabelText: "Last played:",

    // Value (actual date) - separate config
    lastPlayedValueFontSize: 26,  // Value font size (larger)
    lastPlayedValueOpacity: 0.9,  // Value opacity (more visible)
    lastPlayedValueColor: "#FFFFFF",
    lastPlayedValueWeight: "Bold",
    lastPlayedNeverText: "Never",
    lastPlayedSpacing: 5,

    lastPlayedBackgroundOpacity: 0.25,
    lastPlayedBackgroundColor: "#000000",
    lastPlayedBackgroundRadius: 16,
    lastPlayedBackgroundPaddingX: 12,
    lastPlayedBackgroundPaddingY: 6,
    lastPlayedAlignment: "center",

    lastPlayedFadeInDuration: 600,
    lastPlayedFadeOutDuration: 400,
    lastPlayedFadeInEasing: "OutQuad",
    lastPlayedFadeOutEasing: "InQuad",

    // Developer (% of container)
    developerXPercent: 0.55,
    developerYPercent: 0.32,
    developerWidthPercent: 0.4,

    // Label "Developer:" - separate config
    developerLabelFontSize: 24,
    developerLabelOpacity: 0.7,
    developerLabelColor: "#AAAAAA",
    developerLabelWeight: "Normal",
    developerLabelText: "Dev:",

    // Value (actual developer) - separate config
    developerValueFontSize: 26,
    developerValueOpacity: 0.9,
    developerValueColor: "#FFFFFF",
    developerValueWeight: "Bold",
    developerUnknownText: "Unknown",
    developerSpacing: 5,

    developerBackgroundOpacity: 0.25,
    developerBackgroundColor: "#000000",
    developerBackgroundRadius: 16,
    developerBackgroundPaddingX: 12,
    developerBackgroundPaddingY: 6,
    developerAlignment: "center",

    developerFadeInDuration: 600,
    developerFadeOutDuration: 400,
    developerFadeInEasing: "OutQuad",
    developerFadeOutEasing: "InQuad",

    genreXPercent: 0.75,
    genreYPercent: 0.32,
    genreWidthPercent: 0.4,

    genreFontSize: 24,
    genreOpacity: 0.9,
    genreColor: "#FFFFFF",
    genreWeight: "Bold",
    genreUnknownText: "Unknown",
    genreMaxGenres: 2,  // Max genres to show
    genreSeparator: " • ",

    genreBackgroundOpacity: 0.25,
    genreBackgroundColor: "#000000",
    genreBackgroundRadius: 16,
    genreBackgroundPaddingX: 12,
    genreBackgroundPaddingY: 6,
    genreAlignment: "center",
    genreFixedWidth: 180,

    genreScrollSpeed: 30,
    genreScrollPause: 3000,
    genreScrollReturn: true,

    genreFadeInDuration: 600,
    genreFadeOutDuration: 400,
    genreFadeInEasing: "OutQuad",
    genreFadeOutEasing: "InQuad",

    autoDistribution: true,
    distributionStartPercent: 0.2,
    distributionEndPercent: 0.98,
    distributionMinSpacing: 2,

    // Effects
    buttonFocusScale: 1.2,
    animationSpeed: 150,

    // ── Selected cover placement (Odin2 / handheld baseline) ──────────────────
    // These values are used whenever a platform config does not override them.
    // In a future settings panel they can be replaced by user-saved overrides
    // (see gameCardUserOverrides scaffold below).
    selectedCoverScale: 1.4,
    selectedCoverPosX: 0.40,
    selectedCoverPosY: 0.58
};

// ── Future settings hook ────────────────────────────────────────────────────
// When in-app layout customisation is added, populate this object from the
// persistent settings store and call applyUserOverrides() at startup.
// var gameCardUserOverrides = {
//     selectedCoverScale: null,   // override selectedCoverScale  (e.g. 1.35)
//     selectedCoverPosX:  null,   // override selectedCoverPosX   (e.g. 0.38)
//     selectedCoverPosY:  null,   // override selectedCoverPosY   (e.g. 0.60)
// };
// function applyUserOverrides() {
//     var o = gameCardUserOverrides;
//     if (o.selectedCoverScale !== null) gameCardConfig.selectedCoverScale = o.selectedCoverScale;
//     if (o.selectedCoverPosX  !== null) gameCardConfig.selectedCoverPosX  = o.selectedCoverPosX;
//     if (o.selectedCoverPosY  !== null) gameCardConfig.selectedCoverPosY  = o.selectedCoverPosY;
// }

var screenWidth = 0;
var screenHeight = 0;

function setScreenDimensions(width, height) {
    screenWidth = width;
    screenHeight = height;
}

function getScreenWidth() {
    return screenWidth;
}

function getScreenHeight() {
    return screenHeight;
}

// Functions

function calculateAutoDistribution(sw, sh) {
    if (!gameCardConfig.autoDistribution) {
        return null;
    }

    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var distributionStart = containerWidth * gameCardConfig.distributionStartPercent;
    var distributionEnd = containerWidth * gameCardConfig.distributionEndPercent;
    var availableWidth = distributionEnd - distributionStart;

    var lastPlayedWidth = 160;
    var developerWidth = 120;
    var genreWidth = gameCardConfig.genreFixedWidth;

    var totalElementsWidth = lastPlayedWidth + developerWidth + genreWidth;
    var totalSpacing = gameCardConfig.distributionMinSpacing * 2;

    var actualSpacing = Math.max(
        gameCardConfig.distributionMinSpacing,
        (availableWidth - totalElementsWidth) / 2
    );

    var lastPlayedX = distributionStart;
    var developerX = lastPlayedX + lastPlayedWidth + actualSpacing;
    var genreX = developerX + developerWidth + actualSpacing;

    // Convert to percentages
    return {
        lastPlayedXPercent: lastPlayedX / containerWidth,
        developerXPercent: developerX / containerWidth,
        genreXPercent: genreX / containerWidth,
        actualSpacing: actualSpacing
    };
}

function getLogoPosition(sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var containerHeight = (sh || screenHeight) * gameCardConfig.containerHeightPercent;
    var logoWidth = containerWidth * gameCardConfig.logoWidthPercent;
    var logoHeight = containerHeight * gameCardConfig.logoHeightPercent;

    return {
        x: (containerWidth * gameCardConfig.logoXPercent) - (logoWidth / 2),
        y: (containerHeight * gameCardConfig.logoYPercent) - (logoHeight / 2)
    };
}

function getLogoSize(sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var containerHeight = (sh || screenHeight) * gameCardConfig.containerHeightPercent;

    return {
        width: containerWidth * gameCardConfig.logoWidthPercent,
        height: containerHeight * gameCardConfig.logoHeightPercent
    };
}

function getLogoScale() {
    return gameCardConfig.logoScale;
}

function getButtonPosition(buttonName, sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var containerHeight = (sh || screenHeight) * gameCardConfig.containerHeightPercent;
    var x, y, size;

    if (buttonName === "play") {
        size = containerWidth * gameCardConfig.playSizePercent;
        x = (containerWidth * gameCardConfig.playXPercent) - (size / 2);
        y = (containerHeight * gameCardConfig.playYPercent) - (size / 2);
    } else if (buttonName === "info") {
        size = containerWidth * gameCardConfig.infoSizePercent;
        x = (containerWidth * gameCardConfig.infoXPercent) - (size / 2);
        y = (containerHeight * gameCardConfig.infoYPercent) - (size / 2);
    } else if (buttonName === "select") {
        size = containerWidth * gameCardConfig.selectSizePercent;
        x = (containerWidth * gameCardConfig.selectXPercent) - (size / 2);
        y = (containerHeight * gameCardConfig.selectYPercent) - (size / 2);
    } else if (buttonName === "favourite") {
        size = containerWidth * gameCardConfig.favouriteSizePercent;
        x = (containerWidth * gameCardConfig.favouriteXPercent) - (size / 2);
        y = (containerHeight * gameCardConfig.favouriteYPercent) - (size / 2);
    } else {
        x = 0;
        y = 0;
    }

    return { x: x, y: y };
}

function getButtonSize(buttonName, sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var size;

    if (buttonName === "play") {
        size = containerWidth * gameCardConfig.playSizePercent;
    } else if (buttonName === "info") {
        size = containerWidth * gameCardConfig.infoSizePercent;
    } else if (buttonName === "select") {
        size = containerWidth * gameCardConfig.selectSizePercent;
    } else if (buttonName === "favourite") {
        size = containerWidth * gameCardConfig.favouriteSizePercent;
    } else {
        size = 80;
    }

    return { width: size, height: size };
}

function getButtonOpacity(buttonName) {
    var opacity;

    if (buttonName === "play") {
        opacity = gameCardConfig.playOpacity;
    } else if (buttonName === "info") {
        opacity = gameCardConfig.infoOpacity;
    } else if (buttonName === "select") {
        opacity = gameCardConfig.selectOpacity;
    } else if (buttonName === "favourite") {
        opacity = gameCardConfig.favouriteOpacity;
    } else {
        opacity = 1.0;
    }

    return opacity;
}

function getFocusScale() {
    return gameCardConfig.buttonFocusScale;
}

function getAnimationSpeed() {
    return gameCardConfig.animationSpeed;
}

function getContainerSize(sw, sh) {
    return {
        width: (sw || screenWidth) * gameCardConfig.containerWidthPercent,
        height: (sh || screenHeight) * gameCardConfig.containerHeightPercent
    };
}

function getContainerPosition(sw, sh) {
    return {
        x: (sw || screenWidth) * gameCardConfig.containerXPercent,
        y: (sh || screenHeight) * gameCardConfig.containerYPercent
    };
}

function isDebugMode() {
    return gameCardConfig.debugMode;
}

// Description functions
function getDescriptionPosition(sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var containerHeight = (sh || screenHeight) * gameCardConfig.containerHeightPercent;
    var descriptionWidth = containerWidth * gameCardConfig.descriptionWidthPercent;

    return {
        x: (containerWidth * gameCardConfig.descriptionXPercent) - (descriptionWidth / 2),
        y: containerHeight * gameCardConfig.descriptionYPercent
    };
}

function getDescriptionSize(sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var containerHeight = (sh || screenHeight) * gameCardConfig.containerHeightPercent;

    var buttonsYPosition = containerHeight * gameCardConfig.playYPercent;
    var descriptionStartY = containerHeight * gameCardConfig.descriptionYPercent;
    var bottomMargin = containerHeight * gameCardConfig.descriptionBottomMarginPercent;
    var calculatedMaxHeight = buttonsYPosition - descriptionStartY - bottomMargin;

    var configuredMaxHeight = containerHeight * gameCardConfig.descriptionMaxHeightPercent;
    var finalMaxHeight = Math.min(calculatedMaxHeight, configuredMaxHeight);

    return {
        width: containerWidth * gameCardConfig.descriptionWidthPercent,
        maxHeight: Math.max(finalMaxHeight, 50)  // Ensure at least 50px height
    };
}

function getDescriptionConfig() {
    return {
        maxLines: gameCardConfig.descriptionMaxLines,
        fontSize: gameCardConfig.descriptionFontSize,
        opacity: gameCardConfig.descriptionOpacity,
        lineHeight: gameCardConfig.descriptionLineHeight,
        letterSpacing: gameCardConfig.descriptionLetterSpacing,
        scrollSpeed: gameCardConfig.descriptionScrollSpeed,
        scrollPause: gameCardConfig.descriptionScrollPause,
        scrollEndPause: gameCardConfig.descriptionScrollEndPause,
        fadeInDuration: gameCardConfig.descriptionFadeInDuration,
        fadeOutDuration: gameCardConfig.descriptionFadeOutDuration,
        fadeInEasing: gameCardConfig.descriptionFadeInEasing,
        fadeOutEasing: gameCardConfig.descriptionFadeOutEasing
    };
}

function getDescriptionBottomMargin(sw, sh) {
    var containerHeight = (sh || screenHeight) * gameCardConfig.containerHeightPercent;
    return containerHeight * gameCardConfig.descriptionBottomMarginPercent;
}

function getLastPlayedPosition(sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var containerHeight = (sh || screenHeight) * gameCardConfig.containerHeightPercent;
    var lastPlayedWidth = containerWidth * gameCardConfig.lastPlayedWidthPercent;

    var autoDistribution = calculateAutoDistribution(sw, sh);
    var xPercent = autoDistribution ? autoDistribution.lastPlayedXPercent : gameCardConfig.lastPlayedXPercent;

    return {
        x: (containerWidth * xPercent) - (lastPlayedWidth / 2),
        y: containerHeight * gameCardConfig.lastPlayedYPercent
    };
}

function getLastPlayedSize(sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;

    return {
        width: containerWidth * gameCardConfig.lastPlayedWidthPercent
    };
}

function getLastPlayedConfig() {
    return {
        // Config for the label "Last played:"
        labelFontSize: gameCardConfig.lastPlayedLabelFontSize,
        labelOpacity: gameCardConfig.lastPlayedLabelOpacity,
        labelColor: gameCardConfig.lastPlayedLabelColor,
        labelWeight: gameCardConfig.lastPlayedLabelWeight,
        labelText: gameCardConfig.lastPlayedLabelText,

        // Value config (date)
        valueFontSize: gameCardConfig.lastPlayedValueFontSize,
        valueOpacity: gameCardConfig.lastPlayedValueOpacity,
        valueColor: gameCardConfig.lastPlayedValueColor,
        valueWeight: gameCardConfig.lastPlayedValueWeight,

        backgroundOpacity: gameCardConfig.lastPlayedBackgroundOpacity,
        backgroundColor: gameCardConfig.lastPlayedBackgroundColor,
        backgroundRadius: gameCardConfig.lastPlayedBackgroundRadius,
        backgroundPaddingX: gameCardConfig.lastPlayedBackgroundPaddingX,
        backgroundPaddingY: gameCardConfig.lastPlayedBackgroundPaddingY,
        alignment: gameCardConfig.lastPlayedAlignment,

        fadeInDuration: gameCardConfig.lastPlayedFadeInDuration,
        fadeOutDuration: gameCardConfig.lastPlayedFadeOutDuration,
        fadeInEasing: gameCardConfig.lastPlayedFadeInEasing,
        fadeOutEasing: gameCardConfig.lastPlayedFadeOutEasing,

        neverText: gameCardConfig.lastPlayedNeverText,
        spacing: gameCardConfig.lastPlayedSpacing
    };
}

// Developer functions
function getDeveloperPosition(sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var containerHeight = (sh || screenHeight) * gameCardConfig.containerHeightPercent;
    var developerWidth = containerWidth * gameCardConfig.developerWidthPercent;

    var autoDistribution = calculateAutoDistribution(sw, sh);
    var xPercent = autoDistribution ? autoDistribution.developerXPercent : gameCardConfig.developerXPercent;

    return {
        x: (containerWidth * xPercent) - (developerWidth / 2),
        y: containerHeight * gameCardConfig.developerYPercent
    };
}

function getDeveloperSize(sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;

    return {
        width: containerWidth * gameCardConfig.developerWidthPercent
    };
}

function getDeveloperConfig() {
    return {
        // Config for the label "Developer:"
        labelFontSize: gameCardConfig.developerLabelFontSize,
        labelOpacity: gameCardConfig.developerLabelOpacity,
        labelColor: gameCardConfig.developerLabelColor,
        labelWeight: gameCardConfig.developerLabelWeight,
        labelText: gameCardConfig.developerLabelText,

        // Value config (developer)
        valueFontSize: gameCardConfig.developerValueFontSize,
        valueOpacity: gameCardConfig.developerValueOpacity,
        valueColor: gameCardConfig.developerValueColor,
        valueWeight: gameCardConfig.developerValueWeight,

        backgroundOpacity: gameCardConfig.developerBackgroundOpacity,
        backgroundColor: gameCardConfig.developerBackgroundColor,
        backgroundRadius: gameCardConfig.developerBackgroundRadius,
        backgroundPaddingX: gameCardConfig.developerBackgroundPaddingX,
        backgroundPaddingY: gameCardConfig.developerBackgroundPaddingY,
        alignment: gameCardConfig.developerAlignment,

        fadeInDuration: gameCardConfig.developerFadeInDuration,
        fadeOutDuration: gameCardConfig.developerFadeOutDuration,
        fadeInEasing: gameCardConfig.developerFadeInEasing,
        fadeOutEasing: gameCardConfig.developerFadeOutEasing,

        unknownText: gameCardConfig.developerUnknownText,
        spacing: gameCardConfig.developerSpacing
    };
}

// Genre functions
function getGenrePosition(sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var containerHeight = (sh || screenHeight) * gameCardConfig.containerHeightPercent;
    var genreWidth = containerWidth * gameCardConfig.genreWidthPercent;

    var autoDistribution = calculateAutoDistribution(sw, sh);
    var xPercent = autoDistribution ? autoDistribution.genreXPercent : gameCardConfig.genreXPercent;

    return {
        x: (containerWidth * xPercent) - (genreWidth / 2),
        y: containerHeight * gameCardConfig.genreYPercent
    };
}

function getGenreSize(sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;

    return {
        width: containerWidth * gameCardConfig.genreWidthPercent
    };
}

function getGenreConfig() {
    return {
        fontSize: gameCardConfig.genreFontSize,
        opacity: gameCardConfig.genreOpacity,
        color: gameCardConfig.genreColor,
        weight: gameCardConfig.genreWeight,

        backgroundOpacity: gameCardConfig.genreBackgroundOpacity,
        backgroundColor: gameCardConfig.genreBackgroundColor,
        backgroundRadius: gameCardConfig.genreBackgroundRadius,
        backgroundPaddingX: gameCardConfig.genreBackgroundPaddingX,
        backgroundPaddingY: gameCardConfig.genreBackgroundPaddingY,
        alignment: gameCardConfig.genreAlignment,
        fixedWidth: gameCardConfig.genreFixedWidth,

        scrollSpeed: gameCardConfig.genreScrollSpeed,
        scrollPause: gameCardConfig.genreScrollPause,
        scrollReturn: gameCardConfig.genreScrollReturn,

        fadeInDuration: gameCardConfig.genreFadeInDuration,
        fadeOutDuration: gameCardConfig.genreFadeOutDuration,
        fadeInEasing: gameCardConfig.genreFadeInEasing,
        fadeOutEasing: gameCardConfig.genreFadeOutEasing,

        unknownText: gameCardConfig.genreUnknownText,
        maxGenres: gameCardConfig.genreMaxGenres,
        separator: gameCardConfig.genreSeparator
    };
}

function updateDistributionWidths(lastPlayedActualWidth, developerActualWidth, genreActualWidth, sw, sh) {
    if (!gameCardConfig.autoDistribution) return;

    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var distributionStart = containerWidth * gameCardConfig.distributionStartPercent;
    var distributionEnd = containerWidth * gameCardConfig.distributionEndPercent;
    var availableWidth = distributionEnd - distributionStart;

    var totalElementsWidth = lastPlayedActualWidth + developerActualWidth + genreActualWidth;
    var totalSpacing = gameCardConfig.distributionMinSpacing * 2;

    var optimalSpacing = Math.max(
        gameCardConfig.distributionMinSpacing,
        (availableWidth - totalElementsWidth) / 2
    );

    if (gameCardConfig.debugMode) {
        console.log("GameCardConfig: Auto Distribution Update");
        console.log("  Available width:", availableWidth);
        console.log("  Elements width:", totalElementsWidth);
        console.log("  Optimal spacing:", optimalSpacing);
    }
}

function debugAutoDistribution() {
    if (!gameCardConfig.debugMode) return;

    var distribution = calculateAutoDistribution();
    if (distribution) {
        console.log("GameCardConfig: Auto Distribution Debug");
        console.log("  Last Played X:", distribution.lastPlayedXPercent * 100 + "%");
        console.log("  Developer X:", distribution.developerXPercent * 100 + "%");
        console.log("  Genre X:", distribution.genreXPercent * 100 + "%");
        console.log("  Actual spacing:", distribution.actualSpacing + "px");
    }
}

function setAutoDistribution(enabled) {
    gameCardConfig.autoDistribution = enabled;
    debugAutoDistribution();
}

function getLegendConfig() {
    return {
        yPercent: gameCardConfig.legendYPercent,
        fontSize: gameCardConfig.legendFontSize,
        spacing: gameCardConfig.legendSpacing,
        badgeSize: gameCardConfig.legendBadgeSize
    };
}

function getLegendPosition(sw, sh) {
    var containerWidth = (sw || screenWidth) * gameCardConfig.containerWidthPercent;
    var containerHeight = (sh || screenHeight) * gameCardConfig.containerHeightPercent;
    return {
        x: containerWidth * 0.5,
        y: containerHeight * gameCardConfig.legendYPercent
    };
}
