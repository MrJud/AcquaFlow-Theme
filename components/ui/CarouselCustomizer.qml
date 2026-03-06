import QtQuick 2.15
import QtGraphicalEffects 1.15
import ".."
import "../config/PlatformConfigs.js" as PlatformConfigs
import "../config/Translations.js" as T

Item {
    id: root
    anchors.fill: parent

    property string lang: "it"
    property QtObject screenMetrics: null
    property alias isCustomizerVisible: customPanel.visible
    property real customCoverScale: 1.0
    property real customCoverYOffset: 0.0
    property real customPathSpread: 1.0
    property real customFrontCoverScale: 1.0
    property real customCenterCoverYOffset: 0.0
    property int gameCount: 0
    property real customCenterSpacing: 0.142
    property bool isCustomizing: false
    property bool isCoverSelected: false
    property bool focused: false  // Focus property for navigation
    property string fillDirection: "bottom"  // "bottom", "left", "right"

    onFocusedChanged: {
        custWaterCanvas._dir = fillDirection === "right" ? 1 : (fillDirection === "left" ? -1 : 0);
        custWaterCanvas._target = focused ? 1.0 : 0.0;
        if (!focused) custWaterCanvas._drops = [];
    }

    property bool isPanelNavigationActive: false
    property int currentSliderIndex: 0
    readonly property int sliderCount: 8  // 0-4 visible sliders, 5=hidden, 7=Reset, 8=Apply
    property real sliderAdjustmentStep: 0.05  // Fine adjustment step with arrows

    property bool frontCoverScaleDirty: false
    property real lastFrontCoverScale: 1.0

    property string currentPlatform: ""
    property string viewModeName: "Coverflow"  // Displayed view mode name
    property string viewModeKey: "main"

    property color themeColor1: {
        switch(viewModeKey) {
            case "carousel1": return "#8E2DE2"  // Purple
            case "carousel2": return "#2193b0"  // Blue
            case "carousel3": return "#11998e"  // Green
            case "carousel4": return "#f12711"  // Orange/Red
            default: return "#8E2DE2"
        }
    }

    property color themeColor2: {
        switch(viewModeKey) {
            case "carousel1": return "#4A00E0"  // Dark Purple
            case "carousel2": return "#6dd5ed"  // Light Blue
            case "carousel3": return "#38ef7d"  // Light Green
            case "carousel4": return "#f5af19"  // Yellow/Orange
            default: return "#4A00E0"
        }
    }

    property real originalCoverScale: 1.0
    property real originalCoverYOffset: 0.0
    property real originalPathSpread: 1.0
    property real originalFrontCoverScale: 1.0
    property real originalCenterCoverYOffset: 0.0
    property real originalCenterSpacing: 0.142

    signal customValuesChanged(real scale, real yOffset, real spread, real frontScale, real centerYOffset, real centerSpacing)
    signal frontCoverScaleChanged(real frontScale)
    signal customizationToggled(bool enabled)
    signal resetToDefaults()
    signal sliderDraggingChanged(bool dragging)
    signal panelNavigationActiveChanged(bool active)

    onGameCountChanged: {
        if (currentPlatform && !isPanelNavigationActive) {
            var mode = viewModeKey || "carousel1"
            var defaults = PlatformConfigs.getOriginalDefaults(currentPlatform, mode, gameCount)
            var newSpread = defaults.spread
            if (Math.abs(newSpread - originalPathSpread) > 0.001) {
                var wasAtDefault = Math.abs(customPathSpread - originalPathSpread) < 0.001
                console.log("[CarouselCustomizer] gameCount changed to", gameCount,
                    "- originalSpread", originalPathSpread, "→", newSpread,
                    "wasAtDefault:", wasAtDefault)
                originalPathSpread = newSpread
                if (wasAtDefault) {
                    customPathSpread = newSpread
                    customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                }
            }
        }
    }

    function initializeFromConfig(config) {
        if (!config) return

        loadSettings()
    }

    function setPlatform(platformName) {
        // If panel is open for navigation, do NOT reload (preserves slider changes)
        if (isPanelNavigationActive) {
            console.log("[CarouselCustomizer] Panel is open - skipping setPlatform to preserve edits")
            return
        }

        if (currentPlatform && currentPlatform !== platformName) {
            saveDebounceTimer.stop()
            console.log("[CarouselCustomizer] Saving settings for previous platform:", currentPlatform)
            saveSettings()
        }

        currentPlatform = platformName || "default"

        var mode = viewModeKey || "carousel1"
        console.log("[CarouselCustomizer] setPlatform:", currentPlatform, "mode:", mode)

        var defaults = PlatformConfigs.getOriginalDefaults(currentPlatform, mode, gameCount)
        originalCoverScale = defaults.scale
        originalFrontCoverScale = defaults.frontScale
        originalCoverYOffset = defaults.yOffset
        originalCenterCoverYOffset = defaults.centerYOffset
        originalPathSpread = defaults.spread
        originalCenterSpacing = defaults.centerSpacing

        loadAndApplySettings()
    }

    function loadAndApplySettings() {
        if (!currentPlatform) return

        try {
            var mode = viewModeKey || "carousel1"
            var config = null

            if (typeof api !== "undefined" && api.memory) {
                var key = "acquaflow_cv2_" + mode + "_" + currentPlatform
                var savedData = api.memory.get(key)
                if (savedData) {
                    try {
                        var parsed = JSON.parse(savedData)
                        config = {
                            scale: parsed.scale !== undefined ? parsed.scale : 1.0,
                            frontScale: parsed.frontScale !== undefined ? parsed.frontScale : 1.0,
                            yOffset: parsed.yOffset !== undefined ? parsed.yOffset : 0.0,
                            centerYOffset: parsed.centerYOffset !== undefined ? parsed.centerYOffset : 0.0,
                            spread: parsed.spread !== undefined ? parsed.spread : 1.0,
                            centerSpacing: parsed.centerSpacing !== undefined ? parsed.centerSpacing : 0.142
                        }
                        console.log("[CarouselCustomizer] ✅ Loaded from api.memory:", currentPlatform, mode,
                                    "- Values: scale=" + config.scale, "yOff=" + config.yOffset, "spread=" + config.spread,
                                    "fcs=" + config.frontScale, "cyOff=" + config.centerYOffset)
                    } catch (parseError) {
                        config = null
                    }
                }
            }

            if (!config) {
                config = PlatformConfigs.getOriginalDefaults(currentPlatform, mode, gameCount)
                console.log("[CarouselCustomizer] ✅ Loaded from PlatformConfigs defaults:", currentPlatform, mode,
                            "- Values: scale=" + config.scale, "yOff=" + config.yOffset, "spread=" + config.spread,
                            "fcs=" + config.frontScale, "cyOff=" + config.centerYOffset)
            }

            // Apply loaded values
            customCoverScale = config.scale
            customFrontCoverScale = config.frontScale
            customCoverYOffset = config.yOffset
            customCenterCoverYOffset = config.centerYOffset
            customPathSpread = config.spread
            customCenterSpacing = config.centerSpacing

            customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)

        } catch (e) {
            console.log("[CarouselCustomizer] Error loading settings:", e)
            customCoverScale = 1.0
            customCoverYOffset = 0.0
            customPathSpread = 1.0
            customFrontCoverScale = 1.0
            customCenterCoverYOffset = 0.0
            customCenterSpacing = 0.142
        }
    }

    function getCurrentScale() {
        return customCoverScale
    }

    function getCurrentYOffset() {
        return customCoverYOffset
    }

    function getCurrentSpread() {
        return customPathSpread
    }

    function getCurrentFrontCoverScale() {
        return customFrontCoverScale
    }

    function notifyFrontCoverScaleChange() {
        if (Math.abs(customFrontCoverScale - lastFrontCoverScale) > 0.001) {
            lastFrontCoverScale = customFrontCoverScale
            frontCoverScaleDirty = !frontCoverScaleDirty
            frontCoverScaleChanged(customFrontCoverScale)
            Qt.callLater(function() {
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
            })
        }
    }

    function _isAtOriginalDefaults() {
        var eps = 0.0005
        return Math.abs(customCoverScale - originalCoverScale) < eps &&
               Math.abs(customFrontCoverScale - originalFrontCoverScale) < eps &&
               Math.abs(customCoverYOffset - originalCoverYOffset) < eps &&
               Math.abs(customPathSpread - originalPathSpread) < eps &&
               Math.abs(customCenterCoverYOffset - originalCenterCoverYOffset) < eps &&
               Math.abs(customCenterSpacing - originalCenterSpacing) < eps
    }

    function saveSettings() {
        if (!currentPlatform) {
            console.log("[CarouselCustomizer] ❌ SAVE BLOCKED - currentPlatform is empty!")
            return
        }

        try {
            var mode = viewModeKey || "carousel1"
            var key = "acquaflow_cv2_" + mode + "_" + currentPlatform
            var atDefaults = _isAtOriginalDefaults()

            if (atDefaults) {
                // Values equal to defaults: clear persistent key and restore runtime
                // Next launch will use fresh defaults from file
                PlatformConfigs.restoreRuntimeDefaults(currentPlatform, mode, gameCount)

                if (typeof api !== "undefined" && api.memory) {
                    api.memory.unset(key)
                    console.log("[CarouselCustomizer] 🗑️ Values at defaults - cleared api.memory key:", key)
                }
            } else {
                console.log("[CarouselCustomizer] 💾 SAVING SETTINGS:")
                console.log("  Platform:", currentPlatform, "Mode:", mode)
                console.log("  Values: scale=" + customCoverScale, "frontScale=" + customFrontCoverScale,
                            "yOffset=" + customCoverYOffset, "spread=" + customPathSpread,
                            "centerYOffset=" + customCenterCoverYOffset)

                var platformConfig = PlatformConfigs.platformBoxConfigs[currentPlatform]
                if (platformConfig) {
                    if (platformConfig.carouselScales) platformConfig.carouselScales[mode] = customCoverScale
                    if (platformConfig.carouselFrontCoverScales) platformConfig.carouselFrontCoverScales[mode] = customFrontCoverScale
                    if (platformConfig.carouselYOffsets) platformConfig.carouselYOffsets[mode] = customCoverYOffset
                    if (platformConfig.carouselFrontYOffsets) platformConfig.carouselFrontYOffsets[mode] = customCenterCoverYOffset
                    if (platformConfig.carouselPathSpreads) platformConfig.carouselPathSpreads[mode] = customPathSpread
                }

                var persistentData = {
                    scale: customCoverScale,
                    frontScale: customFrontCoverScale,
                    yOffset: customCoverYOffset,
                    spread: customPathSpread,
                    centerYOffset: customCenterCoverYOffset,
                    centerSpacing: customCenterSpacing,
                    timestamp: Date.now()
                }

                if (typeof api !== "undefined" && api.memory) {
                    api.memory.set(key, JSON.stringify(persistentData))
                    console.log("[CarouselCustomizer] 💾 ✅ SAVED TO PEGASUS API:", key)
                } else {
                    console.log("[CarouselCustomizer] ❌ FAILED - Pegasus API not available!")
                }
            }

        } catch (e) {
            console.log("[CarouselCustomizer] ❌ ERROR saving settings:", e)
        }
    }

    function saveAllPlatformSettings() {
        // All other platforms already saved correctly
        try {
            saveSettings()
        } catch (e) {
        }
    }

    function loadAllPlatformSettings() {
        try {
            if (typeof api === "undefined" || !api.memory) return

            console.log("[CarouselCustomizer] loadAllPlatformSettings - START")

            var modes = ["carousel1", "carousel2", "carousel3", "carousel4"]

            for (var platform in PlatformConfigs.platformBoxConfigs) {
                var config = PlatformConfigs.platformBoxConfigs[platform]
                if (config) {
                    for (var m = 0; m < modes.length; m++) {
                        var mode = modes[m]
                        var key = "acquaflow_cv2_" + mode + "_" + platform
                        var persistentData = api.memory.get(key)

                        if (persistentData) {
                            try {
                                var settings = JSON.parse(persistentData)

                                if (config.carouselScales) config.carouselScales[mode] = settings.scale !== undefined ? settings.scale : config.carouselScales[mode]
                                if (config.carouselFrontCoverScales) config.carouselFrontCoverScales[mode] = settings.frontScale !== undefined ? settings.frontScale : config.carouselFrontCoverScales[mode]
                                if (config.carouselYOffsets) config.carouselYOffsets[mode] = settings.yOffset !== undefined ? settings.yOffset : config.carouselYOffsets[mode]
                                if (config.carouselFrontYOffsets) config.carouselFrontYOffsets[mode] = settings.centerYOffset !== undefined ? settings.centerYOffset : config.carouselFrontYOffsets[mode]
                                if (config.carouselPathSpreads) config.carouselPathSpreads[mode] = settings.spread !== undefined ? settings.spread : config.carouselPathSpreads[mode]

                            } catch (parseError) {
                            }
                        }
                    }
                }
            }

            console.log("[CarouselCustomizer] loadAllPlatformSettings - END")

        } catch (e) {
        }
    }

    function loadSettings() {
        if (!currentPlatform) return

        try {
            var mode = viewModeKey || "carousel1"
            var loadedFromPersistent = false

            if (typeof api !== "undefined" && api.memory) {
                var key = "acquaflow_cv2_" + mode + "_" + currentPlatform
                var persistentData = api.memory.get(key)

                if (persistentData) {
                    try {
                        var settings = JSON.parse(persistentData)
                        customCoverScale = settings.scale !== undefined ? settings.scale : 1.0
                        customFrontCoverScale = settings.frontScale !== undefined ? settings.frontScale : 1.0
                        customCoverYOffset = settings.yOffset !== undefined ? settings.yOffset : 0.0
                        customCenterCoverYOffset = settings.centerYOffset !== undefined ? settings.centerYOffset : 0.0
                        customPathSpread = settings.spread !== undefined ? settings.spread : 1.0
                        customCenterSpacing = settings.centerSpacing !== undefined ? settings.centerSpacing : 0.142
                        loadedFromPersistent = true

                        var platformConfig = PlatformConfigs.platformBoxConfigs[currentPlatform]
                        if (platformConfig) {
                            if (platformConfig.carouselScales) platformConfig.carouselScales[mode] = customCoverScale
                            if (platformConfig.carouselFrontCoverScales) platformConfig.carouselFrontCoverScales[mode] = customFrontCoverScale
                            if (platformConfig.carouselYOffsets) platformConfig.carouselYOffsets[mode] = customCoverYOffset
                            if (platformConfig.carouselFrontYOffsets) platformConfig.carouselFrontYOffsets[mode] = customCenterCoverYOffset
                            if (platformConfig.carouselPathSpreads) platformConfig.carouselPathSpreads[mode] = customPathSpread
                        }

                    } catch (parseError) {
                    }
                }
            }

            if (!loadedFromPersistent) {
                var platformConfig = PlatformConfigs.platformBoxConfigs[currentPlatform]
                if (platformConfig) {
                    customCoverScale = (platformConfig.carouselScales && platformConfig.carouselScales[mode] !== undefined) ? platformConfig.carouselScales[mode] : 1.0
                    customFrontCoverScale = (platformConfig.carouselFrontCoverScales && platformConfig.carouselFrontCoverScales[mode] !== undefined) ? platformConfig.carouselFrontCoverScales[mode] : 1.0
                    customCoverYOffset = (platformConfig.carouselYOffsets && platformConfig.carouselYOffsets[mode] !== undefined) ? platformConfig.carouselYOffsets[mode] : 0.0
                    customCenterCoverYOffset = (platformConfig.carouselFrontYOffsets && platformConfig.carouselFrontYOffsets[mode] !== undefined) ? platformConfig.carouselFrontYOffsets[mode] : 0.0
                    customPathSpread = (platformConfig.carouselPathSpreads && platformConfig.carouselPathSpreads[mode] !== undefined) ? platformConfig.carouselPathSpreads[mode] : 1.0
                    customCenterSpacing = 0.142
                }
            }

            if (scaleSlider) scaleSlider.setValue(customCoverScale)
            if (frontCoverScaleSlider) frontCoverScaleSlider.setValue(customFrontCoverScale)
            if (yOffsetSlider) yOffsetSlider.setValue(customCoverYOffset)
            if (spreadSlider) spreadSlider.setValue(customPathSpread)
            if (centerCoverYOffsetSlider) centerCoverYOffsetSlider.setValue(customCenterCoverYOffset)
            if (centerSpacingSlider) centerSpacingSlider.setValue(customCenterSpacing)

            customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)

        } catch (e) {
        }
    }

    function refreshUI() {
        if (scaleSlider) scaleSlider.setValue(customCoverScale)
        if (frontCoverScaleSlider) frontCoverScaleSlider.setValue(customFrontCoverScale)
        if (yOffsetSlider) yOffsetSlider.setValue(customCoverYOffset)
        if (spreadSlider) spreadSlider.setValue(customPathSpread)
        if (centerCoverYOffsetSlider) centerCoverYOffsetSlider.setValue(customCenterCoverYOffset)
        if (centerSpacingSlider) centerSpacingSlider.setValue(customCenterSpacing)
    }

    function forceReloadForViewMode() {
        console.log("[CarouselCustomizer] forceReloadForViewMode - reloading for new viewModeKey:", viewModeKey)
        var mode = viewModeKey || "carousel1"
        var defaults = PlatformConfigs.getOriginalDefaults(currentPlatform, mode, gameCount)
        originalCoverScale = defaults.scale
        originalFrontCoverScale = defaults.frontScale
        originalCoverYOffset = defaults.yOffset
        originalCenterCoverYOffset = defaults.centerYOffset
        originalPathSpread = defaults.spread
        originalCenterSpacing = defaults.centerSpacing
        loadAndApplySettings()
        refreshUI()
    }

    function resetValues() {
        saveDebounceTimer.stop()
        var mode = viewModeKey || "carousel1"

        customCoverScale = originalCoverScale
        customFrontCoverScale = originalFrontCoverScale
        customCoverYOffset = originalCoverYOffset
        customPathSpread = originalPathSpread
        customCenterCoverYOffset = originalCenterCoverYOffset
        customCenterSpacing = originalCenterSpacing

        if (scaleSlider) scaleSlider.setValue(customCoverScale)
        if (frontCoverScaleSlider) frontCoverScaleSlider.setValue(customFrontCoverScale)
        if (yOffsetSlider) yOffsetSlider.setValue(customCoverYOffset)
        if (spreadSlider) spreadSlider.setValue(customPathSpread)
        if (centerCoverYOffsetSlider) centerCoverYOffsetSlider.setValue(customCenterCoverYOffset)
        if (centerSpacingSlider) centerSpacingSlider.setValue(customCenterSpacing)

        // saveSettings() will be called by closePanelAndSave/onDestruction
        // and _isAtOriginalDefaults() will auto-unset + restoreRuntimeDefaults
        // Call immediately for instant cleanup
        saveSettings()

        notifyFrontCoverScaleChange()
        customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)

        console.log("[CarouselCustomizer] ✅ RESET complete for", currentPlatform, mode,
                    "- Values: scale=" + customCoverScale, "fcs=" + customFrontCoverScale,
                    "yOff=" + customCoverYOffset, "spread=" + customPathSpread,
                    "cyOff=" + customCenterCoverYOffset)
    }

    function resetCurrentSlider() {
        if (!isPanelNavigationActive) return

        console.log("[CarouselCustomizer] Resetting slider at index:", currentSliderIndex, "platform:", currentPlatform, "mode:", viewModeKey)

        switch(currentSliderIndex) {
            case 0:  // scaleSlider - General layout
                scaleSlider.value = originalCoverScale
                scaleSlider.updateHandle()
                customCoverScale = originalCoverScale
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
            case 1:  // frontCoverScaleSlider - Center layout
                frontCoverScaleSlider.value = originalFrontCoverScale
                frontCoverScaleSlider.updateHandle()
                customFrontCoverScale = originalFrontCoverScale
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
            case 2:
                spreadSlider.value = originalPathSpread
                spreadSlider.updateHandle()
                customPathSpread = originalPathSpread
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
            case 3:  // yOffsetSlider - Height
                yOffsetSlider.value = originalCoverYOffset
                yOffsetSlider.updateHandle()
                customCoverYOffset = originalCoverYOffset
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
            case 4:  // centerCoverYOffsetSlider - Center Y offset
                centerCoverYOffsetSlider.value = originalCenterCoverYOffset
                centerCoverYOffsetSlider.updateHandle()
                customCenterCoverYOffset = originalCenterCoverYOffset
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
            case 5:
                centerSpacingSlider.value = originalCenterSpacing
                centerSpacingSlider.updateHandle()
                customCenterSpacing = originalCenterSpacing
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
        }

        saveSettings()
        console.log("[CarouselCustomizer] Current slider reset to default for", currentPlatform, viewModeKey)
    }

    function navigateSliderDown() {
        if (!isPanelNavigationActive) return
        saveDebounceTimer.stop()
        saveSettings()
        if (currentSliderIndex === 4) {
            currentSliderIndex = 7  // Skip hidden slider 5, go to Reset button
        } else if (currentSliderIndex >= 7) {
            currentSliderIndex = 0  // Wrap from buttons to first slider
        } else {
            currentSliderIndex = currentSliderIndex + 1
        }
        console.log("[CarouselCustomizer] Navigate down to:", currentSliderIndex)
        updateSliderFocus()
    }

    function navigateSliderUp() {
        if (!isPanelNavigationActive) return
        saveDebounceTimer.stop()
        saveSettings()
        if (currentSliderIndex === 0) {
            currentSliderIndex = 7  // Wrap from first slider to Reset button
        } else if (currentSliderIndex >= 7) {
            currentSliderIndex = 4  // Go from buttons to last visible slider
        } else {
            currentSliderIndex = currentSliderIndex - 1
        }
        console.log("[CarouselCustomizer] Navigate up to:", currentSliderIndex)
        updateSliderFocus()
    }

    function adjustSliderLeft() {
        if (!isPanelNavigationActive) return
        if (currentSliderIndex === 8) {
            currentSliderIndex = 7
            updateSliderFocus()
        } else if (currentSliderIndex === 7) {
            // Already on Reset, do nothing
        } else {
            adjustCurrentSlider(-sliderAdjustmentStep)
        }
    }

    function adjustSliderRight() {
        if (!isPanelNavigationActive) return
        if (currentSliderIndex === 7) {
            currentSliderIndex = 8
            updateSliderFocus()
        } else if (currentSliderIndex === 8) {
            // Already on Apply, do nothing
        } else {
            adjustCurrentSlider(sliderAdjustmentStep)
        }
    }

    function adjustCurrentSlider(delta) {
        if (currentSliderIndex >= 7) return  // Button indices - no slider adjustment
        var newValue
        switch(currentSliderIndex) {
            case 0:  // scaleSlider
                newValue = Math.max(scaleSlider.minimumValue, Math.min(scaleSlider.maximumValue, scaleSlider.value + delta))
                scaleSlider.value = newValue
                scaleSlider.updateHandle()
                customCoverScale = newValue
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
            case 1:  // frontCoverScaleSlider
                newValue = Math.max(frontCoverScaleSlider.minimumValue, Math.min(frontCoverScaleSlider.maximumValue, frontCoverScaleSlider.value + delta))
                frontCoverScaleSlider.value = newValue
                frontCoverScaleSlider.updateHandle()
                customFrontCoverScale = newValue
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
            case 2:  // spreadSlider
                newValue = Math.max(spreadSlider.minimumValue, Math.min(spreadSlider.maximumValue, spreadSlider.value + delta))
                spreadSlider.value = newValue
                spreadSlider.updateHandle()
                customPathSpread = newValue
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
            case 3:  // yOffsetSlider
                newValue = Math.max(yOffsetSlider.minimumValue, Math.min(yOffsetSlider.maximumValue, yOffsetSlider.value - delta))
                yOffsetSlider.value = newValue
                yOffsetSlider.updateHandle()
                customCoverYOffset = newValue
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
            case 4:  // centerCoverYOffsetSlider
                newValue = Math.max(centerCoverYOffsetSlider.minimumValue, Math.min(centerCoverYOffsetSlider.maximumValue, centerCoverYOffsetSlider.value - delta))
                centerCoverYOffsetSlider.value = newValue
                centerCoverYOffsetSlider.updateHandle()
                customCenterCoverYOffset = newValue
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
            case 5:  // centerSpacingSlider
                newValue = Math.max(centerSpacingSlider.minimumValue, Math.min(centerSpacingSlider.maximumValue, centerSpacingSlider.value + delta))
                centerSpacingSlider.value = newValue
                centerSpacingSlider.updateHandle()
                customCenterSpacing = newValue
                customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                break
        }

        // Restart debounce timer - saves 500ms after last change
        saveDebounceTimer.restart()
    }

    function updateSliderFocus() {
        if (scaleSlider) scaleSlider.focused = false
        if (frontCoverScaleSlider) frontCoverScaleSlider.focused = false
        if (yOffsetSlider) yOffsetSlider.focused = false
        if (spreadSlider) spreadSlider.focused = false
        if (centerCoverYOffsetSlider) centerCoverYOffsetSlider.focused = false
        if (centerSpacingSlider) centerSpacingSlider.focused = false

        switch(currentSliderIndex) {
            case 0:
                if (scaleSlider) scaleSlider.focused = true
                break
            case 1:
                if (frontCoverScaleSlider) frontCoverScaleSlider.focused = true
                break
            case 2:
                if (spreadSlider) spreadSlider.focused = true
                break
            case 3:
                if (yOffsetSlider) yOffsetSlider.focused = true
                break
            case 4:
                if (centerCoverYOffsetSlider) centerCoverYOffsetSlider.focused = true
                break
            case 5:
                if (centerSpacingSlider) centerSpacingSlider.focused = true
                break
            case 7:
                // Reset button focused - handled by property binding
                break
            case 8:
                // Apply button focused - handled by property binding
                break
        }
    }

    // Update UI sliders visually when panel is open (e.g. on platform change)
    function updateSlidersUI() {
        console.log("[CarouselCustomizer] Updating sliders UI with current values")

        if (scaleSlider) {
            scaleSlider.value = customCoverScale
            scaleSlider.updateHandle()
        }

        if (frontCoverScaleSlider) {
            frontCoverScaleSlider.value = customFrontCoverScale
            frontCoverScaleSlider.updateHandle()
        }

        if (yOffsetSlider) {
            yOffsetSlider.value = customCoverYOffset
            yOffsetSlider.updateHandle()
        }

        if (spreadSlider) {
            spreadSlider.value = customPathSpread
            spreadSlider.updateHandle()
        }

        if (centerCoverYOffsetSlider) {
            centerCoverYOffsetSlider.value = customCenterCoverYOffset
            centerCoverYOffsetSlider.updateHandle()
        }

        if (centerSpacingSlider) {
            centerSpacingSlider.value = customCenterSpacing
            centerSpacingSlider.updateHandle()
        }

        console.log("[CarouselCustomizer] Sliders UI updated")
    }

    function closePanelAndSave() {
        console.log("[CarouselCustomizer] Closing panel and saving")
        saveDebounceTimer.stop()
        isPanelNavigationActive = false
        customPanel.visible = false
        saveSettings()
        isCustomizing = false
        panelNavigationActiveChanged(false)
        customizationToggled(false)
    }

    function confirmCurrentButton() {
        if (!isPanelNavigationActive) return
        if (currentSliderIndex === 7) {
            // Reset button
            resetValues()
            resetToDefaults()
        } else if (currentSliderIndex === 8) {
            // Apply button
            closePanelAndSave()
        }
    }

    function openPanelForNavigation() {
        console.log("[CarouselCustomizer] Opening panel for navigation")
        console.log("  Current currentPlatform:", currentPlatform)
        console.log("  Current viewModeKey:", viewModeKey)

        customPanel.visible = true
        isPanelNavigationActive = true
        currentSliderIndex = 0
        updateSlidersUI()  // Sync sliders with current platform values
        updateSliderFocus()
        panelNavigationActiveChanged(true)  // Emetti segnale

        customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)

        console.log("[CarouselCustomizer] Panel opened with values:")
        console.log("  scale=" + customCoverScale, "spread=" + customPathSpread, "yOffset=" + customCoverYOffset,
                    "frontScale=" + customFrontCoverScale, "centerYOffset=" + customCenterCoverYOffset,
                    "centerSpacing=" + customCenterSpacing)
    }

    Rectangle {
        id: menuIcon
        x: 20 + (screenMetrics ? screenMetrics.toolbarButtonSize : 80) + 12
        y: 24
        width: screenMetrics ? screenMetrics.toolbarButtonSize : 80
        height: screenMetrics ? screenMetrics.toolbarButtonSize : 80
        radius: width / 2
        color: mouseArea.pressed ? "#339B59B6" : (mouseArea.containsMouse ? "#339B59B6" : "#22FFFFFF")
        border.width: 2
        border.color: "#9B59B6"
        opacity: isCoverSelected ? 0.0 : 0.9
        visible: !isCoverSelected
        clip: false

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        // Water fill effect — physics water
        Item {
            id: custWaterFillContainer
            anchors.fill: parent
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: menuIcon.width
                    height: menuIcon.height
                    radius: menuIcon.radius
                }
            }
            Canvas {
                id: custWaterCanvas
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
                    ctx.fillStyle = "#CC9B59B6";
                    ctx.fill();
                    for (var i = 0; i < _drops.length; i++) {
                        var d = _drops[i];
                        ctx.globalAlpha = Math.max(0, d.alpha);
                        ctx.beginPath();
                        ctx.arc(d.x, d.y, d.r, 0, Math.PI * 2);
                        ctx.fillStyle = "#9B59B6";
                        ctx.fill();
                    }
                    ctx.globalAlpha = 1.0;
                }
                Timer {
                    interval: 16; repeat: true
                    running: custWaterCanvas._level > 0.005 || custWaterCanvas._target > 0.5
                    onTriggered: {
                        var c = custWaterCanvas;
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

        // Focus circle (visible when button is focused)
        Rectangle {
            id: focusRing
            anchors.centerIn: parent
            width: parent.width + 10
            height: parent.height + 10
            radius: width / 2
            color: "transparent"
            border.color: "#9B59B6"
            border.width: 3
            opacity: root.focused ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }

        // Focus label (zoom-in dal basso quando focalizzato)
        Rectangle {
            id: custFocusLabel
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height + 8
            width: Math.max(custFocusLabelText.implicitWidth + 16, 40)
            height: screenMetrics ? Math.max(20, Math.min(26, Math.round(22 * screenMetrics.scaleRatio))) : 22
            radius: height / 2
            color: "#CC1a1a2e"
            border.color: "#66FFFFFF"
            border.width: 1
            transformOrigin: Item.Top
            scale: root.focused ? 1.0 : 0.0
            opacity: root.focused ? 1.0 : 0.0
            Behavior on scale {
                NumberAnimation { duration: 220; easing.type: Easing.OutBack }
            }
            Behavior on opacity {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
            Text {
                id: custFocusLabelText
                anchors.centerIn: parent
                text: "Settings"
                font.pixelSize: screenMetrics ? Math.max(10, Math.min(13, Math.round(11 * screenMetrics.scaleRatio))) : 11
                font.bold: true
                color: "white"
            }
        }

        // Gear icon (outline style)
        Canvas {
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: parent.width * 0.5
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var w = width, h = height
                var cx = w / 2, cy = h / 2
                ctx.strokeStyle = "white"
                ctx.lineWidth = 2
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                // Inner circle
                ctx.beginPath()
                ctx.arc(cx, cy, w * 0.18, 0, Math.PI * 2)
                ctx.stroke()
                // Gear teeth
                var teeth = 6
                var outerR = w * 0.42
                var innerR = w * 0.32
                var toothW = 0.28  // radians half-width
                ctx.beginPath()
                for (var i = 0; i < teeth; i++) {
                    var angle = (i / teeth) * Math.PI * 2 - Math.PI / 2
                    var a1 = angle - toothW
                    var a2 = angle + toothW
                    if (i === 0) {
                        ctx.moveTo(cx + innerR * Math.cos(a1 - 0.15), cy + innerR * Math.sin(a1 - 0.15))
                    }
                    ctx.lineTo(cx + outerR * Math.cos(a1), cy + outerR * Math.sin(a1))
                    ctx.lineTo(cx + outerR * Math.cos(a2), cy + outerR * Math.sin(a2))
                    var nextAngle = ((i + 1) / teeth) * Math.PI * 2 - Math.PI / 2
                    var na1 = nextAngle - toothW
                    ctx.lineTo(cx + innerR * Math.cos(a2 + 0.15), cy + innerR * Math.sin(a2 + 0.15))
                    ctx.lineTo(cx + innerR * Math.cos(na1 - 0.15), cy + innerR * Math.sin(na1 - 0.15))
                }
                ctx.closePath()
                ctx.stroke()
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                if (customPanel.visible) {
                    closePanelAndSave()
                } else {
                    openPanelForNavigation()
                    isCustomizing = true
                    customizationToggled(true)
                }
            }
        }

    }

    Rectangle {
        id: customPanel
        visible: false
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        width: 440
        height: Math.min(parent.height - 60, panelContentColumn.implicitHeight + 52)
        color: "transparent"
        radius: 20
        clip: true

        // Blur background
        Item {
            id: panelBlurLayer
            anchors.fill: parent
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: customPanel.width
                    height: customPanel.height
                    radius: 20
                }
            }

            FastBlur {
                width: root.width
                height: root.height
                x: -customPanel.x
                y: -customPanel.y
                source: ShaderEffectSource {
                    sourceItem: root.parent
                    live: customPanel.visible
                }
                radius: 40
            }

            // Dark overlay
            Rectangle {
                anchors.fill: parent
                color: "#B8100a22"
            }

            // Frosted glass top highlight
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#14FFFFFF" }
                    GradientStop { position: 0.08; color: "#08FFFFFF" }
                    GradientStop { position: 1.0; color: "#00FFFFFF" }
                }
            }
        }

        // Purple border
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: parent.radius
            border.color: "#BB9B59B6"
            border.width: 2
        }

        property real initialCoverScale
        property real initialFrontCoverScale
        property real initialCoverYOffset
        property real initialPathSpread
        property real initialCenterCoverYOffset
        property real initialCenterSpacing

        onVisibleChanged: {
            if (visible) {
                initialCoverScale = customCoverScale
                initialFrontCoverScale = customFrontCoverScale
                initialCoverYOffset = customCoverYOffset
                initialPathSpread = customPathSpread
                initialCenterCoverYOffset = customCenterCoverYOffset
                initialCenterSpacing = customCenterSpacing
            }
        }

        Column {
            id: panelContentColumn
            anchors.fill: parent
            anchors.margins: 24
            spacing: 14

            // Panel Title
            Row {
                width: parent.width
                height: 34
                spacing: 10

                Canvas {
                    width: 22; height: 22
                    anchors.verticalCenter: parent.verticalCenter
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width, h = height
                        ctx.strokeStyle = "#FFFFFF"
                        ctx.lineWidth = 1.5
                        ctx.lineCap = "round"
                        ctx.moveTo(w*0.15, h*0.25); ctx.lineTo(w*0.85, h*0.25)
                        ctx.moveTo(w*0.15, h*0.5);  ctx.lineTo(w*0.85, h*0.5)
                        ctx.moveTo(w*0.15, h*0.75); ctx.lineTo(w*0.85, h*0.75)
                        ctx.stroke()
                        ctx.fillStyle = "#FFFFFF"
                        ctx.beginPath(); ctx.arc(w*0.6, h*0.25, 2.5, 0, Math.PI*2); ctx.fill()
                        ctx.beginPath(); ctx.arc(w*0.35, h*0.5, 2.5, 0, Math.PI*2); ctx.fill()
                        ctx.beginPath(); ctx.arc(w*0.7, h*0.75, 2.5, 0, Math.PI*2); ctx.fill()
                    }
                }

                Text {
                    text: T.t("cc_title", root.lang)
                    color: "#EEEEFF"
                    font.pixelSize: 17
                    font.bold: true
                    font.letterSpacing: 0.5
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Separator
            Rectangle { width: parent.width; height: 1; color: "#409B59B6" }

            Column {
                id: slidersColumn
                width: parent.width
                spacing: 8

                // Size
                Item {
                    id: scaleSlider
                    width: parent.width
                    height: 68

                    property string label: T.t("cc_size", root.lang)
                    property real minimumValue: 0.5
                    property real maximumValue: 3.0
                    property real value: 1.0
                    property bool focused: false

                    signal scaleValueChanged()

                    function setValue(newValue) {
                        value = Math.max(minimumValue, Math.min(maximumValue, newValue))
                        updateHandle()
                    }

                    function updateHandle() {
                        if (width > 0) {
                            var ratio = (value - minimumValue) / (maximumValue - minimumValue)
                            scaleHandle.x = ratio * (scaleTrack.width - scaleHandle.width)
                        }
                    }

                    onWidthChanged: updateHandle()
                    Component.onCompleted: updateHandle()

                    onScaleValueChanged: {
                        customCoverScale = value
                        customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        spacing: 8
                        height: 22

                        Canvas {
                            width: 20; height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width, h = height
                                ctx.strokeStyle = "#FFFFFF"
                                ctx.lineWidth = 1.5
                                ctx.lineCap = "round"
                                ctx.lineJoin = "round"
                                ctx.moveTo(w*0.7, w*0.85); ctx.lineTo(w*0.85, w*0.85); ctx.lineTo(w*0.85, w*0.7)
                                ctx.moveTo(w*0.3, w*0.15); ctx.lineTo(w*0.15, w*0.15); ctx.lineTo(w*0.15, w*0.3)
                                ctx.moveTo(w*0.85, w*0.85); ctx.lineTo(w*0.15, w*0.15)
                                ctx.stroke()
                            }
                        }

                        Text {
                            text: parent.parent.label
                            color: "#BBBBCC"
                            font.pixelSize: 14
                            font.letterSpacing: 0.3
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: parent.value.toFixed(2)
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 1
                    }

                    Rectangle {
                        id: scaleTrack
                        height: 8
                        color: parent.focused ? "#90FFFFFF" : "#30FFFFFF"
                        radius: 4
                        Behavior on color { ColorAnimation { duration: 200 } }
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 30

                        Rectangle {
                            id: scaleTrackFill
                            width: scaleHandle.x + scaleHandle.width / 2
                            height: parent.height
                            radius: parent.radius
                            color: "white"
                            layer.enabled: width > 0
                            layer.effect: LinearGradient {
                                start: Qt.point(0, 0)
                                end: Qt.point(scaleTrack.width, 0)
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#8E2DE2" }
                                    GradientStop { position: 1.0; color: "#2193b0" }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: scaleHandle
                        width: 24
                        height: 24
                        radius: 12
                        color: "transparent"
                        anchors.verticalCenter: scaleTrack.verticalCenter

                        Rectangle {
                            anchors.centerIn: parent
                            width: 14; height: 14; radius: 7
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#2193b0" }
                                GradientStop { position: 1.0; color: "#8E2DE2" }
                            }
                        }
                        Rectangle {
                            anchors.fill: parent; radius: parent.radius
                            color: "transparent"
                            border.color: "#80FFFFFF"; border.width: 1.5
                        }

                        MouseArea {
                            anchors.fill: parent
                            property bool dragging: false
                            property real startX: 0

                            onPressed: {
                                root.currentSliderIndex = 0
                                dragging = true
                                startX = mouse.x
                                root.sliderDraggingChanged(true)
                            }

                            onPositionChanged: {
                                if (dragging) {
                                    var deltaX = mouse.x - startX
                                    var newX = parent.x + deltaX
                                    newX = Math.max(0, Math.min(scaleTrack.width - parent.width, newX))
                                    parent.x = newX

                                    var ratio = newX / (scaleTrack.width - parent.width)
                                    parent.parent.value = parent.parent.minimumValue + ratio * (parent.parent.maximumValue - parent.parent.minimumValue)
                                    parent.parent.scaleValueChanged()
                                }
                            }

                            onReleased: {
                                dragging = false
                                root.sliderDraggingChanged(false)
                            }
                        }
                    }

                }

                // Center Size
                Item {
                    id: frontCoverScaleSlider
                    width: parent.width
                    height: 68

                    property string label: T.t("cc_center_size", root.lang)
                    property real minimumValue: 0.3
                    property real maximumValue: 3.0
                    property real value: 1.0
                    property bool focused: false

                    signal frontCoverScaleValueChanged()

                    function setValue(newValue) {
                        value = Math.max(minimumValue, Math.min(maximumValue, newValue))
                        updateHandle()
                    }

                    function updateHandle() {
                        if (width > 0) {
                            var ratio = (value - minimumValue) / (maximumValue - minimumValue)
                            frontCoverHandle.x = ratio * (frontCoverTrack.width - frontCoverHandle.width)
                        }
                    }

                    onWidthChanged: updateHandle()
                    Component.onCompleted: updateHandle()

                    onFrontCoverScaleValueChanged: {
                        customFrontCoverScale = value
                        customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        spacing: 8
                        height: 22

                        Canvas {
                            width: 20; height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width, h = height
                                ctx.strokeStyle = "#FFFFFF"
                                ctx.lineWidth = 1.5
                                ctx.lineCap = "round"
                                ctx.strokeRect(w*0.1, h*0.1, w*0.8, h*0.8)
                                ctx.strokeRect(w*0.3, h*0.3, w*0.4, h*0.4)
                                ctx.fillStyle = "#FFFFFF"
                                ctx.beginPath(); ctx.arc(w/2, h/2, 2, 0, Math.PI*2); ctx.fill()
                            }
                        }

                        Text {
                            text: parent.parent.label
                            color: "#BBBBCC"
                            font.pixelSize: 14
                            font.letterSpacing: 0.3
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: parent.value.toFixed(2)
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 1
                    }

                    Rectangle {
                        id: frontCoverTrack
                        height: 8
                        color: parent.focused ? "#90FFFFFF" : "#30FFFFFF"
                        radius: 4
                        Behavior on color { ColorAnimation { duration: 200 } }
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 30

                        Rectangle {
                            id: frontCoverTrackFill
                            width: frontCoverHandle.x + frontCoverHandle.width / 2
                            height: parent.height
                            radius: parent.radius
                            color: "white"
                            layer.enabled: width > 0
                            layer.effect: LinearGradient {
                                start: Qt.point(0, 0)
                                end: Qt.point(frontCoverTrack.width, 0)
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#8E2DE2" }
                                    GradientStop { position: 1.0; color: "#2193b0" }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: frontCoverHandle
                        width: 24
                        height: 24
                        radius: 12
                        color: "transparent"
                        anchors.verticalCenter: frontCoverTrack.verticalCenter

                        Rectangle {
                            anchors.centerIn: parent
                            width: 14; height: 14; radius: 7
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#2193b0" }
                                GradientStop { position: 1.0; color: "#8E2DE2" }
                            }
                        }
                        Rectangle {
                            anchors.fill: parent; radius: parent.radius
                            color: "transparent"
                            border.color: "#80FFFFFF"; border.width: 1.5
                        }

                        MouseArea {
                            anchors.fill: parent
                            property bool dragging: false
                            property real startX: 0

                            onPressed: {
                                root.currentSliderIndex = 1
                                dragging = true
                                startX = mouse.x
                                root.sliderDraggingChanged(true)
                            }

                            onPositionChanged: {
                                if (dragging) {
                                    var deltaX = mouse.x - startX
                                    var newX = parent.x + deltaX
                                    newX = Math.max(0, Math.min(frontCoverTrack.width - parent.width, newX))
                                    parent.x = newX

                                    var ratio = newX / (frontCoverTrack.width - parent.width)
                                    parent.parent.value = parent.parent.minimumValue + ratio * (parent.parent.maximumValue - parent.parent.minimumValue)
                                    parent.parent.frontCoverScaleValueChanged()
                                }
                            }

                            onReleased: {
                                dragging = false
                                root.sliderDraggingChanged(false)
                            }
                        }
                    }

                }

                // Spread
                Item {
                    id: spreadSlider
                    width: parent.width
                    height: 68

                    property string label: T.t("cc_spread", root.lang)
                    property real minimumValue: 0.40
                    property real maximumValue: 1.5
                    property real value: 1.0
                    property bool focused: false

                    signal spreadValueChanged()

                    function setValue(newValue) {
                        value = Math.max(minimumValue, Math.min(maximumValue, newValue))
                        updateHandle()
                    }

                    function updateHandle() {
                        if (width > 0) {
                            var ratio = (value - minimumValue) / (maximumValue - minimumValue)
                            spreadHandle.x = ratio * (spreadTrack.width - spreadHandle.width)
                        }
                    }

                    onWidthChanged: updateHandle()
                    Component.onCompleted: updateHandle()

                    onSpreadValueChanged: {
                        customPathSpread = value
                        customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        spacing: 8
                        height: 22

                        Canvas {
                            width: 20; height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width, h = height
                                ctx.strokeStyle = "#FFFFFF"
                                ctx.lineWidth = 1.5
                                ctx.lineCap = "round"
                                ctx.lineJoin = "round"
                                ctx.moveTo(w*0.1, h/2); ctx.lineTo(w*0.38, h/2)
                                ctx.moveTo(w*0.1, h/2); ctx.lineTo(w*0.24, h*0.32)
                                ctx.moveTo(w*0.1, h/2); ctx.lineTo(w*0.24, h*0.68)
                                ctx.moveTo(w*0.9, h/2); ctx.lineTo(w*0.62, h/2)
                                ctx.moveTo(w*0.9, h/2); ctx.lineTo(w*0.76, h*0.32)
                                ctx.moveTo(w*0.9, h/2); ctx.lineTo(w*0.76, h*0.68)
                                ctx.moveTo(w/2, h*0.25); ctx.lineTo(w/2, h*0.75)
                                ctx.stroke()
                            }
                        }

                        Text {
                            text: parent.parent.label
                            color: "#BBBBCC"
                            font.pixelSize: 14
                            font.letterSpacing: 0.3
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: parent.value.toFixed(2)
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 1
                    }

                    Rectangle {
                        id: spreadTrack
                        height: 8
                        color: parent.focused ? "#90FFFFFF" : "#30FFFFFF"
                        radius: 4
                        Behavior on color { ColorAnimation { duration: 200 } }
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 30

                        Rectangle {
                            id: spreadTrackFill
                            width: spreadHandle.x + spreadHandle.width / 2
                            height: parent.height
                            radius: parent.radius
                            color: "white"
                            layer.enabled: width > 0
                            layer.effect: LinearGradient {
                                start: Qt.point(0, 0)
                                end: Qt.point(spreadTrack.width, 0)
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#8E2DE2" }
                                    GradientStop { position: 1.0; color: "#2193b0" }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: spreadHandle
                        width: 24
                        height: 24
                        radius: 12
                        color: "transparent"
                        anchors.verticalCenter: spreadTrack.verticalCenter

                        Rectangle {
                            anchors.centerIn: parent
                            width: 14; height: 14; radius: 7
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#2193b0" }
                                GradientStop { position: 1.0; color: "#8E2DE2" }
                            }
                        }
                        Rectangle {
                            anchors.fill: parent; radius: parent.radius
                            color: "transparent"
                            border.color: "#80FFFFFF"; border.width: 1.5
                        }

                        MouseArea {
                            anchors.fill: parent
                            property bool dragging: false
                            property real startX: 0

                            onPressed: {
                                root.currentSliderIndex = 2
                                dragging = true
                                startX = mouse.x
                                root.sliderDraggingChanged(true)
                            }

                            onPositionChanged: {
                                if (dragging) {
                                    var deltaX = mouse.x - startX
                                    var newX = parent.x + deltaX
                                    newX = Math.max(0, Math.min(spreadTrack.width - parent.width, newX))
                                    parent.x = newX

                                    var ratio = newX / (spreadTrack.width - parent.width)
                                    parent.parent.value = parent.parent.minimumValue + ratio * (parent.parent.maximumValue - parent.parent.minimumValue)
                                    parent.parent.spreadValueChanged()
                                }
                            }

                            onReleased: {
                                dragging = false
                                root.sliderDraggingChanged(false)
                            }
                        }
                    }

                }

                // Offset Y
                Item {
                    id: yOffsetSlider
                    width: parent.width
                    height: 68

                    property string label: T.t("cc_offset_y", root.lang)
                    property real minimumValue: -3.0
                    property real maximumValue: 3.0
                    property real value: 0.0
                    property bool focused: false

                    signal yOffsetValueChanged()

                    function setValue(newValue) {
                        value = Math.max(minimumValue, Math.min(maximumValue, newValue))
                        updateHandle()
                    }

                    function updateHandle() {
                        if (width > 0) {
                            var ratio = (maximumValue - value) / (maximumValue - minimumValue)
                            yOffsetHandle.x = ratio * (yOffsetTrack.width - yOffsetHandle.width)
                        }
                    }

                    onWidthChanged: updateHandle()
                    Component.onCompleted: updateHandle()

                    onYOffsetValueChanged: {
                        customCoverYOffset = value
                        customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        spacing: 8
                        height: 22

                        Canvas {
                            width: 20; height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width, h = height
                                ctx.strokeStyle = "#FFFFFF"
                                ctx.lineWidth = 1.5
                                ctx.lineCap = "round"
                                ctx.lineJoin = "round"
                                ctx.moveTo(w/2, h*0.1); ctx.lineTo(w/2, h*0.9)
                                ctx.moveTo(w*0.3, h*0.28); ctx.lineTo(w/2, h*0.1); ctx.lineTo(w*0.7, h*0.28)
                                ctx.moveTo(w*0.3, h*0.72); ctx.lineTo(w/2, h*0.9); ctx.lineTo(w*0.7, h*0.72)
                                ctx.stroke()
                            }
                        }

                        Text {
                            text: parent.parent.label
                            color: "#BBBBCC"
                            font.pixelSize: 14
                            font.letterSpacing: 0.3
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: parent.value.toFixed(2)
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 1
                    }

                    Rectangle {
                        id: yOffsetTrack
                        height: 8
                        color: parent.focused ? "#90FFFFFF" : "#30FFFFFF"
                        radius: 4
                        Behavior on color { ColorAnimation { duration: 200 } }
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 30

                        Rectangle {
                            id: yOffsetTrackFill
                            width: yOffsetHandle.x + yOffsetHandle.width / 2
                            height: parent.height
                            radius: parent.radius
                            color: "white"
                            layer.enabled: width > 0
                            layer.effect: LinearGradient {
                                start: Qt.point(0, 0)
                                end: Qt.point(yOffsetTrack.width, 0)
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#8E2DE2" }
                                    GradientStop { position: 1.0; color: "#2193b0" }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: yOffsetHandle
                        width: 24
                        height: 24
                        radius: 12
                        color: "transparent"
                        anchors.verticalCenter: yOffsetTrack.verticalCenter

                        Rectangle {
                            anchors.centerIn: parent
                            width: 14; height: 14; radius: 7
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#2193b0" }
                                GradientStop { position: 1.0; color: "#8E2DE2" }
                            }
                        }
                        Rectangle {
                            anchors.fill: parent; radius: parent.radius
                            color: "transparent"
                            border.color: "#80FFFFFF"; border.width: 1.5
                        }

                        MouseArea {
                            anchors.fill: parent
                            property bool dragging: false
                            property real startX: 0

                            onPressed: {
                                root.currentSliderIndex = 3
                                dragging = true
                                startX = mouse.x
                                root.sliderDraggingChanged(true)
                            }

                            onPositionChanged: {
                                if (dragging) {
                                    var deltaX = mouse.x - startX
                                    var newX = parent.x + deltaX
                                    newX = Math.max(0, Math.min(yOffsetTrack.width - parent.width, newX))
                                    parent.x = newX

                                    var ratio = newX / (yOffsetTrack.width - parent.width)
                                    parent.parent.value = parent.parent.maximumValue - ratio * (parent.parent.maximumValue - parent.parent.minimumValue)
                                    parent.parent.yOffsetValueChanged()
                                }
                            }

                            onReleased: {
                                dragging = false
                                root.sliderDraggingChanged(false)
                            }
                        }
                    }

                }

                // Center Y
                Item {
                    id: centerCoverYOffsetSlider
                    width: parent.width
                    height: 68

                    property string label: T.t("cc_center_y", root.lang)
                    property real minimumValue: -3.0
                    property real maximumValue: 3.0
                    property real value: 0.0
                    property bool focused: false

                    signal centerYOffsetValueChanged()

                    function setValue(newValue) {
                        value = Math.max(minimumValue, Math.min(maximumValue, newValue))
                        updateHandle()
                    }

                    function updateHandle() {
                        if (width > 0) {
                            // Inverted logic preserved
                            var ratio = (maximumValue - value) / (maximumValue - minimumValue)
                            centerYOffsetHandle.x = ratio * (centerYOffsetTrack.width - centerYOffsetHandle.width)
                        }
                    }

                    onWidthChanged: updateHandle()
                    Component.onCompleted: updateHandle()

                    onCenterYOffsetValueChanged: {
                        customCenterCoverYOffset = value
                        customValuesChanged(customCoverScale, customCoverYOffset, customPathSpread, customFrontCoverScale, customCenterCoverYOffset, customCenterSpacing)
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        spacing: 8
                        height: 22

                        Canvas {
                            width: 20; height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width, h = height
                                ctx.strokeStyle = "#FFFFFF"
                                ctx.lineWidth = 1.5
                                ctx.lineCap = "round"
                                ctx.beginPath()
                                ctx.arc(w/2, h/2, w*0.32, 0, Math.PI*2)
                                ctx.stroke()
                                ctx.beginPath()
                                ctx.moveTo(w/2, h*0.08); ctx.lineTo(w/2, h*0.92)
                                ctx.moveTo(w*0.08, h/2); ctx.lineTo(w*0.92, h/2)
                                ctx.stroke()
                            }
                        }

                        Text {
                            text: parent.parent.label
                            color: "#BBBBCC"
                            font.pixelSize: 14
                            font.letterSpacing: 0.3
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: parent.value.toFixed(2)
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 1
                    }

                    Rectangle {
                        id: centerYOffsetTrack
                        height: 8
                        color: parent.focused ? "#90FFFFFF" : "#30FFFFFF"
                        radius: 4
                        Behavior on color { ColorAnimation { duration: 200 } }
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 30

                        Rectangle {
                            id: centerYOffsetTrackFill
                            width: centerYOffsetHandle.x + centerYOffsetHandle.width / 2
                            height: parent.height
                            radius: parent.radius
                            color: "white"
                            layer.enabled: width > 0
                            layer.effect: LinearGradient {
                                start: Qt.point(0, 0)
                                end: Qt.point(centerYOffsetTrack.width, 0)
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#8E2DE2" }
                                    GradientStop { position: 1.0; color: "#2193b0" }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: centerYOffsetHandle
                        width: 24
                        height: 24
                        radius: 12
                        color: "transparent"
                        anchors.verticalCenter: centerYOffsetTrack.verticalCenter

                        Rectangle {
                            anchors.centerIn: parent
                            width: 14; height: 14; radius: 7
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#2193b0" }
                                GradientStop { position: 1.0; color: "#8E2DE2" }
                            }
                        }
                        Rectangle {
                            anchors.fill: parent; radius: parent.radius
                            color: "transparent"
                            border.color: "#80FFFFFF"; border.width: 1.5
                        }

                        MouseArea {
                            anchors.fill: parent
                            property bool dragging: false
                            property real startX: 0

                            onPressed: {
                                root.currentSliderIndex = 4
                                dragging = true
                                startX = mouse.x
                                root.sliderDraggingChanged(true)
                            }

                            onPositionChanged: {
                                if (dragging) {
                                    var deltaX = mouse.x - startX
                                    var newX = parent.x + deltaX
                                    newX = Math.max(0, Math.min(centerYOffsetTrack.width - parent.width, newX))
                                    parent.x = newX

                                    // Inverted logic
                                    var ratio = newX / (centerYOffsetTrack.width - parent.width)
                                    parent.parent.value = parent.parent.maximumValue - ratio * (parent.parent.maximumValue - parent.parent.minimumValue)
                                    parent.parent.centerYOffsetValueChanged()
                                }
                            }

                            onReleased: {
                                dragging = false
                                root.sliderDraggingChanged(false)
                            }
                        }
                    }

                }

                // Hidden 6th slider
                Item {
                    id: centerSpacingSlider
                    visible: false
                    property real value: 0.142
                    property bool focused: false
                    function setValue(v) { value = v }
                    function updateHandle() {}
                    signal centerSpacingValueChanged()
                }
            }

            // Separator before buttons
            Rectangle { width: parent.width; height: 1; color: "#309B59B6" }

            // Buttons
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                // Reset button (D-pad index 7)
                Rectangle {
                    id: resetButton
                    width: 140
                    height: 44
                    radius: 22
                    color: root.currentSliderIndex === 7 && root.isPanelNavigationActive ? "#40FFFFFF" : "#20FFFFFF"
                    border.color: root.currentSliderIndex === 7 && root.isPanelNavigationActive ? "#BB9B59B6" : "#40FFFFFF"
                    border.width: root.currentSliderIndex === 7 && root.isPanelNavigationActive ? 2 : 1

                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Canvas {
                            width: 16; height: 16
                            anchors.verticalCenter: parent.verticalCenter
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width, h = height
                                ctx.strokeStyle = "#FFFFFF"
                                ctx.lineWidth = 1.5
                                ctx.lineCap = "round"
                                ctx.moveTo(w*0.25, h*0.25); ctx.lineTo(w*0.75, h*0.75)
                                ctx.moveTo(w*0.75, h*0.25); ctx.lineTo(w*0.25, h*0.75)
                                ctx.stroke()
                            }
                        }

                        Text {
                            text: T.t("cc_reset", root.lang)
                            color: "#FFFFFF"
                            font.pixelSize: 15
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Focus glow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -3
                        radius: parent.radius + 3
                        color: "transparent"
                        border.color: "#8E2DE2"
                        border.width: 1.5
                        opacity: root.currentSliderIndex === 7 && root.isPanelNavigationActive ? 0.7 : 0
                        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            resetValues()
                            resetToDefaults()
                        }
                    }
                }

                // Apply button (D-pad index 8)
                Rectangle {
                    id: applyButton
                    width: 140
                    height: 44
                    radius: 22
                    color: "transparent"
                    border.color: root.currentSliderIndex === 8 && root.isPanelNavigationActive ? "#DDFFFFFF" : "#8E2DE2"
                    border.width: root.currentSliderIndex === 8 && root.isPanelNavigationActive ? 2 : 1.5

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Canvas {
                            width: 16; height: 16
                            anchors.verticalCenter: parent.verticalCenter
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width, h = height
                                ctx.strokeStyle = "#FFFFFF"
                                ctx.lineWidth = 2
                                ctx.lineCap = "round"
                                ctx.lineJoin = "round"
                                ctx.moveTo(w*0.2, h*0.5)
                                ctx.lineTo(w*0.42, h*0.75)
                                ctx.lineTo(w*0.8, h*0.25)
                                ctx.stroke()
                            }
                        }

                        Text {
                            text: T.t("cc_apply", root.lang)
                            color: "#FFFFFF"
                            font.pixelSize: 15
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Focus glow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -3
                        radius: parent.radius + 3
                        color: "transparent"
                        border.color: "#FFFFFF"
                        border.width: 1.5
                        opacity: root.currentSliderIndex === 8 && root.isPanelNavigationActive ? 0.7 : 0
                        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            closePanelAndSave()
                        }
                    }
                }
            }

            // Button Legend
            Rectangle { width: parent.width; height: 1; color: "#209B59B6" }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                // B button
                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 18; height: 18; radius: 9
                        color: "#20FFFFFF"; border.color: "#40FFFFFF"; border.width: 1
                        Text { anchors.centerIn: parent; text: "B"; color: "#AAAACC"; font.pixelSize: 10; font.bold: true }
                    }
                    Text { text: T.t("cc_apply_close", root.lang); color: "#8888AA"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                }

                // X button
                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 18; height: 18; radius: 9
                        color: "#20FFFFFF"; border.color: "#40FFFFFF"; border.width: 1
                        Text { anchors.centerIn: parent; text: "X"; color: "#AAAACC"; font.pixelSize: 10; font.bold: true }
                    }
                    Text { text: T.t("cc_reset", root.lang); color: "#8888AA"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                }

                // Y button
                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 18; height: 18; radius: 9
                        color: "#20FFFFFF"; border.color: "#40FFFFFF"; border.width: 1
                        Text { anchors.centerIn: parent; text: "Y"; color: "#AAAACC"; font.pixelSize: 10; font.bold: true }
                    }
                    Text { text: T.t("cc_reset_all", root.lang); color: "#8888AA"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }
    }

    Item {
        visible: isCustomizing
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 24
        anchors.bottomMargin: 20
        width: statusRow.width + 28
        height: 32

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: "#40000000"
            border.color: "#409B59B6"
            border.width: 1
        }

        Row {
            id: statusRow
            anchors.centerIn: parent
            spacing: 8

            Canvas {
                id: statusDot
                width: 12; height: 12
                anchors.verticalCenter: parent.verticalCenter
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width, h = height
                    ctx.fillStyle = blinkTimer.blink ? "#9B59B6" : "#5B3976"
                    ctx.beginPath()
                    ctx.arc(w/2, h/2, w*0.38, 0, Math.PI*2)
                    ctx.fill()
                }

                Timer {
                    id: blinkTimer
                    property bool blink: true
                    interval: 800
                    repeat: true
                    running: isCustomizing
                    onTriggered: { blink = !blink; statusDot.requestPaint() }
                }
            }

            Text {
                text: T.t("cc_customizing", root.lang)
                color: "#BBBBCC"
                font.pixelSize: 13
                font.letterSpacing: 0.5
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Timer {
        id: saveDebounceTimer
        interval: 500
        repeat: false
        onTriggered: {
            console.log("[CarouselCustomizer] Debounce timer triggered - saving settings")
            saveSettings()
        }
    }

    // PlatformConfigs.js is now the source of truth — no longer needed
    // to overwrite its values with saved Pegasus data

    Component.onDestruction: {
        saveSettings()
    }
}
