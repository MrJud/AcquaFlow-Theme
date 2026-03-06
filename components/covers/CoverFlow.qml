import QtQuick 2.15
import ".."
import QtQml 2.15
import QtGraphicalEffects 1.15
import QtQuick.Window 2.15
import "../../utils.js" as Utils
import "../config/PlatformConfigs.js" as Cfg
import "../config/PathViewConfigs.js" as PathConfigs

FocusScope {
    id: coverFlow

    property var menuManager: null
    property var platformBarRef: null
    property var playtimeTracker: null
    property QtObject raServiceRef: null  // Explicit RA service reference (passed from theme.qml)
    property string lang: "it"

    property string currentViewMode: isCarousel4 ? "carousel4" : isCarousel3 ? "carousel3" : isCarousel2 ? "carousel2" : "carousel1"
    onCurrentViewModeChanged: updatePlatformBaseValues()

    property bool favouriteFilterActive: false
    property bool _pendingFavRefresh: false  // deferred refresh when deselecting on Favourites platform

    property alias searchButton: searchBtn
    property alias favouriteButton: favouriteBtn
    property alias viewSwitcher: viewSwitcher
    property alias carouselCustomizer: customizer
    property alias menuButton: menuBtn
    property alias raButton: raBtn

    signal raHubRequested()
    signal favouriteRemovedOnFavPlatform()
    signal coverScrolledInSelectedMode()

    property alias pathViewLoader: pathViewLoader

    signal showAlphabeticLetter(string letter)

    signal viewModeChangeRequested(string viewType)

    function getNextViewMode() {
        // console.log("CoverFlow.getNextViewMode: Current mode:", currentViewMode)

        if (currentViewMode === "carousel1") return "carousel2"
        if (currentViewMode === "carousel2") return "carousel3"
        if (currentViewMode === "carousel3") return "carousel4"
        return "carousel1"
    }

    // ScreenMetrics is now passed in from theme.qml
    property QtObject screenMetrics: null

    ColorSampler {
        id: centralColorSampler
        // PERF: Pass matching sourceSize so ColorSampler hits the QML pixmap cache
        refWidth: imagePrefetcher._refWidth
        refHeight: imagePrefetcher._refHeight
        onColorReady: (item, url, topColor, bottomColor) => {
            if (item) {
                item.sampledTopColor = topColor;
                item.sampledBottomColor = bottomColor;
            }
        }
    }

    // IMAGE PREFETCHER
    // Pre-loads cover images for ±6 adjacent positions into QML's pixmap cache.
    // Each invisible Image uses the SAME sourceSize (×1.2) as coverLoader/coverImage,
    // so when a delegate scrolls into view its image is already decoded → instant display.
    // The pool is a fixed set of 12 Image elements (no Repeater overhead).
    // Prefetch sources update with a 50ms debounce to avoid thrashing during fast scroll.

    readonly property int _prefetchRadius: 5  // covers to prefetch on each side (slot 0 = center)

    Item {
        id: imagePrefetcher
        visible: false
        width: 0; height: 0

        // Stable reference dimensions for sourceSize (must match coverLoader/coverImage)
        readonly property int _refWidth: screenMetrics ? Math.round(screenMetrics.baseCoverHeight * 0.7 * 1.2) : 240
        readonly property int _refHeight: screenMetrics ? Math.round(screenMetrics.baseCoverHeight * 1.2) : 400

        // 12 pre-fetch slots: 0 = center, 1-5 = left side, 6-10 = right side, 11 = far-right lookahead
        Image { id: pf0;  visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }
        Image { id: pf1;  visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }
        Image { id: pf2;  visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }
        Image { id: pf3;  visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }
        Image { id: pf4;  visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }
        Image { id: pf5;  visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }
        Image { id: pf6;  visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }
        Image { id: pf7;  visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }
        Image { id: pf8;  visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }
        Image { id: pf9;  visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }
        Image { id: pf10; visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }
        Image { id: pf11; visible:false; asynchronous:true; cache:true; sourceSize.width:imagePrefetcher._refWidth; sourceSize.height:imagePrefetcher._refHeight }

        // Array reference for programmatic access
        property var _slots: [pf0,pf1,pf2,pf3,pf4,pf5,pf6,pf7,pf8,pf9,pf10,pf11]
    }

    Timer {
        id: prefetchDebounce
        interval: 16  // 1 frame debounce — fast prefetch without per-frame thrashing
        repeat: false
        onTriggered: coverFlow._updatePrefetchSources()
    }

    function _updatePrefetchSources() {
        if (!gameModel || gameModel.count === 0 || !pathViewLoader.item) return;
        var total = gameModel.count;
        var ci = pathViewLoader.item.currentIndex;
        if (ci < 0) return;
        var realIdx = isGridView ? ci : (ci % total);

        var slots = imagePrefetcher._slots;
        var radius = _prefetchRadius; // 5
        var plat = platform || "default";

        // Slot 0 — center cover (highest priority)
        var centerGame = gameModel.get(realIdx);
        var centerUrl = (centerGame && centerGame.assets && centerGame.assets.boxFront) ? centerGame.assets.boxFront : "";
        if (slots[0].source !== centerUrl) slots[0].source = centerUrl;
        if (centerUrl) centralColorSampler.presample(centerUrl, plat);

        for (var i = 0; i < radius; ++i) {
            // Left side: slots 1..5
            var leftIdx = (realIdx - 1 - i + total) % total;
            var leftGame = gameModel.get(leftIdx);
            var leftUrl = (leftGame && leftGame.assets && leftGame.assets.boxFront) ? leftGame.assets.boxFront : "";
            if (slots[1 + i].source !== leftUrl) slots[1 + i].source = leftUrl;
            if (leftUrl) centralColorSampler.presample(leftUrl, plat);

            // Right side: slots 6..10
            var rightIdx = (realIdx + 1 + i) % total;
            var rightGame = gameModel.get(rightIdx);
            var rightUrl = (rightGame && rightGame.assets && rightGame.assets.boxFront) ? rightGame.assets.boxFront : "";
            if (slots[radius + 1 + i].source !== rightUrl) slots[radius + 1 + i].source = rightUrl;
            if (rightUrl) centralColorSampler.presample(rightUrl, plat);
        }

        // Slot 11 — far-right lookahead (+6)
        var farIdx = (realIdx + radius + 1) % total;
        var farGame = gameModel.get(farIdx);
        var farUrl = (farGame && farGame.assets && farGame.assets.boxFront) ? farGame.assets.boxFront : "";
        if (slots[11].source !== farUrl) slots[11].source = farUrl;
        if (farUrl) centralColorSampler.presample(farUrl, plat);
    }

    function _clearPrefetchSources() {
        var slots = imagePrefetcher._slots;
        for (var i = 0; i < slots.length; ++i) {
            slots[i].source = "";
        }
    }

    property bool isInitialLoad: true

    Timer {
        id: initialLoadTimer
        interval: 280  // PERF: reduced from 350ms — gives PathView enough time to stabilize
        repeat: false
        onTriggered: populateAndShowCovers()
    }

    Timer {
        id: fadeInDelayTimer
        // FIX: 16ms (1 frame) caused covers to appear blank on 2K+ — GPU hadn't finished
        // uploading textures before PathView became visible. 80ms gives enough headroom.
        interval: 80
        repeat: false
        onTriggered: {
            isTransitioning = false;

            // Unfreeze pathItemCount AFTER reveal. By now all covers are loaded
            // and visible. PathView adjusts delegate count (e.g. 15→7) seamlessly
            // — extra edge delegates are removed but the visible ones stay.
            if (coverFlow._frozenPathItemCount >= 0) {
                Qt.callLater(function() {
                    coverFlow._frozenPathItemCount = -1;
                });
            }
        }
    }

    Timer {
        id: preloadTimer
        interval: 50
        repeat: false
        onTriggered: preloadFirstCovers()
    }

    Timer {
        id: fadeOutTimer
        interval: 200
        repeat: false
        property int _pendingJumpIndex: -1
        property bool _pendingJumpForward: true
        onTriggered: {
            if (_pendingJumpIndex >= 0 && pathViewLoader.item) {
                var pathView = pathViewLoader.item;
                pathView.currentIndex = _pendingJumpIndex;
                _pendingJumpIndex = -1;
                fadeInTimer.start();
            }
        }
    }

    Timer {
        id: fadeInTimer
        interval: 100
        repeat: false
        onTriggered: {
            if (pathViewLoader.item) {
                var pathView = pathViewLoader.item;
                pathView._isTeleportingPathView = false;
                pathView.isAlphabeticJumpInProgress = false;
                pathView.alphabeticJumpDistance = 0;
            }
        }
    }

    property bool isEnteringGridView: false
    property int transitionFromIndex: 0

    Timer {
        id: viewTransitionTimer
        interval: 300
        repeat: false
        onTriggered: {
            if (isEnteringGridView) {
                isGridView = true
                isCarousel2 = false
                isCarousel3 = false
                isCarousel4 = false

                populateAndShowCovers()

                Qt.callLater(function() {
                    isTransitioning = false
                })

                saveCurrentViewMode()
            } else {
                isGridView = false

                populateAndShowCovers()

                Qt.callLater(function() {
                    isTransitioning = false
                })
            }
        }
    }

    property real axisX: 0
    property int selectedCoverIndex: -1
    property bool isCoverSelected: selectedCoverIndex !== -1
    property bool isRefreshingPathView: false

    property var currentPathConfig: null
    property int realGameCount: gameModel ? gameModel.count : 0

    property real animGlobalYOffset: 0
    property real animSpreadMultiplier: 1.0

    Behavior on animGlobalYOffset { NumberAnimation { duration: viewModeTransitionDuration; easing.type: viewModeTransitionEasing } }
    Behavior on animSpreadMultiplier { NumberAnimation { duration: viewModeTransitionDuration; easing.type: viewModeTransitionEasing } }

    // PERF: Gate path point Behaviors - only animate during view mode transitions
    property bool _pathPointAnimating: false
    // PERF: Guard flag to suppress cascading reloadPathConfig() during completeViewModeSwitch
    property bool _suppressReload: false
    Timer {
        id: pathPointAnimEndTimer
        interval: (viewModeTransitionDuration * 2) + 200  // position (500) + rotation (500) + margin
        onTriggered: {
            coverFlow._pathPointAnimating = false
            coverFlow._scaleTargets = null
            coverFlow._scaleNewScales = null
            coverFlow._pendingXPositions = null
            staggerUpdateTimer.stop()
            delayedXPositionTimer.stop()
            scaleBlendAnim.stop()
            // Reset timer intervals to default
            pathPointAnimEndTimer.interval = (coverFlow.viewModeTransitionDuration * 2) + 200
            viewModeTransitionTimer.interval = (coverFlow.viewModeTransitionDuration * 2) + 200

            // Force PathView to re-interpolate all delegate itemScale values.
            // After a stagger transition, outer point*.scale Behaviors may still be
            // mid-flight when delayedXPositionTimer fires its PathLine geometry update,
            // causing PathView to lock in stale itemScale values for edge delegates.
            // Calling reloadPathConfig() here (instant path, _pathPointAnimating=false)
            // re-writes all point*.scale to their final values AND changes PathLine x/y,
            // forcing PathView to re-read every delegate's PathAttribute immediately.
            Qt.callLater(function() {
                if (!coverFlow._pathPointAnimating) {
                    coverFlow.reloadPathConfig()
                }
            })
        }
    }

    // Per-property optimized easing: OutCubic=spatial, OutBack=scale pop, InOutCubic=rotation, InOutQua...
    QtObject { id: point0; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point1; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point2; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point3; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point4; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point5; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point6; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point7; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point8; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point9; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point10; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point11; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point12; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point13; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }
    QtObject { id: point14; property real xPosition: 0; property real yOffset: 0; property real scale: 1; property real rotationY: 0; property real rotationX: 0; property real opacity: 1; property real zIndex: 0; Behavior on xPosition { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on yOffset { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.OutCubic } } Behavior on scale { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing { type: Easing.OutBack; overshoot: 1.02 } } } Behavior on rotationY { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on rotationX { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutCubic } } Behavior on opacity { enabled: _pathPointAnimating; NumberAnimation { duration: viewModeTransitionDuration; easing.type: Easing.InOutQuad } } }

    property var _pendingConfig: null
    property var _pendingDynamicPositions: null
    property int _staggerIndex: 0
    property var _pendingXPositions: null  // for C2→C3 sequenced phase 2

    // Pending rotation targets for sequenced animation (position first, then rotation)
    property var _pendingRotations: null

    // Single-driver scale blend: 1 NumberAnimation drives all 15 point scales via lerp
    // Used only for simultaneous (non-stagger) transitions
    property real _scaleBlendFactor: 1.0
    property var _scaleTargets: null
    property bool _scaleUseStagger: false
    on_ScaleBlendFactorChanged: {
        if (!_scaleTargets) return
        var save = _pathPointAnimating
        _pathPointAnimating = false
        for (var i = 0; i < _scaleTargets.length; i++) {
            var t = _scaleTargets[i]
            // OutCubic: f(t) = 1 - (1-t)^3
            var inv = 1.0 - _scaleBlendFactor
            var p = 1.0 - (inv * inv * inv)
            t.point.scale = t.oldScale + (t.newScale - t.oldScale) * p
        }
        _pathPointAnimating = save
    }

    NumberAnimation {
        id: scaleBlendAnim
        target: coverFlow
        property: "_scaleBlendFactor"
        from: 0; to: 1
        duration: viewModeTransitionDuration
        easing.type: Easing.Linear
    }

    // Sequential scale stagger: one cover triggered every interval ms
    // Sequence order (center-out): pos8 → pos7 → pos9 → pos6 → pos10 → ... → pos1 → pos15
    property var _scaleNewScales: null
    property int _scaleStaggerIdx: 0
    readonly property var _scaleSeqOrder: [7, 6, 8, 5, 9, 4, 10, 3, 11, 2, 12, 1, 13, 0, 14]

    Timer {
        id: delayedXPositionTimer
        // Fires after scale stagger completes (15 steps × 40ms = 560ms → add 40ms margin)
        interval: 600
        repeat: false
        onTriggered: {
            if (!coverFlow._pendingXPositions) return
            var pts = [point0, point1, point2, point3, point4, point5, point6, point7,
                       point8, point9, point10, point11, point12, point13, point14]
            coverFlow._pathPointAnimating = true
            for (var i = 0; i < coverFlow._pendingXPositions.length; i++) {
                var entry = coverFlow._pendingXPositions[i]
                pts[entry.idx].xPosition = entry.newX
                pts[entry.idx].yOffset   = entry.yOffset
            }
            // Apply rotation together with position
            if (coverFlow._pendingRotations) {
                for (var i = 0; i < 15; i++) {
                    var rot = coverFlow._pendingRotations[i]
                    if (rot) {
                        pts[i].rotationY = rot.rotY
                        pts[i].rotationX = rot.rotX
                    }
                }
                coverFlow._pendingRotations = null
            }
            coverFlow._pendingXPositions = null
        }
    }

    Timer {
        id: delayedRotationTimer
        interval: coverFlow.viewModeTransitionDuration  // fires when position animation finishes
        repeat: false
        onTriggered: {
            if (!coverFlow._pendingRotations) return
            var points = [point0, point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13, point14];
            coverFlow._pathPointAnimating = true
            for (var i = 0; i < 15; i++) {
                var rot = coverFlow._pendingRotations[i]
                if (rot) {
                    points[i].rotationY = rot.rotY
                    points[i].rotationX = rot.rotX
                }
            }
            coverFlow._pendingRotations = null
        }
    }

    Timer {
        id: staggerUpdateTimer
        interval: 40  // ms between each cover in the sequential scale cascade
        repeat: true
        running: false
        onTriggered: {
            if (!coverFlow._scaleNewScales || coverFlow._scaleStaggerIdx >= 15) {
                running = false
                return
            }
            var ptIdx = coverFlow._scaleSeqOrder[coverFlow._scaleStaggerIdx]
            var pts = [point0, point1, point2, point3, point4, point5, point6, point7,
                       point8, point9, point10, point11, point12, point13, point14]
            coverFlow._pathPointAnimating = true
            pts[ptIdx].scale = coverFlow._scaleNewScales[ptIdx]
            coverFlow._scaleStaggerIdx++
            if (coverFlow._scaleStaggerIdx >= 15) running = false
        }
    }

    function getPathConfigKey() {
        if (isCarousel2) return "carousel2"
        if (isCarousel3) return "carousel3"
        if (isCarousel4) return "carousel4"
        return "carousel1"
    }

    function reloadPathConfig() {
        var config = PathConfigs.getConfig(getPathConfigKey())

        // Shallow copy of base config
        var configCopy = {}
        for (var key in config) {
            configCopy[key] = config[key]
        }

        // Override center gap with runtime value (CarouselCustomizer slider)
        var pos7Copy = {}; for (var k in configCopy.position7) pos7Copy[k] = configCopy.position7[k];
        pos7Copy.gap = centerSpacing;
        configCopy.position7 = pos7Copy;

        var pos9Copy = {}; for (var k in configCopy.position9) pos9Copy[k] = configCopy.position9[k];
        pos9Copy.gap = centerSpacing;
        configCopy.position9 = pos9Copy;

        animGlobalYOffset = configCopy.globalYOffset
        animSpreadMultiplier = configCopy.spreadMultiplier

        var allPositions = PathConfigs.interpolatePositions(configCopy, realGameCount)

        var dynamicPositions = PathConfigs.calculatePositionsFromGaps(allPositions)

        if (_pathPointAnimating) {
            // ANIMATED PATH: sequenced — position first, rotation after
            var points = [point0, point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13, point14];

            // Pass 1: instant — opacity, zIndex (no Behavior)
            _pathPointAnimating = false
            for (var i = 0; i < 15; i++) {
                var posKey = "position" + (i + 1)
                var posConfig = allPositions[posKey]
                var animObj = points[i]
                if (animObj && posConfig) {
                    animObj.zIndex = posConfig.zIndex
                    animObj.opacity = PathConfigs.getAdaptiveOpacity(realGameCount, posConfig.opacity)
                }
            }

            // Capture current scales & compute targets for blend animation
            // C2→C3: sequential timer (one cover per 40ms, center-out)
            // Other transitions: simultaneous blend
            var useStagger = (_previousViewMode === "carousel2" && pendingViewMode === "carousel3")
                          || (_previousViewMode === "carousel3" && pendingViewMode === "carousel4")
            _scaleUseStagger = useStagger

            if (useStagger) {
                // Build array of new scales indexed by point (0-14)
                var newScales = []
                for (var i = 0; i < 15; i++) {
                    var posKey = "position" + (i + 1)
                    var posConfig = allPositions[posKey]
                    newScales.push(posConfig ? ((typeof posConfig.scale === "number") ? posConfig.scale : 1.0) : 1.0)
                }
                _scaleNewScales = newScales
                _scaleStaggerIdx = 0
                _scaleTargets = null
            } else {
                // Simultaneous blend for all other transitions
                _scaleNewScales = null
                var scaleTargets = []
                for (var i = 0; i < 15; i++) {
                    var animObj = points[i]
                    var posKey = "position" + (i + 1)
                    var posConfig = allPositions[posKey]
                    if (animObj && posConfig) {
                        var newScale = (typeof posConfig.scale === "number") ? posConfig.scale : 1.0
                        if (Math.abs(animObj.scale - newScale) > 0.001) {
                            scaleTargets.push({ point: animObj, oldScale: animObj.scale, newScale: newScale })
                        } else {
                            animObj.scale = newScale
                        }
                    }
                }
                _scaleTargets = scaleTargets.length > 0 ? scaleTargets : null
                _scaleBlendFactor = 0
            }

            // Store rotation targets for delayed application
            var rotations = []
            for (var i = 0; i < 15; i++) {
                var posKey = "position" + (i + 1)
                var posConfig = allPositions[posKey]
                if (posConfig) {
                    rotations.push({ rotY: posConfig.rotationY, rotX: posConfig.rotationX || 0 })
                } else {
                    rotations.push(null)
                }
            }
            _pendingRotations = rotations

            if (_scaleUseStagger) {
                var delayX = (_previousViewMode === "carousel2" && pendingViewMode === "carousel3")
                if (delayX) {
                    // C2→C3: PHASE 1 = scale stagger, PHASE 2 = xPosition (delayed)
                    var xTargets = []
                    for (var i = 0; i < 15; i++) {
                        var posKey = "position" + (i + 1)
                        var posConfig = allPositions[posKey]
                        if (posConfig) {
                            var newX = (dynamicPositions[posKey] !== undefined) ? dynamicPositions[posKey] : posConfig.xPosition
                            xTargets.push({ idx: i, newX: newX, yOffset: posConfig.yOffset })
                        }
                    }
                    _pendingXPositions = xTargets

                    // Extend transition timers: scale(600ms) + pos+rot(500ms) + margin
                    var totalDuration = 600 + viewModeTransitionDuration + 300
                    pathPointAnimEndTimer.interval = totalDuration
                    viewModeTransitionTimer.interval = totalDuration
                    pathPointAnimEndTimer.restart()
                    viewModeTransitionTimer.restart()

                    staggerUpdateTimer.restart()
                    delayedXPositionTimer.restart()
                } else {
                    // C3→C4: scale stagger + xPosition simultaneous
                    _pathPointAnimating = true
                    for (var i = 0; i < 15; i++) {
                        var posKey = "position" + (i + 1)
                        var posConfig = allPositions[posKey]
                        var animObj = points[i]
                        if (animObj && posConfig) {
                            var newX = (dynamicPositions[posKey] !== undefined) ? dynamicPositions[posKey] : posConfig.xPosition
                            animObj.xPosition = newX
                            animObj.yOffset = posConfig.yOffset
                        }
                    }
                    delayedRotationTimer.restart()
                    staggerUpdateTimer.restart()
                }
            } else {
                // All other transitions: xPosition simultaneous
                // Pass 2: animated — position (Behaviors kick in)
                _pathPointAnimating = true
                for (var i = 0; i < 15; i++) {
                    var posKey = "position" + (i + 1)
                    var posConfig = allPositions[posKey]
                    var animObj = points[i]
                    if (animObj && posConfig) {
                        var newX = (dynamicPositions[posKey] !== undefined) ? dynamicPositions[posKey] : posConfig.xPosition
                        animObj.xPosition = newX
                        animObj.yOffset = posConfig.yOffset
                    }
                }
                delayedRotationTimer.restart()
                if (_scaleTargets) scaleBlendAnim.start()
            }
        } else {
            // INSTANT PATH: apply all positions in one frame (platform load, initial load, etc.)
            var points = [point0, point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11, point12, point13, point14];
            for (var i = 0; i < 15; i++) {
                var posKey = "position" + (i + 1)
                var posConfig = allPositions[posKey]
                var animObj = points[i]
                if (animObj && posConfig) {
                    var newX = (dynamicPositions[posKey] !== undefined) ? dynamicPositions[posKey] : posConfig.xPosition
                    animObj.xPosition = newX
                    animObj.yOffset = posConfig.yOffset
                    animObj.scale = (typeof posConfig.scale === "number") ? posConfig.scale : 1.0
                    animObj.rotationY = posConfig.rotationY
                    animObj.rotationX = posConfig.rotationX || 0
                    animObj.zIndex = posConfig.zIndex
                    animObj.opacity = PathConfigs.getAdaptiveOpacity(realGameCount, posConfig.opacity)
                }
            }
            _pendingConfig = null
            _pendingDynamicPositions = null
        }

        currentPathConfig = configCopy
    }

    onIsCarousel1Changed: if (!_suppressReload) reloadPathConfig()
    onIsCarousel2Changed: if (!_suppressReload) reloadPathConfig()
    onIsCarousel3Changed: if (!_suppressReload) reloadPathConfig()
    onIsCarousel4Changed: if (!_suppressReload) reloadPathConfig()

    property bool isCarousel1: true
    property bool isCarousel2: false
    property bool isCarousel3: false
    property bool isCarousel4: false
    property bool isGridView: false  // Legacy/Unused for now

    property var carousel1Settings: ({})
    property var carousel2Settings: ({})
    property var carousel3Settings: ({})
    property var carousel4Settings: ({})

    property var defaultSettings: ({
        spread: 1.0,
        yOffset: 0.0,
        scale: 1.0,
        frontScale: 1.0
    })

    property int viewModeTransitionDuration: 500
    property var viewModeTransitionEasing: Easing.OutCubic
    property bool isViewModeTransitioning: false
    property int _frozenPathItemCount: -1

    Timer {
        id: viewModeTransitionTimer
        interval: (viewModeTransitionDuration * 2) + 200  // position + rotation + settle margin
        onTriggered: {
            isViewModeTransitioning = false
            _frozenPathItemCount = -1  // unfreeze → binding re-evaluates to real value
        }
    }

    property bool isManuallyCustomizing: false
    property int customizerAnimationDuration: isManuallyCustomizing ? 0 : viewModeTransitionDuration

    property int lastCoverIndex: -1
    property int coverMovementDirection: 0
    property bool isTransitioningCovers: false

    property real animationStaggerDelay: 40
    property real animationBaseDuration: 250
    property bool useStaggeredAnimations: true
    property int animationWaveDirection: 0

    property real rotationAngleX: 0
    property real rotationAngleY: 0
    property real rotationLimitX: 30
    property real rotationLimitY: 999

    property real waveAmplitude: 0.0
    property real wavePhase: 0.0
    property real waveFrequency: 1.5

    Behavior on waveAmplitude {
        NumberAnimation {
            duration: animationBaseDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on wavePhase {
        NumberAnimation {
            duration: animationBaseDuration * 1.5
            easing.type: Easing.OutCubic
        }
    }

    Behavior on rotationAngleX {
        enabled: !isCoverSelected
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }
    Behavior on rotationAngleY {
        enabled: !isCoverSelected
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }
    property var gameSpecificColors: ({})

    property var platformBoxConfigs: Cfg.platformBoxConfigs

    // Properties for-carosello da PlatformConfigs
    property real originalSpread: 1.0
    property real originalYOffset: 0
    property real platformYOffsetNormalized: 0
    property real originalCoverScale: 1.0
    property real originalFrontCoverScale: 1.0

    // pathSpread per-carosello
    property real currentSpread: 1.0
    Behavior on currentSpread {
        NumberAnimation {
            duration: coverFlow.customizerAnimationDuration
            easing.type: viewModeTransitionEasing
        }
    }

    // yOffset per-carosello
    property real currentYOffset: 0
    Behavior on currentYOffset {
        NumberAnimation {
            duration: coverFlow.customizerAnimationDuration
            easing.type: viewModeTransitionEasing
        }
    }

    // coverScale per-carosello
    property real currentCoverScale: 1.0
    Behavior on currentCoverScale {
        enabled: !isViewModeTransitioning
        NumberAnimation {
            duration: coverFlow.customizerAnimationDuration
            easing.type: viewModeTransitionEasing
        }
    }

    // frontCoverScale per-carosello
    property real frontCoverScale: 1.0
    Behavior on frontCoverScale {
        enabled: !isViewModeTransitioning && !isManuallyCustomizing && !(customizer && customizer.isPanelNavigationActive)
        NumberAnimation {
            duration: coverFlow.customizerAnimationDuration
            easing.type: viewModeTransitionEasing
        }
    }

    property real centerCoverYOffset: 0
    Behavior on centerCoverYOffset {
        NumberAnimation {
            duration: coverFlow.customizerAnimationDuration
            easing.type: viewModeTransitionEasing
        }
    }

    // Fixed centerSpacing
    property real centerSpacing: 0.142
    Behavior on centerSpacing {
        NumberAnimation {
            duration: coverFlow.customizerAnimationDuration
            easing.type: viewModeTransitionEasing
        }
    }

    onCenterSpacingChanged: if (!_suppressReload && !isCoverSelected && !isViewModeTransitioning) reloadPathConfig()

    property bool enable3DEffect: true

    property real carouselTwoAngleMultiplier: 1.0

    property real carouselTwoSideScale: 0.1
    property real carouselTwoMidScale: 0.5
    property real carouselTwoOuterScale: 0.95
    property real carouselTwoCenterScale: 1.0

    property real carouselTwoSideYOffset: isCarousel3 ? ((1.0 - carouselTwoSideScale) * 0.25) : 0
    property real carouselTwoMidYOffset: isCarousel3 ? ((1.0 - carouselTwoMidScale) * 0.25) : 0
    property real carouselTwoOuterYOffset: isCarousel3 ? ((1.0 - carouselTwoOuterScale) * 0.25) : 0

    property real carouselThreeAngleMultiplier: isCarousel4 ? -1.0 : 1.0
    Behavior on carouselThreeAngleMultiplier {
        NumberAnimation {
            duration: viewModeTransitionDuration
            easing.type: viewModeTransitionEasing
        }
    }

    property real carouselThreeSideScale: 0.75
    property real carouselThreeOuterScale: 0.30

    property real carouselThreeSideSpacing: isCarousel4 ? 0.3 : 0.2
    Behavior on carouselThreeSideSpacing {
        NumberAnimation {
            duration: viewModeTransitionDuration
            easing.type: viewModeTransitionEasing
        }
    }

    property real activeSideScale: {
        if (isGridView) return 0.8;
        if (isCarousel2) return 0.72;
        if (isCarousel4) return carouselThreeSideScale;
        if (isCarousel3) return carouselTwoSideScale;
        return 0.72;
    }
    Behavior on activeSideScale {
        NumberAnimation {
            duration: viewModeTransitionDuration
            easing.type: viewModeTransitionEasing
        }
    }

    property real activeOuterScale: {
        if (isGridView) return 0.65;
        if (isCarousel2) return 0.72;
        if (isCarousel4) return carouselThreeOuterScale;
        if (isCarousel3) return carouselTwoOuterScale;
        return 0.42;
    }
    Behavior on activeOuterScale {
        NumberAnimation {
            duration: viewModeTransitionDuration
            easing.type: viewModeTransitionEasing
        }
    }

    // Theme-aware cover fallback colors
    property color themeFallback1: "#65333333"
    property color themeFallback2: "#55111111"

    property bool enableEdgeEffect: true
    property color edgeColor: "#60000000"
    property int edgeWidth: 2
    property real perspectiveStrength: 0.4
    property real tallCoverThreshold: 0.9

    property real currentCoverAspectRatio: {
        if (!platform || !platformBoxConfigs[platform]) {
            return platformBoxConfigs.default.aspectRatio || 0.67;
        }
        return platformBoxConfigs[platform].aspectRatio || platformBoxConfigs.default.aspectRatio || 0.67;
    }

    property bool darkenSideCovers: (platformBoxConfigs[platform] || platformBoxConfigs.default).darkenSideCovers || false
    property real sideCoverDarkenStrength: (platformBoxConfigs[platform] || platformBoxConfigs.default).sideCoverDarkenStrength || 0.2

    property alias gameActionPanelRef: gameActionPanel
    property alias customizer: customizer

    property int inputInitialDelay: 400
    property int calculatedScrollRepeatInterval: {
        var numGames = gameModel ? gameModel.count : 0;

        var verySlowRate = 150;
        var slowRate = 120;
        var fastRate = 100;
        var superFastRate = 80;

        var slowGamesThreshold = 25;
        var fastGamesThreshold = 150;
        var maxGamesForSuperFast = 500;

        var rate;

        if (numGames <= slowGamesThreshold) {
            rate = verySlowRate;
        } else if (numGames >= fastGamesThreshold) {
            var normalized = (numGames - fastGamesThreshold) / (maxGamesForSuperFast - fastGamesThreshold);
            rate = Math.max(superFastRate, fastRate - (normalized * (fastRate - superFastRate)));
        } else {
            var normalized = (numGames - slowGamesThreshold) / (fastGamesThreshold - slowGamesThreshold);
            rate = slowRate - (normalized * (slowRate - fastRate));
        }
        return Math.round(rate);
    }

    property var _sourceGameModel  // bound from theme.qml
    property var _filteredGameModel: null
    property var gameModel: _filteredGameModel || _sourceGameModel
    property string platform: ""
    property string previousPlatform: ""
    property int boxbackVersion: 0

    function updatePlatformBaseValues() {
        var config = Cfg.getPlatformBoxConfig(platform)
        var mode = currentViewMode

        // Scale
        var scale = (config.carouselScales && config.carouselScales[mode] !== undefined)
                    ? config.carouselScales[mode] : 1.0
        currentCoverScale = scale

        // FrontCoverScale
        var fcs = (config.carouselFrontCoverScales && config.carouselFrontCoverScales[mode] !== undefined)
                  ? config.carouselFrontCoverScales[mode] : 1.0
        frontCoverScale = fcs

        // YOffset
        var yOff = (config.carouselYOffsets && config.carouselYOffsets[mode] !== undefined)
                   ? config.carouselYOffsets[mode] : 0
        currentYOffset = yOff

        // FrontYOffset
        var fyOff = (config.carouselFrontYOffsets && config.carouselFrontYOffsets[mode] !== undefined)
                    ? config.carouselFrontYOffsets[mode] : 0
        centerCoverYOffset = fyOff

        var spread;
        if (realTotalCovers > 0 && realTotalCovers <= 6 && config.carouselPathSpreadsFewCovers && config.carouselPathSpreadsFewCovers[mode] !== undefined) {
            spread = config.carouselPathSpreadsFewCovers[mode]
        } else {
            spread = (config.carouselPathSpreads && config.carouselPathSpreads[mode] !== undefined)
                     ? config.carouselPathSpreads[mode] : 1.0
        }
        currentSpread = spread

        console.log("🔍 [CoverFlow] updatePlatformBaseValues - platform:", platform,
                    "| mode:", mode,
                    "| scale:", scale, "| fcs:", fcs, "| yOff:", yOff,
                    "| fyOff:", fyOff, "| spread:", spread)
    }

    onPlatformChanged: {
        console.log("🔄 Platform changed from", previousPlatform, "to", platform)

        updatePlatformBaseValues()

        // Clear favourite filter when switching platform
        clearFavouriteFilter();

        if (platform === "lastplayed") {
            if (customizer) {
                customizer.gameCount = realTotalCovers
                customizer.setPlatform(platform)
            }
            if (currentViewMode !== "carousel2") {
                // Use the new viewMode system to switch to carousel2
                viewModeChangeRequested("carousel2")
            }
            previousPlatform = platform
            return
        }

        if (previousPlatform === "lastplayed") {
            // console.log("🔄 Exiting Last Played - reloading global view mode")
            Qt.callLater(function() {
                if (typeof api !== "undefined" && api.memory) {
                    try {
                        var savedViewMode = api.memory.get("acquaflow_last_viewmode");
                        if (savedViewMode) {
                            // console.log("📂 Loaded global view mode:", savedViewMode)
                            viewModeChangeRequested(savedViewMode)
                        }
                    } catch (e) {
                        // console.log("❌ Error loading global view mode:", e)
                    }
                }
            })
            previousPlatform = platform
            return
        }

        if (previousPlatform !== "" && previousPlatform !== platform) {
            // customizer.setPlatform() tramite saveSettings().
            saveCurrentViewMode()
            saveViewModeGlobally()
        }

        if (customizer && platform) {
            customizer.gameCount = realTotalCovers;
            customizer.setPlatform(platform);
        }

        previousPlatform = platform
    }

    property var inputHandler: null

    property int realTotalCovers: gameModel ? gameModel.count : 0
    onRealTotalCoversChanged: {
        if (customizer) customizer.gameCount = realTotalCovers
        updatePlatformBaseValues()
        if (customizer && customizer.currentPlatform) {
            customizer.loadAndApplySettings()
        }
    }
    property int totalModelEntries: 0  // actual displayModel size (dynamic multiplier)

    property int currentIndex: pathViewLoader.item ? pathViewLoader.item.currentIndex : -1

    property bool isScrolling: false
    property bool isFastScrolling: false

    Timer {
        id: fastScrollDetector
        interval: 200  // PERF: increased from 100ms — avoids loading transient covers during brief pauses
        repeat: false
        onTriggered: {
            isFastScrolling = false
        }
    }

    Timer {
        id: coverStabilizationTimer
        interval: 200
        repeat: false
        onTriggered: {
            if (pathViewLoader.item && !isCoverSelected) {
                var currentIdx = pathViewLoader.item.currentIndex
                pathViewLoader.item.currentIndex = currentIdx
            }
        }
    }

    property string pendingViewMode: ""
    property bool pendingWasGridView: false
    property string _previousViewMode: "carousel1"

    function completeViewModeSwitch() {
        // console.log("🔄 Completing view mode switch to:", pendingViewMode)

        // Capture source carousel for stagger decision
        _previousViewMode = currentViewMode
        // carousel2 uses 11 pathItems vs 15 for others; without freezing, changing carousel
        // booleans triggers pathItemCount binding → delegate destruction → visible flash
        if (pathViewLoader.item) {
            _frozenPathItemCount = pathViewLoader.item.pathItemCount
        }
        isViewModeTransitioning = true
        viewModeTransitionTimer.restart()

        // PERF: Suppress cascading reloadPathConfig() from boolean changes and centerSpacing
        _suppressReload = true

        if (customizer.isPanelNavigationActive) {
            customizer.saveSettings()
        }

        if (pendingViewMode === "carousel2") {
            isCarousel1 = false
            isCarousel2 = true
            isCarousel3 = false
            isCarousel4 = false

            customizer.viewModeName = "Carousel 2"

            if (customizer.isPanelNavigationActive) {
                customizer.forceReloadForViewMode()
            } else {
                customizer.setPlatform(platform)
                customizer.refreshUI()
            }
        } else if (pendingViewMode === "carousel3") {
            isCarousel1 = false
            isCarousel2 = false
            isCarousel3 = true
            isCarousel4 = false

            customizer.viewModeName = "Carousel 3"

            if (customizer.isPanelNavigationActive) {
                customizer.forceReloadForViewMode()
            } else {
                customizer.setPlatform(platform)
                customizer.refreshUI()
            }
        } else if (pendingViewMode === "carousel4") {
            isCarousel1 = false
            isCarousel2 = false
            isCarousel3 = false
            isCarousel4 = true

            customizer.viewModeName = "Carousel 4"

            if (customizer.isPanelNavigationActive) {
                customizer.forceReloadForViewMode()
            } else {
                customizer.setPlatform(platform)
                customizer.refreshUI()
            }
        } else if (pendingViewMode === "carousel1") {
            isCarousel1 = true
            isCarousel2 = false
            isCarousel3 = false
            isCarousel4 = false

            customizer.viewModeName = "Carousel 1"

            if (customizer.isPanelNavigationActive) {
                customizer.forceReloadForViewMode()
            } else {
                customizer.setPlatform(platform)
                customizer.refreshUI()
            }
            // console.log("🔄 Entered Carousel 1 mode")
        }

        if (pendingWasGridView) {
            populateAndShowCovers()
        }

        saveCurrentViewMode()

        // PERF: Re-enable reload before the single explicit call
        _suppressReload = false

        // Activate animated morph transition — Behaviors on point objects will animate
        _pathPointAnimating = true
        pathPointAnimEndTimer.restart()

        reloadPathConfig()
    }

    property int lastIndex: -1
    onCurrentIndexChanged: {
        if (isCoverSelected && lastCoverIndex !== -1) {
            if (currentIndex > lastCoverIndex) {
                coverMovementDirection = 1;
            } else if (currentIndex < lastCoverIndex) {
                coverMovementDirection = -1;
            }
            isTransitioningCovers = true;

            Qt.callLater(function() {
                coverMovementDirection = 0;
                isTransitioningCovers = false;
            });
        }

        if (isCoverSelected) {
            lastCoverIndex = currentIndex;
        }

        var diff = Math.abs(currentIndex - lastIndex);
        var isWrapping = diff > (realTotalCovers / 2);

        if (diff > 2 && !isWrapping) {
            isFastScrolling = true
            fastScrollDetector.restart()
        }
        lastIndex = currentIndex
    }
    property bool showNumberIndicator: false
    property bool isTransitioning: false
    property bool isPlatformLoading: false
    Timer {
        id: sliderVisibilityTimer
        interval: 2000
        repeat: false
        onTriggered: {
            isScrolling = false;
            showNumberIndicator = false;
        }
    }
    Timer {
        id: numberAppearanceTimer
        interval: 200
        repeat: false
        onTriggered: {
            showNumberIndicator = true;
        }
    }
    Connections {
        target: pathViewLoader.item
        function onCurrentIndexChanged() {
            isScrolling = true;
            showNumberIndicator = false;
            sliderVisibilityTimer.restart();
            numberAppearanceTimer.restart();
        }
        function onMovingChanged() {
            if (pathViewLoader.item && !pathViewLoader.item.moving) {
            }
        }
    }
    signal gameSelected(var game)
    property int minStepInterval: 220
    property bool _stepLocked: false
    Timer {
        id: stepUnlocker
        interval: minStepInterval
        repeat: false
        onTriggered: coverFlow._stepLocked = false
    }
    function _lockStep() {
        coverFlow._stepLocked = true
        stepUnlocker.restart()
    }
    property int defaultHighlightMoveDuration: 500

    ListModel { id: displayModel }

    function showActionPanelForCurrentGame() {
        if (coverFlow.current()) {
            if (coverFlow.isCoverSelected) {
                gameActionPanel.show(coverFlow.current());
            }
            else {
                if (pathViewLoader.item && pathViewLoader.item.currentIndex !== -1) {
                    coverFlow.selectedCoverIndex = pathViewLoader.item.currentIndex;
                }
            }
        }
    }

    property int _prevTopBarIndex: -1

    function updateTopBarFocus(buttonIndex) {
        // Determine fill direction from navigation
        var direction = "bottom";
        if (_prevTopBarIndex >= 0) {
            if (buttonIndex > _prevTopBarIndex) direction = "right";
            else if (buttonIndex < _prevTopBarIndex) direction = "left";
        }

        // Set direction on all buttons before changing focus
        searchBtn.fillDirection = direction;
        favouriteBtn.fillDirection = direction;
        viewSwitcher.fillDirection = direction;
        customizer.fillDirection = direction;
        menuBtn.fillDirection = direction;
        raBtn.fillDirection = direction;

        // Reset focus (drain with direction)
        searchBtn.focused = false
        favouriteBtn.focused = false
        viewSwitcher.focused = false
        customizer.focused = false
        menuBtn.focused = false
        raBtn.focused = false

        switch(buttonIndex) {
            case 0:
                raBtn.focused = true
                break
            case 1:
                customizer.focused = true
                break
            case 2:
                viewSwitcher.focused = true
                break
            case 3:
                searchBtn.focused = true
                break
            case 4:
                favouriteBtn.focused = true
                break
            case 5:
                menuBtn.focused = true
                break
        }
        _prevTopBarIndex = buttonIndex;
    }

    function resetTopBarFocus() {
        // Drain all buttons downward when exiting topbar
        searchBtn.fillDirection = "bottom";
        favouriteBtn.fillDirection = "bottom";
        viewSwitcher.fillDirection = "bottom";
        customizer.fillDirection = "bottom";
        menuBtn.fillDirection = "bottom";
        raBtn.fillDirection = "bottom";

        searchBtn.focused = false;
        favouriteBtn.focused = false;
        viewSwitcher.focused = false;
        customizer.focused = false;
        menuBtn.focused = false;
        raBtn.focused = false;

        _prevTopBarIndex = -1;
    }

    function activateTopBarButton(buttonIndex) {
        switch(buttonIndex) {
            case 0:
                raBtn.clicked()
                raHubRequested()
                break
            case 1:
                customizer.setPlatform(platform)
                customizer.openPanelForNavigation()
                break
            case 2:
                var nextMode = getNextViewMode()
                viewModeChangeRequested(nextMode)
                break
            case 3:
                // Search: A button opens search bar (same as X)
                if (searchBtn.searchActive) {
                    searchBtn.open();
                } else {
                    searchBtn.press();
                }
                break
            case 4:
                favouriteBtn.clicked()
                break
            case 5:
                menuBtn.clicked()
                break
        }
    }

    function saveCurrentSettings() {
        return {
            spread: customizer.customPathSpread,
            yOffset: customizer.customCoverYOffset,
            scale: customizer.customCoverScale,
            frontScale: customizer.customFrontCoverScale,
            centerYOffset: customizer.customCenterCoverYOffset,
            centerSpacing: customizer.customCenterSpacing
        }
    }

    function saveCurrentViewModeSettings() {
        var currentSettings = saveCurrentSettings()
        if (isCarousel2) {
            saveSettingsToPegasus("carousel2", currentSettings)
        } else if (isCarousel3) {
            saveSettingsToPegasus("carousel3", currentSettings)
        } else if (isCarousel4) {
            saveSettingsToPegasus("carousel4", currentSettings)
        }
    }

    function loadSettings(settings) {
        if (settings && settings.spread !== undefined) {
            customizer.customPathSpread = settings.spread
            customizer.customCoverYOffset = settings.yOffset
            customizer.customCoverScale = settings.scale
            customizer.customFrontCoverScale = settings.frontScale
            customizer.customCenterCoverYOffset = settings.centerYOffset || 0.0
            customizer.customCenterSpacing = settings.centerSpacing || 0.142

            customizer.refreshUI()

            // Push values to CoverFlow properties so Behaviors animate them in sync with path points
            customizer.customValuesChanged(
                customizer.customCoverScale,
                customizer.customCoverYOffset,
                customizer.customPathSpread,
                customizer.customFrontCoverScale,
                customizer.customCenterCoverYOffset,
                customizer.customCenterSpacing
            )
        }
    }

    function saveSettingsToPegasus(modeName, settings) {
        if (typeof api !== "undefined" && api.memory) {
            try {
                var key = "acquaflow_cv2_" + modeName + "_" + platform
                var data = {
                    spread: settings.spread,
                    yOffset: settings.yOffset,
                    scale: settings.scale,
                    frontScale: settings.frontScale,
                    centerYOffset: settings.centerYOffset || 0.0,
                    centerSpacing: settings.centerSpacing || 0.142,
                    platform: platform,
                    timestamp: Date.now()
                }
                api.memory.set(key, JSON.stringify(data))
            } catch (e) {
            }
        }
    }

    function loadSettingsFromPegasus(modeName) {
        try {
            var config = null

            if (typeof api !== "undefined" && api.memory) {
                var key = "acquaflow_cv2_" + modeName + "_" + platform
                var savedData = api.memory.get(key)
                if (savedData) {
                    try {
                        config = JSON.parse(savedData)
                        return {
                            spread: config.spread !== undefined ? config.spread : 1.0,
                            yOffset: config.yOffset !== undefined ? config.yOffset : 0.0,
                            scale: config.scale !== undefined ? config.scale : 1.0,
                            frontScale: config.frontScale !== undefined ? config.frontScale : 1.0,
                            centerYOffset: config.centerYOffset !== undefined ? config.centerYOffset : 0.0,
                            centerSpacing: config.centerSpacing !== undefined ? config.centerSpacing : 0.142
                        }
                    } catch (parseError) {
                        config = null
                    }
                }
            }

            if (!config) {
                var platformConfig = Cfg.getPlatformBoxConfig(platform)
                if (platformConfig) {
                    var fewSpread = (realTotalCovers > 0 && realTotalCovers <= 6 && platformConfig.carouselPathSpreadsFewCovers && platformConfig.carouselPathSpreadsFewCovers[modeName] !== undefined)
                                    ? platformConfig.carouselPathSpreadsFewCovers[modeName] : null;
                    return {
                        spread: fewSpread !== null ? fewSpread : ((platformConfig.carouselPathSpreads && platformConfig.carouselPathSpreads[modeName] !== undefined) ? platformConfig.carouselPathSpreads[modeName] : 1.0),
                        yOffset: (platformConfig.carouselYOffsets && platformConfig.carouselYOffsets[modeName] !== undefined) ? platformConfig.carouselYOffsets[modeName] : 0.0,
                        scale: (platformConfig.carouselScales && platformConfig.carouselScales[modeName] !== undefined) ? platformConfig.carouselScales[modeName] : 1.0,
                        frontScale: (platformConfig.carouselFrontCoverScales && platformConfig.carouselFrontCoverScales[modeName] !== undefined) ? platformConfig.carouselFrontCoverScales[modeName] : 1.0,
                        centerYOffset: (platformConfig.carouselFrontYOffsets && platformConfig.carouselFrontYOffsets[modeName] !== undefined) ? platformConfig.carouselFrontYOffsets[modeName] : 0.0,
                        centerSpacing: 0.142
                    }
                }
            }

            return null

        } catch (e) {
            return null
        }
    }

    function saveCurrentViewMode() {
        if (platform === "lastplayed" || platform === "favourites" || platform === "search") return
        if (typeof api !== "undefined" && api.memory && platform) {
            try {
                var key = "acquaflow_viewmode_" + platform
                var viewModeName = ""

                if (isCarousel2) viewModeName = "carousel2"
                else if (isCarousel3) viewModeName = "carousel3"
                else if (isCarousel4) viewModeName = "carousel4"
                else viewModeName = "carousel1"

                api.memory.set(key, viewModeName)
            } catch (e) {
            }
        }
    }

    function saveViewModeGlobally() {
        if (platform === "lastplayed" || platform === "favourites" || platform === "search") {
            return
        }

        if (typeof api !== "undefined" && api.memory) {
            try {
                var viewModeName = ""

                if (isCarousel2) viewModeName = "carousel2"
                else if (isCarousel3) viewModeName = "carousel3"
                else if (isCarousel4) viewModeName = "carousel4"
                else viewModeName = "carousel1"

                api.memory.set("acquaflow_last_viewmode", viewModeName)
            } catch (e) {
            }
        }
    }

    function loadSavedViewMode() {
        if (typeof api !== "undefined" && api.memory && platform) {
            try {
                var key = "acquaflow_viewmode_" + platform
                var savedViewMode = api.memory.get(key)
                if (savedViewMode) {
                    return savedViewMode
                }
            } catch (e) {
            }
        }
        return "carousel1"  // Default: Carousel 1
    }

    // Enter Carousel 2 mode
    function enterCarousel2() {
        if (isCarousel2 || isCoverSelected) return

        saveCurrentViewModeSettings()

        pendingWasGridView = isGridView
        pendingViewMode = "carousel2"

        completeViewModeSwitch()
    }

    function exitCarousel2() {
        if (!isCarousel2) return
        isCarousel2 = false
    }

    // Enter Carousel 3 mode
    function enterCarousel3() {
        if (isCarousel3 || isCoverSelected) return

        saveCurrentViewModeSettings()

        pendingWasGridView = isGridView
        pendingViewMode = "carousel3"

        completeViewModeSwitch()
    }

    function exitCarousel3() {
        if (!isCarousel3) return
        isCarousel3 = false
    }

    // Enter Carousel 4 mode
    function enterCarousel4() {
        if (isCarousel4 || isCoverSelected) return

        saveCurrentViewModeSettings()

        pendingWasGridView = isGridView
        pendingViewMode = "carousel4"

        completeViewModeSwitch()
    }

    function exitCarousel4() {
        if (!isCarousel4) return
        isCarousel4 = false
    }

    function enterGridView() {
        if (isGridView || isCoverSelected) return

        if (pathViewLoader.item && realTotalCovers > 0) {
            transitionFromIndex = pathViewLoader.item.currentIndex % realTotalCovers

            var pathView = pathViewLoader.item
            var currentItem = pathView.currentItem

            if (currentItem) {
                var sourceCoverWidth = currentItem.width
                var sourceCoverHeight = currentItem.height

                var sourceScale = currentItem.scale || 1.0
                var sourceRotation = currentItem.rotation || 0

                // console.log("📏 Source cover BASE dimensions:", sourceCoverWidth.toFixed(1), "x", sourceCoverHeigh...
                // console.log("📏 Source cover VISUAL scale (includes activeCenterScale):", sourceScale.toFixed(3))

                var itemGlobalRect = currentItem.mapToItem(null, 0, 0, sourceCoverWidth, sourceCoverHeight)
                var coverFlowRect = coverFlow.mapToItem(null, 0, 0)

                var visualX = itemGlobalRect.x - coverFlowRect.x
                var visualY = itemGlobalRect.y - coverFlowRect.y
                var visualWidth = sourceCoverWidth * sourceScale
                var visualHeight = sourceCoverHeight * sourceScale

                var startCenterX = visualX + visualWidth / 2
                var startCenterY = visualY + visualHeight / 2

                var startX = visualX
                var startY = visualY

                var gridStartX = coverFlow.width * 0.15
                var gridStartY = coverFlow.height * 0.08
                var gridCellWidth = (coverFlow.width * 0.7) / 3
                var gridCellHeight = gridCellWidth * 1.5

                var gridCol = transitionFromIndex % 3
                var gridRow = Math.floor(transitionFromIndex / 3)

                var coverAspectRatio = sourceCoverWidth / sourceCoverHeight

                var targetCoverHeight = gridCellHeight * 0.90
                var targetCoverWidth = targetCoverHeight * coverAspectRatio

                // console.log("🎮 Platform:", platform, "- Aspect Ratio:", coverAspectRatio.toFixed(3))

                var visualSourceWidth = sourceCoverWidth * sourceScale
                var visualSourceHeight = sourceCoverHeight * sourceScale

                var finalScaleX = targetCoverWidth / visualSourceWidth
                var finalScaleY = targetCoverHeight / visualSourceHeight
                var finalScale = Math.min(finalScaleX, finalScaleY)

                // console.log("🔍 Visual source:", visualSourceWidth.toFixed(1), "x", visualSourceHeight.toFixed(1))
                // console.log("🔍 Scale calculation: target", targetCoverWidth.toFixed(1), "/ visual", visualSourceW...

                var cellCenterX = gridStartX + (gridCol * gridCellWidth) + (gridCellWidth / 2)
                var cellCenterY = gridStartY + (gridRow * gridCellHeight) + (gridCellHeight / 2)

                var targetX = cellCenterX - (targetCoverWidth / 2)
                var targetY = cellCenterY - (targetCoverHeight / 2)

                // console.log("====================================================")
                // console.log("[CAROUSEL SOURCE]")
                // console.log("  Base:", sourceCoverWidth.toFixed(1), "x", sourceCoverHeight.toFixed(1))
                // console.log("  Scale:", sourceScale.toFixed(3))
                // console.log("  Visual:", visualWidth.toFixed(1), "x", visualHeight.toFixed(1))
                // console.log("[GRID TARGET]")
                // console.log("  Cell:", gridCellWidth.toFixed(1), "x", gridCellHeight.toFixed(1))
                // console.log("  Cover:", targetCoverWidth.toFixed(1), "x", targetCoverHeight.toFixed(1))
                // console.log("  Aspect:", coverAspectRatio.toFixed(3))
                // console.log("[SCALE]:", finalScaleX.toFixed(3), "x", finalScaleY.toFixed(3), "=", finalScale.toFi...
                // console.log("====================================================")

                heroCoverTransition.startHeroTransition(
                    startX, startY,
                    sourceScale,
                    sourceRotation,
                    targetX, targetY,
                    finalScale
                )
            }
        } else {
            transitionFromIndex = 0
        }

        isEnteringGridView = true

        isTransitioning = true

        customizer.viewModeName = "Grid View (Uniform)"

        var pegasusSettings = loadSettingsFromPegasus("gridView")
        if (pegasusSettings) {
            loadSettings(pegasusSettings)
        } else {
            loadSettings(defaultSettings)
        }

        viewTransitionTimer.start()
    }

    function exitGridView() {
        if (!isGridView) return

        if (heroCoverTransition.visible) {
            heroCoverTransition.visible = false
            hideHeroTimer.stop()
        }

        isEnteringGridView = false

        isTransitioning = true

        viewTransitionTimer.start()
    }

    function enterCarousel1() {
        if (isCarousel1 || isCoverSelected) return

        saveCurrentViewModeSettings()

        pendingWasGridView = isGridView
        pendingViewMode = "carousel1"

        completeViewModeSwitch()
    }

    function hideActionPanel() {
        if (gameActionPanel.visible) {
            gameActionPanel.hide();
            coverFlow.selectedCoverIndex = -1;
        }
    }

    function preloadFirstCovers() {
        if (!gameModel || gameModel.count === 0) return;
    }

    function startPlatformLoading() {
        isPlatformLoading = true;
    }

    function stopPlatformLoading() {
        isPlatformLoading = false;
    }

    // Optimized collection loading
    // Uses index-based model (stores integer indices, not game objects)
    // Dynamic multiplier (adapts to collection size instead of fixed ×4)
    // set() reuse when model size unchanged (avoids full PathView delegate rebuild)
    // Chunked append for large collections (>60 entries → batches of 30)

    readonly property int _chunkThreshold: 60  // above this, use chunked loading
    readonly property int _chunkSize: 30  // items per frame in chunked mode

    function _calcMultiplier(numGames, visibleItems) {
        // Guarantee enough entries for seamless infinite scroll
        // Need pathItemCount + cacheItemCount entries minimum
        if (numGames <= 0) return 1;
        var cacheCount = Math.min(10, Math.ceil(visibleItems * 1.5));
        var minEntries = visibleItems + cacheCount;
        var mult = Math.ceil(minEntries / numGames);
        return Math.max(2, mult);
    }

    function populateAndShowCovers() {
        realTotalCovers = gameModel ? gameModel.count : 0;
        chunkedPopulateTimer.stop();
        // NOTE: do NOT call _clearPrefetchSources() here.
        // Clearing evicts images from QML's pixmap cache, causing left-side
        // delegates to appear blank when PathView recreates them.
        // _updatePrefetchSources() overwrites stale URLs naturally.

        if (realTotalCovers <= 0) {
            displayModel.clear();
            totalModelEntries = 0;
            Qt.callLater(function() {
                if (pathViewLoader.item) {
                    pathViewLoader.item.currentIndex = -1;
                    isInitialLoad = false;
                }
                fadeInDelayTimer.start();
            });
            return;
        }

        var newTotal;
        if (isGridView) {
            newTotal = realTotalCovers;
        } else {
            var pItems = (pathViewLoader.item && pathViewLoader.item.pathItemCount)
                         ? pathViewLoader.item.pathItemCount : 13;
            var mult = _calcMultiplier(realTotalCovers, pItems);
            newTotal = realTotalCovers * mult;
        }

        // SMALL COLLECTION FAST PATH: For ≤7 games, use model detach/reattach.
        // Two Qt PathView bugs combine to hide left-side delegates:
        //   (a) Delegates created while PathView has opacity 0 (isTransitioning=true
        //       during platform switch) don't get GPU textures uploaded by the scene
        //       graph. They stay blank even after opacity returns to 1.
        //   (b) Sequential displayModel.append() calls trigger incremental rowsInserted
        //       signals. PathView creates delegates right-biased, deferring left-side
        //       creation to a later pass that may never complete.
        // Fix: Detach model first (no incremental signals), populate fully, ensure
        // PathView visible (isTransitioning=false), reattach atomically, then bounce
        // currentIndex to force bilateral delegate creation.
        if (!isGridView && realTotalCovers > 0 && realTotalCovers <= 7) {
            // Step 1: Detach model — PathView won't process individual append signals
            if (pathViewLoader.item) {
                pathViewLoader.item.model = null;
            }

            // Step 2: Rebuild model while PathView is detached
            displayModel.clear();
            for (var k = 0; k < newTotal; ++k) {
                displayModel.append({ "idx": k % realTotalCovers });
            }
            totalModelEntries = newTotal;

            // Step 3: Ensure PathView visible BEFORE reattaching model
            // Qt scene graph skips texture upload for elements in opacity-0 trees
            isTransitioning = false;

            // Step 4: Reattach — PathView sees fully populated model atomically
            if (pathViewLoader.item) {
                pathViewLoader.item.model = displayModel;
            }

            _finishPopulateSmall();
            Qt.callLater(function() { coverFlow._updatePrefetchSources(); });
            return;
        }

        var oldCount = displayModel.count;

        // FIX: Clamp currentIndex BEFORE model mutation to prevent out-of-bounds.
        // When going from a large collection (100 entries) to a small one (18 entries),
        // the old currentIndex (e.g. 50) would be invalid during the trim → PathView chaos.
        if (pathViewLoader.item && newTotal < oldCount && pathViewLoader.item.currentIndex >= newTotal) {
            pathViewLoader.item.currentIndex = 0;
        }

        // Incremental update: reuse existing delegates, avoid full rebuild
        // Step 1: Update entries that already exist (set() doesn't destroy/recreate delegates)
        var updateEnd = Math.min(oldCount, newTotal);
        for (var i = 0; i < updateEnd; ++i) {
            displayModel.set(i, { "idx": isGridView ? i : (i % realTotalCovers) });
        }

        // Step 2: Trim excess entries if new model is smaller
        if (newTotal < oldCount) {
            displayModel.remove(newTotal, oldCount - newTotal);
        }
        // Step 3: Append new entries if new model is larger
        else if (newTotal > oldCount) {
            var appendStart = oldCount;
            var appendCount = newTotal - oldCount;
            if (appendCount <= _chunkThreshold) {
                // Small difference: append all at once
                for (var j = appendStart; j < newTotal; ++j) {
                    displayModel.append({ "idx": isGridView ? j : (j % realTotalCovers) });
                }
            } else {
                // Large difference: append first batch, schedule rest
                var firstBatch = Math.min(_chunkSize, appendCount);
                for (var j = appendStart; j < appendStart + firstBatch; ++j) {
                    displayModel.append({ "idx": isGridView ? j : (j % realTotalCovers) });
                }
                chunkedPopulateTimer._targetTotal = newTotal;
                chunkedPopulateTimer._nextIndex = appendStart + firstBatch;
                chunkedPopulateTimer.start();
            }
        }

        totalModelEntries = newTotal;
        _finishPopulate();
        // PERF: Direct prefetch call after populate — no debounce.
        // During platform switch we need covers cached ASAP, especially left-side ones
        // that PathView creates slightly after center/right delegates.
        Qt.callLater(function() { coverFlow._updatePrefetchSources(); });
    }

    Timer {
        id: chunkedPopulateTimer
        interval: 4  // ~¼ frame — append a batch and yield
        repeat: true
        property int _targetTotal: 0
        property int _nextIndex: 0
        onTriggered: {
            var end = Math.min(_nextIndex + _chunkSize, _targetTotal);
            for (var i = _nextIndex; i < end; ++i) {
                displayModel.append({ "idx": coverFlow.isGridView ? i : (i % coverFlow.realTotalCovers) });
            }
            _nextIndex = end;
            if (_nextIndex >= _targetTotal) {
                stop();
            }
        }
    }

    function _finishPopulate() {
        Qt.callLater(function() {
            if (pathViewLoader.item) {
                if (realTotalCovers > 0) {
                    pathViewLoader.item.highlightMoveDuration = 0;
                    var targetIndex;
                    if (isGridView) {
                        targetIndex = Math.min(transitionFromIndex, realTotalCovers - 1);
                    } else {
                        targetIndex = Math.floor(totalModelEntries / 2);
                    }
                    pathViewLoader.item.currentIndex = targetIndex;

                    // FIX: Force a complete PathView layout pass so all delegates
                    // get correct interpolated itemScale/itemAngle/itemZ values.
                    // Without this, PathView may not re-interpolate PathAttributes
                    // until the first user scroll, leaving covers at wrong sizes.
                    pathViewLoader.item.positionViewAtIndex(targetIndex, PathView.Center);

                    // Restore highlight animation duration
                    pathViewLoader.item.highlightMoveDuration = (coverFlow.inputHandler && coverFlow.inputHandler.inputRepeatInterval) ? coverFlow.inputHandler.inputRepeatInterval * 1.5 : 150;
                    coverFlow._updatePrefetchSources();

                    isInitialLoad = false;

                    fadeInDelayTimer.start();
                } else {
                    pathViewLoader.item.currentIndex = -1;
                    isInitialLoad = false;
                }
            }
        });
    }

    function _finishPopulateSmall() {
        if (!pathViewLoader.item) {
            return;
        }

        var pv = pathViewLoader.item;
        pv.highlightMoveDuration = 0;
        var targetIndex = Math.floor(totalModelEntries / 2);
        pv.currentIndex = targetIndex;

        // FIX: Force full layout pass for small collections too
        pv.positionViewAtIndex(targetIndex, PathView.Center);

        isInitialLoad = false;

        // Deferred index bounce: force PathView to create delegates on BOTH sides.
        // After model reattach, PathView queues delegate creation for next event loop.
        // The bounce (increment then decrement) triggers PathView's internal scroll
        // logic which forces bilateral delegate creation and texture upload.
        Qt.callLater(function() {
            if (!pathViewLoader.item) return;
            var pv2 = pathViewLoader.item;
            pv2.highlightMoveDuration = 0;
            pv2.incrementCurrentIndex();
            Qt.callLater(function() {
                if (!pathViewLoader.item) return;
                var pv3 = pathViewLoader.item;
                pv3.highlightMoveDuration = 0;
                pv3.decrementCurrentIndex();
                pv3.highlightMoveDuration = (coverFlow.inputHandler && coverFlow.inputHandler.inputRepeatInterval) ? coverFlow.inputHandler.inputRepeatInterval * 1.5 : 150;

                isTransitioning = false;
                fadeInDelayTimer.start();
            });
        });
    }

    Timer {
        id: deferredPopulateTimer
        interval: 50
        repeat: false
        onTriggered: populateAndShowCovers()
    }

    onGameModelChanged: {

        fadeInDelayTimer.stop();
        preloadTimer.stop();
        deferredPopulateTimer.stop();
        chunkedPopulateTimer.stop();
        initialLoadTimer.stop();

        if (isInitialLoad) {
            // INITIAL LOAD PATH: Do NOT set isTransitioning = true.
            // Qt's scene graph skips GPU texture generation for Image elements
            // when their ancestor tree has opacity 0. Setting isTransitioning = true
            // would give PathView opacity 0, causing delegates (especially left-side
            // ones) to be created without texture upload. When opacity returns to 1,
            // those delegates remain blank until a property change forces re-render.
            // By keeping PathView visible during initial load, delegates render
            // immediately with full textures. There's nothing to "flash" at startup.
            if (!gameModel || gameModel.count === 0) {
                // First binding with null model — wait for real data
                return;
            }
            preloadTimer.start();
            initialLoadTimer.start();
        } else {
            // PLATFORM SWITCH PATH
            isTransitioning = true;

            // FIX: Freeze pathItemCount at its current value to prevent premature
            // delegate destruction when switching from large to small collection.
            if (pathViewLoader.item) {
                _frozenPathItemCount = pathViewLoader.item.pathItemCount;
            }

            // Defer populate so platform bar animation isn't blocked
            deferredPopulateTimer.start();
        }
    }

    function movePrev() {
        if (!pathViewLoader.item || pathViewLoader.item.count === 0 || realTotalCovers === 0) return;

        var view = pathViewLoader.item;

        // Grid4 mode: move left in grid
        if (isGridView) {
            if (view.currentIndex > 0) {
                view.currentIndex--;
            }
            // else: already at first item, do nothing
        } else {
            // Other modes: wrap around in PathView
            if (view.currentIndex > 0) {
                view.currentIndex--;
            } else {
                view.currentIndex = totalModelEntries - 1;
            }
            animationWaveDirection = -1;
            triggerWaveAnimation();
        }
    }

    function moveNext() {
        if (!pathViewLoader.item || pathViewLoader.item.count === 0 || realTotalCovers === 0) return;

        var view = pathViewLoader.item;

        // Grid4 mode: move right in grid
        if (isGridView) {
            if (view.currentIndex < realTotalCovers - 1) {
                view.currentIndex++;
            }
            // else: already at last item, do nothing
        } else {
            // Other modes: wrap around in PathView
            if (view.currentIndex < totalModelEntries - 1) {
                view.currentIndex++;
            } else {
                view.currentIndex = 0;
            }
            animationWaveDirection = 1;
            triggerWaveAnimation();
        }
    }

    Timer {
        id: waveResetTimer
        interval: 180
        repeat: false
        onTriggered: waveAmplitude = 0.0
    }

    function triggerWaveAnimation() {
        if (!useStaggeredAnimations) return;

        waveAmplitude = 0.15;
        wavePhase += Math.PI * 0.4 * animationWaveDirection;

        waveResetTimer.restart();
    }

    // Alphabetic jump functions (L2/R2)
    function jumpToNextLetter() {
        if (!pathViewLoader.item || pathViewLoader.item.count === 0 || realTotalCovers === 0 || !gameModel) return;

        var pathView = pathViewLoader.item;

        // Prevent multiple simultaneous jumps
        if (pathView.isAlphabeticJumpInProgress) {
            return;
        }

        var currentIndex = pathView.currentIndex;
        var currentRealIndex;

        // Grid4 mode: direct index (no wrapping)
        if (isGridView) {
            currentRealIndex = currentIndex;
        } else {
            // Other modes: use modulo for wrapped index
            currentRealIndex = currentIndex % realTotalCovers;
        }

        var currentGame = gameModel.get(currentRealIndex);
        var currentLetter = currentGame && currentGame.title ? currentGame.title.charAt(0).toUpperCase() : "";

        // console.log("jumpToNextLetter: Current game:", currentGame.title, "Letter:", currentLetter);

        // First, skip all games with the same letter as current
        var i = 1;
        var searchLimit = realTotalCovers;

        while (i < searchLimit) {
            var checkIndex;

            // Grid4 mode: no wrapping
            if (isGridView) {
                checkIndex = currentRealIndex + i;
                if (checkIndex >= realTotalCovers) {
                    // Reached end in grid4 mode, stop search
                    // console.log("jumpToNextLetter: Reached end of list in grid4 mode");
                    return;
                }
            } else {
                // Other modes: wrap around
                checkIndex = (currentRealIndex + i) % realTotalCovers;
            }

            var checkGame = gameModel.get(checkIndex);
            var checkLetter = checkGame && checkGame.title ? checkGame.title.charAt(0).toUpperCase() : "";

            if (checkLetter !== currentLetter) {
                // Found first game with different letter
                break;
            }
            i++;
        }

        // Now find the first valid next letter (A-Z or 0-9)
        for (; i < searchLimit; i++) {
            var nextRealIndex;

            // Grid4 mode: no wrapping
            if (isGridView) {
                nextRealIndex = currentRealIndex + i;
                if (nextRealIndex >= realTotalCovers) {
                    // Reached end in grid4 mode
                    // console.log("jumpToNextLetter: No more letters found in grid4 mode");
                    return;
                }
            } else {
                // Other modes: wrap around
                nextRealIndex = (currentRealIndex + i) % realTotalCovers;
            }

            var nextGame = gameModel.get(nextRealIndex);
            var nextLetter = nextGame && nextGame.title ? nextGame.title.charAt(0).toUpperCase() : "";

            if (nextLetter !== currentLetter && nextLetter.match(/[A-Z0-9]/)) {
                // console.log("jumpToNextLetter: Jumping to:", nextGame.title, "Letter:", nextLetter, "Distance:", i);
                // Calculate jump distance for animation optimization
                pathView.alphabeticJumpDistance = i;
                pathView.isAlphabeticJumpInProgress = true;

                // Calculate the new absolute index
                var newIndex;
                if (isGridView) {
                    newIndex = nextRealIndex;
                } else {
                    newIndex = currentIndex + i;
                }

                // Use fade transition when jumping 6+ covers, smooth scroll for 1-5 covers
                if (i >= 6) {
                    pathView._isTeleportingPathView = true;

                    // Smooth fade transition with proper timing for large jumps:
                    // Use onTriggered instead of connect() to avoid signal accumulation memory leak
                    fadeOutTimer.interval = 200;
                    var capturedNewIndex = newIndex;  // Capture for closure
                    fadeOutTimer._pendingJumpIndex = capturedNewIndex;
                    fadeOutTimer._pendingJumpForward = true;
                    fadeOutTimer.start();
                } else {
                    // Short jump (1-5 covers): use smooth scroll animation
                    pathView.currentIndex = newIndex;
                    animationWaveDirection = 1;
                    triggerWaveAnimation();

                    // Reset flag after animation completes
                    Qt.callLater(function() {
                        pathView.isAlphabeticJumpInProgress = false;
                        pathView.alphabeticJumpDistance = 0;
                    });
                }

                showAlphabeticIndicator(nextLetter);
                return;
            }
        }
    }

    function jumpToPrevLetter() {
        if (!pathViewLoader.item || pathViewLoader.item.count === 0 || realTotalCovers === 0 || !gameModel) return;

        var pathView = pathViewLoader.item;

        if (pathView.isAlphabeticJumpInProgress) {
            return;
        }

        var currentIndex = pathView.currentIndex;
        var currentRealIndex;

        if (isGridView) {
            currentRealIndex = currentIndex;
        } else {
            currentRealIndex = currentIndex % realTotalCovers;
        }

        var currentGame = gameModel.get(currentRealIndex);
        var currentLetter = currentGame && currentGame.title ? currentGame.title.charAt(0).toUpperCase() : "";

        // console.log("jumpToPrevLetter: Current game:", currentGame.title, "Letter:", currentLetter);

        var i = 1;
        var searchLimit = realTotalCovers;

        while (i < searchLimit) {
            var checkIndex;

            if (isGridView) {
                checkIndex = currentRealIndex - i;
                if (checkIndex < 0) {
                    // console.log("jumpToPrevLetter: Reached beginning of list in grid4 mode");
                    return;
                }
            } else {
                checkIndex = (currentRealIndex - i + realTotalCovers) % realTotalCovers;
            }

            var checkGame = gameModel.get(checkIndex);
            var checkLetter = checkGame && checkGame.title ? checkGame.title.charAt(0).toUpperCase() : "";

            if (checkLetter !== currentLetter) {
                break;
            }
            i++;
        }

        for (; i < searchLimit; i++) {
            var prevRealIndex;

            if (isGridView) {
                prevRealIndex = currentRealIndex - i;
                if (prevRealIndex < 0) {
                    // console.log("jumpToPrevLetter: No more letters found in grid4 mode");
                    return;
                }
            } else {
                prevRealIndex = (currentRealIndex - i + realTotalCovers) % realTotalCovers;
            }

            var prevGame = gameModel.get(prevRealIndex);
            var prevLetter = prevGame && prevGame.title ? prevGame.title.charAt(0).toUpperCase() : "";

            if (prevLetter !== currentLetter && prevLetter.match(/[A-Z0-9]/)) {
                // console.log("jumpToPrevLetter: Jumping to:", prevGame.title, "Letter:", prevLetter, "Distance:", i);
                pathView.alphabeticJumpDistance = i;
                pathView.isAlphabeticJumpInProgress = true;

                var newIndex;
                if (isGridView) {
                    newIndex = prevRealIndex;
                } else {
                    newIndex = currentIndex - i;
                }

                if (i >= 6) {
                    pathView._isTeleportingPathView = true;

                    // Use onTriggered instead of connect() to avoid signal accumulation memory leak
                    fadeOutTimer.interval = 200;
                    var capturedNewIndex = newIndex;  // Capture for closure
                    fadeOutTimer._pendingJumpIndex = capturedNewIndex;
                    fadeOutTimer._pendingJumpForward = false;
                    fadeOutTimer.start();
                } else {
                    pathView.currentIndex = newIndex;
                    animationWaveDirection = -1;
                    triggerWaveAnimation();

                    Qt.callLater(function() {
                        pathView.isAlphabeticJumpInProgress = false;
                        pathView.alphabeticJumpDistance = 0;
                    });
                }

                showAlphabeticIndicator(prevLetter);
                return;
            }
        }
    }

    function showAlphabeticIndicator(letter) {
        coverFlow.showAlphabeticLetter(letter);
    }

    function prevRow() { movePrev() }
    function nextRow() { moveNext() }

    function current() {
        if (gameModel && currentIndex >= 0 && realTotalCovers > 0) {
            if (isGridView) {
                if (currentIndex < realTotalCovers) {
                    return gameModel.get(currentIndex);
                }
            } else {
                var realCurrentIndex = currentIndex % realTotalCovers;
                return gameModel.get(realCurrentIndex);
            }
        }
        return null;
    }
    function launchCurrent() {
        var currentGame = current()
        if (currentGame) {
            if (playtimeTracker) playtimeTracker.trackLaunch(currentGame);
            currentGame.launch()
        }
    }

    // Favourite filter
    // When active, shows ONLY favourite games for the current platform.

    function _buildFilteredFavModel() {
        if (!_sourceGameModel || !platformBarRef) return null;
        var favGames = [];
        for (var i = 0; i < _sourceGameModel.count; i++) {
            var g = _sourceGameModel.get(i);
            if (g && platformBarRef.isGameFavourite(g, platform)) {
                favGames.push(g);
            }
        }
        if (favGames.length === 0) return null;
        // Return a proxy object with .count and .get() like Pegasus model
        return {
            count: favGames.length,
            get: function(idx) { return favGames[idx]; },
            _items: favGames
        };
    }

    function toggleFavouriteFilter() {
        if (!platformBarRef) {
            console.warn("[CoverFlow] No platformBarRef, cannot filter favourites");
            return;
        }

        if (favouriteFilterActive) {
            // Deactivate → restore full model
            favouriteFilterActive = false;
            favouriteBtn.isFavourite = false;
            _filteredGameModel = null;
            populateAndShowCovers();
            console.log("[CoverFlow] Favourite filter OFF — full model restored");
        } else {
            // Activate → build filtered model
            var filtered = _buildFilteredFavModel();
            if (!filtered) {
                console.log("[CoverFlow] No favourites for", platform, "— filter not activated");
                return;
            }
            favouriteFilterActive = true;
            favouriteBtn.isFavourite = true;
            _filteredGameModel = filtered;
            populateAndShowCovers();
            console.log("[CoverFlow] Favourite filter ON for", platform, "—", filtered.count, "games");
        }
    }

    function refreshFavouriteFilter() {
        // Called after toggling a game's fav while filter is active
        if (!favouriteFilterActive) return;
        var filtered = _buildFilteredFavModel();
        if (!filtered || filtered.count === 0) {
            // No more favourites → deactivate filter
            favouriteFilterActive = false;
            favouriteBtn.isFavourite = false;
            _filteredGameModel = null;
            populateAndShowCovers();
            console.log("[CoverFlow] Favourite filter auto-OFF — no favourites left");
        } else {
            _filteredGameModel = filtered;
            populateAndShowCovers();
            console.log("[CoverFlow] Favourite filter refreshed —", filtered.count, "games");
        }
    }

    function clearFavouriteFilter() {
        if (favouriteFilterActive) {
            favouriteFilterActive = false;
            favouriteBtn.isFavourite = false;
            _filteredGameModel = null;
        }
    }

    // Zoom functions for selected cover
    function zoomInSelectedCover() {
        if (isCoverSelected && pathViewLoader.item && pathViewLoader.item.currentItem) {
            pathViewLoader.item.currentItem.zoomIn();
        }
    }

    function zoomOutSelectedCover() {
        if (isCoverSelected && pathViewLoader.item && pathViewLoader.item.currentItem) {
            pathViewLoader.item.currentItem.zoomOut();
        }
    }

    // Smooth zoom functions with custom velocity for inertia
    function zoomInSelectedCoverSmooth(velocity) {
        if (isCoverSelected && pathViewLoader.item && pathViewLoader.item.currentItem) {
            pathViewLoader.item.currentItem.zoomInSmooth(velocity);
        }
    }

    function zoomOutSelectedCoverSmooth(velocity) {
        if (isCoverSelected && pathViewLoader.item && pathViewLoader.item.currentItem) {
            pathViewLoader.item.currentItem.zoomOutSmooth(velocity);
        }
    }

    // Cover scrolling functions when in selected mode (R1/L1)
    // When favouriteFilterActive, the model itself is already filtered — normal scroll works.

    function scrollNextCoverInSelectedMode() {
        if (!isCoverSelected) return;
        if (!gameModel || realTotalCovers === 0) return;
        var pathView = pathViewLoader.item;
        if (!pathView) return;

        pathView.incrementCurrentIndex();
        selectedCoverIndex = pathView.currentIndex;
        coverScrolledInSelectedMode();
    }

    function scrollPrevCoverInSelectedMode() {
        if (!isCoverSelected) return;
        if (!gameModel || realTotalCovers === 0) return;
        var pathView = pathViewLoader.item;
        if (!pathView) return;

        pathView.decrementCurrentIndex();
        selectedCoverIndex = pathView.currentIndex;
        coverScrolledInSelectedMode();
    }

    // MenuManager { ... }
    // Connections { target: menuManagerInstance ... }

    // property alias menuManager: menuManagerInstance

    // Debounce timer for GameCard update during rapid L1/R1 scrolling in selected mode.
    // Cover animations run instantly; heavy data loading (playtime, colors, bar anims)
    // is deferred until the user stops scrolling.
    Timer {
        id: selectedCoverDataDebounce
        interval: 180
        repeat: false
        onTriggered: {
            if (coverFlow.isCoverSelected) {
                gameActionPanel.show(coverFlow.current());
            }
        }
    }

    Connections {
        target: coverFlow
        function onSelectedCoverIndexChanged() {
            if (coverFlow.isCoverSelected) {
                lastCoverIndex = currentIndex;
                // Debounce: during rapid scrolling, only update GameCard after pause
                selectedCoverDataDebounce.restart();
            } else {
                selectedCoverDataDebounce.stop();
                lastCoverIndex = -1;
                gameActionPanel.hide();

                // Deferred refresh: on Favourites platform or active fav filter
                if (coverFlow._pendingFavRefresh) {
                    coverFlow._pendingFavRefresh = false;
                    if (coverFlow.favouriteFilterActive) {
                        coverFlow.refreshFavouriteFilter();
                    } else {
                        coverFlow.favouriteRemovedOnFavPlatform();
                    }
                }

                // reloadPathConfig() here caused stagger animation conflicting with snapMode
            }
        }
    }

    Connections {
        target: platformBar
        function onCollectionChanged(collection) {
            if (collection && collection.shortName) {
                coverFlow.platform = collection.shortName.toLowerCase();
            } else {
                coverFlow.platform = "default";
            }
        }
        function onScrollingStarted() {
            coverFlow.startPlatformLoading();
        }
        function onScrollingStopped() {
            coverFlow.stopPlatformLoading();
        }
    }

    Component {
        id: pathViewComponent
        PathView {
            id: pathView
            anchors.fill: parent
            model: displayModel
            cacheItemCount: Math.min(8, Math.ceil(pathItemCount * 0.6))  // PERF: slightly larger cache to reduce delegate destroy/recreate on scroll
            focus: false
            interactive: !(coverFlow.menuManager && coverFlow.menuManager.menuOpen)
            enabled: !isCoverSelected && !(coverFlow.menuManager && coverFlow.menuManager.menuOpen)

            Timer {
                id: deselectionStabilizeTimer
                interval: 700
                repeat: false
                onTriggered: {
                    if (!coverFlow.isCoverSelected && pathView.currentIndex >= 0 && pathView.count > 0) {
                        pathView.positionViewAtIndex(pathView.currentIndex, PathView.Center);
                    }
                }
            }

            Connections {
                target: coverFlow
                function onIsCoverSelectedChanged() {
                    if (!coverFlow.isCoverSelected) {
                        // PathView.enabled was false during isCoverSelected=true, which freezes
                        // PathAttribute interpolation for all delegates (itemScale, itemAngle, etc.).
                        // When enabled goes back to true, PathView does NOT re-interpolate automatically
                        // — it waits for the next path geometry change.  Calling positionViewAtIndex
                        // immediately (Qt.callLater = next event-loop tick, after 'enabled' propagates)
                        // forces a full PathView layout pass, restoring correct itemScale on ALL covers
                        // before any frame is rendered.  The deselectionStabilizeTimer remains as a
                        // late safety call for bounce-animation settle, but the visual glitch window
                        // shrinks from 700 ms to ~1 frame.
                        Qt.callLater(function() {
                            if (!coverFlow.isCoverSelected && pathView.currentIndex >= 0 && pathView.count > 0) {
                                pathView.positionViewAtIndex(pathView.currentIndex, PathView.Center);
                            }
                        })
                        deselectionStabilizeTimer.restart();
                    } else {
                        deselectionStabilizeTimer.stop();
                    }
                }
            }

            opacity: (isTransitioning || isPlatformLoading || _isTeleportingPathView) ? 0 : 1

            Behavior on opacity {
                enabled: !_isTeleportingPathView
                NumberAnimation {
                    // FIX: 30ms on platform load (~2 frames) caused blank-cover flash on 2K+.
                    // 150ms ensures textures are GPU-ready before full opacity is reached.
                    duration: isPlatformLoading ? 150 : 180
                    easing.type: Easing.OutCubic
                }
            }
            snapMode: PathView.SnapToItem
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5

            property bool _isTeleportingPathView: false
            property bool isClickJumpInProgress: false
            property bool isAlphabeticJumpInProgress: false
            property int alphabeticJumpDistance: 0

            highlightMoveDuration: {
                if (coverFlow.isCoverSelected) {
                    return 0;
                }
                if (isAlphabeticJumpInProgress && alphabeticJumpDistance > 3) {
                    return 0;
                }
                if (isAlphabeticJumpInProgress) {
                    return 120;
                }
                if (isClickJumpInProgress) {
                    return 400;
                }

                var isRepeating = coverFlow.inputHandler && coverFlow.inputHandler.isRepeating;
                var repeatInterval = coverFlow.inputHandler ? coverFlow.inputHandler.inputRepeatInterval : 100;

                if (isRepeating || isFinishingScroll) {
                    return Math.max(50, repeatInterval * 0.9);
                } else {
                    return 300;
                }
            }

            property bool isFinishingScroll: false
            Timer {
                id: scrollFinishTimer
                interval: 250
                onTriggered: pathView.isFinishingScroll = false
            }

            Connections {
                target: coverFlow.inputHandler || null
                enabled: coverFlow.inputHandler !== null
                function onIsRepeatingChanged() {
                    if (!coverFlow.inputHandler.isRepeating) {
                        pathView.isFinishingScroll = true;
                        scrollFinishTimer.restart();
                    } else {
                        pathView.isFinishingScroll = false;
                        scrollFinishTimer.stop();
                    }
                }
            }

            onMovingChanged: {
                if (moving) {
                    coverFlow.isScrolling = true;
                } else {
                    if (pathView.isClickJumpInProgress) {
                        pathView.isClickJumpInProgress = false;
                    }
                    if (pathView.isAlphabeticJumpInProgress) {
                        pathView.isAlphabeticJumpInProgress = false;
                        pathView.alphabeticJumpDistance = 0;
                    }
                    animationWaveDirection = 0;

                    Qt.callLater(function() {
                        coverFlow.isScrolling = false;
                    });
                }
            }

            pathItemCount: {
                // PERF: Freeze pathItemCount during view mode transitions to prevent delegate destroy/create flash
                if (coverFlow._frozenPathItemCount >= 0) return coverFlow._frozenPathItemCount;

                if (!gameModel || gameModel.count === 0) return 15;

                if (coverFlow.isGridView) {
                    return Math.min(7, gameModel.count);
                }

                var realGameCount = gameModel.count;
                var layoutSettings = Utils.getCollectionLayoutSettings();

                if (realGameCount === 1) {
                    return layoutSettings.singleGame.items;
                } else if (realGameCount <= layoutSettings.smallCollection.maxGames) {
                    return layoutSettings.smallCollection.items;
                } else if (realGameCount <= layoutSettings.mediumCollection.maxGames) {
                    return layoutSettings.mediumCollection.items;
                } else {
                    return layoutSettings.largeCollection.items;
                }
            }

            path: Path {
                startY: parent.height * (0.52 + point0.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                startX: parent.width * (0.5 + (point0.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                PathPercent { value: 0.000 }
                PathAttribute { name: "itemAngle"; value: point0.rotationY }
                PathAttribute { name: "itemRotationX"; value: point0.rotationX }
                PathAttribute { name: "itemScale"; value: point0.scale }
                PathAttribute { name: "itemOpacity"; value: point0.opacity }
                PathAttribute { name: "itemZ"; value: point0.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point1.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point1.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.071 }
                PathAttribute { name: "itemAngle"; value: point1.rotationY }
                PathAttribute { name: "itemRotationX"; value: point1.rotationX }
                PathAttribute { name: "itemScale"; value: point1.scale }
                PathAttribute { name: "itemOpacity"; value: point1.opacity }
                PathAttribute { name: "itemZ"; value: point1.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point2.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point2.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.143 }
                PathAttribute { name: "itemAngle"; value: point2.rotationY }
                PathAttribute { name: "itemRotationX"; value: point2.rotationX }
                PathAttribute { name: "itemScale"; value: point2.scale }
                PathAttribute { name: "itemOpacity"; value: point2.opacity }
                PathAttribute { name: "itemZ"; value: point2.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point3.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point3.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.214 }
                PathAttribute { name: "itemAngle"; value: point3.rotationY }
                PathAttribute { name: "itemRotationX"; value: point3.rotationX }
                PathAttribute { name: "itemScale"; value: point3.scale }
                PathAttribute { name: "itemOpacity"; value: point3.opacity }
                PathAttribute { name: "itemZ"; value: point3.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point4.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point4.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.286 }
                PathAttribute { name: "itemAngle"; value: point4.rotationY }
                PathAttribute { name: "itemRotationX"; value: point4.rotationX }
                PathAttribute { name: "itemScale"; value: point4.scale }
                PathAttribute { name: "itemOpacity"; value: point4.opacity }
                PathAttribute { name: "itemZ"; value: point4.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point5.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point5.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.357 }
                PathAttribute { name: "itemAngle"; value: point5.rotationY }
                PathAttribute { name: "itemRotationX"; value: point5.rotationX }
                PathAttribute { name: "itemScale"; value: point5.scale }
                PathAttribute { name: "itemOpacity"; value: point5.opacity }
                PathAttribute { name: "itemZ"; value: point5.zIndex }
                PathLine {
                    x: parent.width * (0.5 + (point6.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point6.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.429 }
                PathAttribute { name: "itemAngle"; value: point6.rotationY }
                PathAttribute { name: "itemRotationX"; value: point6.rotationX }
                PathAttribute { name: "itemScale"; value: point6.scale }
                PathAttribute { name: "itemOpacity"; value: point6.opacity }
                PathAttribute { name: "itemZ"; value: point6.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point7.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * ((coverFlow.currentCoverAspectRatio < 0.9 ? 0.55 : 0.52) + point7.yOffset + coverFlow.animGlobalYOffset + coverFlow.centerCoverYOffset + coverFlow.platformYOffsetNormalized)
                }
                PathPercent { value: 0.500 }
                PathAttribute { name: "itemAngle"; value: point7.rotationY }
                PathAttribute { name: "itemRotationX"; value: point7.rotationX }
                PathAttribute { name: "itemScale"; value: point7.scale }
                PathAttribute { name: "itemOpacity"; value: point7.opacity }
                PathAttribute { name: "itemZ"; value: point7.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point8.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point8.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.571 }
                PathAttribute { name: "itemAngle"; value: point8.rotationY }
                PathAttribute { name: "itemRotationX"; value: point8.rotationX }
                PathAttribute { name: "itemScale"; value: point8.scale }
                PathAttribute { name: "itemOpacity"; value: point8.opacity }
                PathAttribute { name: "itemZ"; value: point8.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point9.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point9.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.643 }
                PathAttribute { name: "itemAngle"; value: point9.rotationY }
                PathAttribute { name: "itemRotationX"; value: point9.rotationX }
                PathAttribute { name: "itemScale"; value: point9.scale }
                PathAttribute { name: "itemOpacity"; value: point9.opacity }
                PathAttribute { name: "itemZ"; value: point9.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point10.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point10.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.714 }
                PathAttribute { name: "itemAngle"; value: point10.rotationY }
                PathAttribute { name: "itemRotationX"; value: point10.rotationX }
                PathAttribute { name: "itemScale"; value: point10.scale }
                PathAttribute { name: "itemOpacity"; value: point10.opacity }
                PathAttribute { name: "itemZ"; value: point10.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point11.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point11.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.786 }
                PathAttribute { name: "itemAngle"; value: point11.rotationY }
                PathAttribute { name: "itemRotationX"; value: point11.rotationX }
                PathAttribute { name: "itemScale"; value: point11.scale }
                PathAttribute { name: "itemOpacity"; value: point11.opacity }
                PathAttribute { name: "itemZ"; value: point11.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point12.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point12.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.857 }
                PathAttribute { name: "itemAngle"; value: point12.rotationY }
                PathAttribute { name: "itemRotationX"; value: point12.rotationX }
                PathAttribute { name: "itemScale"; value: point12.scale }
                PathAttribute { name: "itemOpacity"; value: point12.opacity }
                PathAttribute { name: "itemZ"; value: point12.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point13.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point13.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 0.929 }
                PathAttribute { name: "itemAngle"; value: point13.rotationY }
                PathAttribute { name: "itemRotationX"; value: point13.rotationX }
                PathAttribute { name: "itemScale"; value: point13.scale }
                PathAttribute { name: "itemOpacity"; value: point13.opacity }
                PathAttribute { name: "itemZ"; value: point13.zIndex }

                PathLine {
                    x: parent.width * (0.5 + (point14.xPosition * coverFlow.animSpreadMultiplier * coverFlow.currentSpread))
                    y: parent.height * (0.52 + point14.yOffset + coverFlow.animGlobalYOffset + coverFlow.currentYOffset)
                }
                PathPercent { value: 1.000 }
                PathAttribute { name: "itemAngle"; value: point14.rotationY }
                PathAttribute { name: "itemRotationX"; value: point14.rotationX }
                PathAttribute { name: "itemScale"; value: point14.scale }
                PathAttribute { name: "itemOpacity"; value: point14.opacity }
                PathAttribute { name: "itemZ"; value: point14.zIndex }
            }

            delegate: CoverItem {
                sampler: centralColorSampler
                coverFlowRef: coverFlow
                modelData: (gameModel && gameModel.count > 0) ? gameModel.get(model.idx % gameModel.count) : null
                itemIndex: index
                isCurrentItem: PathView.isCurrentItem || false
                isNearCenter: {
                    var dist = Math.abs(index - pathView.currentIndex);
                    if (pathView.count > 0 && dist > pathView.count / 2) dist = pathView.count - dist;
                    return dist <= (coverFlow.isViewModeTransitioning ? 7 : 3);
                }
                itemAngle: PathView.itemAngle || 0
                itemRotationX: PathView.itemRotationX || 0
                itemScale: PathView.itemScale || 1.0
                itemOpacity: PathView.itemOpacity || 1.0
                itemZ: PathView.itemZ || 0
                itemHeight: screenMetrics.baseCoverHeight
                metrics: screenMetrics
                fastScrollMode: coverFlow.isFastScrolling

                darkenSideCovers: coverFlow.darkenSideCovers
                sideCoverDarkenStrength: coverFlow.sideCoverDarkenStrength

                animationStaggerDelay: coverFlow.animationStaggerDelay
                animationBaseDuration: coverFlow.animationBaseDuration
                animationWaveDirection: coverFlow.animationWaveDirection
                waveAmplitude: coverFlow.waveAmplitude
                wavePhase: coverFlow.wavePhase
                waveFrequency: coverFlow.waveFrequency
                useStaggeredAnimations: coverFlow.useStaggeredAnimations

                onClicked: {
                    if (pathView.currentIndex !== index) {
                        pathView.isClickJumpInProgress = true;
                        pathView.currentIndex = index;
                    } else {
                        coverFlow.selectedCoverIndex = index;
                    }
                }
            }

            onCurrentIndexChanged: {
                if (realTotalCovers > 0) {
                    var realIndex;
                    if (coverFlow.isGridView) {
                        realIndex = currentIndex;
                    } else {
                        realIndex = currentIndex % realTotalCovers;
                    }

                    if (gameModel && realIndex >= 0 && realIndex < gameModel.count) {
                        var currentGame = gameModel.get(realIndex);
                        if (currentGame) {
                            coverFlow.gameSelected(currentGame);
                        }
                    }
                }
                // Trigger prefetch of adjacent cover images
                prefetchDebounce.restart();
            }

            Keys.onLeftPressed: {
            }
            Keys.onRightPressed: {
            }

            Keys.onEscapePressed: {
                if (coverFlow.isCoverSelected) {
                    hideActionPanel();
                    event.accepted = true;
                }
            }
        }
    }

    Component {
        id: gridViewComponent
        GridView {
            id: gridView
            anchors.fill: parent
            anchors.topMargin: parent.height * 0.08
            anchors.bottomMargin: parent.height * 0.08
            anchors.leftMargin: parent.width * 0.15
            anchors.rightMargin: parent.width * 0.15

            model: displayModel
            focus: false
            interactive: !(coverFlow.menuManager && coverFlow.menuManager.menuOpen)
            enabled: !isCoverSelected && !(coverFlow.menuManager && coverFlow.menuManager.menuOpen)
            opacity: (coverFlow.isTransitioning || coverFlow.isPlatformLoading) ? 0 : 1

            cacheBuffer: gridView.cellHeight * 2  // PERF: pre-create 2 extra rows of delegates off-screen
            displayMarginBeginning: 0
            displayMarginEnd: 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            cellWidth: width / 3
            cellHeight: cellWidth * 1.5

            currentIndex: 0
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 150

            highlight: Rectangle {
                color: "transparent"
                border.color: "#00d4ff"
                border.width: 3
                radius: 8
                z: 100
            }

            delegate: Item {
                id: delegateItem
                width: gridView.cellWidth
                height: gridView.cellHeight

                scale: 1.0
                opacity: 1.0

                property bool isHeroCover: index === coverFlow.transitionFromIndex && coverFlow.isTransitioning

                CoverItem {
                    id: coverItem
                    anchors.centerIn: parent
                    visible: !delegateItem.isHeroCover

                    sampler: centralColorSampler
                    coverFlowRef: coverFlow
                    modelData: (gameModel && gameModel.count > 0) ? gameModel.get(model.idx % gameModel.count) : null
                    itemIndex: index
                    isCurrentItem: GridView.isCurrentItem || false
                    itemAngle: 0
                    itemScale: 1.0
                    itemOpacity: 1.0
                    itemZ: 0
                    itemHeight: parent.height * 0.90
                    metrics: screenMetrics
                    fastScrollMode: false

                    darkenSideCovers: false
                    sideCoverDarkenStrength: 0

                    animationStaggerDelay: 0
                    animationBaseDuration: 200
                    animationWaveDirection: 0
                    waveAmplitude: 0
                    wavePhase: 0
                    waveFrequency: 0
                    useStaggeredAnimations: false

                    onClicked: {
                        if (gridView.currentIndex !== index) {
                            gridView.currentIndex = index;
                        } else {
                            coverFlow.selectedCoverIndex = index;
                        }
                    }
                }
            }

            add: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 500
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 450
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.3
                    to: 1.0
                    duration: 500
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.3
                }
            }

            populate: Transition {
                id: populateTransition

                SequentialAnimation {
                    PauseAnimation {
                        duration: {
                            var distance = Math.abs(ViewTransition.index - coverFlow.transitionFromIndex)
                            return distance === 0 ? 450 : Math.min(distance * 25, 250)
                        }
                    }

                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 250  // Leggermente faster
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0.6  // Partenza meno drammatica
                            to: 1.0
                            duration: 300
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            move: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 450
                    easing.type: Easing.InOutCubic
                }
            }

            remove: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        property: "scale"
                        to: 0
                        duration: 350
                        easing.type: Easing.InBack
                    }
                }
            }

            onCurrentIndexChanged: {
                if (realTotalCovers > 0 && currentIndex >= 0 && currentIndex < realTotalCovers) {
                    if (gameModel && currentIndex < gameModel.count) {
                        var currentGame = gameModel.get(currentIndex);
                        if (currentGame) {
                            coverFlow.gameSelected(currentGame);
                        }
                    }
                }
            }

            Keys.onLeftPressed: {
                if (currentIndex % 3 !== 0) {
                    currentIndex--;
                }
                event.accepted = true;
            }

            Keys.onRightPressed: {
                if (currentIndex % 3 !== 2 && currentIndex < count - 1) {
                    currentIndex++;
                }
                event.accepted = true;
            }

            Keys.onUpPressed: {
                if (currentIndex >= 3) {
                    currentIndex -= 3;
                }
                event.accepted = true;
            }

            Keys.onDownPressed: {
                if (currentIndex + 3 < count) {
                    currentIndex += 3;
                }
                event.accepted = true;
            }

            Keys.onEscapePressed: {
                if (coverFlow.isCoverSelected) {
                    hideActionPanel();
                    event.accepted = true;
                }
            }
        }
    }

    Loader {
        id: pathViewLoader
        anchors.fill: parent
        sourceComponent: coverFlow.isGridView ? gridViewComponent : pathViewComponent

        opacity: (coverFlow.isTransitioning && coverFlow.isEnteringGridView) ? 0 : 1
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }

    Item {
        id: heroCoverTransition
        anchors.fill: parent
        visible: false
        z: 1000

        property var sourceGame: null
        property real startX: 0
        property real startY: 0
        property real startScale: 1.0
        property real startRotation: 0
        property real targetX: 0
        property real targetY: 0
        property real targetScale: 1.0

        ShaderEffectSource {
            id: capturedCover
            x: heroCoverTransition.startX
            y: heroCoverTransition.startY

            width: sourceItem ? (sourceItem.width * heroCoverTransition.startScale) : 0
            height: sourceItem ? (sourceItem.height * heroCoverTransition.startScale) : 0

            scale: 1.0
            rotation: heroCoverTransition.startRotation

            sourceItem: {
                if (!heroCoverTransition.visible) return null
                if (!pathViewLoader.item) return null
                var currentItem = pathViewLoader.item.currentItem
                return currentItem || null
            }

            live: false
            hideSource: true
            smooth: true

            layer.enabled: true
            layer.smooth: true
            layer.textureSize: Qt.size(512, 768)

            // Manually controlled ParallelAnimation for max smoothness

            Rectangle {
                anchors.fill: parent
                anchors.margins: -8
                color: "transparent"
                border.color: "#FFD700"
                border.width: 4
                radius: 12
                opacity: 0.6
                z: -1
                visible: parent.visible
            }
        }

        ParallelAnimation {
            id: heroAnimation
            running: false

            property int animationDuration: 450
            property int easingType: Easing.InOutQuad

            PropertyAnimation {
                id: xAnim
                target: capturedCover
                property: "x"
                duration: heroAnimation.animationDuration
                easing.type: heroAnimation.easingType
            }

            PropertyAnimation {
                id: yAnim
                target: capturedCover
                property: "y"
                duration: heroAnimation.animationDuration
                easing.type: heroAnimation.easingType
            }

            PropertyAnimation {
                id: widthAnim
                target: capturedCover
                property: "width"
                duration: heroAnimation.animationDuration
                easing.type: heroAnimation.easingType
            }

            PropertyAnimation {
                id: heightAnim
                target: capturedCover
                property: "height"
                duration: heroAnimation.animationDuration
                easing.type: heroAnimation.easingType
            }

            PropertyAnimation {
                id: rotationAnim
                target: capturedCover
                property: "rotation"
                to: 0
                duration: heroAnimation.animationDuration * 0.7  // Rotation faster
                easing.type: Easing.OutBack  // Effetto elastico
            }

            onStopped: {
                hideHeroTimer.restart()
            }
        }

        Timer {
            id: hideHeroTimer
            interval: 500
            repeat: false
            onTriggered: {
                heroCoverTransition.finishHeroTransition()
            }
        }

        function startHeroTransition(fromX, fromY, fromScale, fromRotation, toX, toY, toScale) {
            // console.log("🦸 startHeroTransition - capturing source cover")

            heroAnimation.stop()
            hideHeroTimer.stop()

            startX = fromX
            startY = fromY
            startScale = fromScale
            startRotation = fromRotation
            targetX = toX
            targetY = toY
            targetScale = toScale

            capturedCover.x = fromX
            capturedCover.y = fromY
            capturedCover.rotation = fromRotation

            // console.log("🎬 Capture from:", fromX.toFixed(1), fromY.toFixed(1), "rotation:", fromRotation.toFi...
            // console.log("🎯 Animate to:", toX.toFixed(1), toY.toFixed(1), "finalScale:", toScale.toFixed(3))

            capturedCover.hideSource = true

            visible = true

            capturedCover.scheduleUpdate()

            if (capturedCover.sourceItem) {
                var visualSourceWidth = capturedCover.sourceItem.width * fromScale
                var visualSourceHeight = capturedCover.sourceItem.height * fromScale

                var targetWidth = visualSourceWidth * toScale
                var targetHeight = visualSourceHeight * toScale

                // console.log("� Base dimensions:", capturedCover.sourceItem.width.toFixed(1), "x", capturedCover.s...
                // console.log("📏 Visual source size (base * carousel scale):", visualSourceWidth.toFixed(1), "x", v...
                // console.log("🎯 Target grid size (visual * toScale):", targetWidth.toFixed(1), "x", targetHeight.t...
                // console.log("📊 Scale transition: carousel", fromScale.toFixed(3), "→ effective grid", toScale.toF...

                xAnim.to = targetX
                yAnim.to = targetY
                widthAnim.to = targetWidth
                heightAnim.to = targetHeight

                Qt.callLater(function() {
                    heroAnimation.start()
                })
            }
        }

        function finishHeroTransition() {
            visible = false
            if (capturedCover.sourceItem) {
                capturedCover.hideSource = false  // Restore source
            }
            // console.log("✅ Hero transition completed")
        }
    }

    GameCard {
        id: gameActionPanel
        platformBarRef: coverFlow.platformBarRef
        currentPlatform: coverFlow.platform
        playtimeTracker: coverFlow.playtimeTracker
        raServiceRef: coverFlow.raServiceRef
        lang: coverFlow.lang

        onPlayClicked: (g) => {
            if (g) {
                if (coverFlow.playtimeTracker) coverFlow.playtimeTracker.trackLaunch(g);
                g.launch();
            }
        }
        onDetailsClicked: (g) => {
            if (pathViewLoader.item && pathViewLoader.item.currentItem) {
                pathViewLoader.item.currentItem.flip();
            }
        }
        onFavouriteClicked: (g) => {
            if (g && platformBarRef) {
                var isFav = platformBarRef.toggleFavourite(g, platform);
                // Direct animation call — binding re-eval is unreliable
                gameActionPanel.applyFavouriteState(isFav);
                // On favourites platform, defer refresh to deselect
                if (coverFlow.platform === "favourites" && !isFav) {
                    coverFlow._pendingFavRefresh = true;
                }
            } else {
                console.warn("CoverFlow: Cannot toggle favourite, no game or platformBarRef.");
            }
        }
        onClosed: {
        }
    }

    MouseArea {
        id: globalInteractionArea
        anchors.fill: parent
        z: 2000
        // Disable interaction when menu is open
        enabled: coverFlow.isCoverSelected && (!coverFlow.menuManager || !coverFlow.menuManager.menuOpen)

        property real lastMouseX: -1
        property real lastMouseY: -1
        property real rotationSensitivity: 0.3
        property bool wasDragged: false

        onPressed: (mouse) => {
            lastMouseX = mouse.x;
            lastMouseY = mouse.y;
            wasDragged = false;
        }

        onPositionChanged: (mouse) => {
            if (pressed) {
                var deltaX = mouse.x - lastMouseX;
                var deltaY = mouse.y - lastMouseY;

                if (Math.abs(deltaX) > 2 || Math.abs(deltaY) > 2) {
                    wasDragged = true;
                }

                var newAngleY = coverFlow.rotationAngleY + deltaX * rotationSensitivity;
                coverFlow.rotationAngleY = Math.max(-rotationLimitY, Math.min(rotationLimitY, newAngleY));

                var newAngleX = coverFlow.rotationAngleX - deltaY * rotationSensitivity;
                coverFlow.rotationAngleX = Math.max(-rotationLimitX, Math.min(rotationLimitX, newAngleX));

                lastMouseX = mouse.x;
                lastMouseY = mouse.y;
            }
        }

        onReleased: {
            lastMouseX = -1;
            lastMouseY = -1;
        }

        onClicked: {
            if (!wasDragged) {
                hideActionPanel();
            }
        }
    }

    Item {
        id: verticalSlider
        anchors.left: parent.left
        anchors.leftMargin: 25
        width: 12
        height: parent.height * 0.4
        // Center on full screen (same as zoom slider)
        y: {
            var barH = (coverFlow.platformBarRef && coverFlow.platformBarRef.height) ? coverFlow.platformBarRef.height : 0;
            var screenH = parent.height + barH;
            return (screenH / 2) - (height / 2);
        }
        property bool __visible: isScrolling && realTotalCovers > 5 && !isPlatformLoading && !isCoverSelected
        opacity: __visible ? 0.5 : 0.0
        scale: __visible ? 1.0 : 0.6
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        Rectangle {
            id: sliderTrack;
            anchors.centerIn: parent;
            width: 4;
            height: parent.height;
            radius: 2;
            color: "#33FFFFFF"
        }
        Rectangle {
            id: sliderThumb
            width: 12;
            height: 12;
            radius: 6;
            color: "#664A9EFF";
            border.color: "#FFFFFF";
            border.width: 1.5
            anchors.horizontalCenter: sliderTrack.horizontalCenter
            y: {
                if (realTotalCovers > 1) {
                    var realCurrentIndex;
                    if (coverFlow.isGridView) {
                        realCurrentIndex = currentIndex;
                    } else {
                        realCurrentIndex = currentIndex % realTotalCovers;
                    }
                    return (sliderTrack.height - height) * (realCurrentIndex / (realTotalCovers - 1));
                }
                return 0;
            }
            Behavior on y { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
        }
        Text {
            id: numberIndicator
            anchors.left: verticalSlider.right
            anchors.leftMargin: 10
            anchors.verticalCenter: sliderThumb.verticalCenter
            property int realIndex: {
                if (!gameModel || realTotalCovers === 0) return 0;
                if (coverFlow.isGridView) {
                    return currentIndex;
                } else {
                    return currentIndex % realTotalCovers;
                }
            }
            text: (realIndex + 1) + " / " + realTotalCovers
            font.pixelSize: screenMetrics.fontPixelSizeMedium
            font.bold: true
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            opacity: (showNumberIndicator && !isPlatformLoading) ? 0.8 : 0.0
            scale: (showNumberIndicator && !isPlatformLoading) ? 1.0 : 0.8
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }
    }

    // Zoom slider (visible only in selected cover mode)
    Item {
        id: zoomSlider
        z: 2001  // Above globalInteractionArea (z:2000)
        anchors.left: parent.left
        anchors.leftMargin: 25
        width: 22
        height: parent.height * 0.35
        // Center on full screen: CoverFlow.height excludes platformBar, so screen midpoint is shifted down
        y: {
            var barH = (coverFlow.platformBarRef && coverFlow.platformBarRef.height) ? coverFlow.platformBarRef.height : 0;
            var screenH = parent.height + barH;
            return (screenH / 2) - (height / 2);
        }
        opacity: isCoverSelected ? 0.5 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        // Zoom active detection (L2/R2 or touch drag)
        property bool _isZoomActive: false
        property bool _isDragging: false
        property real _lastZoom: 1.0

        scale: _isZoomActive ? 1.15 : (isCoverSelected ? 1.0 : 0.6)
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

        property real currentZoom: {
            if (isCoverSelected && pathViewLoader.item && pathViewLoader.item.currentItem)
                return pathViewLoader.item.currentItem.zoomLevel;
            return 1.0;
        }
        property real minZoom: 0.5
        property real maxZoom: 3.0

        onCurrentZoomChanged: {
            if (Math.abs(currentZoom - _lastZoom) > 0.005) {
                _lastZoom = currentZoom;
                _isZoomActive = true;
                zoomActiveTimer.restart();
            }
        }

        Timer {
            id: zoomActiveTimer
            interval: 400
            onTriggered: {
                if (!zoomSlider._isDragging) zoomSlider._isZoomActive = false;
            }
        }

        // Magnifying glass + (top)
        Canvas {
            id: zoomPlusIcon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: 22; height: 22
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = "#FFFFFF";
                ctx.lineWidth = 1.8;
                ctx.beginPath();
                ctx.arc(10, 9, 6.5, 0, 2 * Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(14.8, 13.8);
                ctx.lineTo(19, 18);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(7.5, 9);
                ctx.lineTo(12.5, 9);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(10, 6.5);
                ctx.lineTo(10, 11.5);
                ctx.stroke();
            }
        }

        // Track
        Rectangle {
            id: zoomTrack
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: zoomPlusIcon.bottom
            anchors.topMargin: 8
            anchors.bottom: zoomMinusIcon.top
            anchors.bottomMargin: 8
            width: 4
            radius: 2
            color: "#33FFFFFF"

            // Touch drag area on the full track
            MouseArea {
                anchors.fill: parent
                anchors.margins: -15
                onPressed: {
                    zoomSlider._isDragging = true;
                    zoomSlider._isZoomActive = true;
                    _applyZoomFromY(mouse.y);
                }
                onPositionChanged: {
                    if (zoomSlider._isDragging) _applyZoomFromY(mouse.y);
                }
                onReleased: {
                    zoomSlider._isDragging = false;
                    zoomActiveTimer.restart();
                }
                onCanceled: {
                    zoomSlider._isDragging = false;
                    zoomActiveTimer.restart();
                }
                function _applyZoomFromY(mouseY) {
                    var localY = mouseY + 15;  // offset from margins
                    var trackH = zoomTrack.height;
                    var normalized = 1.0 - Math.max(0, Math.min(1, localY / trackH));
                    var newZoom = zoomSlider.minZoom + normalized * (zoomSlider.maxZoom - zoomSlider.minZoom);
                    if (pathViewLoader.item && pathViewLoader.item.currentItem) {
                        pathViewLoader.item.currentItem.zoomLevel = Math.max(zoomSlider.minZoom, Math.min(zoomSlider.maxZoom, newZoom));
                    }
                }
            }
        }

        // Thumb (hidden when not zooming)
        Rectangle {
            id: zoomThumb
            width: 12; height: 12; radius: 6
            color: "#664A9EFF"
            border.color: "#FFFFFF"; border.width: 1.5
            anchors.horizontalCenter: zoomTrack.horizontalCenter
            opacity: zoomSlider._isZoomActive ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            y: {
                var range = zoomSlider.maxZoom - zoomSlider.minZoom;
                var normalized = (zoomSlider.currentZoom - zoomSlider.minZoom) / range;
                var trackTop = zoomTrack.y;
                var trackUsable = zoomTrack.height - height;
                return trackTop + trackUsable * (1.0 - normalized);
            }
            Behavior on y { NumberAnimation { duration: 80; easing.type: Easing.OutQuad } }
        }

        // Magnifying glass - (bottom)
        Canvas {
            id: zoomMinusIcon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: 22; height: 22
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = "#FFFFFF";
                ctx.lineWidth = 1.8;
                ctx.beginPath();
                ctx.arc(10, 9, 6.5, 0, 2 * Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(14.8, 13.8);
                ctx.lineTo(19, 18);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(7.5, 9);
                ctx.lineTo(12.5, 9);
                ctx.stroke();
            }
        }
    }

    CarouselCustomizer {
        id: customizer
        anchors.fill: parent
        isCoverSelected: coverFlow.isCoverSelected
        screenMetrics: coverFlow.screenMetrics
        viewModeKey: isCarousel2 ? "carousel2" :
                     isCarousel3 ? "carousel3" :
                     isCarousel4 ? "carousel4" : "carousel1"
        lang: coverFlow.lang

        onCustomValuesChanged: (scale, yOffset, spread, frontScale, centerYOffset, centerSpacing) => {
            coverFlow.currentCoverScale = scale
            coverFlow.currentYOffset = yOffset
            coverFlow.currentSpread = spread
            coverFlow.frontCoverScale = frontScale
            coverFlow.centerCoverYOffset = centerYOffset
            coverFlow.centerSpacing = centerSpacing
        }

        onSliderDraggingChanged: (dragging) => {
            coverFlow.isManuallyCustomizing = dragging
        }

        onCustomizationToggled: {
            if (enabled) {
                customizer.currentPlatform = platform

                if (!isCarousel2 && !isCarousel3 && !isCarousel4 && !isGridView) {
                    customizer.setPlatform(platform)
                } else {
                    customizer.refreshUI()
                    customizer.customValuesChanged(
                        customizer.customCoverScale,
                        customizer.customCoverYOffset,
                        customizer.customPathSpread,
                        customizer.customFrontCoverScale,
                        customizer.customCenterCoverYOffset,
                        customizer.customCenterSpacing
                    )
                }
            } else {
                var currentSettings = saveCurrentSettings()
                if (isCarousel2) {
                    saveSettingsToPegasus("carousel2", currentSettings)
                    // console.log("✅ Salvate impostazioni CarouselOne per", platform, ":", JSON.stringify(currentSettin...
                } else if (isCarousel3) {
                    saveSettingsToPegasus("carousel3", currentSettings)
                    // console.log("✅ Salvate impostazioni CarouselTwo per", platform, ":", JSON.stringify(currentSettin...
                } else if (isCarousel4) {
                    saveSettingsToPegasus("carousel4", currentSettings)
                    // console.log("✅ Salvate impostazioni CarouselThree per", platform, ":", JSON.stringify(currentSett...
                } else if (isGridView) {
                    saveSettingsToPegasus("gridView", currentSettings)
                    // console.log("✅ Salvate impostazioni GridView per", platform, ":", JSON.stringify(currentSettings))
                } else {
                    saveSettingsToPegasus("carousel1", currentSettings)
                    // console.log("✅ Salvate impostazioni Carousel Main per", platform, ":", JSON.stringify(currentSett...
                }
            }
        }

        onResetToDefaults: {
        }

        Connections {
            target: coverFlow
            function onPlatformChanged() {
                if (customizer.isCustomizing) {
                    customizer.setPlatform(platform)
                }
            }
        }
    }

    // RA trophy icon — left of carousel customizer
    Rectangle {
        id: raBtn
        x: 20
        y: 24
        width: screenMetrics ? screenMetrics.toolbarButtonSize : 80
        height: screenMetrics ? screenMetrics.toolbarButtonSize : 80
        radius: width / 2
        color: raBtnMA.pressed ? "#33E74C3C" : (raBtnMA.containsMouse ? "#33E74C3C" : "#22FFFFFF")
        border.width: 2
        border.color: "#E74C3C"
        opacity: isCoverSelected ? 0.0 : 0.9
        visible: !isCoverSelected
        clip: false

        property bool focused: false
        property string fillDirection: "bottom"  // "bottom", "left", "right"

        signal clicked()

        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on color  { ColorAnimation  { duration: 150 } }

        // Water fill effect — physics water
        Item {
            id: raBtnWaterFillContainer
            anchors.fill: parent
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: raBtn.width
                    height: raBtn.height
                    radius: raBtn.radius
                }
            }
            Canvas {
                id: raBtnWaterCanvas
                anchors.fill: parent
                property real _level: 0.0
                property real _target: 0.0
                property real _velocity: 0.0
                property real _wavePhase: 0.0
                property real _dir: 0
                property var _drops: []
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    if (_level < 0.005 && _target < 0.5) return;
                    var w = width, h = height;
                    var baseY = h * (1.0 - _level);
                    var tilt = _velocity * 120 * _dir;
                    var leftY = baseY - tilt;
                    var rightY = baseY + tilt;
                    var amp = 4;
                    ctx.beginPath();
                    ctx.moveTo(0, h);
                    for (var px = 0; px <= w; px += 2) {
                        var t = px / w;
                        var surfY = leftY + (rightY - leftY) * t
                            + Math.sin(t * Math.PI * 4 + _wavePhase) * amp;
                        ctx.lineTo(px, surfY);
                    }
                    ctx.lineTo(w, h);
                    ctx.closePath();
                    ctx.fillStyle = "#CCE74C3C";
                    ctx.fill();
                    for (var i = 0; i < _drops.length; i++) {
                        var d = _drops[i];
                        ctx.globalAlpha = Math.max(0, d.alpha);
                        ctx.beginPath();
                        ctx.arc(d.x, d.y, d.r, 0, Math.PI * 2);
                        ctx.fillStyle = "#E74C3C";
                        ctx.fill();
                    }
                    ctx.globalAlpha = 1.0;
                }
                Timer {
                    interval: 16; repeat: true
                    running: raBtnWaterCanvas._level > 0.005 || raBtnWaterCanvas._target > 0.5
                    onTriggered: {
                        var c = raBtnWaterCanvas;
                        var diff = c._target - c._level;
                        c._velocity = c._velocity * 0.95 + diff * 0.035;
                        c._level = Math.max(0, Math.min(1, c._level + c._velocity));
                        c._wavePhase = (c._wavePhase + 0.07) % (Math.PI * 2);
                        if (Math.abs(c._velocity) > 0.01) {
                            var w = c.width, h = c.height;
                            var baseY = h * (1.0 - c._level);
                            var n = Math.floor(Math.random() * 2) + 1;
                            for (var j = 0; j < n; j++) {
                                var rx = Math.random() * w;
                                var t = rx / w;
                                var tilt = c._velocity * 120 * c._dir;
                                var surfY = (baseY - tilt) + tilt * 2 * t
                                    + Math.sin(t * Math.PI * 4 + c._wavePhase) * 4;
                                c._drops.push({ x: rx, y: surfY,
                                    vy: -(Math.random() * 2.5 + 1.5),
                                    vx: (Math.random() - 0.5) * 2.0,
                                    r: Math.random() * 2.5 + 0.8, alpha: 0.85 });
                            }
                        }
                        for (var i = c._drops.length - 1; i >= 0; i--) {
                            var d = c._drops[i];
                            d.y += d.vy; d.vy += 0.25; d.x += d.vx; d.alpha -= 0.03;
                            if (d.alpha <= 0) c._drops.splice(i, 1);
                        }
                        c.requestPaint();
                    }
                }
            }
        }

        onFocusedChanged: {
            raBtnWaterCanvas._dir = fillDirection === "right" ? 1 : (fillDirection === "left" ? -1 : 0);
            raBtnWaterCanvas._target = focused ? 1.0 : 0.0;
            if (!focused) raBtnWaterCanvas._drops = [];
        }

        // Focus ring
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 10; height: parent.height + 10
            radius: width / 2
            color: "transparent"
            border.color: "#E74C3C"; border.width: 3
            opacity: raBtn.focused ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        // Focus label (zoom-in dal basso quando focalizzato)
        Rectangle {
            id: raBtnFocusLabel
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height + 8
            width: Math.max(raBtnFocusLabelText.implicitWidth + 16, 40)
            height: screenMetrics ? Math.max(20, Math.min(26, Math.round(22 * screenMetrics.scaleRatio))) : 22
            radius: height / 2
            color: "#CC1a1a2e"
            border.color: "#66FFFFFF"
            border.width: 1
            transformOrigin: Item.Top
            scale: raBtn.focused ? 1.0 : 0.0
            opacity: raBtn.focused ? 1.0 : 0.0
            Behavior on scale {
                NumberAnimation { duration: 220; easing.type: Easing.OutBack }
            }
            Behavior on opacity {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
            Text {
                id: raBtnFocusLabelText
                anchors.centerIn: parent
                text: "RA"
                font.pixelSize: screenMetrics ? Math.max(10, Math.min(13, Math.round(11 * screenMetrics.scaleRatio))) : 11
                font.bold: true
                color: "white"
            }
        }

        // Trophy icon (outline style)
        Canvas {
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: parent.width * 0.5
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var w = width, h = height
                ctx.strokeStyle = "white"
                ctx.lineWidth = 2
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                // Cup body
                ctx.beginPath()
                ctx.moveTo(w * 0.25, h * 0.12)
                ctx.lineTo(w * 0.75, h * 0.12)
                ctx.lineTo(w * 0.68, h * 0.50)
                ctx.quadraticCurveTo(w * 0.5, h * 0.65, w * 0.32, h * 0.50)
                ctx.closePath()
                ctx.stroke()
                // Left handle
                ctx.beginPath()
                ctx.arc(w * 0.22, h * 0.32, w * 0.10, -Math.PI * 0.5, Math.PI * 0.5)
                ctx.stroke()
                // Right handle
                ctx.beginPath()
                ctx.arc(w * 0.78, h * 0.32, w * 0.10, Math.PI * 0.5, -Math.PI * 0.5)
                ctx.stroke()
                // Stem
                ctx.beginPath()
                ctx.moveTo(w * 0.5, h * 0.60)
                ctx.lineTo(w * 0.5, h * 0.75)
                ctx.stroke()
                // Base
                ctx.beginPath()
                ctx.moveTo(w * 0.32, h * 0.82)
                ctx.lineTo(w * 0.68, h * 0.82)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(w * 0.36, h * 0.75)
                ctx.lineTo(w * 0.64, h * 0.75)
                ctx.stroke()
            }
        }

        MouseArea {
            id: raBtnMA
            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true
            onClicked: {
                raBtn.clicked()
                coverFlow.raHubRequested()
            }
        }

    }

    ViewSwitcher {
        id: viewSwitcher
        x: raBtn.x + raBtn.width + 12 + (screenMetrics ? screenMetrics.toolbarButtonSize : 80) + 18
        y: 24
        width: screenMetrics ? screenMetrics.viewSwitcherWidth : 130
        height: screenMetrics ? screenMetrics.toolbarButtonSize : 80
        radius: height / 2
        screenMetrics: coverFlow.screenMetrics
        isCoverSelected: coverFlow.isCoverSelected
        currentViewMode: coverFlow.currentViewMode
        currentPlatform: coverFlow.platform
        lang: coverFlow.lang

        onViewChanged: (viewType) => {
            // console.log("CoverFlow: ViewSwitcher clicked - emitting viewModeChangeRequested")

            var nextMode = getNextViewMode()
            // console.log("CoverFlow: Next view mode will be:", nextMode)
            viewModeChangeRequested(nextMode)
        }
    }

    Rectangle {
        visible: customizer.isCustomizing
        width: parent.width
        height: 2
        color: "#FF00FF"
        y: parent.height * 0.52 + currentYOffset
        opacity: 0.7

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "YOffset: " + Math.round(currentYOffset)
            color: "#FF00FF"
            font.pixelSize: 12
            font.bold: true
        }
    }

    Item {
        id: topRightButtons
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.rightMargin: 20
        width: (screenMetrics ? screenMetrics.toolbarButtonSize * 3 + 20 : 280)
        height: screenMetrics ? screenMetrics.toolbarButtonSize : 60
        opacity: isCoverSelected ? 0.0 : 1.0
        visible: !isCoverSelected

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        SearchButton {
            id: searchBtn
            anchors.right: favouriteBtn.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            closedSize: screenMetrics ? screenMetrics.toolbarButtonSize : 80
            expandedWidth: coverFlow.width * 0.275
            screenMetrics: coverFlow.screenMetrics
            collections: coverFlow.platformBarRef ? coverFlow.platformBarRef.collections : null
            platformBarRef: coverFlow.platformBarRef
            lang: coverFlow.lang
        }

        FavouriteButton {
            id: favouriteBtn
            objectName: "coverFlowFavouriteButton"
            anchors.right: menuBtn.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: screenMetrics ? screenMetrics.toolbarButtonSize : 80
            height: screenMetrics ? screenMetrics.toolbarButtonSize : 80
            radius: width / 2
            iconSize: screenMetrics ? screenMetrics.toolbarIconSize : 32
            screenMetrics: coverFlow.screenMetrics

            onClicked: {
                coverFlow.toggleFavouriteFilter();
            }
        }

        MenuButton {
            id: menuBtn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: screenMetrics ? screenMetrics.toolbarButtonSize : 80
            height: screenMetrics ? screenMetrics.toolbarButtonSize : 80
            radius: width / 2
            iconSize: screenMetrics ? screenMetrics.toolbarIconSize : 32
            screenMetrics: coverFlow.screenMetrics

            onClicked: {
                if (coverFlow.menuManager) {
                    coverFlow.menuManager.toggleMenu();
                }
            }
        }
    }

    Component.onCompleted: {
        // Populate PlatformConfigs runtime dicts with values saved in api.memory
        if (customizer) customizer.loadAllPlatformSettings()

        updatePlatformBaseValues()

        // FIX: Load path config SYNCHRONOUSLY before PathView creates delegates.
        // Previously Qt.callLater(reloadPathConfig) left path points at default
        // values (scale=1, x=0) for the first frame, causing wrong initial layout.
        reloadPathConfig()

        pathViewLoader.active = true;

        if (customizer) {
            customizer.gameCount = realTotalCovers;
            customizer.setPlatform(platform);
        }
    }
}

