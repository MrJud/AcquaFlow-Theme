import QtQuick 2.15
import ".."
import QtGraphicalEffects 1.15
import "../../utils.js" as Utils
import "../config/PlatformConfigs.js" as PlatformConfigs
import "../config/LogoConfigs.js" as LogoConfigs
import "../config/GameCardConfig.js" as GCConfig

Item {
    id: coverItem
    clip: false

    property var sampler
    property var coverFlowRef
    property var modelData
    property int itemIndex: -1
    property bool isCurrentItem
    property bool isNearCenter: false
    property bool isReturningToCarousel: false  // true during the return-to-carousel slide-back window
    // Theme-aware fallback colors
    property color themeFallback1: coverFlowRef ? coverFlowRef.themeFallback1 : "#65333333"
    property color themeFallback2: coverFlowRef ? coverFlowRef.themeFallback2 : "#55111111"
    property real itemAngle
    property real itemRotationX: 0
    property real itemScale
    property real itemOpacity
    property real itemZ
    property int itemHeight: 480
    property bool fastScrollMode: false

    property bool enableBackSides3D: true

    property real maxRotationY: 45
    property real maxRotationX: 30

    property real baseRotationY: 20
    property real baseRotationX: 15

    property real animatedBaseRotationY: 0
    property real animatedBaseRotationX: 0

    Behavior on animatedBaseRotationY {
        // OPTIMIZATION: Disable animation during fast scrolling to save CPU
        enabled: isNearCenter && !fastScrollMode
        NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
    }
    Behavior on animatedBaseRotationX {
        // OPTIMIZATION: Disable animation during fast scrolling
        enabled: isNearCenter && !fastScrollMode
        NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
    }

    property real animatedInteractiveRotationY: 0
    property real animatedInteractiveRotationX: 0

    property real lastRotationY: 0
    property real lastRotationX: 0
    property real rotationVelocityY: 0
    property real rotationVelocityX: 0
    property bool isRotatingFast: Math.abs(rotationVelocityY) > 5 || Math.abs(rotationVelocityX) > 5
    property bool isInInitialTransition: false

    property bool isUserInteracting: false
    property real lastInteractionTime: 0

    property bool isTransitioningInSelectedMode: false
    property int transitionDirection: 0
    property bool isExitingLeft: false  // Exit direction for animation
    property int previousSelectedIndex: -1  // Track scroll direction
    property bool isBounceAnimationActive: false

    Timer {
        id: initialEntryTimer
        interval: 16
        repeat: false
        onTriggered: {
            var targetPos = calculateSelectedModeTargetPosition();
            if (targetPos) {
                visualTargetX = targetPos.x;
                visualTargetY = targetPos.y;
                visualTargetScale = targetPos.scale;
                visualTargetOpacity = targetPos.opacity;
            } else {
            }

            animatedBaseRotationY = baseRotationY;
            animatedBaseRotationX = baseRotationX;
            animatedInteractiveRotationY = 0;
            animatedInteractiveRotationX = 0;
            velocityTimer.start();
            transitionDelayTimer.start();

            isUserInteracting = false;
            idleStartTimer.start();

            dominoTiltZ = 0;
        }
    }

    Behavior on animatedInteractiveRotationY {
        enabled: isNearCenter && !isUserInteracting  // Disable animation during user input for instant response
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
            easing.overshoot: 1.25  // Subtle bounce effect
        }
    }
    Behavior on animatedInteractiveRotationX {
        enabled: isNearCenter && !isUserInteracting  // Disable animation during user input for instant response
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
            easing.overshoot: 1.25  // Subtle bounce effect
        }
    }

    property bool isRotated: Math.abs(animatedBaseRotationY + animatedInteractiveRotationY) > 0.05 || Math.abs(animatedBaseRotationX + animatedInteractiveRotationX) > 0.05 ||
                             Math.abs(alignmentContainer.y) > 0.1 || Math.abs(alignmentContainer.scale - 1.0) > 0.005

    signal clicked()
    property var metrics

    property real flipRotation: 0
    property bool isFlipped: false

    function flip() {
        isFlipped = !isFlipped
        if (isFlipped) {
            flipRotation = 180
        } else {
            flipRotation = 0
        }
    }

    Behavior on flipRotation {
        enabled: isNearCenter
        NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
    }

    property string currentPlatform: coverFlowRef ? coverFlowRef.platform || "default" : "default"

    property string effectivePlatform: {
        if (currentPlatform === "lastplayed" && modelData) {
            if (modelData.originalPlatform && modelData.originalPlatform.shortName) {
                return modelData.originalPlatform.shortName.toLowerCase();
            }
            else if (modelData.originalPlatformName) {
                return modelData.originalPlatformName.toLowerCase();
            }
            else {
                return "lastplayed";
            }
        }
        else if (currentPlatform === "gc") {
            return "gc";
        }
        else if (modelData && modelData.originalPlatformName) {
            return modelData.originalPlatformName.toLowerCase();
        }
        var platformName = currentPlatform;
        if (modelData) {
            platformName = Utils.detectGameCubePlatform(modelData, currentPlatform);
        }
        return platformName;
    }

    property var activeConfig: {
        if (!coverFlowRef) return undefined;
        return PlatformConfigs.getPlatformBoxConfig(effectivePlatform);
    }

    property var activeLogoConfig: {
        if (!coverFlowRef) return undefined;
        return LogoConfigs.getPlatformLogoConfig(effectivePlatform);
    }
    property bool isTallCover: false

    property bool _isPathViewItemAvailable: !!(coverFlowRef && coverFlowRef.pathViewLoader && coverFlowRef.pathViewLoader.item)
    property bool _isTeleportingPathView: _isPathViewItemAvailable && coverFlowRef.pathViewLoader.item._isTeleportingPathView === true

    property bool isActive: itemOpacity > 0.001 || _isTeleportingPathView || coverLoader.source !== ""

    // Calculated property to avoid repetition
    property bool isSelectedCover: coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex

    onIsActiveChanged: {
        updateActiveState();
    }

    property real lastItemOpacity: 0.0
    onItemOpacityChanged: {
        if (Math.abs(itemOpacity - lastItemOpacity) > 0.01) {
            lastItemOpacity = itemOpacity;
        }
    }

    property string realCoverUrl: {
        var coverPath = Utils.getGameCover(modelData);
        return coverPath;
    }
    onRealCoverUrlChanged: {
        updateActiveState();
    }

    property color sampledTopColor: "transparent"
    property color sampledBottomColor: "transparent"
    property color dynamicTopColor: {
        if (!activeConfig) return "transparent";
        var overrideColor = (coverFlowRef && coverFlowRef.gameSpecificColors && modelData) ? coverFlowRef.gameSpecificColors[modelData.title] : undefined;
        if (overrideColor) return overrideColor;
        if (sampledTopColor.a > 0) return sampledTopColor;
        return activeConfig.boxSideColor;
    }
    property color dynamicBottomColor: {
        if (!activeConfig) return "transparent";
        var overrideColor = (coverFlowRef && coverFlowRef.gameSpecificColors && modelData) ? coverFlowRef.gameSpecificColors[modelData.title] : undefined;
        if (overrideColor) return overrideColor;
        if (sampledBottomColor.a > 0) return sampledBottomColor;
        return activeConfig.boxSideColor;
    }

    property bool darkenSideCovers: false
    property real sideCoverDarkenStrength: 0.2

    property real animationStaggerDelay: 40
    property real animationBaseDuration: 250
    property int animationWaveDirection: 0
    property real waveAmplitude: 0.0
    property real wavePhase: 0.0
    property real waveFrequency: 1.5
    property bool useStaggeredAnimations: true

    property real calculatedStaggerDelay: {
        if (!useStaggeredAnimations || !coverFlowRef) return 0;

        var centerIndex = (coverFlowRef && coverFlowRef.pathViewLoader && coverFlowRef.pathViewLoader.item) ? coverFlowRef.pathViewLoader.item.currentIndex : 0;
        var distance = Math.abs(itemIndex - centerIndex);

        return Math.min(distance * 20, 80);
    }

    // Brief scale pop when this cover visually ARRIVES at center (fired after highlightMoveDuration).
    // The peak is proportional to frontCoverScale so it respects CarouselCustomizer / PlatformConfig sizes.
    // Zero during repeat (fast scroll) or platform loading to avoid noise.
    property real arrivalBounce: 0.0

    // Timer that delays the bounce until the PathView highlight animation has finished,
    // i.e. the cover is actually at center when the pop plays.
    Timer {
        id: arrivalBounceTimer
        repeat: false
        onTriggered: {
            if (coverItem.isCurrentItem && coverFlowRef && !coverFlowRef.isCoverSelected
                    && !coverFlowRef.isPlatformLoading && !coverFlowRef._initializingPathView) {
                arrivalBounceAnimation.restart();
            }
        }
    }

    SequentialAnimation {
        id: arrivalBounceAnimation
        // 8 % overshoot — proportional because arrivalBounce multiplies the full
        // configured scale (itemScale × currentCoverScale × animatedFrontCoverScaleFactor),
        // so the visual pop is always relative to whatever size the platform/customizer set.
        NumberAnimation {
            target: coverItem
            property: "arrivalBounce"
            to: 0.035
            duration: 90
            easing.type: Easing.OutCubic
        }
        // Settle back with a gentle tail
        NumberAnimation {
            target: coverItem
            property: "arrivalBounce"
            to: 0.0
            duration: 180
            easing.type: Easing.OutBack
            easing.overshoot: 0.8
        }
    }

    property real dynamicBounce: {
        if (coverFlowRef && coverFlowRef.isCarousel1) return 0;

        if (!useStaggeredAnimations || !coverFlowRef) return 0;

        var distance = Math.abs(itemIndex - ((coverFlowRef && coverFlowRef.pathViewLoader && coverFlowRef.pathViewLoader.item) ? coverFlowRef.pathViewLoader.item.currentIndex : 0));
        if (distance === 0 || waveAmplitude <= 0) return 0;

        return Math.sin(wavePhase * 2 + distance) * waveAmplitude * 0.05;
    }

    Image {
        id: coverLoader
        visible: false
        source: ""
        cache: true
        asynchronous: true

        sourceSize.width: width * 1.2
        sourceSize.height: height * 1.2

        // coverLoader is INVISIBLE — mipmap/smooth have zero visual effect here
        // Disabling saves GPU texture generation time during decode
        mipmap: false
        smooth: false

        onStatusChanged: {
            if (status === Image.Ready) {
                if (paintedWidth > 0 && paintedHeight > 0) {
                    coverItem.isTallCover = (paintedWidth / paintedHeight) < coverFlowRef.tallCoverThreshold;
                }

                if(modelData && sampler) {
                    sampler.sample(coverItem, source, coverItem.effectivePlatform);
                }
            } else if (status === Image.Error) {
            } /* Original onStatusChanged for coverLoader, no changes needed here */
        }
    }

    Timer {
        id: activityTimer
        repeat: false

        property string currentMode: ""

        onTriggered: {
            switch (currentMode) {
                case "load":
                    if (isActive) {
                        if (coverLoader.source !== realCoverUrl) {
                            coverLoader.source = realCoverUrl;
                        }
                    }
                    break;
                case "unload":
                    // Stiamo scrollando (isFastScrolling o isScrolling)
                    var shouldKeepLoaded = isActive ||
                                          itemOpacity > 0.001 ||
                                          (coverFlowRef && (coverFlowRef.isFastScrolling || coverFlowRef.isScrolling));

                    if (!shouldKeepLoaded && coverLoader.source !== "") {
                        coverLoader.source = "";
                    }
                    break;
            }
        }

        function startMode(mode, delay) {
            stop();
            currentMode = mode;
            interval = delay;
            start();
        }
    }

    function updateActiveState() {
        if (isActive) {
            // OPTIMIZATION: Near-instant load for normal browsing (1ms ≈ immediate)
            // During fast scroll: 150ms delay skips transient covers
            activityTimer.startMode("load", fastScrollMode ? 150 : 1);
        }
        else {
            // OPTIMIZATION: Dynamic unload delay based on collection size and scroll speed
            var unloadDelay = 2500;  // Default conservative delay

            if (coverFlowRef) {
                if (coverFlowRef.isFastScrolling) {
                    unloadDelay = 50;
                } else if (coverFlowRef.realTotalCovers > 100) {
                    unloadDelay = 500;  // Faster unload for large collections
                }
            }

            activityTimer.startMode("unload", unloadDelay);
        }
    }

    height: itemHeight

    Binding on width {
        value: {
            var ratio = activeConfig ? (activeConfig.aspectRatio || 0.7) : 0.7;
            return height * ratio;
        }
    }

    property real visualTargetScale: 1.0
    property real visualTargetX: 0
    property real visualTargetY: 0
    property real visualTargetOpacity: 1.0

    // Carousel One mode properties
    property bool isCarouselOne: coverFlowRef ? coverFlowRef.isCarousel1 : false
    property bool isGridView: coverFlowRef ? coverFlowRef.isGridView : false

    // Animated blend factor for smooth transition to/from grid view mode only
    // 0 = pathview rotation active, 1 = no rotation mode (grid only)
    property real carouselOneBlend: isGridView ? 1.0 : 0.0

    Behavior on carouselOneBlend {
        enabled: isNearCenter
        NumberAnimation {
            duration: coverFlowRef ? coverFlowRef.viewModeTransitionDuration : 500
            easing.type: coverFlowRef ? coverFlowRef.viewModeTransitionEasing : Easing.InOutCubic
        }
    }

    function calculateSelectedModeTargetPosition() {
        if (!coverFlowRef || !activeConfig) {
            return null;
        }

        var platformScale = activeConfig.selectedCoverScale !== null ?
                              activeConfig.selectedCoverScale : GCConfig.gameCardConfig.selectedCoverScale;
        var platformPosition = activeConfig.selectedCoverPosition !== null ?
                                 activeConfig.selectedCoverPosition : { x: GCConfig.gameCardConfig.selectedCoverPosX, y: GCConfig.gameCardConfig.selectedCoverPosY };

        var currentItemScale = itemScale || 1.0;
        var coverScaleFactor = coverFlowRef ? coverFlowRef.currentCoverScale : 1.0;
        var frontScaleFactor = coverFlowRef ? coverFlowRef.frontCoverScale : 1.0;
        var totalOuterScale = currentItemScale * coverScaleFactor * frontScaleFactor;

        // totalOuterScale × compensatedScale = platformScale
        // → compensatedScale = platformScale / totalOuterScale
        var compensatedScale = platformScale / totalOuterScale;

        var desiredCenterXInCoverFlow = coverFlowRef.width * platformPosition.x;
        var desiredCenterYInCoverFlow = coverFlowRef.height * platformPosition.y;

        var pathViewCenterX = coverFlowRef.width / 2;
        var baseY = coverFlowRef.currentCoverAspectRatio < 0.9 ? 0.55 : 0.52;
        var pathViewCenterY = coverFlowRef.height * (baseY + coverFlowRef.animGlobalYOffset + coverFlowRef.centerCoverYOffset + coverFlowRef.platformYOffsetNormalized);

        var offsetX = desiredCenterXInCoverFlow - pathViewCenterX;
        var offsetY = desiredCenterYInCoverFlow - pathViewCenterY;

        var localOffsetX = offsetX / totalOuterScale;
        var localOffsetY = offsetY / totalOuterScale;

        // Size container per centratura
        var containerWidth = alignmentContainer.width > 0 ? alignmentContainer.width : coverItem.width;
        var containerHeight = alignmentContainer.height > 0 ? alignmentContainer.height : coverItem.height;

        var targetX = localOffsetX - (containerWidth * compensatedScale / 2);
        var targetY = localOffsetY - (containerHeight * compensatedScale / 2);

        return {
            x: targetX,
            y: targetY,
            scale: compensatedScale,
            opacity: 1.0
        };
    }

    Behavior on visualTargetOpacity {
        enabled: isNearCenter
        NumberAnimation { duration: 180; easing.type: Easing.InOutQuart }
    }

    property real dominoTiltZ: 0
    Behavior on dominoTiltZ {
        enabled: isNearCenter
        NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.0 }
    }

    Component.onCompleted: {
        if (coverFlowRef && !coverFlowRef.isPlatformLoading) {
            visualTargetOpacity = 1.0;
            visualTargetScale = 1.0;
        }
        if (!coverFlowRef || !coverFlowRef.isCoverSelected) {
            visualTargetOpacity = 1.0;
        }
        updateActiveState();
    }

    transform: Translate {
        y: isCurrentItem && coverFlowRef ? coverFlowRef.centerCoverYOffset : 0
    }

    property real animatedFrontCoverScaleFactor: 1.0

    Binding on animatedFrontCoverScaleFactor {
        value: isCurrentItem ? (coverFlowRef ? coverFlowRef.frontCoverScale : 1.0) : 1.0
    }

    Behavior on animatedFrontCoverScaleFactor {
        enabled: isNearCenter && !(coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex) &&
                 !(coverFlowRef && coverFlowRef.customizer && coverFlowRef.customizer.isCustomizing)
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    // Zoom properties for selected cover mode
    property real zoomLevel: 1.0
    property real minZoom: 0.5
    property real maxZoom: 3.0
    property real zoomStep: 0.15

    Behavior on zoomLevel {
        enabled: isNearCenter
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    // Functions for zoom control
    function zoomIn() {
        if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex) {
            zoomLevel = Math.min(zoomLevel + zoomStep, maxZoom);
        }
    }

    function zoomOut() {
        if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex) {
            zoomLevel = Math.max(zoomLevel - zoomStep, minZoom);
        }
    }

    // Smooth zoom functions with custom velocity for inertia
    function zoomInSmooth(velocity) {
        if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex) {
            zoomLevel = Math.min(zoomLevel + velocity, maxZoom);
        }
    }

    function zoomOutSmooth(velocity) {
        if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex) {
            zoomLevel = Math.max(zoomLevel - velocity, minZoom);
        }
    }

    function resetZoom() {
        zoomLevel = 1.0;
    }

    scale: {
        // e arriva fluidamente a selectedCoverScale.
        var coverScaleFactor = coverFlowRef ? coverFlowRef.currentCoverScale : 1.0;
        return (itemScale * coverScaleFactor * animatedFrontCoverScaleFactor * (1.0 + arrivalBounce)) + dynamicBounce;
    }
    z: {
        if (coverFlowRef && coverFlowRef.isCoverSelected) {
            if (coverFlowRef.selectedCoverIndex === itemIndex) {
                return 100;
            } else {
                var distance = Math.abs(itemIndex - coverFlowRef.selectedCoverIndex);
                if (coverFlowRef.realTotalCovers > 0 && distance > coverFlowRef.realTotalCovers / 2) {
                    distance = coverFlowRef.realTotalCovers - distance;
                }
                return Math.max(0, 50 - distance * 5);  // Z decreases with distance
            }
        }

        return itemZ;
    }
    opacity: itemOpacity

    onIsCurrentItemChanged: {
        if (isCurrentItem && coverFlowRef && !coverFlowRef.isCoverSelected) {
            visualTargetX = 0;
            visualTargetY = 0;
            visualTargetOpacity = 1.0;
            idleTriggerTimer.start();
            flipRotation = 0;
            isFlipped = false;
            // Fire the bounce after the PathView highlight animation finishes so it plays
            // when the cover is visually at center, not while it is still sliding in.
            // Skip during fast repeat scroll or platform loading to avoid noise.
            var isRep = coverFlowRef.inputHandler && coverFlowRef.inputHandler.isRepeating;
            if (!isRep && !coverFlowRef.isPlatformLoading && !coverFlowRef._initializingPathView) {
                var pv = coverFlowRef.pathViewLoader ? coverFlowRef.pathViewLoader.item : null;
                var hlDur = (pv && pv.highlightMoveDuration > 0) ? pv.highlightMoveDuration : 300;
                arrivalBounceTimer.interval = Math.max(hlDur - 30, 10);
                arrivalBounceTimer.restart();
            } else {
                arrivalBounceTimer.stop();
                arrivalBounce = 0.0;
            }
        } else if (!isCurrentItem && coverFlowRef && !coverFlowRef.isCoverSelected) {
            // Cancel any pending arrival bounce
            arrivalBounceTimer.stop();
            arrivalBounceAnimation.stop();
            arrivalBounce = 0.0;
            visualTargetScale = 1.0;
            visualTargetX = 0;
            visualTargetY = 0;
            visualTargetOpacity = 1.0;
            idleTriggerTimer.stop();
            idleAnimation.stop();
            smartResetAnimation.start();
            flipRotation = 0;
            isFlipped = false;
        }
    }

    Connections {
        target: coverFlowRef
        function onIsCoverSelectedChanged() {
            var newTargetX = 0;
            var newTargetY = 0;
            var newTargetScale = 1.0;
            var newTargetOpacity = 1.0;

            if (coverFlowRef.isCoverSelected) {
                if (coverFlowRef.selectedCoverIndex === itemIndex) {
                    // Stop non-selected idle animation and reset its transforms
                    // to prevent desync between cover rotation and side perspective
                    idleAnimation.stop();
                    idleTriggerTimer.stop();
                    arrivalBounceTimer.stop();
                    arrivalBounceAnimation.stop();
                    arrivalBounce = 0.0;
                    idleRotation.angle = 0;
                    idleTilt.angle = 0;
                    idleScale.xScale = 1;
                    idleScale.yScale = 1;
                    idleTranslateY.y = 0;

                    initialEntryTimer.start();

                } else {
                    // Circular-normalised direction: items at path positions 1-7 go left, 9-15 go right
                    var rawOffset = itemIndex - coverFlowRef.selectedCoverIndex;
                    if (coverFlowRef.realTotalCovers > 0) {
                        var halfTotal = coverFlowRef.realTotalCovers / 2;
                        if (rawOffset > halfTotal)       rawOffset -= coverFlowRef.realTotalCovers;
                        else if (rawOffset < -halfTotal) rawOffset += coverFlowRef.realTotalCovers;
                    }
                    var direction = rawOffset < 0 ? -1 : 1;

                    var distanceToSelected = Math.abs(itemIndex - coverFlowRef.selectedCoverIndex);
                    if (coverFlowRef.realTotalCovers > 0) {
                        distanceToSelected = Math.min(distanceToSelected, coverFlowRef.realTotalCovers - distanceToSelected);
                    }
                    distanceToSelected = Math.max(1, distanceToSelected);

                    // Cascade: closest covers clear first, wave spreads outward.
                    // delay = (distance-1) × 35ms  →  dist=1:0ms, dist=2:35ms, dist=3:70ms ...
                    var delayUnit = 35;
                    var maxCascadeDistance = 8;
                    var clampedDistance = Math.min(distanceToSelected, maxCascadeDistance);
                    var cascadeDelay = (clampedDistance - 1) * delayUnit;

                    var effectiveSlideDistance = distanceToSelected;
                    var slideMagnitudeX = coverItem.width * 3.5 * (1 + effectiveSlideDistance * 0.25);
                    var slideMagnitudeY = coverItem.height * 0.08 * effectiveSlideDistance;

                    var finalTargetX     = direction * slideMagnitudeX;
                    var finalTargetY     = slideMagnitudeY;
                    var finalDominoTiltZ = direction * (12 + effectiveSlideDistance * 2);

                    scatterDelayTimer.stop();
                    scatterDelayTimer._tX     = finalTargetX;
                    scatterDelayTimer._tY     = finalTargetY;
                    scatterDelayTimer._tTiltZ = finalDominoTiltZ;
                    scatterDelayTimer.interval = cascadeDelay;
                    scatterDelayTimer.start();

                    animatedBaseRotationY = 0;
                    animatedBaseRotationX = 0;
                    animatedInteractiveRotationY = 0;
                    animatedInteractiveRotationX = 0;
                    idleAnimation.stop();
                    selectedIdleAnimation.stop();
                    idleTriggerTimer.stop();
                    returnToCarouselCompleteTimer.stop();
                    flipRotation = 0;
                    isFlipped = false;
                }
            } else {
                // Reset isInInitialTransition to allow Behaviors to work properly
                isInInitialTransition = false;

                if (isCurrentItem) {
                    newTargetScale = 1.0;
                } else {
                    newTargetScale = 1.0;
                }
                newTargetX = 0;
                newTargetY = 0;
                newTargetOpacity = 1.0;

                // Enable Behaviors on ALL covers (including far-edge, isNearCenter=false)
                // so every scattered cover slides back smoothly instead of snapping.
                isReturningToCarousel = true;
                returnToCarouselReturnTimer.restart();

                visualTargetX = newTargetX;
                visualTargetY = newTargetY;
                visualTargetScale = newTargetScale;
                visualTargetOpacity = newTargetOpacity;

                scatterDelayTimer.stop();
                velocityTimer.stop();
                rotationVelocityY = 0;
                rotationVelocityX = 0;
                transitionDelayTimer.stop();
                selectedIdleAnimation.stop();
                idleReturnTimer.stop();
                idleStartTimer.stop();

                // smartResetAnimation will animate them with bounce
                idleAnimation.stop();

                isUserInteracting = false;
                animatedBaseRotationY = 0;
                animatedBaseRotationX = 0;
                animatedInteractiveRotationY = 0;
                animatedInteractiveRotationX = 0;
                dominoTiltZ = 0;

                // smartResetAnimation will animate them with OutBack bounce
                idleRotation.angle = 0;
                idleTilt.angle = 0;

                smartResetAnimation.start();

                if (isCurrentItem) {
                    returnToCarouselBounceAnimation.start();
                    returnToCarouselCompleteTimer.start();
                }

                coverItem.flipRotation = 0;
                coverItem.isFlipped = false;

                // Reset zoom when exiting selected mode
                resetZoom();
            }
        }

        function onSelectedCoverIndexChanged() {
            if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex) {
                // console.log("CoverItem " + itemIndex + ": onSelectedCoverIndexChanged - becoming selected (isCurr...

                coverItem.flipRotation = 0;
                coverItem.isFlipped = false;

                // to fully position the cover at center
                selectedModePositionTimer.start();

            } else if (coverFlowRef && coverFlowRef.isCoverSelected && previousSelectedIndex === itemIndex && coverFlowRef.selectedCoverIndex !== itemIndex) {
                // Determine exit direction
                var oldIndex = previousSelectedIndex;
                var newIndex = coverFlowRef.selectedCoverIndex;
                var totalCovers = coverFlowRef.realTotalCovers || 100;

                var forwardDistance = (newIndex - oldIndex + totalCovers) % totalCovers;
                var backwardDistance = (oldIndex - newIndex + totalCovers) % totalCovers;

                isExitingLeft = forwardDistance < backwardDistance;  // NEXT = exits right, PREV = exits left

                // console.log("CoverItem " + itemIndex + ": EXITING (was selected, now " + newIndex + " is selected...

                selectedModeTransitionAnimation.stop();

                if (isExitingLeft) {
                    // L1 (PREV): cover exits LEFT
                    exitSelectedLeftAnimation.start();
                } else {
                    exitSelectedRightAnimation.start();
                }

            } else if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex !== itemIndex) {
                // console.log("CoverItem " + itemIndex + ": onSelectedCoverIndexChanged - losing selection");

                isInInitialTransition = false;

                // Circular-normalised direction: items at path positions 1-7 go left, 9-15 go right
                var rawOffset2 = itemIndex - coverFlowRef.selectedCoverIndex;
                if (coverFlowRef.realTotalCovers > 0) {
                    var halfTotal2 = coverFlowRef.realTotalCovers / 2;
                    if (rawOffset2 > halfTotal2)       rawOffset2 -= coverFlowRef.realTotalCovers;
                    else if (rawOffset2 < -halfTotal2) rawOffset2 += coverFlowRef.realTotalCovers;
                }
                var direction = rawOffset2 < 0 ? -1 : 1;
                var distanceToSelected = Math.abs(itemIndex - coverFlowRef.selectedCoverIndex);
                if (coverFlowRef.realTotalCovers > 0) {
                    distanceToSelected = Math.min(distanceToSelected, coverFlowRef.realTotalCovers - distanceToSelected);
                }
                distanceToSelected = Math.max(1, distanceToSelected);

                var effectiveSlideDistance = distanceToSelected;
                var slideMagnitudeX = coverItem.width * 3.5 * (1 + effectiveSlideDistance * 0.3);
                var slideMagnitudeY = coverItem.height * 0.1 * effectiveSlideDistance;

                var finalTargetX = direction * slideMagnitudeX;
                var finalTargetY = slideMagnitudeY;
                var finalDominoTiltZ = direction * (15 + effectiveSlideDistance * 2);

                visualTargetX = finalTargetX;
                visualTargetY = finalTargetY;
                visualTargetScale = 1.0;
                visualTargetOpacity = 1.0;
                dominoTiltZ = finalDominoTiltZ;

                animatedBaseRotationY = 0;
                animatedBaseRotationX = 0;
                animatedInteractiveRotationY = 0;
                animatedInteractiveRotationX = 0;
            }
        }
    }

    Connections {
        target: coverFlowRef
        function onCoverMovementDirectionChanged() {
            if (coverFlowRef && coverFlowRef.isCoverSelected &&
                coverFlowRef.selectedCoverIndex === itemIndex &&
                coverFlowRef.isTransitioningCovers) {

                isTransitioningInSelectedMode = true;
                transitionDirection = coverFlowRef.coverMovementDirection;

                var slideOffset = transitionDirection * 30;
                visualTargetX = slideOffset;

                Qt.callLater(function() {
                    Qt.callLater(function() {
                        visualTargetX = (coverFlowRef && coverFlowRef.isCoverSelected &&
                                        coverFlowRef.selectedCoverIndex === itemIndex) ?
                                        visualTargetX : 0;
                        isTransitioningInSelectedMode = false;
                        transitionDirection = 0;
                    });
                });
            }
        }
        function onRotationAngleYChanged() {
            if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex) {
                selectedIdleAnimation.stop();
                idleStartTimer.stop();
                isUserInteracting = true;
                idleReturnTimer.restart();

                var interactiveAngle = coverFlowRef.rotationAngleY;
                var minLimit, maxLimit;

                // Original asymmetric limits (restored)
                if (interactiveAngle >= 0) {
                    maxLimit = maxRotationY * 0.6;
                    minLimit = -maxRotationY * 0.2;
                } else {
                    maxLimit = maxRotationY * 0.2;
                    minLimit = -maxRotationY * 1.5;
                }

                animatedInteractiveRotationY = Math.max(minLimit, Math.min(maxLimit, interactiveAngle));
            }
        }
        function onRotationAngleXChanged() {
            if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex) {
                selectedIdleAnimation.stop();
                idleStartTimer.stop();
                isUserInteracting = true;
                idleReturnTimer.restart();

                var interactiveAngle = coverFlowRef.rotationAngleX;
                var minLimit, maxLimit;

                // Original asymmetric limits (restored)
                if (interactiveAngle >= 0) {
                    maxLimit = maxRotationX * 0.6;
                    minLimit = -maxRotationX * 0.2;
                } else {
                    maxLimit = maxRotationX * 0.2;
                    minLimit = -maxRotationX * 1.5;
                }

                animatedInteractiveRotationX = Math.max(minLimit, Math.min(maxLimit, interactiveAngle));
            }
        }
    }

    // Carousel One Mode Connection
    Connections {
        target: coverFlowRef
        function onIsCarousel1Changed() {
            if (coverFlowRef && coverFlowRef.isCarousel1) {
                animatedBaseRotationY = 0
                animatedBaseRotationX = 0
                animatedInteractiveRotationY = 0
                animatedInteractiveRotationX = 0
            }
        }
    }

    Timer { id: idleTriggerTimer; interval: 100; repeat: false; onTriggered: if (isCurrentItem && !coverFlowRef.isCoverSelected) idleAnimation.start() }

    // Scatter delay timer — one per delegate.
    // Each cover fires after (distance-1)×35ms so the wave spreads outward:
    // cover at distance 1 clears immediately (0ms), distance 2 after 35ms, etc.
    Timer {
        id: scatterDelayTimer
        repeat: false
        property real _tX: 0
        property real _tY: 0
        property real _tTiltZ: 0
        onTriggered: {
            if (coverFlowRef && coverFlowRef.isCoverSelected &&
                    coverFlowRef.selectedCoverIndex !== coverItem.itemIndex) {
                coverItem.visualTargetX = _tX;
                coverItem.visualTargetY = _tY;
                coverItem.dominoTiltZ   = _tTiltZ;
            }
        }
    }

    Timer {
        id: returnToCarouselCompleteTimer
        interval: 600
        repeat: false
        onTriggered: {
            if (isCurrentItem && !coverFlowRef.isCoverSelected) {
                idleAnimation.start()
            }
        }
    }

    // Clears the isReturningToCarousel flag after all return Behavior animations have finished.
    // Duration (550 ms) slightly exceeds the max Behavior duration (500 ms) so the flag
    // stays active for the full travel of even the farthest scattered cover.
    Timer {
        id: returnToCarouselReturnTimer
        interval: 550
        repeat: false
        onTriggered: { isReturningToCarousel = false; }
    }

    Timer {
        id: transitionDelayTimer
        interval: 650
        repeat: false
        onTriggered: {
            isInInitialTransition = false
        }
    }

    Timer {
        id: velocityTimer
        interval: 16
        repeat: true
        onTriggered: {
            if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex) {
                var currentRotY = animatedInteractiveRotationY
                var currentRotX = animatedInteractiveRotationX

                rotationVelocityY = Math.abs(currentRotY - lastRotationY) / (interval / 1000.0)
                rotationVelocityX = Math.abs(currentRotX - lastRotationX) / (interval / 1000.0)

                lastRotationY = currentRotY
                lastRotationX = currentRotX
            }
        }
    }

    Timer {
        id: idleStartTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex) {
                selectedIdleAnimation.start();
            }
        }
    }

    Timer {
        id: idleReturnTimer
        interval: 500  // Increased to avoid interfering with rapid D-pad input
        repeat: false
        onTriggered: {
            if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex) {
                isUserInteracting = false;
                selectedIdleAnimation.start();
            }
        }
    }

    Timer {
        id: selectedModePositionTimer
        interval: 100  // Delay to let PathView position the cover
        repeat: false
        onTriggered: {
            if (coverFlowRef && coverFlowRef.isCoverSelected) {
                previousSelectedIndex = coverFlowRef.selectedCoverIndex;
            }

            var targetPos = calculateSelectedModeTargetPosition();
            if (!targetPos) {
                return;
            }

            isInInitialTransition = true;

            visualTargetX = targetPos.x;
            visualTargetY = targetPos.y;
            visualTargetScale = targetPos.scale;
            visualTargetOpacity = targetPos.opacity;

            if (previousSelectedIndex >= 0 && previousSelectedIndex !== itemIndex) {
                alignmentContainer.x = 0;  // PathView center
                alignmentContainer.y = 0;
                alignmentContainer.scale = 1.0;
                alignmentContainer.opacity = 0.5;
                // console.log("  → [Timer] Starting from carousel position (R1/L1 transition)");
            }

            selectedModeTransitionAnimation.start();

            animatedBaseRotationY = baseRotationY;
            animatedBaseRotationX = baseRotationX;
            animatedInteractiveRotationY = 0;
            animatedInteractiveRotationX = 0;

            velocityTimer.start();
            transitionDelayTimer.start();
            isUserInteracting = false;
            idleStartTimer.start();
            dominoTiltZ = 0;
        }
    }

    ParallelAnimation {
        id: idleAnimation
        loops: Animation.Infinite
        SequentialAnimation {
            NumberAnimation { target: idleTranslateY; property: "y"; to: -3; duration: 2000; easing.type: Easing.OutSine }
            NumberAnimation { target: idleTranslateY; property: "y"; to: -12; duration: 3000; easing.type: Easing.InOutSine }
            NumberAnimation { target: idleTranslateY; property: "y"; to: -5;  duration: 2500; easing.type: Easing.InOutSine }
            NumberAnimation { target: idleTranslateY; property: "y"; to: -18; duration: 4000; easing.type: Easing.InOutSine }
            NumberAnimation { target: idleTranslateY; property: "y"; to: -15; duration: 2000; easing.type: Easing.InOutSine }
            NumberAnimation { target: idleTranslateY; property: "y"; to: 0;   duration: 3000; easing.type: Easing.InOutSine }
        }
        SequentialAnimation {
            // SOFT START: Begin with small gradual rotation
            NumberAnimation { target: idleRotation; property: "angle"; to: 2;  duration: 2500; easing.type: Easing.OutQuad }
            NumberAnimation { target: idleRotation; property: "angle"; to: 6;  duration: 3500; easing.type: Easing.InOutQuad }
            NumberAnimation { target: idleRotation; property: "angle"; to: -8; duration: 4500; easing.type: Easing.InOutQuad }
            NumberAnimation { target: idleRotation; property: "angle"; to: 4;  duration: 3000; easing.type: Easing.InOutQuad }
            NumberAnimation { target: idleRotation; property: "angle"; to: -2; duration: 1500; easing.type: Easing.InOutQuad }
            NumberAnimation { target: idleRotation; property: "angle"; to: 0;  duration: 2000; easing.type: Easing.InOutQuad }
        }
        SequentialAnimation {
            // SOFT START: Begin with minimal tilt
            NumberAnimation { target: idleTilt; property: "angle"; to: -1; duration: 3000; easing.type: Easing.OutSine }
            NumberAnimation { target: idleTilt; property: "angle"; to: -2; duration: 4000; easing.type: Easing.InOutSine }
            NumberAnimation { target: idleTilt; property: "angle"; to: 2;  duration: 5000; easing.type: Easing.InOutSine }
            NumberAnimation { target: idleTilt; property: "angle"; to: -1; duration: 3000; easing.type: Easing.InOutSine }
            NumberAnimation { target: idleTilt; property: "angle"; to: 0;  duration: 2500; easing.type: Easing.InOutSine }
        }
        SequentialAnimation {
            NumberAnimation { target: idleScale; properties: "xScale,yScale"; to: 1.06; duration: 4500; easing.type: Easing.InOutQuart }
            NumberAnimation { target: idleScale; properties: "xScale,yScale"; to: 1.02; duration: 3500; easing.type: Easing.InOutQuart }
            NumberAnimation { target: idleScale; properties: "xScale,yScale"; to: 1.05; duration: 3000; easing.type: Easing.InOutQuart }
            NumberAnimation { target: idleScale; properties: "xScale,yScale"; to: 1.03; duration: 2000; easing.type: Easing.InOutQuart }
        }
    }

    ParallelAnimation {
        id: selectedIdleAnimation
        loops: Animation.Infinite
        running: false

        SequentialAnimation {
            NumberAnimation { target: idleTranslateY; property: "y"; to: -8; duration: 2000; easing.type: Easing.InOutSine }
            NumberAnimation { target: idleTranslateY; property: "y"; to: 5; duration: 2500; easing.type: Easing.InOutSine }
            NumberAnimation { target: idleTranslateY; property: "y"; to: -12; duration: 3000; easing.type: Easing.InOutSine }
            NumberAnimation { target: idleTranslateY; property: "y"; to: 0; duration: 2500; easing.type: Easing.InOutSine }
        }

        SequentialAnimation {
            NumberAnimation { target: coverItem; property: "animatedBaseRotationY"; to: baseRotationY + 5; duration: 2500; easing.type: Easing.InOutQuad }
            NumberAnimation { target: coverItem; property: "animatedBaseRotationY"; to: baseRotationY - 3; duration: 3000; easing.type: Easing.InOutQuad }
            NumberAnimation { target: coverItem; property: "animatedBaseRotationY"; to: baseRotationY + 2; duration: 2000; easing.type: Easing.InOutQuad }
            NumberAnimation { target: coverItem; property: "animatedBaseRotationY"; to: baseRotationY; duration: 2500; easing.type: Easing.InOutQuad }
        }

        SequentialAnimation {
            NumberAnimation { target: coverItem; property: "animatedBaseRotationX"; to: baseRotationX + 3; duration: 3000; easing.type: Easing.InOutSine }
            NumberAnimation { target: coverItem; property: "animatedBaseRotationX"; to: baseRotationX - 2; duration: 2500; easing.type: Easing.InOutSine }
            NumberAnimation { target: coverItem; property: "animatedBaseRotationX"; to: baseRotationX + 1; duration: 2000; easing.type: Easing.InOutSine }
            NumberAnimation { target: coverItem; property: "animatedBaseRotationX"; to: baseRotationX; duration: 2500; easing.type: Easing.InOutSine }
        }
    }

    SequentialAnimation {
        id: smartResetAnimation
        property real calculatedDuration: {
            var rotationDistance = Math.abs(animatedBaseRotationY) + Math.abs(animatedBaseRotationX) +
                                   Math.abs(idleRotation.angle) + Math.abs(idleTilt.angle);
            var idleTranslateDistance = Math.abs(idleTranslateY.y) / 20;
            var idleScaleDistance = Math.abs(idleScale.xScale - 1.0) * 50;

            var totalDistance = rotationDistance + idleTranslateDistance + idleScaleDistance;
            return Math.max(300, Math.min(800, 300 + totalDistance * 20))
        }

        ParallelAnimation {
            NumberAnimation {
                target: coverItem; property: "animatedBaseRotationY";
                to: 0; duration: smartResetAnimation.calculatedDuration * 0.7;
                easing.type: Easing.OutBack; easing.overshoot: 0.8
            }
            NumberAnimation {
                target: coverItem; property: "animatedBaseRotationX";
                to: 0; duration: smartResetAnimation.calculatedDuration * 0.7;
                easing.type: Easing.OutBack; easing.overshoot: 0.8
            }
            NumberAnimation {
                target: idleRotation; property: "angle";
                to: 0; duration: smartResetAnimation.calculatedDuration * 0.6;
                easing.type: Easing.OutQuart
            }
            NumberAnimation {
                target: idleTilt; property: "angle";
                to: 0; duration: smartResetAnimation.calculatedDuration * 0.6;
                easing.type: Easing.OutQuart
            }

            NumberAnimation {
                target: idleTranslateY; property: "y"; to: 0;
                duration: smartResetAnimation.calculatedDuration * 0.7;
                easing.type: Easing.OutBack;
                easing.overshoot: 1.2  // Overshoot moderato
            }
            PropertyAnimation {
                target: idleScale; properties: "xScale,yScale"; to: 1.0;
                duration: smartResetAnimation.calculatedDuration * 0.7;
                easing.type: Easing.OutBack;
                easing.overshoot: 1.15
            }

            NumberAnimation {
                target: rotationContainer; property: "z";
                to: 0; duration: smartResetAnimation.calculatedDuration * 0.5;
                easing.type: Easing.OutCubic
            }
        }

        onStopped: {
        }
    }

    ParallelAnimation {
        id: exitSelectedLeftAnimation

        // LEFT exit (L1) — synced durations, snappy
        NumberAnimation {
            target: alignmentContainer; property: "x";
            to: alignmentContainer.x - coverFlowRef.width * 0.5;
            duration: 280; easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: alignmentContainer; property: "y";
            to: alignmentContainer.y + 50;
            duration: 280; easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: alignmentContainer; property: "opacity"; to: 0;
            duration: 220; easing.type: Easing.InQuad
        }

        NumberAnimation {
            target: alignmentContainer; property: "scale"; to: visualTargetScale * 0.7;
            duration: 280; easing.type: Easing.InCubic
        }
    }

    ParallelAnimation {
        id: exitSelectedRightAnimation

        NumberAnimation {
            target: alignmentContainer; property: "x";
            to: alignmentContainer.x + coverFlowRef.width * 0.8;
            duration: 320; easing.type: Easing.InOutCubic
        }

        NumberAnimation {
            target: alignmentContainer; property: "y";
            to: alignmentContainer.y - 30;
            duration: 320; easing.type: Easing.InOutCubic
        }

        NumberAnimation {
            target: alignmentContainer; property: "opacity"; to: 0;
            duration: 300; easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: alignmentContainer; property: "scale"; to: visualTargetScale * 0.75;
            duration: 320; easing.type: Easing.InCubic
        }
    }

    SequentialAnimation {
        id: selectedModeTransitionAnimation

        ParallelAnimation {
            // Entrata R1/L1 — durate sincronizzate, easing premium
            NumberAnimation {
                target: alignmentContainer; property: "x"; to: visualTargetX;
                duration: 480; easing.type: Easing.OutQuint
            }

            NumberAnimation {
                target: alignmentContainer; property: "y"; to: visualTargetY;
                duration: 480; easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: alignmentContainer; property: "scale"; to: visualTargetScale;
                duration: 480; easing.type: Easing.OutQuint
            }

            NumberAnimation {
                target: alignmentContainer; property: "opacity"; to: visualTargetOpacity;
                duration: 350; easing.type: Easing.OutCubic
            }
        }

        ScriptAction {
            script: {
                isInInitialTransition = false;
            }
        }
    }

    SequentialAnimation {
        id: returnToCarouselBounceAnimation

        onStarted: {
            isBounceAnimationActive = true;
        }

        onStopped: {
            isBounceAnimationActive = false;
        }

        ParallelAnimation {
            // Smooth return — synced durations, subtle vertical bounce
            NumberAnimation {
                target: alignmentContainer; property: "x"; to: 0;
                duration: 550;
                easing.type: Easing.OutCubic;
            }

            NumberAnimation {
                target: alignmentContainer; property: "scale"; to: 1.0;
                duration: 550;
                easing.type: Easing.OutCubic;
            }

            NumberAnimation {
                target: alignmentContainer; property: "opacity"; to: 1.0;
                duration: 350;
                easing.type: Easing.OutCubic;
            }

            NumberAnimation {
                target: alignmentContainer; property: "y";
                from: -60;
                to: 0;
                duration: 600;
                easing.type: Easing.OutBounce;
            }
        }
    }

    Item {
        id: alignmentContainer
        width: parent.width
        height: parent.height

        // BEHAVIOR: Initial entry (A) and return from selected
        Behavior on x {
            enabled: (isNearCenter || isReturningToCarousel) && !isInInitialTransition && !isBounceAnimationActive && !(coverFlowRef && coverFlowRef.isViewModeTransitioning)
            NumberAnimation {
                duration: Math.abs(visualTargetX) < 10 ? 380 : 500
                easing.type: Math.abs(visualTargetX) < 10 ? Easing.OutCubic : Easing.OutQuint
            }
        }

        Behavior on y {
            enabled: (isNearCenter || isReturningToCarousel) && !isInInitialTransition && !isBounceAnimationActive && !(coverFlowRef && coverFlowRef.isViewModeTransitioning)
            NumberAnimation {
                duration: Math.abs(visualTargetY) < 10 ? 380 : 500
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            enabled: (isNearCenter || isReturningToCarousel) && !isInInitialTransition && !isBounceAnimationActive && !(coverFlowRef && coverFlowRef.isViewModeTransitioning)
            NumberAnimation {
                duration: Math.abs(visualTargetScale - 1.0) < 0.1 ? 380 : 500
                easing.type: Math.abs(visualTargetScale - 1.0) < 0.1 ? Easing.OutCubic : Easing.OutQuint
            }
        }

        Behavior on opacity {
            enabled: (isNearCenter || isReturningToCarousel) && !isInInitialTransition && !isBounceAnimationActive
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        x: visualTargetX
        y: visualTargetY
        scale: visualTargetScale * zoomLevel

        opacity: {
            if (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex !== itemIndex) {
                var xDistance = Math.abs(alignmentContainer.x);
                var indexDistance = Math.abs(itemIndex - coverFlowRef.selectedCoverIndex);

                if (coverFlowRef.realTotalCovers > 0 && indexDistance > coverFlowRef.realTotalCovers / 2) {
                    indexDistance = coverFlowRef.realTotalCovers - indexDistance;
                }

                if (indexDistance <= 2 && xDistance > 200) {
                    return 0.0;
                }

                if (xDistance < 50) return 1.0;
                if (xDistance > 300) return 0.0;

                var opacityByX = Math.max(0.0, 1.0 - (xDistance - 50) / 250);

                var opacityByIndex = indexDistance <= 3 ? 1.0 : Math.max(0.0, 1.0 - (indexDistance - 3) / 5);

                return Math.min(opacityByX, opacityByIndex);
            }
            return visualTargetOpacity;
        }

        transform: [
            Translate { id: idleTranslateY; y: 0 },
            Scale { id: idleScale; xScale: 1; yScale: 1; origin.x: alignmentContainer.width/2; origin.y: alignmentContainer.height/2 }
        ]

        Connections {
            target: coverFlowRef;
            function onIsPlatformLoadingChanged() {
                if (coverFlowRef && !coverFlowRef.isPlatformLoading) {
                    if (visualTargetOpacity < 1.0) visualTargetOpacity = 1.0;
                    if (visualTargetScale < 1.0) visualTargetScale = 1.0;
                }
            }
        }

        Item {
            id: rotationContainer
            anchors.fill: parent
            Behavior on z { enabled: isNearCenter; NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

            transform: [
                Rotation {
                    origin.x: width / 2; origin.y: height / 2; axis { x: 0; y: 1; z: 0 }
                    angle: coverItem.flipRotation
                },
                Rotation {
                    origin.x: width / 2; origin.y: height / 2; axis { x: 0; y: 0; z: 1 }
                    angle: dominoTiltZ
                },
                Rotation {
                    id: interactiveRotationY
                    origin.x: width / 2; origin.y: height / 2; axis { x: 0; y: 1; z: 0 }
                    angle: animatedBaseRotationY + animatedInteractiveRotationY
                },
                Rotation {
                    id: interactiveRotationX
                    origin.x: width / 2; origin.y: height / 2; axis { x: 1; y: 0; z: 0 }
                    angle: animatedBaseRotationX + animatedInteractiveRotationX
                },
                Rotation {
                    id: pathViewRotation
                    origin.x: width / 2; origin.y: height / 2; axis { x: 0; y: 1; z: 0 }
                    angle: itemAngle * (1.0 - carouselOneBlend)
                },
                Rotation {
                    id: pathViewRotationX
                    origin.x: width / 2; origin.y: height / 2; axis { x: 1; y: 0; z: 0 }
                    angle: itemRotationX * (1.0 - carouselOneBlend)
                },
                Rotation {
                    id: idleRotation
                    origin.x: width / 2; origin.y: height / 2; axis { x: 0; y: 1; z: 0 }
                    angle: 0
                },
                Rotation {
                    id: idleTilt
                    origin.x: width / 2; origin.y: height / 2; axis { x: 1; y: 0; z: 0 }
                    angle: 0
                }
            ]

            CoverPresenter {
                id: frontCoverPresenter
                anchors.fill: parent
                modelData: coverItem.modelData
                coverSource: coverLoader.source
                itemAngle: pathViewRotation.angle + idleRotation.angle
                isCurrentItem: coverItem.isCurrentItem
                isTallCover: coverItem.isTallCover
                activeConfig: coverItem.activeConfig
                themeFallback1: coverItem.themeFallback1
                themeFallback2: coverItem.themeFallback2
                dynamicTopColor: coverItem.dynamicTopColor
                dynamicBottomColor: coverItem.dynamicBottomColor
                perspectiveStrength: coverFlowRef ? coverFlowRef.perspectiveStrength : 0.4
                enable3DEffect: coverFlowRef ? coverFlowRef.enable3DEffect : false
                enableEdgeEffect: coverFlowRef ? coverFlowRef.enableEdgeEffect : false
                edgeColor: coverFlowRef ? coverFlowRef.edgeColor : "white"
                edgeWidth: coverFlowRef ? coverFlowRef.edgeWidth : 2
                metrics: coverItem.metrics
                platform: coverFlowRef ? coverFlowRef.platform || "default" : "default"
                animatedYOffset: alignmentContainer.y + idleTranslateY.y
                animatedXRotation: (coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex)
                    ? (coverItem.animatedBaseRotationX + coverItem.animatedInteractiveRotationX)
                    : idleTilt.angle
                isSelected: coverFlowRef && coverFlowRef.isCoverSelected && coverFlowRef.selectedCoverIndex === itemIndex
                selectedRotationAngleY: coverItem.animatedBaseRotationY + coverItem.animatedInteractiveRotationY
                parentIsInteractingFast: coverItem.isRotatingFast
                darkenSideCovers: coverItem.darkenSideCovers
                sideCoverDarkenStrength: coverItem.sideCoverDarkenStrength
                isTransitioning: coverFlowRef ? coverFlowRef.isTransitioning : false
                isPlatformLoading: coverFlowRef ? coverFlowRef.isPlatformLoading : false
                isAlphabeticTeleporting: coverItem._isTeleportingPathView

                // FIXED: Pass info for side opacity sync
                parentOpacity: alignmentContainer.opacity
                isInSelectedMode: coverFlowRef ? coverFlowRef.isCoverSelected : false
                isNearCenter: coverItem.isNearCenter
                isScrolling: coverFlowRef ? coverFlowRef.isScrolling : false

                currentViewMode: coverFlowRef ? coverFlowRef.currentViewMode : "coverflow"

                opacity: coverItem.flipRotation < 90 || coverItem.flipRotation > 270 ? 1 : 0
                Behavior on opacity { enabled: coverItem.isNearCenter; NumberAnimation { duration: 100 } }

            }

            Rectangle {
                id: backVisualContainer
                anchors.fill: parent

                y: (coverItem.animatedBaseRotationX + coverItem.animatedInteractiveRotationX) * 0.4 + idleTranslateY.y
                Behavior on y {
                    enabled: coverItem.isNearCenter
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                color: "transparent"
                clip: true

                transform: Rotation { origin.x: width / 2; origin.y: height / 2; axis { x: 0; y: 1; z: 0 } angle: 180 }

                opacity: coverItem.flipRotation > 90 && coverItem.flipRotation < 270 ? 1 : 0
                Behavior on opacity { enabled: coverItem.isNearCenter; NumberAnimation { duration: 100 } }

                property real backEffectiveNormalizedAngleY: Math.abs(coverItem.animatedBaseRotationY + coverItem.animatedInteractiveRotationY) / 90.0
                property real backDynamicDepth: backEffectiveNormalizedAngleY * (coverItem.activeConfig ? coverItem.activeConfig.boxDepth || 40 : 40) * 1.8 * (coverItem.metrics ? coverItem.metrics.scaleRatio : 1.0)

                readonly property Item actualBackContent: box2dBackLoader.hasValidSource ? box2dBackLoader : fallbackBackContent

                // Properties to get the actual rendered dimensions and position of the back content
                property real renderedContentWidth: {
                    if (box2dBackLoader.hasValidSource) {
                        return box2dBackLoader.paintedWidth;
                    }
                    return fallbackBackContent.width;
                }
                property real renderedContentHeight: {
                    if (box2dBackLoader.hasValidSource) {
                        return box2dBackLoader.paintedHeight;
                    }
                    return fallbackBackContent.height;
                }

                // Y position of the *top* of the rendered content, relative to backVisualContainer
                property real renderedContentLocalY: {
                    if (box2dBackLoader.hasValidSource) {
                        // box2dBackLoader.y is (backVisualContainer.height - box2dBackLoader.height)
                        // The image is aligned to bottom within box2dBackLoader, so its top is at
                        // box2dBackLoader.y + (box2dBackLoader.height - box2dBackLoader.paintedHeight)
                        return (backVisualContainer.height - box2dBackLoader.height) + (box2dBackLoader.height - box2dBackLoader.paintedHeight);
                    }
                    // fallbackBackContent.y is (backVisualContainer.height - fallbackBackContent.height)
                    return (backVisualContainer.height - fallbackBackContent.height);
                }

                // X position of the *left* of the rendered content, relative to backVisualContainer
                property real renderedContentLocalX: {
                    if (box2dBackLoader.hasValidSource) {
                        // box2dBackLoader.x is (backVisualContainer.width - box2dBackLoader.width) / 2
                        // The image is centered horizontally, so its left is at
                        // box2dBackLoader.x + (box2dBackLoader.width - box2dBackLoader.paintedWidth) / 2
                        return (backVisualContainer.width - box2dBackLoader.width) / 2 + (box2dBackLoader.width - box2dBackLoader.paintedWidth) / 2;
                    }
                    // fallbackBackContent.x is (backVisualContainer.width - fallbackBackLoader.width) / 2
                    return (backVisualContainer.width - fallbackBackContent.width) / 2;
                }

                Image {
                    id: box2dBackLoader
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom

                    property var fallbackConfig: coverItem.activeConfig ? coverItem.activeConfig.fallback : undefined;
                    property real defaultAspectRatio: coverItem.activeConfig ? (coverItem.activeConfig.aspectRatio || 0.7) : 0.7
                    width: coverItem.itemHeight * (coverItem.activeConfig && coverItem.activeConfig.backAspectRatio !== undefined ? coverItem.activeConfig.backAspectRatio : defaultAspectRatio)
                    height: coverItem.itemHeight

                    property int _bbVer: coverFlowRef ? coverFlowRef.boxbackVersion : 0
                    property string _customBbPath: {
                        var v = _bbVer;  // dependency for reactivity
                        if (!effectivePlatform) return "";
                        return api.memory.get("boxback_path_" + effectivePlatform.toLowerCase()) || "";
                    }
                    property string baseSource: Utils.getGameBox2DBack(modelData, effectivePlatform, _customBbPath)
                    property bool _isAbsolute: baseSource.indexOf("ABSOLUTE:") === 0
                    property string _resolvedBase: _isAbsolute ? baseSource.substring(9) : baseSource
                    source: {
                        if (!baseSource) return "";
                        if (_isAbsolute) return "file://" + _resolvedBase + ".png";
                        return Qt.resolvedUrl("../../" + _resolvedBase + ".png");
                    }

                    fillMode: Image.PreserveAspectFit
                    verticalAlignment: Image.AlignBottom
                    asynchronous: true
                    cache: true

                    property bool hasValidSource: status === Image.Ready && source !== "" && source !== undefined

                    opacity: hasValidSource ? 1.0 : 0.0
                    Behavior on opacity { enabled: coverItem.isNearCenter; NumberAnimation { duration: 150 } }

                    onStatusChanged: {
                        if (status === Image.Error) {
                            // Try .jpg if .png failed
                            var s = source.toString();
                            if (_resolvedBase && s.endsWith(".png")) {
                                if (_isAbsolute)
                                    source = "file://" + _resolvedBase + ".jpg";
                                else
                                    source = Qt.resolvedUrl("../../" + _resolvedBase + ".jpg");
                            } else {
                                source = "";
                            }
                        }
                    }
                }

                Rectangle {
                    id: fallbackBackContent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom

                    property var fallbackConfig: coverItem.activeConfig ? coverItem.activeConfig.fallback : undefined;
                    property real defaultAspectRatio: coverItem.activeConfig ? (coverItem.activeConfig.aspectRatio || 0.7) : 0.7
                    width: coverItem.itemHeight * (fallbackConfig && fallbackConfig.fallbackWidthRatio !== undefined ? fallbackConfig.fallbackWidthRatio : defaultAspectRatio)
                    height: coverItem.itemHeight * (fallbackConfig && fallbackConfig.fallbackHeightRatio !== undefined ? fallbackConfig.fallbackHeightRatio : 1.0)

                    visible: !box2dBackLoader.hasValidSource
                    opacity: visible ? 1.0 : 0.0
                    Behavior on opacity { enabled: coverItem.isNearCenter; NumberAnimation { duration: 150 } }

                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: coverItem.themeFallback1
                        }
                        GradientStop {
                            position: 1.0
                            color: coverItem.themeFallback2
                        }
                    }

                    PlatformLogoWithOutline {
                        anchors.fill: parent
                        platformIdentifier: coverItem.effectivePlatform
                        logoConfig: coverItem.activeLogoConfig
                    }
                }
            }

                Rectangle {
                    id: leftSideBackRectangle
                    x: backVisualContainer.renderedContentLocalX - width
                    y: backVisualContainer.renderedContentLocalY
                    visible: coverItem.enableBackSides3D && backVisualContainer.actualBackContent.visible && (coverItem.flipRotation > 90 && coverItem.flipRotation < 270)
                    opacity: (coverItem.animatedBaseRotationY + coverItem.animatedInteractiveRotationY) < -0.01 ? 1.0 : 0.0
                    width: backVisualContainer.backDynamicDepth
                    height: backVisualContainer.renderedContentHeight
                    z: parent.z - 1

                Behavior on opacity {
                    enabled: coverItem.isNearCenter
                    NumberAnimation {
                        duration: coverItem.isRotatingFast ? 60 : 120
                        easing.type: coverItem.isRotatingFast ? Easing.OutQuint : Easing.OutQuart
                    }
                }

                color: "transparent"
                clip: true

                ColorMaskedSideFallback {
                    id: leftSideBackColorMasked
                    anchors.fill: parent
                    textureSource: "../../" + Utils.getPlatformSide4(coverItem.effectivePlatform)

                    topColor: (coverItem.isCurrentItem || coverItem.isSelectedCover) ? coverItem.dynamicTopColor : Qt.darker(coverItem.dynamicTopColor, 1.2);
                    bottomColor: (coverItem.isCurrentItem || coverItem.isSelectedCover) ? coverItem.dynamicBottomColor : Qt.darker(coverItem.dynamicBottomColor, 1.2);

                    side: "back-left"
                    active: parent.visible && parent.opacity > 0.01

                    opacity: (coverItem.isCurrentItem || coverItem.isSelectedCover) ? 1.0 : 0.6
                }
                }

                Rectangle {
                    id: rightSideBackRectangle
                    x: backVisualContainer.renderedContentLocalX + backVisualContainer.renderedContentWidth
                    y: backVisualContainer.renderedContentLocalY
                    visible: coverItem.enableBackSides3D && backVisualContainer.actualBackContent.visible && (coverItem.flipRotation > 90 && coverItem.flipRotation < 270)
                    opacity: (coverItem.animatedBaseRotationY + coverItem.animatedInteractiveRotationY) > 0.01 ? 1.0 : 0.0
                    width: backVisualContainer.backDynamicDepth
                    height: backVisualContainer.renderedContentHeight
                    z: parent.z - 2

                    Behavior on opacity {
                        enabled: coverItem.isNearCenter
                        NumberAnimation {
                            duration: coverItem.isRotatingFast ? 60 : 120
                            easing.type: coverItem.isRotatingFast ? Easing.OutQuint : Easing.OutQuart
                        }
                    }

                    color: "transparent"
                    clip: true

                    ColorMaskedSideFallback {
                        id: rightSideBackColorMasked
                        anchors.fill: parent
                        textureSource: "../../" + Utils.getPlatformSide3(coverItem.effectivePlatform)

                        topColor: (coverItem.isCurrentItem || coverItem.isSelectedCover) ? coverItem.dynamicTopColor : Qt.darker(coverItem.dynamicTopColor, 1.2);
                        bottomColor: (coverItem.isCurrentItem || coverItem.isSelectedCover) ? coverItem.dynamicBottomColor : Qt.darker(coverItem.dynamicBottomColor, 1.2);

                        side: "back-right"
                        active: parent.visible && parent.opacity > 0.01

                        opacity: (coverItem.isCurrentItem || coverItem.isSelectedCover) ? 1.0 : 0.6
                    }

                    transform: Matrix4x4 {
                        property real normalizedAngle: Math.abs(coverItem.animatedBaseRotationY + coverItem.animatedInteractiveRotationY) / 90.0
                        property real baseShift: height * normalizedAngle * 0.4

                        property real topFactor: 0.25
                        property real bottomFactor: 0.30

                        matrix: {
                            var topShift = baseShift * topFactor / height
                            var bottomShift = baseShift * bottomFactor / height

                            return Qt.matrix4x4(
                                1, 0, 0, 0,
                                -topShift, 1, bottomShift, 0,
                                0, 0, 1, 0,
                                0, 0, 0, 1
                            );
                        }
                    }
                }
        }
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        enabled: (coverFlowRef ? !coverFlowRef.isCoverSelected && !(coverFlowRef.menuManager && coverFlowRef.menuManager.menuOpen) : true)
        onClicked: coverItem.clicked()
    }

}

