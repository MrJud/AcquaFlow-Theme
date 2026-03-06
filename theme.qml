import QtQuick 2.15
import QtQuick.Window 2.15
import "components"
import "utils.js" as Utils
import "components/config/Translations.js" as T

FocusScope {
    id: theme
    width: 1920
    height: 1080
    focus: true

    // ── Screen size override ("auto" | "small" | "large") ──
    property string _screenSizeOverride: "auto"

    ScreenMetrics {
        id: screenMetrics
        sourceWidth:  theme.width
        sourceHeight: theme.height
        screenPixelDensity: Screen.pixelDensity
        screenSizeOverride: theme._screenSizeOverride
    }

    Component.onCompleted: {
        console.log("🚀 ========================================");
        console.log("🚀 THEME.QML LOADED!");
        console.log("🚀 theme.focus:", theme.focus);
        console.log("🚀 theme.activeFocus:", theme.activeFocus);
        console.log("🚀 ========================================");
        theme.forceActiveFocus();

        // Load UI indicator settings
        var sb = api.memory.get("ui_show_battery");
        _uiShowBattery = (sb === null || sb === undefined || sb === "") ? true : (sb === "true");
        var sw = api.memory.get("ui_show_wifi");
        _uiShowWifi = (sw === null || sw === undefined || sw === "") ? true : (sw === "true");

        // Load UI settings for PlatformBar (applied after platformBar is ready via _startupUi*)
        var ah = api.memory.get("platformbar_autohide");
        _startupUiAutoHide = (ah === "true");
        var ol = api.memory.get("ui_logo_outline");
        _startupUiOutline = (ol === null || ol === undefined || ol === "") ? true : (ol === "true");

        // Load language
        var lang = api.memory.get("ui_language");
        if (lang === "it") _lang = "it"; else _lang = "en";

        // Load screen size override
        var ss = api.memory.get("ui_screen_size");
        // Migrate old "xxlarge" value to new "xlarge"
        if (ss === "xxlarge") ss = "xlarge";
        _screenSizeOverride = (ss === "small" || ss === "medium" || ss === "large" || ss === "xlarge") ? ss : "auto";

        console.log("🖥️ ScreenMetrics: pixelDensity=" + Screen.pixelDensity.toFixed(2)
            + " override=" + _screenSizeOverride
            + " sizeLevel=" + screenMetrics.sizeLevel + " (isSmall=" + screenMetrics.isSmallScreen + ")"
            + " scale=" + screenMetrics.scaleRatio.toFixed(2)
            + " mult=" + screenMetrics.sizeMultiplier.toFixed(2));

        // Don't load view mode here!
        // Wait for first platform to load
        // Skip lastplayed, wait for next
        // loadLastViewMode();  // REMOVED
    }

    // Save current view mode
    function saveLastViewMode() {
        // SPECIAL PLATFORM GUARD: never save for lastplayed/favourites/search
        if (currentPlatform === "lastplayed" || currentPlatform === "favourites" || currentPlatform === "search") {
            console.log("[Theme] ⛔ Skipping save - special platform is isolated from global system");
            return;
        }

        if (typeof api !== "undefined" && api.memory) {
            try {
                api.memory.set("acquaflow_last_viewmode", viewMode);
                console.log("[Theme] Saved last view mode:", viewMode);

                // Also save platform-specific view mode
                if (coverFlow) {
                    coverFlow.saveCurrentViewMode();
                }
            } catch (e) {
                console.log("[Theme] Error saving view mode:", e);
            }
        }
    }

    // Load last used view mode
    function loadLastViewMode() {
        if (typeof api !== "undefined" && api.memory) {
            try {
                var savedViewMode = api.memory.get("acquaflow_last_viewmode");
                if (savedViewMode) {
                    console.log("[Theme] Loaded last view mode:", savedViewMode);
                    viewMode = savedViewMode;
                } else {
                    console.log("[Theme] No saved view mode found, using default: carousel1");
                }
            } catch (e) {
                console.log("[Theme] Error loading view mode:", e);
            }
        }
    }

    property string currentPlatform: ""
    property var currentCollection: null

    property string viewMode: "carousel1"  // "carousel1", "carousel2", "carousel3", "carousel4"
    property string previousViewMode: "carousel1"  // Track previous mode
    property bool initialViewModeLoaded: false  // Flag: initial view loaded
    property int _preRaPlatformIndex: 1  // Platform index before RA Hub
    property string _preSearchViewMode: ""  // Stores view mode before search results
    property bool _isSearchMode: false
    property string _searchQueryText: ""
    property var _preSearchCollection: null  // Stores collection before search results
    property string _preSearchPlatform: ""  // Stores platform before search results
    property int _preSearchPlatformIndex: -1  // Stores platform bar index before search
    property bool _selectHoldFired: false  // DEPRECATED - kept for compatibility

    // UI indicator settings
    property bool _uiShowBattery: true
    property bool _uiShowWifi: true
    property bool _startupUiAutoHide: false
    property bool _startupUiOutline: true

    // Language
    property string _lang: "en"

    // L1+R1 combo tracking for theme.qml Keys.onPressed (when InputHandler is disabled)
    property bool _l1PressedCombo: false
    property bool _r1PressedCombo: false
    property int _pendingShoulderDir: 0  // -1=L1 (prev), +1=R1 (next), 0=none

    Timer {
        id: _l1r1ComboTimer
        interval: 150  // combo detection window (ms)
        repeat: false
        onTriggered: {
            // Combo window expired — execute pending single-button scroll
            if (theme._l1PressedCombo && !theme._r1PressedCombo && theme._pendingShoulderDir === -1) {
                // Only L1 was pressed → scroll prev cover
                if (coverFlow && coverFlow.isCoverSelected) {
                    coverFlow.scrollPrevCoverInSelectedMode();
                    _raLookupDebounce.restart();  // trigger RA lookup for new game
                }
            } else if (theme._r1PressedCombo && !theme._l1PressedCombo && theme._pendingShoulderDir === 1) {
                // Only R1 was pressed → scroll next cover
                if (coverFlow && coverFlow.isCoverSelected) {
                    coverFlow.scrollNextCoverInSelectedMode();
                    _raLookupDebounce.restart();  // trigger RA lookup for new game
                }
            }
            theme._l1PressedCombo = false;
            theme._r1PressedCombo = false;
            theme._pendingShoulderDir = 0;
        }
    }

    // L2/R2 zoom system for Android analog triggers.
    // First pull quirk: sends key=0 PRESS (instant) then phantom RELEASE with correct code (on release).
    // Solution: key=0 → start zoom immediately (default: zoomIn).
    // Phantom RELEASE = user released trigger → stop zoom.
    // Second+ pulls: normal PRESS/RELEASE with correct key codes.
    property bool _firstPullZoom: false  // zoom started from key=0 (first pull)
    property bool _l2Confirmed: false  // real L2 PRESS received (second+ pull)
    property bool _r2Confirmed: false  // real R2 PRESS received (second+ pull)

    // Watchdog: auto-stop if stuck (safety net)
    Timer { id: l2Watchdog; interval: 3000; onTriggered: { isZoomingOut = false; _l2Confirmed = false; _firstPullZoom = false; } }
    Timer { id: r2Watchdog; interval: 3000; onTriggered: { isZoomingIn = false; _r2Confirmed = false; _firstPullZoom = false; } }
    // Cooldown: ignore duplicate releases after zoom stops
    Timer { id: l2CooldownTimer; interval: 500 }
    Timer { id: r2CooldownTimer; interval: 500 }

    // Legacy compatibility property (deprecata)
    property bool gridViewMode: viewMode === "carousel2"

    // ViewMode change handling
    onViewModeChanged: {
        console.log("theme.qml: ViewMode changed from", previousViewMode, "to", viewMode)

        // SPECIAL PLATFORM GUARD: always force carousel1 for lastplayed/favourites/search
        if (currentPlatform === "lastplayed" || currentPlatform === "favourites" || currentPlatform === "search") {
            if (viewMode !== "carousel1") {
                // Defer to avoid re-entrant property modification
                Qt.callLater(function() { viewMode = "carousel1" })
                return
            }
            // viewMode IS carousel1 - fall through to enter/exit carousel logic below
            // saveLastViewMode() will skip for these platforms (has its own guard)
        }

        saveLastViewMode()

        // Removing them avoids spurious reloadPathConfig()

        // Enter new mode
        if (viewMode === "carousel1" && coverFlow) {
            console.log("theme.qml: Entering Carousel 1")
            coverFlow.enterCarousel1()
        } else if (viewMode === "carousel2" && coverFlow) {
            console.log("theme.qml: Entering Carousel 2")
            coverFlow.enterCarousel2()
        } else if (viewMode === "carousel3" && coverFlow) {
            console.log("theme.qml: Entering Carousel 3")
            coverFlow.enterCarousel3()
        } else if (viewMode === "carousel4" && coverFlow) {
            console.log("theme.qml: Entering Carousel 4")
            coverFlow.enterCarousel4()
        }

        previousViewMode = viewMode
    }

    // Rotation control properties with physics
    property int rotationAxisX: 0  // -1 = down, 0 = none, 1 = up
    property int rotationAxisY: 0  // -1 = left, 0 = none, 1 = right
    property real baseRotationSpeed: 4  // Base speed (immediate response)
    property real rotationVelocityX: 0  // Current velocity for X axis
    property real rotationVelocityY: 0  // Current velocity for Y axis
    property real rotationAcceleration: 1.2  // How fast velocity builds up (increased for faster response)
    property real rotationDamping: 0.85  // Friction/damping when released (lower = more slide)
    property real maxRotationVelocity: 18  // Maximum velocity cap

    // Zoom control properties with inertia
    property bool isZoomingIn: false  // R2 held down
    property bool isZoomingOut: false  // L2 held down
    property real zoomVelocity: 0.0  // Current zoom velocity for inertia
    property real zoomAcceleration: 0.008
    property real zoomDamping: 0.88
    property real maxZoomVelocity: 0.06

    // Timer for continuous zoom with inertia
    Timer {
        id: zoomRepeatTimer
        interval: 16
        repeat: true
        running: (isZoomingIn || isZoomingOut || Math.abs(zoomVelocity) > 0.001) && coverFlow && coverFlow.isCoverSelected

        onTriggered: {
            if (coverFlow && coverFlow.isCoverSelected) {
                var hasInput = isZoomingIn || isZoomingOut;

                if (hasInput) {
                    // Build up velocity when button is held
                    if (isZoomingIn) {
                        zoomVelocity += zoomAcceleration;
                        zoomVelocity = Math.min(zoomVelocity, maxZoomVelocity);
                    } else if (isZoomingOut) {
                        zoomVelocity -= zoomAcceleration;
                        zoomVelocity = Math.max(zoomVelocity, -maxZoomVelocity);
                    }
                } else {
                    // Apply damping when no input (inertia/slide effect)
                    zoomVelocity *= zoomDamping;
                    if (Math.abs(zoomVelocity) < 0.001) zoomVelocity = 0;
                }

                // Apply velocity to zoom
                if (Math.abs(zoomVelocity) > 0.001) {
                    if (zoomVelocity > 0) {
                        coverFlow.zoomInSelectedCoverSmooth(zoomVelocity);
                    } else {
                        coverFlow.zoomOutSelectedCoverSmooth(Math.abs(zoomVelocity));
                    }
                }
            } else {
                // Reset velocity if cover is not selected
                zoomVelocity = 0;
            }
        }
    }

    // Timer for smooth continuous rotation with inertia
    Timer {
        id: rotationRepeatTimer
        interval: 16  // 60fps for ultra-smooth rotation
        repeat: true
        running: (rotationAxisX !== 0 || rotationAxisY !== 0 || Math.abs(rotationVelocityX) > 0.05 || Math.abs(rotationVelocityY) > 0.05)

        onTriggered: {
            var hasInput = (rotationAxisX !== 0 || rotationAxisY !== 0) &&
                          coverFlow.gameActionPanelRef &&
                          coverFlow.gameActionPanelRef.visible;

            // Update X axis velocity and position
            if (rotationAxisX !== 0 && hasInput) {
                // Constant speed - no acceleration, instant response
                rotationVelocityX = rotationAxisX * baseRotationSpeed;
            } else {
                // Apply damping when no input (inertia/slide effect)
                rotationVelocityX *= rotationDamping;
                if (Math.abs(rotationVelocityX) < 0.05) rotationVelocityX = 0;
            }

            // Update Y axis velocity and position
            if (rotationAxisY !== 0 && hasInput) {
                // Constant speed - no acceleration, instant response
                rotationVelocityY = rotationAxisY * baseRotationSpeed;
            } else {
                // Apply damping when no input (inertia/slide effect)
                rotationVelocityY *= rotationDamping;
                if (Math.abs(rotationVelocityY) < 0.05) rotationVelocityY = 0;
            }

            // Apply velocity to rotation angles with bounce at limits
            // Note: CoverItem applies asymmetric limits internally
            if (rotationVelocityX !== 0) {
                var newAngleX = coverFlow.rotationAngleX + rotationVelocityX;

                // Asymmetric bounce effect matching CoverItem limits
                var maxLimitX = (newAngleX >= 0) ? 30 * 0.6 : 30 * 0.2;  // 18° or 6°
                var minLimitX = (newAngleX >= 0) ? -30 * 0.2 : -30 * 1.5;  // -6° or -45°

                if (newAngleX > maxLimitX) {
                    newAngleX = maxLimitX;
                    rotationVelocityX *= -0.5;  // Bounce back with 50% energy (reduced bounce)
                } else if (newAngleX < minLimitX) {
                    newAngleX = minLimitX;
                    rotationVelocityX *= -0.5;
                }

                coverFlow.rotationAngleX = newAngleX;
            }

            if (rotationVelocityY !== 0) {
                var newAngleY = coverFlow.rotationAngleY + rotationVelocityY;

                // Asymmetric bounce effect matching CoverItem limits
                var maxLimitY = (newAngleY >= 0) ? 45 * 0.6 : 45 * 0.2;  // 27° or 9°
                var minLimitY = (newAngleY >= 0) ? -45 * 0.2 : -45 * 1.5;  // -9° or -67.5°

                if (newAngleY > maxLimitY) {
                    newAngleY = maxLimitY;
                    rotationVelocityY *= -0.5;  // Bounce back with 50% energy (reduced bounce)
                } else if (newAngleY < minLimitY) {
                    newAngleY = minLimitY;
                    rotationVelocityY *= -0.5;
                }

                coverFlow.rotationAngleY = newAngleY;
            }
        }
    }

    // Select hold timer removed — no longer needed

    // Root-level MenuManager for global overlay
    MenuManager {
        id: menuManager
        anchors.fill: parent
        z: 9999
        collections: api.collections
        gcGameCount: platformBar.gameCubeGames ? platformBar.gameCubeGames.length : 0
        lang: theme._lang

        onThemeNavigationEnabled: {
            // inputEnabled binding on InputHandler already reacts to menuManager.menuOpen
            // Restore focus to the correct element when menu closes
            if (enabled) {
                if (raHub.hubOpen) {
                    raHub.forceActiveFocus();
                } else {
                    inputHandler.forceActiveFocus();
                }
            }
        }

        onRaHubRequested: {
            theme._preRaPlatformIndex = platformBar.currentIndex;
            if (platformBar.raVisible) {
                platformBar.goToRaPlatform();
            } else {
                raHub.open();
            }
        }

        Connections {
            target: menuManager
            function onPlatformSelected(platformShortName) {
                console.log("theme.qml: onPlatformSelected called with:", platformShortName);

                if (platformBar) {
                    var totalCount = platformBar.getTotalCount();

                    for (var i = 0; i < totalCount; i++) {
                        var collection = platformBar.getCollectionAt(i);
                        if (collection && collection.shortName.toLowerCase() === platformShortName.toLowerCase()) {
                            console.log("theme.qml: Trovata piattaforma", platformShortName, "at index", i);
                            platformBar.currentIndex = i;
                            break;
                        }
                    }
                }
            }
            function onPlatformOrderChanged(orderArray, lpVisible, raVis, favVis) {
                if (platformBar) {
                    platformBar.applyNewOrder(orderArray, lpVisible, raVis, favVis);
                }
            }
            function onBgSettingsApplied(useArtwork, useVideo, bgSource, customPath, blurIntensity) {
                console.log("theme.qml: BG settings applied. Artwork:", useArtwork, "Video:", useVideo, "Source:", bgSource, "Blur:", blurIntensity);
                if (background) {
                    background.refreshSettings(useArtwork, useVideo, bgSource, customPath, blurIntensity);
                }
            }
            function onClockSettingsApplied(use24h, fontIndex, colorIndex) {
                console.log("theme.qml: Clock settings applied. 24h:", use24h, "Font:", fontIndex, "Color:", colorIndex);
                if (currentTimeDisplay) {
                    currentTimeDisplay.settingsVersion++;
                }
            }
            function onLanguageSettingsApplied(lang) {
                console.log("theme.qml: Language changed to:", lang);
                theme._lang = lang;
            }
            function onUiSettingsApplied(platformBarAutoHide, showLogoOutline, showBattery, showWifi, screenSizeMode) {
                console.log("theme.qml: UI settings applied. AutoHide:", platformBarAutoHide, "Outline:", showLogoOutline, "Battery:", showBattery, "WiFi:", showWifi, "ScreenSize:", screenSizeMode);
                theme._uiShowBattery = showBattery;
                theme._uiShowWifi = showWifi;
                theme._screenSizeOverride = screenSizeMode;
                if (platformBar) {
                    platformBar.autoHideEnabled = platformBarAutoHide;
                    platformBar.logoOutlineEnabled = showLogoOutline;
                    if (platformBarAutoHide) {
                        platformBar.showBar();  // restart timer
                    } else {
                        platformBar._barHidden = false;
                    }
                }
            }
            function onBoxbackPathChanged() {
                console.log("theme.qml: BoxBack path changed, refreshing covers");
                if (coverFlow) {
                    coverFlow.boxbackVersion++;
                }
            }
        }
    }

    NavigationManager {
        id: navigationManager
        navigationEnabled: !menuManager.menuOpen && inputHandler.inputEnabled
        coverSelected: coverFlow.isCoverSelected

        onLevelChanged: {
            // Update InputHandler when navigation level changes
            inputHandler.isTopBarNavigation = navigationManager.atTopBar

            if (navigationManager.atCarousel) {
                if (coverFlow) {
                    coverFlow.resetTopBarFocus()
                }
            }
        }

        onTopBarFocusChanged: {
            if (coverFlow) {
                coverFlow.updateTopBarFocus(newIndex)
            }
        }

        onTopBarButtonActivated: {
            if (coverFlow) {
                coverFlow.activateTopBarButton(buttonIndex)
            }
        }
    }

    // Debounce timer for RA lookup during rapid L1/R1 cover scrolling.
    // Prevents piling up fuzzy match CPU work + network calls on every scroll step.
    Timer {
        id: _raLookupDebounce
        interval: 350
        repeat: false
        onTriggered: _triggerRaLookup()
    }

    // Helper: trigger RA lookup for the currently selected cover
    // Uses raHub.raService which has caching, local fuzzy match, and API fallback
    function _triggerRaLookup() {
        if (!coverFlow || !raHub || !raHub.raService) return;
        var svc = raHub.raService;
        if (!svc.isLoggedIn) {
            svc.loadCredentials();
            if (!svc.isLoggedIn) {
                console.log("[RA-theme] credentials not set, skipping lookup");
                return;
            }
        }
        var g = coverFlow.current();
        if (g && g.title) {
            // Clear stale data from previous game immediately.
            // Prevents showing old game's RA panel while the new lookup runs.
            svc.gameDetail = null;
            svc.gameAchievements = [];
            console.log("[RA-theme] lookupPegasusGame for:", g.title, "platform:", theme.currentPlatform);
            svc.lookupPegasusGame(g.title, theme.currentPlatform, function(gameId) {
                if (gameId > 0) {
                    console.log("[RA-theme] matched gameId:", gameId, "→ fetching detail");
                    svc.fetchGameDetail(gameId);
                } else {
                    console.log("[RA-theme] no RA match for:", g.title);
                    // gameDetail already cleared above — panel shows "—"
                }
            });
        } else {
            console.log("[RA-theme] _triggerRaLookup: no game or no title");
        }
    }

    // RetroAchievements Hub (RA platform at index 0)
    RetroAchievementsHub {
        id: raHub
        anchors.fill: parent
        z: 9998  // Below menu (9999) but above everything else
        lang: theme._lang
        backgroundRef: background

        onHubClosed: {
            // Return to the platform the user was on before entering RA
            platformBar.currentIndex = theme._preRaPlatformIndex;
            navigationManager.reset();  // force TopBar → Carousel
            inputHandler.forceActiveFocus();
        }

        onSettingsRequested: {
            menuManager.openMenu();
        }

        onLaunchGameRequested: {
            // Find the Pegasus collection by RA console name
            var shortName = "";

            // Manual mapping from RA console name to Pegasus shortName
            var consoleMap = {
                "Mega Drive/Genesis": "megadrive", "SNES/Super Famicom": "snes",
                "Game Boy": "gb", "Game Boy Advance": "gba", "Game Boy Color": "gbc",
                "NES/Famicom": "nes", "Nintendo 64": "n64", "Nintendo DS": "nds",
                "Nintendo DSi": "nds", "Nintendo 3DS": "3ds",
                "PlayStation": "psx", "PlayStation 2": "ps2", "PlayStation Portable": "psp",
                "PlayStation Vita": "vita", "GameCube": "gc", "Wii": "wii",
                "Nintendo Switch": "switch", "Dreamcast": "dreamcast",
                "Saturn": "saturn", "Sega 32X": "sega32x", "Sega CD": "segacd",
                "Master System": "mastersystem", "Game Gear": "gamegear",
                "Atari 2600": "atari2600", "Atari 7800": "atari7800",
                "PC Engine/TurboGrafx-16": "pcengine", "Neo Geo Pocket": "ngp",
                "WonderSwan": "wonderswan", "Arcade": "arcade",
                "MSX": "msx", "PC-8000/8800": "pc88",
                "SG-1000": "sg1000", "ColecoVision": "coleco",
                "Intellivision": "intellivision", "Vectrex": "vectrex",
                "Neo Geo CD": "neogeocd", "PC Engine CD/TurboGrafx-CD": "pcenginecd",
                "Amstrad CPC": "amstradcpc", "Apple II": "apple2",
                "Atari Lynx": "atarilynx", "Virtual Boy": "virtualboy"
            };
            shortName = consoleMap[consoleName] || consoleName.toLowerCase().replace(/[^a-z0-9]/g, "");

            // Search api.collections for matching collection
            var targetCollection = null;
            for (var i = 0; i < api.collections.count; i++) {
                var col = api.collections.get(i);
                if (col.shortName === shortName) {
                    targetCollection = col;
                    break;
                }
            }

            if (targetCollection) {
                // Build candidate list from Pegasus collection
                var candidates = [];
                for (var g = 0; g < targetCollection.games.count; g++) {
                    candidates.push({ title: targetCollection.games.get(g).title, index: g });
                }

                // Use fuzzy matching to find best match
                var result = Utils.fuzzyMatchGame(gameTitle, candidates);
                if (result && result.match) {
                    var matchedGame = targetCollection.games.get(result.match.index);
                    console.log("RA Hub: Fuzzy match '" + gameTitle + "' → '" + matchedGame.title + "' (score: " + result.score.toFixed(2) + ")");
                    matchedGame.launch();
                } else {
                    console.log("RA Hub: Game '" + gameTitle + "' not found in collection " + shortName + " (no fuzzy match)");
                }
            } else {
                console.log("RA Hub: Collection '" + shortName + "' (from '" + consoleName + "') not found");
            }
        }
    }

    // Pre-fetch RA completion data at startup (after a short delay)
    // so allUserGames is populated for faster local matching when covers are selected
    Timer {
        id: raPreFetchTimer
        interval: 3000  // 3 seconds after theme load
        running: true
        repeat: false
        onTriggered: {
            if (raHub && raHub.raService) {
                var svc = raHub.raService;
                svc.loadCredentials();
                if (svc.isLoggedIn) {
                    console.log("[RA-theme] Pre-fetching completion data for local matching...");
                    svc.fetchCompletionProgress(false);  // false = use cache if available
                    svc.fetchRecentlyPlayedGames();
                } else {
                    console.log("[RA-theme] No RA credentials, skipping pre-fetch");
                }
            }
        }
    }

    Component.onDestruction: {
        // Save customizer settings on app exit
        if (coverFlow && coverFlow.carouselCustomizer) {
            coverFlow.carouselCustomizer.saveAllPlatformSettings();
        }
    }

    // Functions for platform navigation
    function changeToPrevPlatform() {
        platformBar.previousPlatform();
    }

    function changeToNextPlatform() {
        platformBar.nextPlatform();
    }

    function initializeWithPlatform(platformName) {
        console.log("theme.qml: initializeWithPlatform() called with:", platformName);

        if (platformBar) {
            var totalCount = platformBar.getTotalCount();

            for (var i = 0; i < totalCount; i++) {
                var collection = platformBar.getCollectionAt(i);
                if (collection && collection.shortName.toLowerCase() === platformName.toLowerCase()) {
                    currentCollection = collection;
                    currentPlatform = collection.shortName;
                    platformBar.currentIndex = i;

                    console.log("theme.qml: Trovata piattaforma:", platformName, "at index:", i);

                    if (background) {
                        background.updatePlatform(currentPlatform);
                        background.currentPlatform = currentPlatform;
                        background.gameModel = collection.games;
                    }

                    return;
                }
            }
        }

        // Fallback to API collections
        if (api.collections.count > 0) {
            console.log("theme.qml: Piattaforma non trovata in PlatformBar, cercando in api.collections");
            for (var i = 0; i < api.collections.count; i++) {
                var collection = api.collections.get(i);
                if (collection.shortName.toLowerCase() === platformName.toLowerCase()) {
                    currentCollection = collection;
                    currentPlatform = collection.shortName;

                    if (background) {
                        background.updatePlatform(currentPlatform);
                        background.currentPlatform = currentPlatform;
                        background.gameModel = collection.games;
                    }

                    return;
                }
            }

            // If platform not found, use first available
            console.log("theme.qml: Piattaforma non trovata, usando initializeThemeData()");
            initializeThemeData();
        }
    }

    // Global input handler
    InputHandler {
        id: inputHandler
        anchors.fill: parent
        // Disable InputHandler during loading, waiting for user input, menu open, or when GameCard is visible
        inputEnabled: !themeLoader.active && !menuManager.menuOpen && !raHub.hubOpen && (!coverFlow.gameActionPanelRef || !coverFlow.gameActionPanelRef.visible)

        // Track GameCard visibility for X/Y button handling
        gameCardVisible: coverFlow.gameActionPanelRef ? coverFlow.gameActionPanelRef.visible : false

        coverSelected: coverFlow.isCoverSelected

        isSearchBarOpen: coverFlow.searchButton ? coverFlow.searchButton.isOpen : false

        inputRepeatInitialDelay: coverFlow.inputInitialDelay
        inputRepeatInterval: coverFlow.calculatedScrollRepeatInterval

        onCoverLeft:  coverFlow.movePrev()
        onCoverRight: coverFlow.moveNext()
        onLeftNav:    coverFlow.movePrev()
        onRightNav:   coverFlow.moveNext()

        onPlatformPrev:   { if (coverFlow.carouselCustomizer.isPanelNavigationActive) return; console.log("theme.qml: InputHandler onPlatformPrev signal received. Calling changeToPrevPlatform()."); changeToPrevPlatform(); }
        onPlatformNext:   { if (coverFlow.carouselCustomizer.isPanelNavigationActive) return; console.log("theme.qml: InputHandler onPlatformNext signal received. Calling changeToNextPlatform()."); changeToNextPlatform(); }

        // TopBar navigation signals
        onTopBarEnter: {
            console.log("theme.qml: InputHandler onTopBarEnter signal received.");
            navigationManager.navigateToTopBar();
        }

        onTopBarExit: {
            console.log("theme.qml: InputHandler onTopBarExit signal received.");
            navigationManager.navigateToCarousel();
        }

        onTopBarNavigateLeft: {
            console.log("theme.qml: InputHandler onTopBarNavigateLeft signal received.");
            navigationManager.navigateLeft();
        }

        onTopBarNavigateRight: {
            console.log("theme.qml: InputHandler onTopBarNavigateRight signal received.");
            navigationManager.navigateRight();
        }

        onTopBarActivate: {
            console.log("theme.qml: InputHandler onTopBarActivate signal received.");
            navigationManager.activateCurrentButton();
        }

        // Customizer panel navigation signals
        onCustomizerSliderUp: {
            console.log("theme.qml: InputHandler onCustomizerSliderUp signal received.");
            if (coverFlow.carouselCustomizer) {
                coverFlow.carouselCustomizer.navigateSliderUp();
            }
        }

        onCustomizerSliderDown: {
            console.log("theme.qml: InputHandler onCustomizerSliderDown signal received.");
            if (coverFlow.carouselCustomizer) {
                coverFlow.carouselCustomizer.navigateSliderDown();
            }
        }

        onCustomizerAdjustLeft: {
            console.log("theme.qml: InputHandler onCustomizerAdjustLeft signal received.");
            if (coverFlow.carouselCustomizer) {
                coverFlow.carouselCustomizer.adjustCurrentSlider(-coverFlow.carouselCustomizer.sliderAdjustmentStep);
            }
        }

        onCustomizerAdjustRight: {
            console.log("theme.qml: InputHandler onCustomizerAdjustRight signal received.");
            if (coverFlow.carouselCustomizer) {
                coverFlow.carouselCustomizer.adjustCurrentSlider(coverFlow.carouselCustomizer.sliderAdjustmentStep);
            }
        }

        onCustomizerClose: {
            console.log("theme.qml: InputHandler onCustomizerClose signal received.");
            if (coverFlow.carouselCustomizer) {
                coverFlow.carouselCustomizer.closePanelAndSave();
                inputHandler.isCustomizerPanelActive = false;
            }
        }

        onCustomizerReset: {
            console.log("theme.qml: InputHandler onCustomizerReset signal received.");
            if (coverFlow.carouselCustomizer) {
                coverFlow.carouselCustomizer.resetValues();
                console.log("theme.qml: All customizer sliders reset to default values.");
            }
        }

        onCustomizerResetCurrent: {
            console.log("theme.qml: InputHandler onCustomizerResetCurrent signal received.");
            if (coverFlow.carouselCustomizer) {
                coverFlow.carouselCustomizer.resetCurrentSlider();
            }
        }

        onCustomizerConfirm: {
            console.log("theme.qml: InputHandler onCustomizerConfirm signal received.");
            if (coverFlow.carouselCustomizer) {
                coverFlow.carouselCustomizer.confirmCurrentButton();
                // If Apply was pressed (index 7), deactivate the customizer panel
                if (coverFlow.carouselCustomizer.currentSliderIndex === 7 || !coverFlow.carouselCustomizer.isPanelNavigationActive) {
                    inputHandler.isCustomizerPanelActive = false;
                }
            }
        }

        onSelectCover: {
            console.log("theme.qml: InputHandler onSelectCover signal received.");

            // Prevent auto-repeat A from selecting a cover right after search
            if (coverFlow.searchButton && coverFlow.searchButton._selectGuard) {
                console.log("theme.qml: selectCover blocked by search guard timer");
                return;
            }

            if (!coverFlow.isCoverSelected) {
                if (coverFlow.currentIndex !== -1) {
                    coverFlow.selectedCoverIndex = coverFlow.currentIndex;
                    Qt.callLater(function() {
                        coverFlow.showActionPanelForCurrentGame();
                    });
                    // Trigger RA lookup for the newly selected cover
                    Qt.callLater(_triggerRaLookup);
                }
            } else if (coverFlow.gameActionPanelRef && coverFlow.gameActionPanelRef.visible) {
                coverFlow.gameActionPanelRef.playClicked(coverFlow.current());
            }
        }

        onDeselectCover: {
            if (coverFlow.isCoverSelected) {
                coverFlow.selectedCoverIndex = -1;
            } else if (coverFlow.searchButton && coverFlow.searchButton.searchActive) {
                coverFlow.searchButton.exitSearch();
            } else if (menuManager && menuManager.menuOpen) {
                menuManager.closeMenu();
            }
        }

        onShowInfo: {
            console.log("theme.qml: InputHandler onShowInfo signal received.");
            // X button should only work when cover is selected
            if (coverFlow.isCoverSelected && coverFlow.gameActionPanelRef) {
                console.log("theme.qml: Setting focus to info/details button and toggling description.");
                // Set focus to the details button (currentButton = 1)
                coverFlow.gameActionPanelRef.currentButton = 1;
                // Toggle description (same as pressing Enter on the details button)
                coverFlow.gameActionPanelRef.showDescription = !coverFlow.gameActionPanelRef.showDescription;
                // Trigger the detailsClicked signal
                coverFlow.gameActionPanelRef.detailsClicked(coverFlow.gameActionPanelRef.game);
            } else {
                console.log("theme.qml: X pressed but cover not selected or panel not available. Ignoring.");
            }
        }

        onDetails:    {
            // Show action panel for current game in CoverFlow
            coverFlow.showActionPanelForCurrentGame();
        }
        onFilter:     {

        }

        onJumpNextLetter: {
            if (coverFlow) {
                coverFlow.jumpToNextLetter();
            }
        }

        onJumpPrevLetter: {
            if (coverFlow) {
                coverFlow.jumpToPrevLetter();
            }
        }

        // Cover scrolling in selected mode (R1/L1)
        onScrollNextCoverSelected: {
            console.log("theme.qml: InputHandler onScrollNextCoverSelected signal received (R1 in selected mode).");
            if (coverFlow && coverFlow.isCoverSelected && (!gridViewMode || theme._isSearchMode)) {
                coverFlow.scrollNextCoverInSelectedMode();
                _raLookupDebounce.restart();  // debounced — skip intermediate covers
            }
        }

        onScrollPrevCoverSelected: {
            console.log("theme.qml: InputHandler onScrollPrevCoverSelected signal received (L1 in selected mode).");
            if (coverFlow && coverFlow.isCoverSelected && (!gridViewMode || theme._isSearchMode)) {
                coverFlow.scrollPrevCoverInSelectedMode();
                _raLookupDebounce.restart();  // debounced — skip intermediate covers
            }
        }

        // L1+R1 combo in selected mode → open RA Hub game detail page
        onOpenRaGameDetail: {
            console.log("[RA-theme] L1+R1 combo → opening RA game detail");
            if (!raHub || !raHub.raService) return;
            var svc = raHub.raService;
            var detail = svc.gameDetail;
            if (detail && detail.gameId && detail.gameId > 0) {
                // Open hub and force-refresh game detail for latest data
                theme._preRaPlatformIndex = platformBar.currentIndex;
                raHub.open();
                raHub.openGameDetail({
                    gameId: detail.gameId,
                    title: detail.title || "",
                    consoleName: detail.consoleName || "",
                    imageIcon: detail.imageIcon || "",
                    numAwarded: detail.numAwarded || 0,
                    numAchievements: detail.numAchievements || 0,
                    completionPct: detail.numAchievements > 0 ? Math.round((detail.numAwarded / detail.numAchievements) * 100) : 0
                });
                // openGameDetail now calls fetchGameDetail with forceRefresh=true internally
            } else {
                // No RA data — open as Pegasus-only game
                var game = coverFlow.current();
                if (game) {
                    var platTag = theme.currentCollection ? (theme.currentCollection.shortName || theme.currentCollection.name || "") : "";
                    theme._preRaPlatformIndex = platformBar.currentIndex;
                    raHub.open();
                    raHub.openGameDetail({
                        gameId: 0,
                        title: game.title || "",
                        platform: platTag,
                        imageIcon: game.assets.boxFront || game.assets.screenshot || "",
                        earned: 0,
                        total: 0,
                        progress: 0,
                        isPegasus: true,
                        pegasusGame: game
                    });
                }
            }
        }

        onSwitchViewMode: {
            console.log("🔄 theme.qml: InputHandler switchViewMode signal received!");
            console.log("   Current viewMode:", viewMode);
            console.log("   coverFlow.isCoverSelected:", coverFlow ? coverFlow.isCoverSelected : "N/A");

            if (viewMode === "carousel1" && coverFlow && coverFlow.isCoverSelected) {
                console.log("⚠️ Select in Carousel 1 with cover selected - keeping as confirmation button");
                return;
            }

            // Cyclic view rotation
            if (viewMode === "carousel1") {
                viewMode = "carousel2";
                console.log("✅ Switched to Carousel 2");
            } else if (viewMode === "carousel2") {
                viewMode = "carousel3";
                console.log("✅ Switched to Carousel 3");
            } else if (viewMode === "carousel3") {
                viewMode = "carousel4";
                console.log("✅ Switched to Carousel 4");
            } else {
                viewMode = "carousel1";
                console.log("✅ Switched to Carousel 1");
            }
        }

        // now logic is handled directly by menuManager di theme.
    }

    // Main theme content container
    Item {
        id: themeContainer
        anchors.fill: parent
        visible: !themeLoader.active
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        PlaytimeTracker {
            id: playtimeTracker
        }

        Background {
            id: background
            objectName: "background"
            anchors.fill: parent
            currentPlatform: theme.currentPlatform  // Fixed from root.currentPlatform
            coverFlowRef: coverFlow
            gameModel: currentCollection ? currentCollection.games : null
        }

        CoverFlow {
            id: coverFlow
            objectName: "coverFlow"
            anchors.fill: parent
            anchors.bottomMargin: platformBar.height
            themeFallback1: background.coverFallback1
            themeFallback2: background.coverFallback2
            visible: viewMode === "carousel1" || viewMode === "carousel2" || viewMode === "carousel3" || viewMode === "carousel4"
            opacity: theme.currentPlatform === "ra" ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            _sourceGameModel: currentCollection ? currentCollection.games : null
            platform: theme.currentPlatform  // Fixed from root.currentPlatform
            inputHandler: theme.inputHandler  // Fixed from root.inputHandler
            screenMetrics: screenMetrics
            // Pass instance of menuManager di theme a CoverFlow
            menuManager: menuManager
            platformBarRef: platformBar
            raServiceRef: raHub.raService
            lang: theme._lang
            playtimeTracker: playtimeTracker
            currentViewMode: theme.viewMode

            onGameSelected: function(game) {
                background.updateBackgroundFromGame(game)
            }

            onViewModeChangeRequested: function(viewType) {
                console.log("theme.qml: CoverFlow - View mode change requested:", viewType)
                theme.viewMode = viewType
            }

            onRaHubRequested: {
                theme._preRaPlatformIndex = platformBar.currentIndex;
                if (platformBar.raVisible) {
                    platformBar.goToRaPlatform();
                } else {
                    raHub.open();
                }
            }

            onFavouriteRemovedOnFavPlatform: {
                // Refresh favourites collection model so removed game disappears
                var freshColl = platformBar.createFavouriteCollection();
                platformBar.favouriteCollection = freshColl;
                theme.currentCollection = freshColl;
            }

            Component.onCompleted: {
                if (carouselCustomizer) {
                    carouselCustomizer.panelNavigationActiveChanged.connect(function(active) {
                        inputHandler.isCustomizerPanelActive = active;
                        console.log("theme.qml: Customizer panel active state changed:", active);
                    });
                }

                // Wire search signals
                if (searchButton) {
                    searchButton.searchRequested.connect(function(query) {
                        console.log("🔍 theme: Search requested for '" + query + "'");

                        // Force deselect cover and hide action panel
                        if (coverFlow.gameActionPanelRef && coverFlow.gameActionPanelRef.visible)
                            coverFlow.gameActionPanelRef.visible = false;
                        coverFlow.selectedCoverIndex = -1;

                        theme._preSearchViewMode = theme.viewMode;
                        theme._preSearchCollection = theme.currentCollection;
                        theme._preSearchPlatform = theme.currentPlatform;
                        theme._preSearchPlatformIndex = platformBar.currentIndex;

                        // Enter search mode (hides platform bar, shows search label)
                        theme._isSearchMode = true;
                        theme._searchQueryText = query;
                        searchModeLabel._borderColor = Qt.hsla(Math.random(), 0.7, 0.55, 1.0);

                        // Set search results as current collection
                        var resultsColl = coverFlow.searchButton.searchResultsCollection;
                        if (resultsColl) {
                            theme.currentCollection = resultsColl;
                            theme.currentPlatform = "search";

                            // Switch to carousel1 to display results
                            if (theme.viewMode !== "carousel1") {
                                theme.viewMode = "carousel1";
                            } else {
                                // Already in carousel1 — force model refresh
                                coverFlow._sourceGameModel = null;
                                Qt.callLater(function() {
                                    coverFlow._sourceGameModel = resultsColl.games;
                                });
                            }
                        }

                        // Restore focus to InputHandler so controller works on carousel
                        Qt.callLater(function() {
                            inputHandler.forceActiveFocus();
                        });
                    });

                    searchButton.searchClosed.connect(function() {
                        console.log("🔍 theme: Search closed — restoring previous state");

                        // Exit search mode (restore platform bar)
                        theme._isSearchMode = false;
                        theme._searchQueryText = "";

                        if (theme._preSearchCollection) {
                            theme.currentCollection = theme._preSearchCollection;
                            theme.currentPlatform = theme._preSearchPlatform;

                            // Restore the declarative binding that was broken during search
                            coverFlow._sourceGameModel = Qt.binding(function() {
                                return theme.currentCollection ? theme.currentCollection.games : null;
                            });

                            if (theme._preSearchViewMode && theme._preSearchViewMode !== theme.viewMode) {
                                theme.viewMode = theme._preSearchViewMode;
                            }
                            // Navigate back to the original platform
                            if (theme._preSearchPlatformIndex >= 0) {
                                platformBar.currentIndex = theme._preSearchPlatformIndex;
                            }
                        }
                        theme._preSearchViewMode = "";
                        theme._preSearchCollection = null;
                        theme._preSearchPlatform = "";
                        theme._preSearchPlatformIndex = -1;

                        // Restore focus to InputHandler
                        Qt.callLater(function() {
                            inputHandler.forceActiveFocus();
                        });
                    });
                }
            }
        }

        // Search mode label (replaces platform bar during search)
        Item {
            id: searchModeLabel
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: platformBar.height
            visible: theme._isSearchMode
            z: platformBar.z + 1

            property color _borderColor: Qt.hsla(Math.random(), 0.7, 0.55, 1.0)

            Rectangle {
                anchors.centerIn: parent
                width: searchLabelText.contentWidth + Math.round(searchModeLabel.height * 0.8)
                height: Math.round(searchModeLabel.height * 0.6)
                radius: height / 2
                color: "#22FFFFFF"
                border.width: 2
                border.color: searchModeLabel._borderColor

                Row {
                    id: searchLabelText
                    anchors.centerIn: parent
                    property real contentWidth: searchPrefix.contentWidth + searchWord.contentWidth
                    Text {
                        id: searchPrefix
                        text: T.t("search_for", theme._lang)
                        color: "#FFFFFF"
                        font.pixelSize: Math.round(searchModeLabel.height * 0.15)
                        font.bold: false
                        font.family: "Sans"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: searchWord
                        text: theme._searchQueryText
                        color: "#FFFFFF"
                        font.pixelSize: Math.round(searchModeLabel.height * 0.15)
                        font.bold: true
                        font.family: "Sans"
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        PlatformBar {
            id: platformBar
            objectName: "platformBar"
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            visible: !theme._isSearchMode
            collections: api.collections
            Component.onCompleted: {
                platformBar.autoHideEnabled = theme._startupUiAutoHide;
                platformBar.logoOutlineEnabled = theme._startupUiOutline;
                if (theme._startupUiAutoHide) {
                    platformBar.showBar();
                }
            }
            coverFlowRef: coverFlow
            inputHandlerRef: inputHandler
            screenMetrics: screenMetrics
            lang: theme._lang

            onCollectionChanged: function(collection) {
                theme.currentCollection = collection
                theme.currentPlatform = collection.shortName

                // RA PLATFORM DETECTION
                if (collection.shortName === "ra") {
                    console.log("🏆 RA platform selected — opening RetroAchievements Hub");
                    raHub.open();
                    return;
                }
                if (raHub.hubOpen) {
                    raHub.close();
                }

                background.updatePlatform(currentPlatform)

                if (theme.currentPlatform === "lastplayed" || theme.currentPlatform === "favourites") {
                    console.log("🎮 Special platform loaded - forcing carousel1 mode")
                    if (theme.viewMode !== "carousel1") {
                        theme.viewMode = "carousel1"
                    }
                    return
                }

                if (!theme.initialViewModeLoaded) {
                    console.log("🎬 First real platform loaded:", theme.currentPlatform, "- loading saved view mode")
                    theme.loadLastViewMode()
                    theme.initialViewModeLoaded = true
                }
            }

            onScrollingStarted: {
                // CoverFlow handles isPlatformLoading via its own Connections block.
                // theme.qml only manages background operations.
                background.pauseLoadingOperations();
            }

            onScrollingStopped: {
                background.resumeLoadingOperations();
            }
        }

        // Current time display
        CurrentTime {
            id: currentTimeDisplay
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 5
            width: 350
            height: 120
            gameModel: theme.currentCollection ? theme.currentCollection.games : null  // Fixed from root.currentCollection

            visible: !coverFlow.isCoverSelected && theme.currentPlatform !== "ra"
            opacity: visible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }

        // BATTERY INDICATOR (vertical, left of clock)
        Item {
            id: batteryIndicator
            anchors.right: currentTimeDisplay.left
            anchors.verticalCenter: currentTimeDisplay.verticalCenter
            anchors.verticalCenterOffset: -2
            anchors.rightMargin: 2
            width: 24
            height: 40
            visible: theme._uiShowBattery && currentTimeDisplay.visible
            opacity: visible ? 0.99 : 0.0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

            property real batteryLevel: {
                if (typeof api !== "undefined" && typeof api.device !== "undefined"
                    && typeof api.device.batteryPercent !== "undefined")
                    return api.device.batteryPercent;
                return -1;
            }
            property bool isCharging: {
                if (typeof api !== "undefined" && typeof api.device !== "undefined"
                    && typeof api.device.batteryCharging !== "undefined")
                    return api.device.batteryCharging;
                return false;
            }

            Timer {
                interval: 30000; running: batteryIndicator.visible; repeat: true
                onTriggered: batteryCanvas.requestPaint()
            }

            Canvas {
                id: batteryCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var w = width, h = height;
                    var level = batteryIndicator.batteryLevel;
                    var charging = batteryIndicator.isCharging;

                    // Ultra-minimal: just a thin rounded rect + fill
                    var bodyW = w * 0.70, bodyH = h * 0.78;
                    var bx = (w - bodyW) / 2, by = h * 0.14;
                    var tipW = bodyW * 0.36, tipH = 2;
                    var tipX = (w - tipW) / 2;

                    var clr = "#8aaccc";
                    // Tip
                    ctx.fillStyle = clr;
                    ctx.fillRect(tipX, by - tipH, tipW, tipH);
                    // Body
                    ctx.strokeStyle = clr;
                    ctx.lineWidth = 1.3;
                    ctx.beginPath();
                    ctx.roundedRect(bx, by, bodyW, bodyH, 1.5, 1.5);
                    ctx.stroke();

                    // Fill
                    if (level >= 0) {
                        var fc;
                        if (charging) fc = "#4CAF50";
                        else if (level > 0.5) fc = "#78a060";
                        else if (level > 0.2) fc = "#c0a040";
                        else fc = "#c05040";

                        var p = 1.5;
                        var mH = bodyH - p * 2;
                        var fH = mH * Math.max(0, Math.min(1, level));
                        ctx.fillStyle = fc;
                        ctx.globalAlpha = 0.8;
                        ctx.fillRect(bx + p, by + p + (mH - fH), bodyW - p * 2, fH);
                        ctx.globalAlpha = 1.0;
                    }

                    // Percentage below
                    if (level >= 0) {
                        ctx.fillStyle = "#90b0cc";
                        ctx.font = Math.round(h * 0.17) + "px sans-serif";
                        ctx.textAlign = "center";
                        ctx.textBaseline = "top";
                        ctx.fillText(Math.round(level * 100) + "%", w * 0.5, by + bodyH + 1);
                    }
                }
                Component.onCompleted: requestPaint()
            }
        }

        // WIFI INDICATOR (right of clock)
        Item {
            id: wifiIndicator
            anchors.left: currentTimeDisplay.right
            anchors.verticalCenter: currentTimeDisplay.verticalCenter
            anchors.verticalCenterOffset: -4
            anchors.leftMargin: 2
            width: 32
            height: 32
            visible: theme._uiShowWifi && currentTimeDisplay.visible
            opacity: visible ? 0.92 : 0.0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

            property bool isConnected: false

            Timer {
                id: wifiCheckTimer
                interval: 15000; running: wifiIndicator.visible; repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var xhr = new XMLHttpRequest();
                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            // generate_204 returns 204; any 2xx means connected
                            wifiIndicator.isConnected = (xhr.status >= 200 && xhr.status < 400);
                            wifiCanvas.requestPaint();
                        }
                    };
                    try {
                        xhr.open("GET", "https://connectivitycheck.gstatic.com/generate_204", true);
                        xhr.timeout = 5000;
                        xhr.send();
                    } catch(e) {
                        wifiIndicator.isConnected = false;
                        wifiCanvas.requestPaint();
                    }
                }
            }

            Canvas {
                id: wifiCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var w = width, h = height;
                    var cx = w * 0.5, cy = h * 0.92;
                    var connected = wifiIndicator.isConnected;

                    ctx.lineCap = "round";

                    // Three arcs with gradient opacity
                    for (var i = 1; i <= 3; i++) {
                        var r = w * 0.15 * i;
                        ctx.strokeStyle = connected ? "#8BC34A" : "#607888";
                        ctx.lineWidth = 2.0;
                        ctx.globalAlpha = connected ? (0.50 + i * 0.17) : 0.45;
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, -Math.PI * 0.78, -Math.PI * 0.22);
                        ctx.stroke();
                    }
                    ctx.globalAlpha = 1.0;

                    // Center dot
                    ctx.fillStyle = connected ? "#8BC34A" : "#607888";
                    ctx.globalAlpha = connected ? 0.95 : 0.5;
                    ctx.beginPath();
                    ctx.arc(cx, cy, w * 0.065, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.globalAlpha = 1.0;

                    // Small slash when disconnected
                    if (!connected) {
                        ctx.strokeStyle = "#e05040";
                        ctx.lineWidth = 1.5;
                        ctx.globalAlpha = 0.7;
                        ctx.beginPath();
                        ctx.moveTo(w * 0.22, h * 0.20);
                        ctx.lineTo(w * 0.78, h * 0.75);
                        ctx.stroke();
                        ctx.globalAlpha = 1.0;
                    }
                }
                Component.onCompleted: requestPaint()
            }
        }

        // Alphabetic jump indicator - Fullscreen dim with centered letter
        // Placed here to cover everything, including PlatformBar
        AlphabeticIndicator {
            id: alphabeticIndicator
            anchors.fill: parent
            z: 99999
        }

        // Connected to signal of CoverFlow
        Connections {
            target: coverFlow
            function onShowAlphabeticLetter(letter) {
                alphabeticIndicator.show(letter);
            }
            function onCoverScrolledInSelectedMode() {
                // RA lookup is now debounced via _raLookupDebounce in the scroll handlers.
                // No duplicate trigger here.
            }
        }

    }

    // Global keyboard input
    Keys.onPressed: function(event) {
        // PRIORITY 0: Search panel input intercept
        // When bar is open (expanded / editing), ALL keys are consumed — carousel frozen
        if (coverFlow && coverFlow.searchButton && coverFlow.searchButton.isOpen) {
            coverFlow.searchButton.handleButton(event);
            event.accepted = true;
            return;
        }

        // PRIORITY 1: L2/R2 zoom.
        // key=0: First pull of analog trigger (Android quirk). Start zoom immediately.
        // Default direction: zoom in (R2). Direction corrected if L2 PRESS arrives.
        if (event.key === 0 && !isZoomingIn && !isZoomingOut
                && !r2CooldownTimer.running && !l2CooldownTimer.running
                && !gridViewMode && coverFlow && coverFlow.isCoverSelected) {
            isZoomingIn = true;
            _firstPullZoom = true;
            r2Watchdog.restart();
            event.accepted = true;
            return;
        }
        // L2 PRESS: Start zoomOut (or correct direction from key=0).
        if (event.key === 1048581) {  // L2
            if (!gridViewMode && coverFlow && coverFlow.isCoverSelected) {
                r2Watchdog.stop();
                l2Watchdog.stop();
                if (_firstPullZoom && isZoomingIn) {
                    // key=0 guessed wrong direction → switch to zoomOut
                    isZoomingIn = false;
                }
                _firstPullZoom = false;
                _l2Confirmed = true;
                isZoomingOut = true;
            }
            event.accepted = true;
            return;
        }
        // R2 PRESS: Start or confirm zoomIn.
        if (event.key === 1048584) {  // R2
            if (!gridViewMode && coverFlow && coverFlow.isCoverSelected) {
                r2Watchdog.stop();
                l2Watchdog.stop();
                _firstPullZoom = false;
                _r2Confirmed = true;
                if (!isZoomingIn) isZoomingIn = true;
            }
            event.accepted = true;
            return;
        }

        // PRIORITY 2: Y Button (Favourite) - Explicit check
        // Often mapped to Filters, so we check this before generic Filters check
        if (event.key === 1048579 && !event.isAutoRepeat) {
            // GameCard visible check FIRST (isCoverSelected is also true when GameCard is open)
            if (coverFlow && coverFlow.gameActionPanelRef && coverFlow.gameActionPanelRef.visible) {
                var gcGame = coverFlow.gameActionPanelRef.game;
                if (gcGame && platformBar) {
                    var gcFav = platformBar.toggleFavourite(gcGame, theme.currentPlatform);
                    // Trigger heart animation directly on GameCard
                    coverFlow.gameActionPanelRef.applyFavouriteState(gcFav);
                    if (coverFlow.favouriteButton) coverFlow.favouriteButton.heartbeat();
                    if (theme.currentPlatform === "favourites" && !gcFav) {
                        coverFlow._pendingFavRefresh = true;
                    }
                    if (coverFlow.favouriteFilterActive && !gcFav) {
                        coverFlow._pendingFavRefresh = true;
                    }
                }
            } else if (coverFlow && coverFlow.isCoverSelected) {
                // Cover is selected (no GameCard) → toggle favourite for this game
                var game = coverFlow.current();
                if (game && platformBar) {
                    var isFav = platformBar.toggleFavourite(game, theme.currentPlatform);
                    if (coverFlow.favouriteButton) coverFlow.favouriteButton.heartbeat();

                    // On the Favourites platform, defer carousel refresh to deselect
                    if (theme.currentPlatform === "favourites" && !isFav) {
                        coverFlow._pendingFavRefresh = true;
                    }
                    // If favourite filter is active and game was un-favourited, defer refresh
                    if (coverFlow.favouriteFilterActive && !isFav) {
                        coverFlow._pendingFavRefresh = true;
                    }
                }
            } else if (coverFlow && coverFlow.favouriteButton) {
                // No cover selected → toggle favourite filter for current platform
                coverFlow.toggleFavouriteFilter();
                coverFlow.favouriteButton.heartbeat();
            }
            event.accepted = true;
            return;
        }

        // PRIORITY 2.5: L1/R1 → scroll covers or L1+R1 combo → open RA detail (when GameCard visible)
        if ((event.key === 1048580 || event.key === 1048583) && !event.isAutoRepeat) {
            // Only handle when cover is selected (GameCard visible scenario)
            if (coverFlow && coverFlow.isCoverSelected) {
                if (event.key === 1048580) { theme._l1PressedCombo = true; theme._pendingShoulderDir = -1; }
                if (event.key === 1048583) { theme._r1PressedCombo = true; theme._pendingShoulderDir = 1; }

                if (theme._l1PressedCombo && theme._r1PressedCombo) {
                    // Both pressed! Open RA game detail
                    console.log("[RA-theme] L1+R1 combo → opening RA game detail");
                    theme._l1PressedCombo = false;
                    theme._r1PressedCombo = false;
                    theme._pendingShoulderDir = 0;
                    _l1r1ComboTimer.stop();

                    if (raHub && raHub.raService) {
                        var svc = raHub.raService;
                        var detail = svc.gameDetail;
                        if (detail && detail.gameId && detail.gameId > 0) {
                            theme._preRaPlatformIndex = platformBar.currentIndex;
                            raHub.open();
                            raHub.openGameDetail({
                                gameId: detail.gameId,
                                title: detail.title || "",
                                consoleName: detail.consoleName || "",
                                imageIcon: detail.imageIcon || "",
                                numAwarded: detail.numAwarded || 0,
                                numAchievements: detail.numAchievements || 0,
                                completionPct: detail.numAchievements > 0 ? Math.round((detail.numAwarded / detail.numAchievements) * 100) : 0
                            });
                        } else {
                            // No RA data — open as Pegasus-only game
                            var game2 = coverFlow.current();
                            if (game2) {
                                var platTag2 = theme.currentCollection ? (theme.currentCollection.shortName || theme.currentCollection.name || "") : "";
                                theme._preRaPlatformIndex = platformBar.currentIndex;
                                raHub.open();
                                raHub.openGameDetail({
                                    gameId: 0,
                                    title: game2.title || "",
                                    platform: platTag2,
                                    imageIcon: game2.assets.boxFront || game2.assets.screenshot || "",
                                    earned: 0,
                                    total: 0,
                                    progress: 0,
                                    isPegasus: true,
                                    pegasusGame: game2
                                });
                            }
                        }
                    }
                    event.accepted = true;
                    return;
                }

                // First button: start combo detection window
                _l1r1ComboTimer.restart();
                event.accepted = true;
                return;
            }
        }

        // PRIORITY 3: Select Button — immediate action (no long press)
        var isSelectKey = (event.key === Qt.Key_Select || event.key === 1048582 || event.key === 1048586);
        var isFiltersAction = api.keys.isFilters(event) && event.key !== 1048579;

        if ((isSelectKey || isFiltersAction) && !event.isAutoRepeat) {
            var gcRef = coverFlow.gameActionPanelRef;
            if (gcRef && gcRef.visible && gcRef.statsPanel) {
                // GameCard is open → toggle panel page (PlayStats ↔ RA)
                gcRef.statsPanel.panelPage = (gcRef.statsPanel.panelPage + 1) % 2;
                console.log("📋 SELECT → GameCard panel page:", gcRef.statsPanel.panelPage);
                // Animate bar on the new page
                if (gcRef.statsPanel.panelPage === 1) {
                    gcRef.raBarAnimRef.stop();
                    gcRef.raBarFillRef.width = 0;
                    gcRef.raBarAnimRef.start();
                } else {
                    gcRef.playTimeBarAnimRef.stop();
                    gcRef.playTimeBarFillRef.width = 0;
                    gcRef.playTimeBarAnimRef.start();
                }
                gcRef.bounceSelectIcon();
            } else {
                // No GameCard → toggle menu
                console.log("📋 SELECT → Toggle menu")
                if (menuManager && !menuManager.menuOpen) {
                    menuManager.openMenu();
                } else if (menuManager && menuManager.menuOpen) {
                    menuManager.closeMenu();
                }
            }
            event.accepted = true;
            return;
        }

        // PRIORITY 4: X Button (Search / Details)
        if (event.key === 1048578 && !event.isAutoRepeat) {
            var gameCardVisible = coverFlow.gameActionPanelRef && coverFlow.gameActionPanelRef.visible;

            if (gameCardVisible) {
                // Toggle description on GameCard
                console.log("🔍 X button - Toggling description");
                coverFlow.gameActionPanelRef.currentButton = 1;
                coverFlow.gameActionPanelRef.showDescription = !coverFlow.gameActionPanelRef.showDescription;
                coverFlow.gameActionPanelRef.detailsClicked(coverFlow.gameActionPanelRef.game);
            } else if (coverFlow && coverFlow.searchButton && !coverFlow.isCoverSelected) {
                if (coverFlow.searchButton.searchActive) {
                    // Search active → re-open search bar for new/modified search
                    console.log("🔍 X button - Re-opening search bar");
                    coverFlow.searchButton.open();
                } else {
                    // Open search bar
                    console.log("🔍 X button - Opening SearchButton");
                    coverFlow.searchButton.press();
                }
            }
            event.accepted = true;
            return;
        }

        // PRIORITY 5: D-Pad (Manual 3D Rotation when GameCard is visible)
        if (coverFlow.gameActionPanelRef && coverFlow.gameActionPanelRef.visible) {
            if (event.key === Qt.Key_Left || event.key === 16777234) {
                rotationAxisY = -1;
                event.accepted = true;
                return;
            } else if (event.key === Qt.Key_Right || event.key === 16777236) {
                rotationAxisY = 1;
                event.accepted = true;
                return;
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_W || event.key === 16777235) {
                rotationAxisX = 1;
                event.accepted = true;
                return;
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_S || event.key === 16777237) {
                rotationAxisX = -1;
                event.accepted = true;
                return;
            }
        }

        // PRIORITY 6: Enter / A (Select / Play)
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter ||
            event.key === Qt.Key_Space || event.key === Qt.Key_A || event.key === 1048576) {

            // Block selection during search guard window
            if (coverFlow.searchButton && coverFlow.searchButton._selectGuard) {
                event.accepted = true;
                return;
            }

            if (viewMode === "carousel2" || viewMode === "carousel1" || viewMode === "carousel3" || viewMode === "carousel4") {
                if (!coverFlow.isCoverSelected) {
                    // Seleziona cover + GameCard appare (via Connections in CoverFlow)
                    if (coverFlow.pathViewLoader.item && coverFlow.pathViewLoader.item.currentIndex !== -1) {
                        coverFlow.selectedCoverIndex = coverFlow.pathViewLoader.item.currentIndex;
                        // Trigger RA lookup for the newly selected cover
                        Qt.callLater(_triggerRaLookup);
                    }
                } else if (coverFlow.gameActionPanelRef && coverFlow.gameActionPanelRef.visible) {
                    coverFlow.gameActionPanelRef.playClicked(coverFlow.current());
                }
                event.accepted = true;
                return;
            }
        }

        // PRIORITY 7: Back / B (Back / Deselect / RA Hub)
        else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back ||
                 event.key === Qt.Key_Backspace || event.key === Qt.Key_B || event.key === 1048577) {

            if (!event.isAutoRepeat) {
                if (coverFlow.isCoverSelected) {
                    coverFlow.selectedCoverIndex = -1;
                } else if (menuManager && menuManager.menuOpen) {
                    menuManager.closeMenu();
                } else if (coverFlow.carouselCustomizer && coverFlow.carouselCustomizer.isCustomizerVisible) {
                    coverFlow.carouselCustomizer.closePanelAndSave();
                } else if (event.key === 1048577) {
                    // Gamepad B with nothing active → open RA Hub
                    coverFlow.raHubRequested();
                }
            }
            event.accepted = true;
        }
    }

    // Handle key release to stop continuous rotation
    Keys.onReleased: function(event) {
        // NOTE: Do NOT reset _l1PressedCombo/_r1PressedCombo here!
        // The combo timer (150ms) handles cleanup after processing.
        // Resetting on release caused a race condition: release arrives
        // before the timer fires (~50ms vs 150ms), clearing the flag
        // so the timer found false and never scrolled.

        // Select is now handled on press, not release
        var isSelectKey = (event.key === Qt.Key_Select || event.key === 1048582 || event.key === 1048586);
        var isFiltersAction = api.keys.isFilters(event) && event.key !== 1048579;
        if (isSelectKey || isFiltersAction) {
            event.accepted = true;
            return;
        }

        // Handle L2/R2 RELEASE: stop zoom.
        // First pull: _firstPullZoom=true, any L2/R2 RELEASE stops zoom.
        // Normal pull: _confirmed=true, matching RELEASE stops zoom.
        // Cooldown blocks duplicate releases.
        if (event.key === 1048584) {  // R2 RELEASE
            if (_firstPullZoom && isZoomingIn) {
                // First pull release (direction was R2 = correct)
                isZoomingIn = false;
                _firstPullZoom = false;
                r2Watchdog.stop();
                r2CooldownTimer.restart();
            } else if (isZoomingIn && _r2Confirmed) {
                // Normal hold-to-zoom release
                isZoomingIn = false;
                _r2Confirmed = false;
                r2CooldownTimer.restart();
            }
            event.accepted = true;
            return;
        } else if (event.key === 1048581) {  // L2 RELEASE
            if (_firstPullZoom && (isZoomingIn || isZoomingOut)) {
                // First pull release (was L2)
                isZoomingIn = false;
                isZoomingOut = false;
                _firstPullZoom = false;
                r2Watchdog.stop();
                l2Watchdog.stop();
                l2CooldownTimer.restart();
            } else if (isZoomingOut && _l2Confirmed) {
                // Normal hold-to-zoom release
                isZoomingOut = false;
                _l2Confirmed = false;
                l2CooldownTimer.restart();
            }
            event.accepted = true;
            return;
        }

        if (coverFlow.gameActionPanelRef && coverFlow.gameActionPanelRef.visible) {
            if (event.key === Qt.Key_Left || event.key === 16777234) {
                console.log("theme.qml: D-pad Left released.");
                if (rotationAxisY === -1) rotationAxisY = 0;
                event.accepted = true;
            } else if (event.key === Qt.Key_Right || event.key === 16777236) {
                console.log("theme.qml: D-pad Right released.");
                if (rotationAxisY === 1) rotationAxisY = 0;
                event.accepted = true;
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_W || event.key === 16777235) {
                console.log("theme.qml: D-pad Up released.");
                if (rotationAxisX === 1) rotationAxisX = 0;
                event.accepted = true;
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_S || event.key === 16777237) {
                console.log("theme.qml: D-pad Down released.");
                if (rotationAxisX === -1) rotationAxisX = 0;
                event.accepted = true;
            }
        }
    }

    // Theme loading and initialization
    ThemeLoader {
        id: themeLoader
        anchors.fill: parent
        z: 10000
        apiRef: api
        detectGameReload: true
        lang: theme._lang

        onLoadingComplete: {
            if (typeof themeReady !== 'undefined') themeReady = true
        }

        onUserContinued: {
            if (typeof themeReady !== 'undefined') themeReady = true
            Qt.callLater(function() {
                inputHandler.forceActiveFocus()
            })
        }

        onLoadingFailed: function(error) {
            if (typeof themeReady !== 'undefined') themeReady = true
            console.error("ThemeLoader: Loading failed:", error)
        }
    }
}
