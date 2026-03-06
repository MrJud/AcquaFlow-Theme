import QtQuick 2.15
import ".."
import QtGraphicalEffects 1.15
import QtMultimedia 5.15
import "../../utils.js" as Utils

Item {
    id: background
    anchors.fill: parent

    property string currentPlatform: ""
    property string currentFanart: ""
    property bool isScrolling: false
    property bool loadingPaused: false
    property var coverFlowRef: null
    property var gameModel: null

    property string currentVideoSource: ""
    property bool showVideo: false
    property bool _initialized: false

    property real vignetteOpacity: 0.6
    property real videoVignetteOpacity: 0.75

    // Background settings (from api.memory)
    property bool settingsUseArtwork: true
    property bool settingsUseVideo: true
    property string settingsBgSource: "preset1"  // "preset1".."preset5" or "custom"
    property string settingsCustomPath: ""
    property int settingsBlurIntensity: 5  // 0 (min) .. 10 (max)

    // 5 Gradient presets (same as menu for visual consistency)
    readonly property var bgPresets: [
        { c0: "#040b14", c1: "#0b1a32", c2: "#0f2848", c3: "#081830", accent: "#5890d0" },
        { c0: "#0a0614", c1: "#140e24", c2: "#1e1440", c3: "#160c2e", accent: "#8868c0" },
        { c0: "#040c08", c1: "#081610", c2: "#0c2418", c3: "#061c10", accent: "#4a9868" },
        { c0: "#0c0804", c1: "#180e0a", c2: "#281810", c3: "#20140c", accent: "#c08850" },
        { c0: "#080c12", c1: "#0e141e", c2: "#161e2c", c3: "#101824", accent: "#7898b8" }
    ]

    // Reactive property (not a function) so QML tracks settingsBgSource dependency
    readonly property int _presetIdx: {
        if (settingsBgSource && settingsBgSource.indexOf("preset") === 0) {
            var n = parseInt(settingsBgSource.replace("preset", ""));
            if (n >= 1 && n <= 5) return n - 1;
        }
        return 0;
    }

    property color gradC0: bgPresets[_presetIdx].c0
    property color gradC1: bgPresets[_presetIdx].c1
    property color gradC2: bgPresets[_presetIdx].c2
    property color gradC3: bgPresets[_presetIdx].c3

    // Cover fallback colors (derived from current preset)
    property color coverFallback1: Qt.rgba(gradC1.r, gradC1.g, gradC1.b, 0.40)
    property color coverFallback2: Qt.rgba(gradC3.r, gradC3.g, gradC3.b, 0.33)

    property real fanartBlurRadius: 4 + settingsBlurIntensity * 7.6   // 4..80
    property real backgroundBlurRadius: Math.max(4, fanartBlurRadius * 0.67)
    property real videoBlurRadius: 10
    property int videoBlurSamples: 1 + Math.ceil(videoBlurRadius) * 2        // fixed ~21
    property real fanartBlurOpacity: 0.70
    property real backgroundBlurOpacity: 0.4
    property real videoBlurOpacity: 0.3
    property real fanartBlurScale: 1.04
    property real backgroundBlurScale: 1.05
    property real videoBlurScale: 1.01

    // true when a cover is zoomed-in / selected
    readonly property bool _coverSelected: coverFlowRef && coverFlowRef.isCoverSelected

    function pauseLoadingOperations() {
        loadingPaused = true;
        scrollStabilityTimer.stop();
        fanartDelayTimer.stop();
        fanartLoadTimer.stop();
        videoDelayTimer.stop();
        showVideo = false;
        if (backgroundVideo.playbackState === MediaPlayer.PlayingState) {
            backgroundVideo.stop();
        }
    }

    function resumeLoadingOperations() {
        loadingPaused = false;
        if (currentPlatform) {
            restorePlatformBackground();
        }
        if (settingsUseArtwork && gameModel && coverFlowRef) {
            loadCurrentGameFanart();
        }
    }

    Timer {
        id: scrollStabilityTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (loadingPaused) return;
            isScrolling = false;

            if (coverFlowRef && coverFlowRef.isCoverSelected) {
                loadCurrentGameFanart();
                videoDelayTimer.restart();
            } else {
                fanartDelayTimer.start();
            }
        }
    }

    Timer {
        id: fanartDelayTimer
        interval: 1200
        repeat: false
        onTriggered: {
            if (loadingPaused) return;
            if (!isScrolling) {
                fanartLoadTimer.start();
            }
        }
    }

    Timer {
        id: fanartLoadTimer
        interval: 300
        repeat: false
        onTriggered: {
            if (loadingPaused || isScrolling) return;
            loadCurrentGameFanart();
        }
    }

    Timer {
        id: videoDelayTimer
        interval: 2000
        repeat: false
        onTriggered: {
            if (loadingPaused) return;
            if (coverFlowRef && coverFlowRef.isCoverSelected) {
                if (currentFanart === "" && settingsUseArtwork) {
                    loadCurrentGameFanart();
                }
                if (settingsUseVideo) {
                    loadCurrentGameVideo();
                }
            }
        }
    }

    function loadCurrentGameFanart() {
        if (!settingsUseArtwork) {
            restorePlatformBackground();
            return;
        }
        if (!coverFlowRef || !gameModel) {
            restorePlatformBackground();
            return;
        }

        var currentIndex = coverFlowRef.currentIndex;
        var realTotalCovers = gameModel.count;

        if (realTotalCovers > 0 && currentIndex >= 0) {
            var realCurrentIndex = currentIndex % realTotalCovers;
            var currentGame = gameModel.get(realCurrentIndex);

            if (currentGame) {
                var fanart = Utils.getGameBackground(currentGame);
                if (fanart && fanart !== "") {
                    if (currentFanart !== fanart) {
                        currentFanart = fanart;
                        fanartContainer.crossfadeTo(fanart);
                    }
                } else {
                    restorePlatformBackground();
                }
            }
        } else {
            restorePlatformBackground();
        }
    }

    function loadCurrentGameVideo() {
        if (!settingsUseVideo) {
            showVideo = false;
            backgroundVideo.source = "";
            return;
        }
        if (!coverFlowRef || !gameModel) {
            return;
        }

        var currentIndex = coverFlowRef.currentIndex;
        var realTotalCovers = gameModel.count;

        if (realTotalCovers > 0 && currentIndex >= 0) {
            var realCurrentIndex = currentIndex % realTotalCovers;
            var currentGame = gameModel.get(realCurrentIndex);

            if (currentGame) {
                var videoSource = Utils.getGameVideo(currentGame);
                if (videoSource && videoSource !== "" && videoSource !== currentVideoSource) {
                    currentVideoSource = videoSource;
                    backgroundVideo.source = videoSource;
                    showVideo = true;
                } else if (videoSource === "" || videoSource === undefined) {
                    showVideo = false;
                    backgroundVideo.source = "";
                }
            }
        }
    }

    onGameModelChanged: {
        if (loadingPaused) return;
        scrollStabilityTimer.stop();
        fanartDelayTimer.stop();
        fanartLoadTimer.stop();

        // Load platform background immediately when model changes
        if (currentPlatform) {
            restorePlatformBackground();
        }

        // Then start timer to load game-specific fanart
        if (gameModel && coverFlowRef) {
            scrollStabilityTimer.start();
        }
    }

    function updateBackgroundFromGame(game) {
        if (!game || !settingsUseArtwork) return;
        var newFanart = Utils.getGameBackground(game);
        if (newFanart && newFanart !== "" && newFanart !== currentFanart) {
            currentFanart = newFanart;
            fanartContainer.crossfadeTo(newFanart);
        }
    }

    Connections {
        target: coverFlowRef
        function onCurrentIndexChanged() {
            if (coverFlowRef.isRefreshingPathView) return;

            isScrolling = true;
            scrollStabilityTimer.stop();
            fanartDelayTimer.stop();
            fanartLoadTimer.stop();
            videoDelayTimer.stop();
            showVideo = false;
            if (backgroundVideo.playbackState === MediaPlayer.PlayingState) {
                backgroundVideo.stop();
            }
            scrollStabilityTimer.start();
        }

        function onIsCoverSelectedChanged() {
            if (coverFlowRef.isCoverSelected) {
                if (settingsUseArtwork) loadCurrentGameFanart();
                if (settingsUseVideo) videoDelayTimer.start();
            } else {
                videoDelayTimer.stop();
                showVideo = false;
                if (backgroundVideo.playbackState === MediaPlayer.PlayingState) {
                    backgroundVideo.stop();
                }

                scrollStabilityTimer.stop();
                fanartDelayTimer.stop();
                fanartLoadTimer.stop();

                loadCurrentGameFanart();
            }
        }
    }

    function updatePlatform(platform) {
        if (loadingPaused) {
            currentPlatform = platform;
            return;
        }
        currentPlatform = platform;
        currentFanart = "";
        fanartContainer.clearAll();
        showVideo = false;
        if (backgroundVideo.playbackState === MediaPlayer.PlayingState) {
            backgroundVideo.stop();
        }
        restorePlatformBackground();
    }

    function restorePlatformBackground() {
        // Custom: show custom image as base layer
        if (settingsBgSource === "custom" && settingsCustomPath !== "") {
            backgroundImage.source = "file://" + settingsCustomPath;
            currentFanart = "";
            fanartContainer.clearAll();
            return;
        }
        // Preset: gradient is the base — never load platform BG images
        // Just clear everything; fanart will be loaded on top by loadCurrentGameFanart() if artwork is ON
        backgroundImage.source = "";
        currentFanart = "";
        fanartContainer.clearAll();
    }

    function refreshSettings(useArtwork, useVideo, bgSource, customPath, blurIntensity) {
        settingsUseArtwork = useArtwork;
        settingsUseVideo = useVideo;
        settingsBgSource = bgSource;
        settingsCustomPath = customPath;
        if (blurIntensity !== undefined)
            settingsBlurIntensity = blurIntensity;

        // Re-apply background based on new settings
        if (!useVideo) {
            showVideo = false;
            if (backgroundVideo.playbackState === MediaPlayer.PlayingState) {
                backgroundVideo.stop();
            }
            backgroundVideo.source = "";
        }

        if (!useArtwork) {
            currentFanart = "";
            fanartContainer.clearAll();
        }

        restorePlatformBackground();

        // Re-trigger artwork/video if appropriate
        if (useArtwork && coverFlowRef && gameModel) {
            loadCurrentGameFanart();
        }
        if (useVideo && coverFlowRef && coverFlowRef.isCoverSelected && gameModel) {
            videoDelayTimer.restart();
        }
    }

    function loadSettingsFromMemory() {
        var art = api.memory.get("bg_use_artwork");
        settingsUseArtwork = (art !== "false");
        var vid = api.memory.get("bg_use_video");
        settingsUseVideo = (vid !== "false");
        var src = api.memory.get("bg_source");
        if (src && (src.indexOf("preset") === 0 || src === "custom"))
            settingsBgSource = src;
        else
            settingsBgSource = "preset1";
        var cp = api.memory.get("bg_custom_path");
        settingsCustomPath = (cp && cp !== "") ? cp : "";
        var bi = parseInt(api.memory.get("bg_blur_intensity"));
        settingsBlurIntensity = (!isNaN(bi) && bi >= 0 && bi <= 10) ? bi : 5;
    }

    Component.onCompleted: loadSettingsFromMemory()

    // Ensure background is loaded at startup
    onCoverFlowRefChanged: {
        if (coverFlowRef && !_initialized && currentPlatform) {
            _initialized = true;
            restorePlatformBackground();
            if (gameModel) {
                scrollStabilityTimer.start();
            }
        }
    }

    // Gradient preset (same darker tones as menu for consistency)
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: background.gradC0 }
            GradientStop { position: 0.3; color: background.gradC1 }
            GradientStop { position: 0.7; color: background.gradC2 }
            GradientStop { position: 1.0; color: background.gradC3 }
        }
    }

    // Decorative wave ribbon 1
    Rectangle {
        width: parent.width * 2.4
        height: parent.height * 0.20
        x: -parent.width * 0.35
        y: parent.height * 0.28
        rotation: -7
        opacity: 0.05
        antialiasing: true
        gradient: Gradient {
            GradientStop { position: 0.0;  color: "transparent" }
            GradientStop { position: 0.35; color: "#ffffff" }
            GradientStop { position: 0.65; color: "#ffffff" }
            GradientStop { position: 1.0;  color: "transparent" }
        }
    }

    // Decorative wave ribbon 2
    Rectangle {
        width: parent.width * 2.1
        height: parent.height * 0.14
        x: -parent.width * 0.20
        y: parent.height * 0.37
        rotation: -4.5
        opacity: 0.03
        antialiasing: true
        gradient: Gradient {
            GradientStop { position: 0.0;  color: "transparent" }
            GradientStop { position: 0.35; color: background.bgPresets[background._presetIdx].accent }
            GradientStop { position: 0.65; color: background.bgPresets[background._presetIdx].accent }
            GradientStop { position: 1.0;  color: "transparent" }
        }
    }

    FastBlur {
        id: backgroundBlur
        anchors.fill: parent
        source: ShaderEffectSource {
            sourceItem: backgroundImage
            live: true
            smooth: true
            hideSource: background.settingsUseArtwork
            // Cap source texture to 960×540: blur does not need full resolution.
            // On 2K/4K this prevents 3.7 M-pixel framebuffers being processed on
            // every animated frame (radius/scale/opacity all have 600 ms Behaviors).
            textureSize: Qt.size(Math.min(background.width,  960),
                                 Math.min(background.height, 540))
        }
        radius: (parent.currentFanart === "" && backgroundImage.source != "" && parent.settingsUseArtwork && !parent._coverSelected) ? backgroundBlurRadius : 0
        transparentBorder: false
        cached: false
        opacity: (parent.currentFanart === "" && backgroundImage.source != "" && parent.settingsUseArtwork && !parent.loadingPaused) ? (parent._coverSelected ? 1.0 : backgroundBlurOpacity) : 0.0
        visible: opacity > 0
        scale: (parent.currentFanart === "" && parent.settingsUseArtwork && !parent._coverSelected) ? backgroundBlurScale : 1.0

        Behavior on radius {
            NumberAnimation { duration: 600; easing.type: Easing.InOutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 600; easing.type: Easing.InOutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 600; easing.type: Easing.InOutCubic }
        }
    }

    Image {
        id: backgroundImage
        objectName: "backgroundImage"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
        opacity: {
            if (loadingPaused) return 0;
            if (source == "") return 0;
            if (currentFanart === "") {
                return settingsUseArtwork ? 1.0 : backgroundBlurOpacity;
            }
            return 0;
        }
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation { duration: 800; easing.type: Easing.InOutQuad }
        }

        onStatusChanged: {
            if (status === Image.Error) {
                console.warn("Failed to load background image:", source);
            }
        }
    }

    FastBlur {
        id: fanartBlur
        anchors.fill: parent
        source: ShaderEffectSource {
            sourceItem: fanartVisualContainer
            live: true
            smooth: true
            hideSource: true
            // Same cap as backgroundBlur — reduces GPU load ~8× on 2K+ screens.
            textureSize: Qt.size(Math.min(background.width,  960),
                                 Math.min(background.height, 540))
        }
        radius: (parent.currentFanart !== "" && parent.settingsUseArtwork && !parent._coverSelected) ? fanartBlurRadius : 0
        transparentBorder: false
        cached: false
        opacity: (parent.currentFanart !== "" && parent.settingsUseArtwork && !parent.loadingPaused) ? (parent._coverSelected ? 1.0 : fanartBlurOpacity) : 0.0
        visible: opacity > 0
        z: 2
        scale: (parent.currentFanart !== "" && parent.settingsUseArtwork && !parent._coverSelected) ? fanartBlurScale : 1.0

        Behavior on radius {
            NumberAnimation { duration: 600; easing.type: Easing.InOutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 600; easing.type: Easing.InOutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 600; easing.type: Easing.InOutCubic }
        }
    }

    Item {
        id: fanartVisualContainer
        anchors.fill: parent
        z: 1

        Image {
            id: fanartImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            opacity: {
                if (loadingPaused) return 0;
                if (fanartContainer._slotAActive && source !== "") return 1.0;
                return 0;
            }
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }

            onStatusChanged: {
                if (status === Image.Ready && !fanartContainer._slotAActive) {
                    fanartContainer._slotAActive = true;
                    fanartClearOldTimer.targetSlot = "B";
                    fanartClearOldTimer.restart();
                } else if (status === Image.Error) {
                    console.warn("Failed to load fanart image A:", source);
                }
            }
        }

        Image {
            id: fanartImageB
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            opacity: {
                if (loadingPaused) return 0;
                if (!fanartContainer._slotAActive && source !== "") return 1.0;
                return 0;
            }
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }

            onStatusChanged: {
                if (status === Image.Ready && fanartContainer._slotAActive) {
                    fanartContainer._slotAActive = false;
                    fanartClearOldTimer.targetSlot = "A";
                    fanartClearOldTimer.restart();
                } else if (status === Image.Error) {
                    console.warn("Failed to load fanart image B:", source);
                }
            }
        }
    }

    // Helper container for crossfade state
    QtObject {
        id: fanartContainer
        property bool _slotAActive: true

        function crossfadeTo(url) {
            if (url === "") {
                clearAll();
                return;
            }
            // Load into the inactive slot; onStatusChanged triggers the flip
            if (_slotAActive) {
                fanartImageB.source = url;
            } else {
                fanartImage.source = url;
            }
        }

        function clearAll() {
            fanartImage.source = "";
            fanartImageB.source = "";
            _slotAActive = true;
        }
    }

    Timer {
        id: fanartClearOldTimer
        interval: 150
        property string targetSlot: ""
        onTriggered: {
            if (targetSlot === "A") fanartImage.source = "";
            else if (targetSlot === "B") fanartImageB.source = "";
        }
    }

    Video {
        id: backgroundVideo
        anchors.fill: parent
        visible: showVideo && source !== ""
        autoPlay: false
        loops: 1
        muted: true
        fillMode: VideoOutput.PreserveAspectCrop
        opacity: showVideo ? 1.0 : 0.0
        z: 3

        Behavior on opacity {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.InOutCubic
            }
        }

        onStatusChanged: {
            if (status === MediaPlayer.Loaded && showVideo) {
                play();
            } else if (status === MediaPlayer.Error) {
                console.warn("Failed to load video:", source);
                showVideo = false;
                source = "";
            }
        }

        onSourceChanged: {
            if (source === "") {
                showVideo = false;
            }
        }

        onStopped: {
            if (showVideo) {
                showVideo = false;
            }
        }
    }

    // Timer to check video end (replaces per-frame onPositionChanged)
    Timer {
        id: videoEndTimer
        interval: 500
        repeat: true
        running: backgroundVideo.playbackState === MediaPlayer.PlayingState && showVideo
        onTriggered: {
            if (backgroundVideo.duration > 0 && backgroundVideo.position >= (backgroundVideo.duration - 200)) {
                showVideo = false;
            }
        }
    }

    GaussianBlur {
        id: videoBlur
        anchors.fill: parent
        source: ShaderEffectSource {
            sourceItem: backgroundVideo
            live: true
            smooth: true
        }
        radius: (showVideo && backgroundVideo.source !== "") ? videoBlurRadius : 0
        samples: videoBlurSamples
        opacity: (showVideo && backgroundVideo.source !== "") ? videoBlurOpacity : 0.0
        visible: showVideo && backgroundVideo.source !== ""
        z: 4
        scale: (showVideo && backgroundVideo.source !== "") ? videoBlurScale : 1.0

        Behavior on radius {
            NumberAnimation { duration: 1000; easing.type: Easing.InOutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 1000; easing.type: Easing.InOutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 1000; easing.type: Easing.InOutCubic }
        }
    }

    Rectangle {
        id: darkOverlay
        anchors.fill: parent
        color: "#66000000"
        z: 5
        opacity: (settingsUseArtwork && coverFlowRef && coverFlowRef.isCoverSelected && !showVideo) ? 0.4 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.InOutCubic
            }
        }
    }

    Blend {
        id: videoOverlayBlend
        anchors.fill: parent
        z: 7
        visible: opacity > 0
        opacity: showVideo ? videoVignetteOpacity : 0.0

        source: ShaderEffectSource {
            sourceItem: {
                if (backgroundVideo.source !== "" && videoBlur.visible) {
                    return videoBlur;
                } else {
                    return backgroundVideo;
                }
            }
            live: true
        }

        foregroundSource: Image {
            anchors.fill: parent
            source: "../../assets/images/Background/VignetteVideo.png"
            fillMode: Image.Stretch
            smooth: true
        }

        mode: "multiply"

        Behavior on opacity {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.InOutCubic
            }
        }
    }

    Blend {
        id: vignetteOverlayBlend
        anchors.fill: parent
        z: 6
        visible: opacity > 0
        opacity: {
            if (!settingsUseArtwork) return 0;
            if (coverFlowRef && coverFlowRef.isCoverSelected && !showVideo) {
                return 0.5;
            }
            if (coverFlowRef && !coverFlowRef.isCoverSelected && !showVideo) {
                return vignetteOpacity;
            }
            return 0;
        }

        source: ShaderEffectSource {
            sourceItem: {
                if (currentFanart !== "" && fanartBlur.visible) {
                    return fanartBlur;
                } else if (backgroundImage.source !== "" && backgroundBlur.visible) {
                    return backgroundBlur;
                } else {
                    return backgroundImage;
                }
            }
            live: true
        }

        foregroundSource: Image {
            anchors.fill: parent
            source: "../../assets/images/Background/Vignette.png"
            fillMode: Image.Stretch
            smooth: true
        }

        mode: "overlay"

        Behavior on opacity {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.InOutCubic
            }
        }
    }

    Rectangle {
        id: bottomVignette
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height * 0.4
        z: 6
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.3; color: "#20000000" }
            GradientStop { position: 0.6; color: "#45000000" }
            GradientStop { position: 0.8; color: "#65000000" }
            GradientStop { position: 1.0; color: "#85000000" }
        }
        opacity: {
            if (currentFanart !== "") return fanartBlur.opacity;
            if (backgroundImage.source !== "") return settingsUseArtwork ? backgroundBlur.opacity : backgroundImage.opacity;
            return 0;
        }
    }

}
