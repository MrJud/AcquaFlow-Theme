import QtQuick 2.15
import ".."
import QtGraphicalEffects 1.15
import "../../utils.js" as Utils
import "../config/PlatformConfigs.js" as PlatformConfigs
import "../config/LogoConfigs.js" as LogoConfigs

import ".." as Components

Item {
    id: root

    property var modelData
    property string coverSource
    property real itemAngle
    property bool isCurrentItem
    property bool isNearCenter: false
    property bool isTallCover
    property var activeConfig
    // Theme-aware fallback colors
    property color themeFallback1: "#65333333"
    property color themeFallback2: "#55111111"
    property color dynamicTopColor
    property color dynamicBottomColor
    property real perspectiveStrength
    property bool enable3DEffect
    property bool enableEdgeEffect
    property color edgeColor
    property int edgeWidth
    property var metrics
    property string platform: "default"
    property real animatedYOffset: 0
    property real animatedXRotation: 0
    property bool isSelected: false
    property real selectedRotationAngleY: 0
    // Combined Y angle for selected mode: interactive rotation + pathView rotation
    // Ensures side perspective stays in sync with the total visual rotation
    property real totalSelectedAngleY: selectedRotationAngleY + itemAngle
    property real lastSelectedRotationY: 0
    property real sideAnimationVelocity: 0
    property bool isRotatingQuickly: sideAnimationVelocity > 3
    property bool parentIsInteractingFast: false

    // PERF: Scroll-aware — used to disable expensive GPU operations during scroll
    property bool isScrolling: false

    property bool darkenSideCovers: false
    property real sideCoverDarkenStrength: 0.2

    property bool isTransitioning: false
    property bool isPlatformLoading: false
    property bool isAlphabeticTeleporting: false

    // FIXED: Parent opacity (alignmentContainer) to sync cover and sides in domino mode
    property real parentOpacity: 1.0

    property bool isInSelectedMode: false

    property string currentViewMode: "coverflow"

    property real effectiveCoverOverallOpacity: {
        if (darkenSideCovers && !isCurrentItem && !isSelected) {
            return 1.0 - sideCoverDarkenStrength;
        }
        return 1.0;
    }

    Behavior on effectiveCoverOverallOpacity {
        enabled: root.isNearCenter
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    property string effectivePlatformForSides: {
        if (platform.toLowerCase() === "lastplayed" && modelData && modelData.originalPlatformName) {
            return modelData.originalPlatformName.toLowerCase();
        }
        else if (platform.toLowerCase() === "gc") {
            return "gc";
        }
        else if (modelData && modelData.originalPlatformName) {
            return modelData.originalPlatformName.toLowerCase();
        }
        var platformName = platform.toLowerCase();
        if (modelData) {
            platformName = Utils.detectGameCubePlatform(modelData, platformName);
        }
        return platformName;
    }

    property string currentPlatform: platform.toLowerCase()

    Timer {
        id: sideVelocityTimer
        interval: 16
        repeat: true
        running: root.isSelected
        onTriggered: {
            var currentRotY = root.selectedRotationAngleY
            sideAnimationVelocity = Math.abs(currentRotY - lastSelectedRotationY) / (interval / 1000.0)
            lastSelectedRotationY = currentRotY
        }
    }

    property real effectiveRotationVelocity: 0
    property real lastEffectiveRotationAngle: 0

    Timer {
        id: rotationVelocityCalculator
        interval: 16
        repeat: true
        running: root.isSelected || root.isCurrentItem
        onTriggered: {
            var currentRotationAngle = root.isSelected ? root.selectedRotationAngleY : root.itemAngle;
            effectiveRotationVelocity = Math.abs(currentRotationAngle - lastEffectiveRotationAngle) / (interval / 1000.0);
            lastEffectiveRotationAngle = currentRotationAngle;
        }
        onRunningChanged: if (!running) effectiveRotationVelocity = 0
    }

    property bool isEffectiveRotationQuick: effectiveRotationVelocity > 50

    property bool isFallbackActive: fallbackCover.visible
    property bool effectiveEnable3DEffect: enable3DEffect || isFallbackActive
    property bool effectiveEnableEdgeEffect: enableEdgeEffect || isFallbackActive

    Item {
        id: titleContainer
        y: visualContainer.y - height - 25
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 20
        height: gameTitle.font.pixelSize + 4
        clip: true
        Text {
            id: gameTitle
            text: (root.modelData && root.modelData.title) ? root.modelData.title : ""
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: (paintedWidth <= parent.width) ? parent.horizontalCenter : undefined
            width: paintedWidth
            wrapMode: Text.NoWrap

            font.pixelSize: root.metrics ? root.metrics.fontPixelSizeGameTitle : 16

            font.bold: true
            color: "white"
            style: Text.Outline
            styleColor: "black"
            opacity: root.isCurrentItem ? 1.0 : 0.0
            z: 1000
            Behavior on opacity { enabled: root.isNearCenter; NumberAnimation { duration: 1000; easing.type: Easing.InOutCubic } }
            SequentialAnimation {
                id: scrollAnimation
                loops: Animation.Infinite
                running: root.isCurrentItem && gameTitle.paintedWidth > titleContainer.width
                onRunningChanged: if (!running) gameTitle.x = 0
                PauseAnimation { duration: 1500 }
                PropertyAnimation { target: gameTitle; property: "x"; to: -(gameTitle.paintedWidth - titleContainer.width); duration: Math.max(0, (gameTitle.paintedWidth - titleContainer.width) * 20) }
                PauseAnimation { duration: 2000 }
                PropertyAnimation { target: gameTitle; property: "x"; to: 0; duration: 0 }
            }
        }
    }

    Item {
        id: visualContainer
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        property real calculatedWidth: {
            var fallback = root.activeConfig ? root.activeConfig.fallback : undefined;
            if (fallback && fallback.fallbackWidthRatio !== undefined) {
                var baseHeight = root.metrics ? root.metrics.baseCoverHeight : 336;
                return baseHeight * fallback.fallbackWidthRatio;
            }
            return root.metrics ? root.metrics.maxCoverWidth : 240;
        }

        property real calculatedHeight: {
            var fallback = root.activeConfig ? root.activeConfig.fallback : undefined;
            if (fallback && fallback.fallbackHeightRatio !== undefined) {
                var baseHeight = root.metrics ? root.metrics.baseCoverHeight : 336;
                return baseHeight * fallback.fallbackHeightRatio;
            }
            return root.metrics ? root.metrics.baseCoverHeight : 336;
        }

        // FIX: Fully reactive width/height — never use imperative assignment.
        // The old Connections handler (visualContainer.width = coverImage.paintedWidth)
        // broke the declarative binding. On platform switch, calculatedWidth would
        // update for the new platform config but the broken binding kept the OLD
        // paintedWidth → covers appeared at wrong size until scrolling recycled the
        // delegate and re-created a fresh binding.
        //
        // Now: when the image is ready, use paintedWidth/Height (actual aspect ratio);
        // otherwise fall back to calculatedWidth/Height (platform config estimate).
        // The binding stays intact across platform switches.
        width: (coverImage.status === Image.Ready && coverImage.source !== "" &&
                coverImage.paintedWidth > 0)
               ? coverImage.paintedWidth : calculatedWidth
        height: (coverImage.status === Image.Ready && coverImage.source !== "" &&
                 coverImage.paintedHeight > 0)
                ? coverImage.paintedHeight : calculatedHeight

        property real normalizedAngle: Math.abs(root.itemAngle) / 90.0
        property real normalizedTiltAngle: Math.abs(root.animatedXRotation) / 90.0

        property real selectedNormalizedAngleY: Math.abs(root.selectedRotationAngleY) / 90.0

        property real effectiveNormalizedAngleY: root.isSelected ? Math.abs(root.totalSelectedAngleY) / 90.0 : normalizedAngle
        property real effectiveNormalizedAngleX: normalizedTiltAngle

        property real dynamicDepth: effectiveNormalizedAngleY * (root.activeConfig ? root.activeConfig.boxDepth || 40 : 40) * 1.8 * (root.metrics ? root.metrics.scaleRatio : 1.0)

        property real fallbackDepth: (root.activeConfig ? (root.activeConfig.boxDepth || 40) : 40) * 0.4 * (root.metrics ? root.metrics.scaleRatio : 1.0)

        Image {
            id: coverImage
            anchors.fill: parent
            source: root.coverSource
            fillMode: Image.PreserveAspectFit
            cache: true
            asynchronous: true

            // PERF: Dynamic mipmap — disable during scroll for GPU performance on mobile,
            // re-enable when stationary for maximum visual quality.
            // Mipmap generates cascading textures which is expensive on mobile GPUs.
            mipmap: !root.isScrolling
            smooth: !root.isScrolling

            // FIX: Use stable reference dimensions matching CoverItem.coverLoader and
            // the prefetcher. Previously sourceSize depended on visualContainer.width/height
            // which changes when onStatusChanged fires, causing a sourceSize change →
            // re-decode → opacity flash cycle. Stable dimensions = single cache entry.
            readonly property int _stableRefWidth:  root.metrics ? Math.round(root.metrics.baseCoverHeight * 0.7 * 1.2) : 240
            readonly property int _stableRefHeight: root.metrics ? Math.round(root.metrics.baseCoverHeight * 1.2) : 400
            sourceSize.width: _stableRefWidth
            sourceSize.height: _stableRefHeight

            visible: (source !== "" && source !== undefined && status !== Image.Error)
            opacity: (visible && status === Image.Ready) ? root.effectiveCoverOverallOpacity : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            antialiasing: true
        }

        Rectangle {
            id: fallbackCover
            anchors.fill: parent
            z: 999

            visible: !coverImage.visible
            onVisibleChanged: {
            }
            opacity: visible ? root.effectiveCoverOverallOpacity : 0.0

            gradient: Gradient {
                id: fallbackGradient
                GradientStop {
                    position: 0.0
                    color: root.themeFallback1
                }
                GradientStop {
                    position: 1.0
                    color: root.themeFallback2
                }
            }

            PlatformLogoWithOutline {
                anchors.fill: parent
                platformIdentifier: root.activeConfig ? root.activeConfig.platform : ""
            }
        }

        Components.EdgeAntialiasing {
            id: leftSideAntialiasing
            x: leftSideRectangle.x
            y: leftSideRectangle.y
            width: leftSideRectangle.width
            height: leftSideRectangle.height
            visible: leftSideRectangle.opacity > 0.01 && !root.isSelected
            opacity: leftSideRectangle.opacity
            sourceItem: root.isSelected ? null : leftSideRectangle
            z: leftSideRectangle.z + 1
        }

        Rectangle {
            id: leftSideRectangle
            x: -width
            y: coverImage.y
            visible: true
            opacity: {
                if (root.isTransitioning || root.isPlatformLoading || root.isAlphabeticTeleporting) {
                    return 0.0;
                }
                // Only show sides when cover image is fully decoded (Image.Ready)
                // or fallback gradient is visible. Prevents sides from appearing
                // before the cover has rendered.
                var coverReady = (coverImage.status === Image.Ready && coverImage.visible);
                var totalAngle = root.totalSelectedAngleY;
                var shouldShow = (root.effectiveEnable3DEffect && (coverReady || fallbackCover.visible)) ||
                                (root.isSelected && (totalAngle > 0.01));
                if (!shouldShow) return 0.0;

                var baseSideOpacity = (root.isSelected ? totalAngle > 0.01 : root.itemAngle > 0.01) ? 0.6 : 0.0;

                if (root.isInSelectedMode && !root.isSelected && root.parentOpacity < 1.0) {
                    return baseSideOpacity * root.parentOpacity;
                } else {
                    return baseSideOpacity;
                }
            }
            width: visualContainer.dynamicDepth
            height: visualContainer.height
            z: parent.z - 2

            // FIX: 30ms ≈ 1-2 frames — side appeared before layer FBO was ready → white flash.
            // 120ms gives the GPU time to finish compositing before the side is visible.
            Behavior on opacity { enabled: !root.isSelected; NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

            property real currentShearYFromX: 0
            property real currentShearYFromZ: 0

            color: "transparent"
            clip: false
            antialiasing: true
            smooth: true

            // Clipped wrapper for side texture and logo
            Item {
                anchors.fill: parent
                clip: true

                ColorMaskedSideFallback {
                    id: leftSideColorMasked
                    anchors.fill: parent
                    textureSource: "../../" + Utils.getPlatformSide1(root.effectivePlatformForSides)

                    topColor: (root.isCurrentItem || root.isSelected) ? root.dynamicTopColor : Qt.darker(root.dynamicTopColor, 1.2);
                    bottomColor: (root.isCurrentItem || root.isSelected) ? root.dynamicBottomColor : Qt.darker(root.dynamicBottomColor, 1.2);

                    side: "left"
                    active: root.visible && opacity > 0.01

                    opacity: (root.isCurrentItem || root.isSelected) ? 1.0 : 0.6
                }

                Image {
                    id: leftSideTextureLogo
                source: root.modelData ? Utils.getGameLogo(root.modelData) : ""

                property var logoConfig: LogoConfigs.getPlatformLogoConfig(root.effectivePlatformForSides)

                property var perspectiveData: {
                    if (!logoConfig || !visible) return {};

                    var rotationAngle = root.isSelected ? root.selectedRotationAngleY : root.itemAngle;
                    var sideDepth = visualContainer.dynamicDepth || 40;

                    return LogoConfigs.calculateLogoPerspective(logoConfig, rotationAngle, sideDepth);
                }

                visible: source !== "" && logoConfig.enabled && logoConfig.isLeft

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenterOffset: {
                    var baseOffsetX = (logoConfig.positionX - 0.5) * parent.width;
                    var perspectiveOffsetX = perspectiveData.offsetX || 0;
                    return baseOffsetX + perspectiveOffsetX;
                }
                anchors.verticalCenterOffset: {
                    var baseOffsetY = (logoConfig.positionY - 0.5) * parent.height;
                    var perspectiveOffsetY = perspectiveData.offsetY || 0;
                    return baseOffsetY + perspectiveOffsetY;
                }

                width: {
                    var baseSize = logoConfig.baseSize || 120;
                    var perspectiveScale = perspectiveData.scale || logoConfig.scale;
                    var customScaleX = logoConfig.logoTransforms && logoConfig.logoTransforms.enabled ? logoConfig.logoTransforms.scaleX : 1.0;

                    var deformationScaleX = 1.0;
                    if (logoConfig.perspective && logoConfig.perspective.horizontalDeformation && logoConfig.perspective.horizontalDeformation.enabled) {
                        var rotationAngle = root.isSelected ? root.selectedRotationAngleY : root.itemAngle;
                        var normalizedAngle = Math.abs(rotationAngle) / 90.0;

                        var frontalGrowX = logoConfig.perspective.horizontalDeformation.frontalGrow || 0.0;
                        var tiltedShrinkX = logoConfig.perspective.horizontalDeformation.tiltedShrink || 0.0;

                        deformationScaleX = (1.0 + frontalGrowX) - (frontalGrowX + tiltedShrinkX) * normalizedAngle;
                    }

                    return baseSize * perspectiveScale * deformationScaleX * customScaleX;
                }
                height: {
                    var baseSize = logoConfig.baseSize || 120;
                    var perspectiveScale = perspectiveData.scale || logoConfig.scale;
                    var customScaleY = logoConfig.logoTransforms && logoConfig.logoTransforms.enabled ? logoConfig.logoTransforms.scaleY : 1.0;

                    var deformationScaleY = 1.0;
                    if (logoConfig.perspective && logoConfig.perspective.verticalDeformation && logoConfig.perspective.verticalDeformation.enabled) {
                        var rotationAngle = root.isSelected ? root.selectedRotationAngleY : root.itemAngle;
                        var normalizedAngle = Math.abs(rotationAngle) / 90.0;

                        var frontalGrowY = logoConfig.perspective.verticalDeformation.frontalGrow || 0.0;
                        var tiltedShrinkY = logoConfig.perspective.verticalDeformation.tiltedShrink || 0.0;

                        deformationScaleY = (1.0 + frontalGrowY) - (frontalGrowY + tiltedShrinkY) * normalizedAngle;
                    }

                    return baseSize * perspectiveScale * deformationScaleY * customScaleY;
                }

                rotation: 90 + logoConfig.additionalRotation

                property real logoDeformationCorrectionStrength: 0.7

                transform: [
                    Matrix4x4 {
                        property real shearAngle: leftSideTextureLogo.logoConfig.logoTransforms && leftSideTextureLogo.logoConfig.logoTransforms.enabled ? leftSideTextureLogo.logoConfig.logoTransforms.shearXAngle : 0
                        property real k: Math.tan(shearAngle * Math.PI / 180)
                        property real originY: leftSideTextureLogo.height / 2

                        matrix: Qt.matrix4x4(
                            1, k, 0, -k * originY,
                            0, 1, 0, 0,
                            0, 0, 1, 0,
                            0, 0, 0, 1
                        );
                    },
                    Matrix4x4 {
                        property real shearAngle: leftSideTextureLogo.logoConfig.logoTransforms && leftSideTextureLogo.logoConfig.logoTransforms.enabled ? leftSideTextureLogo.logoConfig.logoTransforms.shearYAngle : 0
                        property real k: Math.tan(shearAngle * Math.PI / 180)
                        property real originX: leftSideTextureLogo.width / 2

                        matrix: Qt.matrix4x4(
                            1, 0, 0, 0,
                            k, 1, 0, -k * originX,
                            0, 0, 1, 0,
                            0, 0, 0, 1
                        );
                    },
                    Translate {
                        x: leftSideTextureLogo.logoConfig.logoTransforms && leftSideTextureLogo.logoConfig.logoTransforms.enabled ? leftSideTextureLogo.logoConfig.logoTransforms.offsetX : 0
                        y: leftSideTextureLogo.logoConfig.logoTransforms && leftSideTextureLogo.logoConfig.logoTransforms.enabled ? leftSideTextureLogo.logoConfig.logoTransforms.offsetY : 0
                    },
                    Matrix4x4 {
                        matrix: {
                            var shearX = -leftSideRectangle.currentShearYFromX * leftSideTextureLogo.logoDeformationCorrectionStrength;
                            var shearZ = -leftSideRectangle.currentShearYFromZ * leftSideTextureLogo.logoDeformationCorrectionStrength;

                            return Qt.matrix4x4(
                                1, 0, 0, 0,
                                shearX, 1, shearZ, 0,
                                0, 0, 1, 0,
                                0, 0, 0, 1
                            );
                        }
                    }
                ]

                fillMode: Image.PreserveAspectFit
                cache: AntialiasingManager.cachedImages
                asynchronous: AntialiasingManager.asynchronousLoading
                smooth: AntialiasingManager.smoothScaling
                antialiasing: true
                mipmap: AntialiasingManager.mipmap

                opacity: (root.isCurrentItem || root.isSelected) ? 1.0 : (perspectiveData.opacity !== undefined ? perspectiveData.opacity : logoConfig.opacity)

                Component.onCompleted: {
                    AntialiasingManager.applyToSideLogo(leftSideTextureLogo);
                }

                z: perspectiveData.zIndex || 100

                layer.enabled: !root.isTransitioning && !root.isPlatformLoading && visible && opacity > 0.01
                layer.format: ShaderEffectSource.RGBA
                layer.sourceRect: Qt.rect(0, 0, width, height)
                layer.textureSize: Qt.size(width, height)
                layer.smooth: true

                Behavior on anchors.horizontalCenterOffset {
                    enabled: root.isNearCenter && !root.isTransitioning
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuart }
                }
                Behavior on anchors.verticalCenterOffset {
                    enabled: root.isNearCenter && !root.isTransitioning
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuart }
                }
                Behavior on opacity {
                    enabled: root.isNearCenter && !root.isTransitioning
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on width {
                    enabled: root.isNearCenter
                    NumberAnimation {
                        duration: (root.parentIsInteractingFast || root.isEffectiveRotationQuick) ? 0 : 180;
                        easing.type: Easing.OutCubic;
                    }
                }
                Behavior on height {
                    enabled: root.isNearCenter
                    NumberAnimation {
                        duration: (root.parentIsInteractingFast || root.isEffectiveRotationQuick) ? 0 : 180;
                        easing.type: Easing.OutCubic;
                    }
                }
                }
            }

            transform: [
                Matrix4x4 {
                    id: leftSideMatrixTransform
                    property real normalizedAngle: visualContainer.effectiveNormalizedAngleY
                    property real baseShift: height * normalizedAngle * 0.4

                    property real topFactor: root.activeConfig && root.activeConfig.reflectionFactors
                        ? root.activeConfig.reflectionFactors.top : 0.32
                    property real bottomFactor: root.activeConfig && root.activeConfig.reflectionFactors
                        ? Math.abs(root.activeConfig.reflectionFactors.bottom) : 0.1

                    property real calculatedTopShift: baseShift * topFactor / height;
                    property real calculatedBottomShift: baseShift * bottomFactor / height;

                    onCalculatedTopShiftChanged: leftSideRectangle.currentShearYFromX = calculatedTopShift;
                    onCalculatedBottomShiftChanged: leftSideRectangle.currentShearYFromZ = 0;

                    matrix: {
                        var topShift = calculatedTopShift;
                        var w = leftSideRectangle.width;

                        return Qt.matrix4x4(
                            1, 0, 0, 0,
                            topShift, 1, 0, -topShift * w,
                            0, 0, 1, 0,
                            0, 0, 0, 1
                        );
                    }
                }
            ]
        }

        Components.EdgeAntialiasing {
            id: rightSideAntialiasing
            x: rightSideRectangle.x
            y: rightSideRectangle.y
            width: rightSideRectangle.width
            height: rightSideRectangle.height
            visible: rightSideRectangle.opacity > 0.01 && !root.isSelected
            opacity: rightSideRectangle.opacity
            sourceItem: root.isSelected ? null : rightSideRectangle
            z: rightSideRectangle.z + 1
        }

        Rectangle {
            id: rightSideRectangle
            x: visualContainer.width
            y: coverImage.y
            visible: true
            opacity: {
                if (root.isTransitioning || root.isPlatformLoading || root.isAlphabeticTeleporting) {
                    return 0.0;
                }
                var coverReady = (coverImage.status === Image.Ready && coverImage.visible);
                var totalAngle = root.totalSelectedAngleY;
                var shouldShow = (root.effectiveEnable3DEffect && (coverReady || fallbackCover.visible)) ||
                                (root.isSelected && (totalAngle < -0.01));
                if (!shouldShow) return 0.0;

                var baseSideOpacity = (root.isSelected ? totalAngle < -0.01 : root.itemAngle < -0.01) ? 0.6 : 0.0;

                if (root.isInSelectedMode && !root.isSelected && root.parentOpacity < 1.0) {
                    return baseSideOpacity * root.parentOpacity;
                } else {
                    return baseSideOpacity;
                }
            }
            width: visualContainer.dynamicDepth
            height: visualContainer.height
            z: parent.z - 2

            // FIX: same as leftSideRectangle — 30ms snap replaced with 120ms.
            Behavior on opacity { enabled: !root.isSelected; NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

            property real currentShearYFromX: 0
            property real currentShearYFromZ: 0

            color: "transparent"
            clip: false
            antialiasing: true
            smooth: true

            // Clipped wrapper for side texture and logo
            Item {
                anchors.fill: parent
                clip: true

                ColorMaskedSideFallback {
                    id: rightSideColorMasked
                    anchors.fill: parent
                    textureSource: "../../" + Utils.getPlatformSide2(root.effectivePlatformForSides)

                    topColor: (root.isCurrentItem || root.isSelected) ? root.dynamicTopColor : Qt.darker(root.dynamicTopColor, 1.2);
                    bottomColor: (root.isCurrentItem || root.isSelected) ? root.dynamicBottomColor : Qt.darker(root.dynamicBottomColor, 1.2);

                    side: "right"
                    active: root.visible && opacity > 0.01

                    opacity: (root.isCurrentItem || root.isSelected) ? 1.0 : 0.6
                }

                Image {
                    id: rightSideTextureLogo
                source: root.modelData ? Utils.getGameLogo(root.modelData) : ""

                property var logoConfig: LogoConfigs.getPlatformLogoConfig(root.effectivePlatformForSides)

                property var perspectiveData: {
                    if (!logoConfig || !visible) return {};

                    var rotationAngle = root.isSelected ? root.selectedRotationAngleY : root.itemAngle;
                    var sideDepth = visualContainer.dynamicDepth || 40;

                    return LogoConfigs.calculateLogoPerspective(logoConfig, rotationAngle, sideDepth);
                }

                visible: source !== "" && logoConfig.enabled && logoConfig.isRight

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenterOffset: {
                    var baseOffsetX = (logoConfig.positionX - 0.5) * parent.width;
                    var perspectiveOffsetX = perspectiveData.offsetX || 0;
                    return baseOffsetX + perspectiveOffsetX;
                }
                anchors.verticalCenterOffset: {
                    var baseOffsetY = (logoConfig.positionY - 0.5) * parent.height;
                    var perspectiveOffsetY = perspectiveData.offsetY || 0;
                    return baseOffsetY + perspectiveOffsetY;
                }

                width: {
                    var baseSize = logoConfig.baseSize || 120;
                    var perspectiveScale = perspectiveData.scale || logoConfig.scale;
                    var customScaleX = logoConfig.logoTransforms && logoConfig.logoTransforms.enabled ? logoConfig.logoTransforms.scaleX : 1.0;

                    var deformationScaleX = 1.0;
                    if (logoConfig.perspective && logoConfig.perspective.horizontalDeformation && logoConfig.perspective.horizontalDeformation.enabled) {
                        var rotationAngle = root.isSelected ? root.selectedRotationAngleY : root.itemAngle;
                        var normalizedAngle = Math.abs(rotationAngle) / 90.0;

                        var frontalGrowX = logoConfig.perspective.horizontalDeformation.frontalGrow || 0.0;
                        var tiltedShrinkX = logoConfig.perspective.horizontalDeformation.tiltedShrink || 0.0;

                        deformationScaleX = (1.0 + frontalGrowX) - (frontalGrowX + tiltedShrinkX) * normalizedAngle;
                    }

                    return baseSize * perspectiveScale * deformationScaleX * customScaleX;
                }
                height: {
                    var baseSize = logoConfig.baseSize || 120;
                    var perspectiveScale = perspectiveData.scale || logoConfig.scale;
                    var customScaleY = logoConfig.logoTransforms && logoConfig.logoTransforms.enabled ? logoConfig.logoTransforms.scaleY : 1.0;

                    var deformationScaleY = 1.0;
                    if (logoConfig.perspective && logoConfig.perspective.verticalDeformation && logoConfig.perspective.verticalDeformation.enabled) {
                        var rotationAngle = root.isSelected ? root.selectedRotationAngleY : root.itemAngle;
                        var normalizedAngle = Math.abs(rotationAngle) / 90.0;

                        var frontalGrowY = logoConfig.perspective.verticalDeformation.frontalGrow || 0.0;
                        var tiltedShrinkY = logoConfig.perspective.verticalDeformation.tiltedShrink || 0.0;

                        deformationScaleY = (1.0 + frontalGrowY) - (frontalGrowY + tiltedShrinkY) * normalizedAngle;
                    }

                    return baseSize * perspectiveScale * deformationScaleY * customScaleY;
                }

                rotation: 90 + logoConfig.additionalRotation

                property real logoDeformationCorrectionStrength: 0.7

                transform: [
                    Matrix4x4 {
                        property real shearAngle: rightSideTextureLogo.logoConfig.logoTransforms && rightSideTextureLogo.logoConfig.logoTransforms.enabled ? rightSideTextureLogo.logoConfig.logoTransforms.shearXAngle : 0
                        property real k: Math.tan(shearAngle * Math.PI / 180)
                        property real originY: rightSideTextureLogo.height / 2

                        matrix: Qt.matrix4x4(
                            1, k, 0, -k * originY,
                            0, 1, 0, 0,
                            0, 0, 1, 0,
                            0, 0, 0, 1
                        );
                    },
                    Matrix4x4 {
                        property real shearAngle: rightSideTextureLogo.logoConfig.logoTransforms && rightSideTextureLogo.logoConfig.logoTransforms.enabled ? rightSideTextureLogo.logoConfig.logoTransforms.shearYAngle : 0
                        property real k: Math.tan(shearAngle * Math.PI / 180)
                        property real originX: rightSideTextureLogo.width / 2

                        matrix: Qt.matrix4x4(
                            1, 0, 0, 0,
                            k, 1, 0, -k * originX,
                            0, 0, 1, 0,
                            0, 0, 0, 1
                        );
                    },
                    Translate {
                        x: rightSideTextureLogo.logoConfig.logoTransforms && rightSideTextureLogo.logoConfig.logoTransforms.enabled ? rightSideTextureLogo.logoConfig.logoTransforms.offsetX : 0
                        y: rightSideTextureLogo.logoConfig.logoTransforms && rightSideTextureLogo.logoConfig.logoTransforms.enabled ? rightSideTextureLogo.logoConfig.logoTransforms.offsetY : 0
                    },
                    Matrix4x4 {
                        matrix: {
                            var shearX = -rightSideRectangle.currentShearYFromX * rightSideTextureLogo.logoDeformationCorrectionStrength;
                            var shearZ = -rightSideRectangle.currentShearYFromZ * rightSideTextureLogo.logoDeformationCorrectionStrength;

                            return Qt.matrix4x4(
                                1, 0, 0, 0,
                                shearX, 1, shearZ, 0,
                                0, 0, 1, 0,
                                0, 0, 0, 1
                            );
                        }
                    }
                ]

                fillMode: Image.PreserveAspectFit
                cache: AntialiasingManager.cachedImages
                asynchronous: AntialiasingManager.asynchronousLoading
                smooth: AntialiasingManager.smoothScaling
                antialiasing: true
                mipmap: AntialiasingManager.mipmap

                opacity: (root.isCurrentItem || root.isSelected) ? 1.0 : (perspectiveData.opacity !== undefined ? perspectiveData.opacity : logoConfig.opacity)

                Component.onCompleted: {
                    AntialiasingManager.applyToSideLogo(rightSideTextureLogo);
                }

                z: perspectiveData.zIndex || 100

                layer.enabled: !root.isTransitioning && !root.isPlatformLoading && visible && opacity > 0.01
                layer.format: ShaderEffectSource.RGBA
                layer.sourceRect: Qt.rect(0, 0, width, height)
                layer.textureSize: Qt.size(width, height)
                layer.smooth: true

                Behavior on anchors.horizontalCenterOffset {
                    enabled: root.isNearCenter && !root.isTransitioning
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuart }
                }
                Behavior on anchors.verticalCenterOffset {
                    enabled: root.isNearCenter && !root.isTransitioning
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuart }
                }
                Behavior on opacity {
                    enabled: root.isNearCenter && !root.isTransitioning
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on width {
                    enabled: root.isNearCenter
                    NumberAnimation {
                        duration: (root.parentIsInteractingFast || root.isEffectiveRotationQuick) ? 0 : 180;
                        easing.type: Easing.OutCubic;
                    }
                }
                Behavior on height {
                    enabled: root.isNearCenter
                    NumberAnimation {
                        duration: (root.parentIsInteractingFast || root.isEffectiveRotationQuick) ? 0 : 180;
                        easing.type: Easing.OutCubic;
                    }
                }
                }
            }

            transform: [
                Matrix4x4 {
                    id: rightSideMatrixTransform
                    property real normalizedAngle: visualContainer.effectiveNormalizedAngleY
                    property real baseShift: height * normalizedAngle * 0.4

                    property real topFactor: root.activeConfig && root.activeConfig.reflectionFactors
                        ? root.activeConfig.reflectionFactors.top : 0.32
                    property real bottomFactor: root.activeConfig && root.activeConfig.reflectionFactors
                        ? Math.abs(root.activeConfig.reflectionFactors.bottom) : 0.1

                    property real calculatedTopShift: baseShift * topFactor / height;
                    property real calculatedBottomShift: baseShift * bottomFactor / height;

                    onCalculatedTopShiftChanged: rightSideRectangle.currentShearYFromX = -calculatedTopShift;
                    onCalculatedBottomShiftChanged: rightSideRectangle.currentShearYFromZ = 0;

                    matrix: {
                        var topShift = calculatedTopShift;

                        return Qt.matrix4x4(
                            1, 0, 0, 0,
                            -topShift, 1, 0, 0,
                            0, 0, 1, 0,
                            0, 0, 0, 1
                        );
                    }
                }
            ]
        }

        // FIX: visible:false removes the item from the scenegraph instantly → 1-frame black flash
        // when itemAngle crosses ±0.1. Use opacity + Behavior instead.
        Rectangle {
            visible: root.effectiveEnableEdgeEffect
            opacity: root.itemAngle > 0.1 ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
            anchors.right: parent.right
            width: root.edgeWidth; height: parent.height; z: parent.z + 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: root.edgeColor }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
        Rectangle {
            visible: root.effectiveEnableEdgeEffect
            opacity: root.itemAngle < -0.1 ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
            anchors.left: parent.left
            width: root.edgeWidth; height: parent.height; z: parent.z + 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: root.edgeColor }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Components.EdgeAntialiasing {
            id: backLeftSideAntialiasing
            x: backLeftSideRectangle.x
            y: backLeftSideRectangle.y
            width: backLeftSideRectangle.width
            height: backLeftSideRectangle.height
            visible: (root.effectiveEnable3DEffect && coverImage.visible && Math.abs(root.itemAngle) > 90) ||
                     (root.isSelected && (Math.abs(root.selectedRotationAngleY) > 90))
            opacity: backLeftSideRectangle.opacity
            sourceItem: backLeftSideRectangle
            z: backLeftSideRectangle.z + 1
        }

        Rectangle {
            id: backLeftSideRectangle
            x: -width
            y: coverImage.y
            visible: root.effectiveEnable3DEffect && (coverImage.visible || fallbackCover.visible) &&
                     (Math.abs(root.itemAngle) > 90 || (root.isSelected && Math.abs(root.selectedRotationAngleY) > 90))
            opacity: {
                if (root.isTransitioning || root.isPlatformLoading) {
                    return 0.0;
                }
                var baseBackSideOpacity = visible ? 1.0 : 0.0;

                if (root.isInSelectedMode && !root.isSelected && root.parentOpacity < 1.0) {
                    return baseBackSideOpacity * root.parentOpacity;
                } else {
                    return baseBackSideOpacity;
                }
            }
            width: opacity > 0 ? visualContainer.dynamicDepth : 0
            height: visualContainer.height
            z: parent.z - 3

            property real currentShearYFromX: 0
            property real currentShearYFromZ: 0

            Behavior on opacity {
                enabled: root.isNearCenter && !root.parentIsInteractingFast && !root.isEffectiveRotationQuick
                NumberAnimation {
                    duration: root.isRotatingQuickly ? 60 : 120
                    easing.type: root.isRotatingQuickly ? Easing.OutQuint : Easing.OutQuart
                }
            }

            Behavior on width {
                enabled: root.isNearCenter && !root.parentIsInteractingFast && !root.isEffectiveRotationQuick
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }

            color: "transparent"
            clip: true

            ColorMaskedSideFallback {
                id: backLeftSideColorMasked
                anchors.fill: parent
                textureSource: "../../" + Utils.getPlatformSide4(root.effectivePlatformForSides)

                topColor: (root.isCurrentItem || root.isSelected) ? root.dynamicTopColor : Qt.darker(root.dynamicTopColor, 1.2);
                bottomColor: (root.isCurrentItem || root.isSelected) ? root.dynamicBottomColor : Qt.darker(root.dynamicBottomColor, 1.2);

                side: "back-left"
                active: root.visible && opacity > 0.01

                opacity: (root.isCurrentItem || root.isSelected) ? 1.0 : 0.6
            }

            transform: [
                Matrix4x4 {
                    id: backLeftSideMatrixTransform
                    property real normalizedAngle: root.isSelected ?
                        (Math.abs(root.totalSelectedAngleY) / 90.0) :
                        (Math.abs(root.itemAngle) / 90.0)
                    property real baseShift: height * normalizedAngle * 0.4

                    property real topFactor: 0.25;
                    property real bottomFactor: 0.30;

                    property real calculatedTopShift: baseShift * topFactor / height;
                    property real calculatedBottomShift: baseShift * bottomFactor / height;

                    onCalculatedTopShiftChanged: backLeftSideRectangle.currentShearYFromX = calculatedTopShift;
                    onCalculatedBottomShiftChanged: backLeftSideRectangle.currentShearYFromZ = 0;

                    matrix: {
                        var topShift = calculatedTopShift;
                        var w = backLeftSideRectangle.width;

                        return Qt.matrix4x4(
                            1, 0, 0, 0,
                            topShift, 1, 0, -topShift * w,
                            0, 0, 1, 0,
                            0, 0, 0, 1
                        );
                    }
                }
            ]
        }

        Components.EdgeAntialiasing {
            id: backRightSideAntialiasing
            x: backRightSideRectangle.x
            y: backRightSideRectangle.y
            width: backRightSideRectangle.width
            height: backRightSideRectangle.height
            visible: (root.effectiveEnable3DEffect && coverImage.visible && Math.abs(root.itemAngle) > 90) ||
                     (root.isSelected && (Math.abs(root.selectedRotationAngleY) > 90))
            opacity: backRightSideRectangle.opacity
            sourceItem: backRightSideRectangle
            z: backRightSideRectangle.z + 1
        }

        Rectangle {
            id: backRightSideRectangle
            x: visualContainer.width
            y: coverImage.y
            visible: root.effectiveEnable3DEffect && (coverImage.visible || fallbackCover.visible) &&
                     (Math.abs(root.itemAngle) > 90 || (root.isSelected && Math.abs(root.selectedRotationAngleY) > 90))
            opacity: {
                if (root.isTransitioning || root.isPlatformLoading) {
                    return 0.0;
                }
                var baseBackSideOpacity = visible ? 1.0 : 0.0;

                if (root.isInSelectedMode && !root.isSelected && root.parentOpacity < 1.0) {
                    return baseBackSideOpacity * root.parentOpacity;
                } else {
                    return baseBackSideOpacity;
                }
            }
            width: opacity > 0 ? visualContainer.dynamicDepth : 0
            height: visualContainer.height
            z: parent.z - 3

            property real currentShearYFromX: 0
            property real currentShearYFromZ: 0

            Behavior on opacity {
                enabled: root.isNearCenter && !root.parentIsInteractingFast && !root.isEffectiveRotationQuick
                NumberAnimation {
                    duration: root.isRotatingQuickly ? 60 : 120
                    easing.type: root.isRotatingQuickly ? Easing.OutQuint : Easing.OutQuart
                }
            }

            Behavior on width {
                enabled: root.isNearCenter && !root.parentIsInteractingFast && !root.isEffectiveRotationQuick
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }

            color: "transparent"
            clip: true

            ColorMaskedSideFallback {
                id: backRightSideColorMasked
                anchors.fill: parent
                textureSource: "../../" + Utils.getPlatformSide3(root.effectivePlatformForSides)

                topColor: (root.isCurrentItem || root.isSelected) ? root.dynamicTopColor : Qt.darker(root.dynamicTopColor, 1.2);
                bottomColor: (root.isCurrentItem || root.isSelected) ? root.dynamicBottomColor : Qt.darker(root.dynamicBottomColor, 1.2);

                side: "back-right"
                active: root.visible && opacity > 0.01

                opacity: (root.isCurrentItem || root.isSelected) ? 1.0 : 0.6
            }

            transform: [
                Matrix4x4 {
                    id: backRightSideMatrixTransform
                    property real normalizedAngle: root.isSelected ?
                        (Math.abs(root.totalSelectedAngleY) / 90.0) :
                        (Math.abs(root.itemAngle) / 90.0)
                    property real baseShift: height * normalizedAngle * 0.4

                    property real topFactor: 0.25;
                    property real bottomFactor: 0.30;

                    property real calculatedTopShift: baseShift * topFactor / height;
                    property real calculatedBottomShift: baseShift * bottomFactor / height;

                    onCalculatedTopShiftChanged: backRightSideRectangle.currentShearYFromX = -calculatedTopShift;
                    onCalculatedBottomShiftChanged: backRightSideRectangle.currentShearYFromZ = 0;

                    matrix: {
                        var topShift = calculatedTopShift;

                        return Qt.matrix4x4(
                            1, 0, 0, 0,
                            -topShift, 1, 0, 0,
                            0, 0, 1, 0,
                            0, 0, 0, 1
                        );
                    }
                }
            ]
        }
    }

    DropShadow {
        anchors.fill: visualContainer; source: visualContainer
        z: visualContainer.z - 2
        horizontalOffset: 0; verticalOffset: 0
        radius: 0; samples: 1; color: "transparent"
        cached: true
        visible: false
    }

    Rectangle {
        id: reflectionContainer
        y: (visualContainer.height + 0)
        width: visualContainer.width; height: visualContainer.height
        anchors.horizontalCenter: visualContainer.horizontalCenter
        z: -3; color: "transparent"
        transform: [
            Scale { origin { x: width / 2; y: height / 2 } yScale: -1.0 },
            Translate { y: -root.animatedYOffset * 2 },
            Rotation {
                origin.x: width / 2; origin.y: height / 2
                axis { x: 1; y: 0; z: 0 }
                angle: -root.animatedXRotation
            }
        ]
        opacity: {
            if (root.isTransitioning || root.isPlatformLoading || root.isAlphabeticTeleporting) {
                return 0.0;
            }
            // Hide reflections in grid4 mode
            if (root.currentViewMode === "grid4") {
                return 0.0;
            }
            // Only show reflection when cover is fully rendered
            if (coverImage.status !== Image.Ready && !fallbackCover.visible) {
                return 0.0;
            }
            return root.isSelected ? 0.0 : 1.0;
        }
        Behavior on opacity { enabled: root.isNearCenter; NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

        GaussianBlur {
            id: blurReflectionSourceImage
            anchors.fill: parent
            source: ShaderEffectSource {
                anchors.fill: parent
                sourceItem: coverImage
                live: !root.parentIsInteractingFast
            }
            radius: root.parentIsInteractingFast ? 0 : 6
            samples: root.parentIsInteractingFast ? 1 : 16
            visible: coverImage.status === Image.Ready && coverImage.visible
            z: parent.z + 3
        }

        GaussianBlur {
            id: blurFallbackReflectionSource
            anchors.fill: parent
            source: ShaderEffectSource {
                anchors.fill: parent
                sourceItem: fallbackCover
                live: !root.parentIsInteractingFast
            }
            radius: root.parentIsInteractingFast ? 0 : 6
            samples: root.parentIsInteractingFast ? 1 : 16
            visible: fallbackCover.visible
            z: parent.z + 2
        }

        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(0, parent.height)
            z: parent.z + 4
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#A0000000" }
                GradientStop { position: 0.7; color: "#50000000" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Rectangle {
            id: reflectionOverlayDarkener
            anchors.fill: parent
            z: parent.z + 5
            visible: true

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#80000000" }
                GradientStop { position: 0.5; color: "#45000000" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

            Item {
        id: sideReflectionsContainer
        y: reflectionContainer.y
        width: reflectionContainer.width
        height: visualContainer.height * 2.0
        anchors.horizontalCenter: reflectionContainer.horizontalCenter
        z: reflectionContainer.z
        clip: false
        transform: [
            Scale { origin { x: width / 2; y: height / 2 } yScale: -1.0 },
            Translate { y: -root.animatedYOffset * 2 },
            Rotation {
                origin.x: width / 2; origin.y: height / 2
                axis { x: 1; y: 0; z: 0 }
                angle: -root.animatedXRotation
            }
        ]
        opacity: {
            if (root.isTransitioning || root.isPlatformLoading || root.isAlphabeticTeleporting) {
                return 0.0;
            }
            if (root.currentViewMode === "grid4") {
                return 0.0;
            }
            if (coverImage.status !== Image.Ready && !fallbackCover.visible) {
                return 0.0;
            }
            return root.isSelected ? 0.0 : 1.0;
        }
        Behavior on opacity { enabled: root.isNearCenter; NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

        // Left side reflection — Canvas trapezoid with gradient color
        // Color is derived from ColorSampler via dynamicTopColor/dynamicBottomColor
        // which already cascade: sampled color → config fallback → theme fallback
        CoverSide {
            id: leftSideReflection

            property real perspMargin: {
                var f = root.activeConfig && root.activeConfig.reflectionFactors
                    ? root.activeConfig.reflectionFactors : { top: 0.32, bottom: -0.1 };
                return visualContainer.height * Math.max(Math.abs(f.top), Math.abs(f.bottom)) * 0.45;
            }

            x: -width
            y: -perspMargin
            // FIX: width snapping from 0 → dynamicDepth triggered an immediate Canvas.requestPaint
            // mid-scroll → visible distortion. Keep width constant; use opacity to show/hide.
            width: visualContainer.dynamicDepth
            height: visualContainer.height + perspMargin * 2
            side: "left"
            opacity: ((root.itemAngle > 0.1) || (root.isSelected && root.selectedRotationAngleY > 0.05)) ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
            coverPaintedHeight: visualContainer.height
            coverPaintedY: perspMargin
            perspectiveFactors: root.activeConfig && root.activeConfig.reflectionFactors
                ? root.activeConfig.reflectionFactors : { top: 0.32, bottom: -0.1 }
            normalizedAngle: visualContainer.effectiveNormalizedAngleY
            isInFastMode: root.parentIsInteractingFast || root.isScrolling
            reflectionFade: true

            // Reflection colors: same current/selected logic as main sides,
            // then darkened for the reflection effect
            topColor: {
                var base = (root.isCurrentItem || root.isSelected)
                    ? root.dynamicTopColor
                    : Qt.darker(root.dynamicTopColor, 1.2);
                return Qt.darker(base, 1.5);
            }
            bottomColor: {
                var base = (root.isCurrentItem || root.isSelected)
                    ? root.dynamicBottomColor
                    : Qt.darker(root.dynamicBottomColor, 1.2);
                return Qt.darker(base, 1.5);
            }

            // FIX: angle condition moved to opacity Behavior above
            visible: root.enable3DEffect && (coverImage.status === Image.Ready || fallbackCover.visible)
        }

        // Right side reflection — Canvas trapezoid with gradient color
        // Color is derived from ColorSampler via dynamicTopColor/dynamicBottomColor
        // which already cascade: sampled color → config fallback → theme fallback
        CoverSide {
            id: rightSideReflection

            property real perspMargin: {
                var f = root.activeConfig && root.activeConfig.reflectionFactors
                    ? root.activeConfig.reflectionFactors : { top: 0.32, bottom: -0.1 };
                return visualContainer.height * Math.max(Math.abs(f.top), Math.abs(f.bottom)) * 0.45;
            }

            x: visualContainer.width
            y: -perspMargin
            // FIX: same as leftSideReflection — always-on width, opacity Behavior to avoid snap.
            width: visualContainer.dynamicDepth
            height: visualContainer.height + perspMargin * 2
            side: "right"
            opacity: ((root.itemAngle < -0.1) || (root.isSelected && root.selectedRotationAngleY < -0.05)) ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
            coverPaintedHeight: visualContainer.height
            coverPaintedY: perspMargin
            perspectiveFactors: root.activeConfig && root.activeConfig.reflectionFactors
                ? root.activeConfig.reflectionFactors : { top: 0.32, bottom: -0.1 }
            normalizedAngle: visualContainer.effectiveNormalizedAngleY
            isInFastMode: root.parentIsInteractingFast || root.isScrolling
            reflectionFade: true

            // Reflection colors: same current/selected logic as main sides,
            // then darkened for the reflection effect
            topColor: {
                var base = (root.isCurrentItem || root.isSelected)
                    ? root.dynamicTopColor
                    : Qt.darker(root.dynamicTopColor, 1.2);
                return Qt.darker(base, 1.5);
            }
            bottomColor: {
                var base = (root.isCurrentItem || root.isSelected)
                    ? root.dynamicBottomColor
                    : Qt.darker(root.dynamicBottomColor, 1.2);
                return Qt.darker(base, 1.5);
            }

            // FIX: angle condition moved to opacity Behavior above
            visible: root.enable3DEffect && (coverImage.status === Image.Ready || fallbackCover.visible)
        }

    }
}
