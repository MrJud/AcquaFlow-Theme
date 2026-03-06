import QtQuick 2.15
import ".."
import QtGraphicalEffects 1.15
import "../../utils.js" as Utils
import "../config/PlatformBarConfig.js" as Cfg
import "../config/Translations.js" as T

Item {
    id: platformBar
    height: _platformBarHeight

    // Auto-hide
    property bool autoHideEnabled: false
    property bool logoOutlineEnabled: true
    property bool _barHidden: false

    // Auto-hide offset (0 = visible, height = hidden)
    property real _autoHideOffset: 0
    property bool shouldHideBar: _barHidden && autoHideEnabled && !isCoverSelected

    property string lang: "en"
    property QtObject screenMetrics: null

    // Asymmetric animation: instant show, slow hide
    property int _hideAnimDuration: 0
    Behavior on _autoHideOffset {
        NumberAnimation {
            duration: platformBar._hideAnimDuration
            easing.type: Easing.InOutQuad
        }
    }

    onShouldHideBarChanged: {
        if (shouldHideBar) {
            _hideAnimDuration = 800;
            _autoHideOffset = _platformBarHeight + 5;
        } else {
            _hideAnimDuration = 0;
            _autoHideOffset = 0;
        }
    }

    transform: Translate { y: platformBar._autoHideOffset }

    Timer {
        id: autoHideTimer
        interval: 3000
        repeat: false
        onTriggered: {
            if (platformBar.autoHideEnabled && !platformBar.isCoverSelected) {
                platformBar._barHidden = true;
            }
        }
    }

    function showBar() {
        _barHidden = false;
        if (autoHideEnabled && !isCoverSelected) {
            autoHideTimer.restart();
        }
    }

    property var collections
    property alias currentIndex: listView.currentIndex

    signal modelDataChanged()

    property var coverFlowRef: null
    property var inputHandlerRef: null
    property bool isCoverSelected: coverFlowRef ? coverFlowRef.isCoverSelected : false
    property real nonCurrentOpacity: isCoverSelected ? 0.0 : 1.0

    // Triangle glow properties L1/R1
    property real leftGlowIntensity: 0.0
    property real rightGlowIntensity: 0.0

    // Connections to intercept L1/R1 signals from InputHandler
    Connections {
        target: inputHandlerRef

        function onScrollNextCoverSelected() {
            triggerRightGlow();
        }

        function onScrollPrevCoverSelected() {
            triggerLeftGlow();
        }
    }

    function triggerLeftGlow() {
        platformBar.leftGlowIntensity = 1.0;
        leftGlowTimer.restart();
    }

    function triggerRightGlow() {
        platformBar.rightGlowIntensity = 1.0;
        rightGlowTimer.restart();
    }

    // Shared color interpolation for gradient animations
    function interpolateColor(color1, color2, t) {
        var r1 = parseInt(color1.substr(1, 2), 16);
        var g1 = parseInt(color1.substr(3, 2), 16);
        var b1 = parseInt(color1.substr(5, 2), 16);
        var r2 = parseInt(color2.substr(1, 2), 16);
        var g2 = parseInt(color2.substr(3, 2), 16);
        var b2 = parseInt(color2.substr(5, 2), 16);
        var r = Math.round(r1 + (r2 - r1) * t);
        var g = Math.round(g1 + (g2 - g1) * t);
        var b = Math.round(b1 + (b2 - b1) * t);
        return "#" +
               (r < 16 ? "0" : "") + r.toString(16) +
               (g < 16 ? "0" : "") + g.toString(16) +
               (b < 16 ? "0" : "") + b.toString(16);
    }

    Timer {
        id: leftGlowTimer
        interval: 200
        onTriggered: {
            platformBar.leftGlowIntensity = 0.0;
        }
    }

    Timer {
        id: rightGlowTimer
        interval: 200
        onTriggered: {
            platformBar.rightGlowIntensity = 0.0;
        }
    }

    Behavior on nonCurrentOpacity {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    // Animated gradient colors for logo outlines (same as clock / RA Hub)
    property color _borderAnim: "#7040c0"
    SequentialAnimation {
        running: true; loops: Animation.Infinite
        ColorAnimation { target: platformBar; property: "_borderAnim"; to: "#5848d8"; duration: 1800; easing.type: Easing.InOutSine   }
        ColorAnimation { target: platformBar; property: "_borderAnim"; to: "#4060f0"; duration: 1400; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: platformBar; property: "_borderAnim"; to: "#2888f0"; duration: 1600; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: platformBar; property: "_borderAnim"; to: "#18b0d8"; duration: 2000; easing.type: Easing.InOutSine   }
        ColorAnimation { target: platformBar; property: "_borderAnim"; to: "#18c8a8"; duration: 1200; easing.type: Easing.OutCubic    }
        ColorAnimation { target: platformBar; property: "_borderAnim"; to: "#20a0e0"; duration: 1000; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: platformBar; property: "_borderAnim"; to: "#6058e0"; duration: 1800; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: platformBar; property: "_borderAnim"; to: "#9040c0"; duration: 2200; easing.type: Easing.InOutSine   }
        ColorAnimation { target: platformBar; property: "_borderAnim"; to: "#a838a8"; duration: 1500; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: platformBar; property: "_borderAnim"; to: "#8040b8"; duration: 1000; easing.type: Easing.OutCubic    }
        ColorAnimation { target: platformBar; property: "_borderAnim"; to: "#7040c0"; duration: 1800; easing.type: Easing.InOutSine   }
    }
    property color _borderAnim2: "#2090e0"
    SequentialAnimation {
        running: true; loops: Animation.Infinite
        ColorAnimation { target: platformBar; property: "_borderAnim2"; to: "#18c8a8"; duration: 2200; easing.type: Easing.InOutSine   }
        ColorAnimation { target: platformBar; property: "_borderAnim2"; to: "#50d8f0"; duration: 1600; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: platformBar; property: "_borderAnim2"; to: "#a838a8"; duration: 2000; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: platformBar; property: "_borderAnim2"; to: "#e060a0"; duration: 1400; easing.type: Easing.OutCubic    }
        ColorAnimation { target: platformBar; property: "_borderAnim2"; to: "#6058e0"; duration: 1800; easing.type: Easing.InOutSine   }
        ColorAnimation { target: platformBar; property: "_borderAnim2"; to: "#38b8d8"; duration: 1200; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: platformBar; property: "_borderAnim2"; to: "#2090e0"; duration: 1600; easing.type: Easing.InOutCubic  }
    }
    property color _borderAnim3: "#20b8a0"
    SequentialAnimation {
        running: true; loops: Animation.Infinite
        ColorAnimation { target: platformBar; property: "_borderAnim3"; to: "#8040b8"; duration: 1800; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: platformBar; property: "_borderAnim3"; to: "#e08050"; duration: 2400; easing.type: Easing.InOutSine   }
        ColorAnimation { target: platformBar; property: "_borderAnim3"; to: "#40d8d0"; duration: 1600; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: platformBar; property: "_borderAnim3"; to: "#5060e8"; duration: 2000; easing.type: Easing.OutCubic    }
        ColorAnimation { target: platformBar; property: "_borderAnim3"; to: "#c848d0"; duration: 1400; easing.type: Easing.InOutSine   }
        ColorAnimation { target: platformBar; property: "_borderAnim3"; to: "#20b8a0"; duration: 1800; easing.type: Easing.InOutQuad   }
    }
    property real _borderAngle: 0
    NumberAnimation {
        running: true; target: platformBar; property: "_borderAngle"
        loops: Animation.Infinite; from: 0; to: 360; duration: 10000
    }

    readonly property int _platformBarHeight: Cfg.PlatformBarConfig.platformBarHeight
    readonly property int _platformLogoSize: Cfg.PlatformBarConfig.platformLogoSize
    readonly property int _platformItemWidth: Cfg.PlatformBarConfig.platformItemWidth
    readonly property int _platformItemWidthCurrent: Cfg.PlatformBarConfig.platformItemWidthCurrent
    readonly property int _platformSpacing: Cfg.PlatformBarConfig.platformSpacing
    readonly property real _platformScale: Cfg.PlatformBarConfig.platformScale
    readonly property int _platformCenterOffsetY: Cfg.PlatformBarConfig.platformCenterOffsetY
    readonly property int _fontSizeSmall: Cfg.PlatformBarConfig.fontSizeSmall
    readonly property int _fontSizeMedium: Cfg.PlatformBarConfig.fontSizeMedium

    property bool isScrollingAsyncMode: false
    property int pendingCollectionIndex: -1

    property var lastPlayedCollection: null
    property var favouriteCollection: null

    property var gameCubeCollection: null
    property var raCollection: null

    function createRaCollection() {
        return {
            name: "RetroAchievements",
            shortName: "ra",
            summary: "RetroAchievements Hub",
            games: {
                count: 0,
                get: function(index) { return null; }
            }
        };
    }

    function createLastPlayedCollection() {
        return {
            name: "Last Played",
            shortName: "lastplayed",
            summary: "Recently played games",
            games: {
                count: lastPlayedGames.length,
                get: function(index) {
                    if (index >= 0 && index < lastPlayedGames.length) {
                        return lastPlayedGames[index];
                    }
                    return null;
                }
            }
        };
    }

    function createFavouriteCollection() {
        return {
            name: "Favourites",
            shortName: "favourites",
            summary: "Your favourite games",
            games: {
                count: favouriteGames.length,
                get: function(index) {
                    if (index >= 0 && index < favouriteGames.length) {
                        return favouriteGames[index];
                    }
                    return null;
                }
            }
        };
    }

    function createGameCubeCollection() {
        return {
            name: "GameCube",
            shortName: "gc",
            summary: "Giochi Nintendo GameCube",
            games: {
                count: gameCubeGames.length,
                get: function(index) {
                    if (index >= 0 && index < gameCubeGames.length) {
                        return gameCubeGames[index];
                    }
                    return null;
                }
            }
        };
    }

    property var filteredWiiCollection: null

    function resetCachedCollections() {
        lastPlayedCollection = null;
        favouriteCollection = null;
        gameCubeCollection = null;
        raCollection = null;
        filteredWiiCollection = null;
    }

    property var gameCubeGames: []

    property var lastPlayedGames: []
    property var favouriteGames: []
    property var _favouriteMap: ({})  // { "platform|title": true }

    // Invalidate cached virtual collections when aderlying arrays change
    onLastPlayedGamesChanged: lastPlayedCollection = null
    onFavouriteGamesChanged: favouriteCollection = null
    onGameCubeGamesChanged: gameCubeCollection = null

    // Ordering system
    property var orderedPlatforms: []  // array of shortNames in display order
    property bool lastPlayedVisible: false
    property bool raVisible: true
    property bool favouriteVisible: false
    property bool lpFavSwapped: false  // false: LP then Fav (default); true: Fav then LP (swapped)
    property string startupPlatform: "first_platform"
    property bool _startupApplied: false  // one-shot flag for startup navigation
    // +1 for RA platform at index 0 (if visible)
    readonly property int platformCount: (raVisible ? 1 : 0) + (orderedPlatforms ? orderedPlatforms.length : 0) + (lastPlayedVisible ? 1 : 0) + (favouriteVisible ? 1 : 0)

    Connections {
        target: collections
        function onCountChanged() {
            resetCachedCollections();
            updateLastPlayedGames();
            updateFavouriteGames();
            updateGameCubeGames();
            buildOrderedPlatforms();
            modelDataChanged();

            // Force-refresh current collection for CoverFlow
            // Only emit after startup navigation completed, otherwise
            // buildOrderedPlatforms handles the first emission via Qt.callLater
            if (_startupApplied && listView.currentIndex >= 0 && listView.currentIndex < getTotalCount()) {
                var refreshedCollection = getCollectionAt(listView.currentIndex);
                if (refreshedCollection) {
                    collectionChanged(refreshedCollection);
                }
            }
        }
    }

    function updateLastPlayedGames() {
        if (!collections) return;

        var tempGames = [];

        for (var i = 0; i < collections.count; i++) {
            var collection = collections.get(i);
            if (collection && collection.games) {
                for (var j = 0; j < collection.games.count; j++) {
                    var game = collection.games.get(j);
                    if (game) {
                        var hasLastPlayed = false;
                        var sortTimestamp = 0;
                        if (game.lastPlayed && game.lastPlayed !== "" && game.lastPlayed !== "0" && game.lastPlayed !== null) {
                            var playDate = new Date(game.lastPlayed);
                            if (!isNaN(playDate.getTime()) && playDate.getTime() > 0) {
                                hasLastPlayed = true;
                                sortTimestamp = playDate.getTime();
                            }
                        }

                        if (!hasLastPlayed && game.playTime && game.playTime > 5) {
                            hasLastPlayed = true;
                        }

                        if (!hasLastPlayed && game.playCount && game.playCount > 0) {
                            hasLastPlayed = true;
                        }

                        if (hasLastPlayed) {
                            // Wrap in plain object to avoid writing on read-only API game
                            tempGames.push({
                                _game: game,
                                _sortTimestamp: sortTimestamp,
                                _platformShortName: collection.shortName,
                                _platformCollection: collection
                            });
                        }
                    }
                }
            }
        }

        // Sort using pre-computed timestamps (avoid repeated Date parsing)
        tempGames.sort(function(a, b) {
            // Primary: by last played timestamp (descending)
            if (a._sortTimestamp > 0 && b._sortTimestamp > 0) {
                return b._sortTimestamp - a._sortTimestamp;
            } else if (a._sortTimestamp > 0) {
                return -1;
            } else if (b._sortTimestamp > 0) {
                return 1;
            }

            // Secondary: by playTime
            var aPT = a._game.playTime || 0;
            var bPT = b._game.playTime || 0;
            if (aPT !== bPT) return bPT - aPT;

            // Tertiary: by playCount
            var aPC = a._game.playCount || 0;
            var bPC = b._game.playCount || 0;
            if (aPC !== bPC) return bPC - aPC;

            return (a._game.title || "").localeCompare(b._game.title || "");
        });

        if (tempGames.length > 50) {
            tempGames = tempGames.slice(0, 50);
        }

        // Attach platform metadata as dynamic JS properties on game objects
        // (QObjects in QML accept dynamic JS properties — standard Pegasus theme pattern)
        var unwrapped = [];
        for (var k = 0; k < tempGames.length; k++) {
            var entry = tempGames[k];
            var g = entry._game;
            g.originalPlatformName = entry._platformShortName;
            g.originalPlatform = entry._platformCollection;
            unwrapped.push(g);
        }

        lastPlayedGames = unwrapped;
    }

    // Favourite system

    function _loadFavouriteMap() {
        try {
            var saved = api.memory.get("favourites");
            if (saved && saved !== "") {
                _favouriteMap = JSON.parse(saved);
            } else {
                _favouriteMap = {};
            }
        } catch (e) {
            console.warn("[PlatformBar] Error loading favourites:", e);
            _favouriteMap = {};
        }
    }

    function _saveFavouriteMap() {
        try {
            api.memory.set("favourites", JSON.stringify(_favouriteMap));
        } catch (e) {
            console.warn("[PlatformBar] Error saving favourites:", e);
        }
    }

    function _favouriteKey(game, platformShortName) {
        var title = game ? (game.title || "") : "";
        var plat = platformShortName || "";
        return plat.toLowerCase() + "|" + title;
    }

    // Resolve the real platform name: on virtual platforms (favourites, lastplayed),
    // use the game's originalPlatformName so keys match the stored entries.
    function _resolvedPlatform(game, platformShortName) {
        if (platformShortName && game && game.originalPlatformName) {
            var lc = platformShortName.toLowerCase();
            if (lc === "favourites" || lc === "lastplayed") {
                return game.originalPlatformName;
            }
        }
        return platformShortName;
    }

    function isGameFavourite(game, platformShortName) {
        if (!game) return false;
        var plat = _resolvedPlatform(game, platformShortName);
        return !!_favouriteMap[_favouriteKey(game, plat)];
    }

    function toggleFavourite(game, platformShortName) {
        if (!game) return false;
        var plat = _resolvedPlatform(game, platformShortName);
        var key = _favouriteKey(game, plat);
        if (_favouriteMap[key]) {
            delete _favouriteMap[key];
        } else {
            _favouriteMap[key] = true;
        }
        _saveFavouriteMap();
        updateFavouriteGames(true);  // skipLoad: use in-memory map we just saved
        favouriteCollection = null;  // invalidate cache
        modelDataChanged();
        return _favouriteMap[key] || false;
    }

    function updateFavouriteGames(skipLoad) {
        if (!collections) return;
        if (!skipLoad) _loadFavouriteMap();

        var tempFavs = [];
        for (var i = 0; i < collections.count; i++) {
            var collection = collections.get(i);
            if (collection && collection.games) {
                for (var j = 0; j < collection.games.count; j++) {
                    var game = collection.games.get(j);
                    if (game && _favouriteMap[_favouriteKey(game, collection.shortName)]) {
                        // Attach platform metadata as dynamic JS properties
                        game.originalPlatformName = collection.shortName;
                        game.originalPlatform = collection;
                        tempFavs.push(game);
                    }
                }
            }
        }

        // Sort alphabetically by title
        tempFavs.sort(function(a, b) {
            return (a.title || "").localeCompare(b.title || "");
        });

        favouriteGames = tempFavs;
    }

    function getFavouritesForPlatform(platformShortName) {
        if (!platformShortName) return [];
        var plat = platformShortName.toLowerCase();
        var result = [];
        for (var key in _favouriteMap) {
            if (_favouriteMap[key] && key.indexOf(plat + "|") === 0) {
                result.push(key.substring(plat.length + 1));
            }
        }
        return result;
    }

    function updateGameCubeGames() {
        if (!collections) return;

        var tempGameCubeGames = [];

        for (var i = 0; i < collections.count; i++) {
            var collection = collections.get(i);

            if (collection && collection.shortName.toLowerCase() === "wii" && collection.games) {
                for (var j = 0; j < collection.games.count; j++) {
                    var game = collection.games.get(j);
                    if (game) {
                        var detectedPlatform = Utils.detectGameCubePlatform(game, "wii");
                        if (detectedPlatform === "gc") {
                            tempGameCubeGames.push(game);
                        }
                    }
                }
                break;
            }
        }

        gameCubeGames = tempGameCubeGames;
        // Note: resetCachedCollections() and modelDataChanged() are called by the caller (onCountChanged)
    }

    function getCollectionAt(index) {
        var raOffset = raVisible ? 1 : 0;

        // Index 0 = RA platform (always visible)
        if (raVisible && index === 0) {
            if (!raCollection) {
                raCollection = createRaCollection();
            }
            return raCollection;
        }

        // Default (lpFavSwapped=false): LP first, Fav second
        // Swapped (lpFavSwapped=true):  Fav first, LP second
        var firstIsLP = !lpFavSwapped;

        if ((lastPlayedVisible || favouriteVisible) && index === raOffset) {
            if (firstIsLP) {
                if (lastPlayedVisible) {
                    if (!lastPlayedCollection) lastPlayedCollection = createLastPlayedCollection();
                    return lastPlayedCollection;
                } else if (favouriteVisible) {
                    if (!favouriteCollection) favouriteCollection = createFavouriteCollection();
                    return favouriteCollection;
                }
            } else {
                if (favouriteVisible) {
                    if (!favouriteCollection) favouriteCollection = createFavouriteCollection();
                    return favouriteCollection;
                } else if (lastPlayedVisible) {
                    if (!lastPlayedCollection) lastPlayedCollection = createLastPlayedCollection();
                    return lastPlayedCollection;
                }
            }
        }

        // Slot 2 (index = raOffset + 1): only if BOTH are visible
        if (lastPlayedVisible && favouriteVisible && index === raOffset + 1) {
            if (firstIsLP) {
                // Slot 1 was LP, slot 2 is Fav
                if (!favouriteCollection) favouriteCollection = createFavouriteCollection();
                return favouriteCollection;
            } else {
                // Slot 1 was Fav, slot 2 is LP
                if (!lastPlayedCollection) lastPlayedCollection = createLastPlayedCollection();
                return lastPlayedCollection;
            }
        }

        // Remaining indices map to orderedPlatforms
        var specialCount = raOffset + (lastPlayedVisible ? 1 : 0) + (favouriteVisible ? 1 : 0);
        var platformIndex = index - specialCount;
        if (platformIndex < 0 || !orderedPlatforms || platformIndex >= orderedPlatforms.length) {
            return null;
        }

        var shortName = orderedPlatforms[platformIndex];

        if (shortName === "gc") {
            if (!gameCubeCollection) {
                gameCubeCollection = createGameCubeCollection();
            }
            return gameCubeCollection;
        }

        // Find in api.collections
        if (collections) {
            for (var i = 0; i < collections.count; i++) {
                var c = collections.get(i);
                if (c && c.shortName === shortName) {
                    // Filter Wii if GC games exist
                    if (shortName.toLowerCase() === "wii" && gameCubeGames.length > 0) {
                        if (!filteredWiiCollection) filteredWiiCollection = createFilteredWiiCollection(c);
                        return filteredWiiCollection;
                    }
                    return c;
                }
            }
        }
        return null;
    }

    function getTotalCount() {
        return platformCount;
    }

    function createFilteredWiiCollection(originalWiiCollection) {
        var filteredGames = [];

        if (originalWiiCollection.games) {
            for (var i = 0; i < originalWiiCollection.games.count; i++) {
                var game = originalWiiCollection.games.get(i);
                if (game) {
                    var detectedPlatform = Utils.detectGameCubePlatform(game, "wii");
                    if (detectedPlatform === "wii") {
                        filteredGames.push(game);
                    }
                }
            }
        }

        var filteredCollection = {
            name: originalWiiCollection.name,
            shortName: originalWiiCollection.shortName,
            summary: originalWiiCollection.summary,
            games: {
                count: filteredGames.length,
                get: function(index) {
                    return (index >= 0 && index < filteredGames.length) ? filteredGames[index] : null;
                }
            }
        };

        return filteredCollection;
    }

    signal collectionChanged(var collection)
    signal scrollingStarted()
    signal scrollingStopped()

    // Debounce: fires collection change after all logo animations complete.
    Timer {
        id: collectionDebounce
        interval: 400
        repeat: false
        onTriggered: {
            scrollStartDeferTimer.stop();
            if (pendingCollectionIndex >= 0 && pendingCollectionIndex < getTotalCount()) {
                var selectedCollection = getCollectionAt(pendingCollectionIndex);
                if (selectedCollection) {
                    platformBar.collectionChanged(selectedCollection);
                }
            }
            pendingCollectionIndex = -1;
            isScrollingAsyncMode = false;
            scrollingStopped();
        }
    }

    // Deferred scrollingStarted — fires after scroll (100ms) + scale (250ms) animations complete.
    Timer {
        id: scrollStartDeferTimer
        interval: 360
        repeat: false
        onTriggered: scrollingStarted()
    }

    function selectPrevPlatform() {
        previousPlatform()
    }

    function selectNextPlatform() {
        nextPlatform()
    }

    // First real platform index (after RA if visible)
    readonly property int _firstRealIndex: raVisible ? 1 : 0

    function nextPlatform() {
        if (isCoverSelected) return;
        showBar();
        if (currentIndex < listView.count - 1) {
            currentIndex++;
        } else {
            currentIndex = _firstRealIndex;
        }
    }

    function previousPlatform() {
        if (isCoverSelected) return;
        showBar();
        if (currentIndex > _firstRealIndex) {
            currentIndex--;
        } else {
            currentIndex = listView.count - 1;
        }
    }

    // Navigate directly to RA platform (index 0) — only via icon
    function goToRaPlatform() {
        if (!raVisible) return;
        collectionDebounce.stop();
        currentIndex = 0;
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 10
        orientation: ListView.Horizontal
        spacing: _platformSpacing
        clip: true
        enabled: !platformBar.isCoverSelected
        // focus: true

        model: platformBar.platformCount

        snapMode: ListView.SnapToItem
        preferredHighlightBegin: width / 2 - _platformItemWidthCurrent / 2
        preferredHighlightEnd: width / 2 + _platformItemWidthCurrent / 2
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: 100
        highlightMoveVelocity: -1
        boundsBehavior: Flickable.DragOverBounds
        flickDeceleration: 1500
        maximumFlickVelocity: 2000
        cacheBuffer: 1200
        displayMarginBeginning: 400
        displayMarginEnd: 400

        // Smooth entrance animation with left-to-right slide + bounce
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
            NumberAnimation { property: "x"; from: -80; duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
        }

        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBack; easing.overshoot: 1.0 }
        }

        delegate: Item {
            id: platformItem

            width: isCurrent ? platformBar._platformItemWidthCurrent : platformBar._platformItemWidth

            Behavior on width {
                NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
            }

            height: listView.height

            y: isCurrent ? platformBar._platformCenterOffsetY : 0

            Behavior on y {
                NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
            }

            property bool isCurrent: ListView.isCurrentItem
            property bool isHovered: mouseArea.containsMouse
            property var collection: null

            Component.onCompleted: {
                collection = platformBar.getCollectionAt(index);
            }

            Connections {
                target: platformBar
                function onModelDataChanged() {
                    Qt.callLater(function() {
                        collection = platformBar.getCollectionAt(index);
                    });
                }
            }

            Rectangle {
                id: itemContainer
                anchors.fill: parent
                anchors.margins: 5
                color: "transparent"
                radius: 12

                border.width: 0

                // Scale animation delayed: starts after scroll animation (200ms) completes
                property bool _scaleAnimReady: false
                scale: (_scaleAnimReady && isCurrent) ? Cfg.PlatformBarConfig.platformScale : 1.0
                transformOrigin: Item.Center

                opacity: platformBar.isCoverSelected ? 0.0 : (isCurrent ? 1.0 : platformBar.nonCurrentOpacity)

                // Trigger scale after scroll completes
                onVisibleChanged: if (visible) _scaleAnimReady = isCurrent
                Timer {
                    id: scaleDelayTimer
                    interval: 110  // just after scroll animation (100ms)
                    repeat: false
                    onTriggered: itemContainer._scaleAnimReady = true
                }

                Connections {
                    target: platformItem
                    function onIsCurrentChanged() {
                        if (platformItem.isCurrent) {
                            itemContainer._scaleAnimReady = false;
                            scaleDelayTimer.restart();
                        } else {
                            // Shrink immediately when deselected
                            itemContainer._scaleAnimReady = false;
                        }
                    }
                }

                Behavior on scale {
                    NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.05 }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }

                Column {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 20
                    spacing: Math.round(platformBar._platformBarHeight * 0.25)

                    Item {
                        id: logoContainer
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: platformBar._platformLogoSize
                        height: platformBar._platformLogoSize
                        scale: isCurrent ? 1.25 : 1.0
                        transformOrigin: Item.Center

                        Behavior on scale {
                            NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
                        }

                        // Padded wrapper — provides transparent margins so the SDF outline
                        // can detect edges even where the logo reaches the image boundary.
                        // Without this, logos that fill the full width (e.g. Commodore)
                        // get their outline clipped on left/right due to texture clamping.
                        Item {
                            id: logoPaddedWrapper
                            anchors.centerIn: parent
                            width: Math.ceil(logoContainer.width * 1.8)
                            height: Math.ceil(logoContainer.height * 1.4)

                            Image {
                                id: platformImage
                                anchors.centerIn: parent
                                width: platformBar._platformLogoSize
                                height: platformBar._platformLogoSize
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                asynchronous: AntialiasingManager.asynchronousLoading
                                cache: AntialiasingManager.cachedImages
                                mipmap: true
                                antialiasing: true
                                // Fixed sourceSize to prevent async reload when isCurrent changes
                                sourceSize.width: platformBar._platformLogoSize * 2
                                sourceSize.height: platformBar._platformLogoSize * 2
                                // Always visible inside the wrapper — ShaderEffectSource.hideSource
                                // handles hiding the wrapper when the outline shader is active.
                                visible: !(collection && collection.shortName === "ra")
                                source: (collection && collection.shortName === "ra") ? "" : Qt.resolvedUrl("../../assets/images/logospng/" + (collection && collection.shortName ? collection.shortName.toLowerCase() : "") + ".png")

                                Component.onCompleted: {
                                    AntialiasingManager.applyToImage(platformImage);
                                }
                            }
                        }

                        ShaderEffectSource {
                            id: logoSource
                            sourceItem: logoPaddedWrapper
                            hideSource: logoOutline.visible
                            live: isCurrent
                        }

                        ShaderEffect {
                            id: logoOutline
                            anchors.centerIn: parent
                            width: logoPaddedWrapper.width
                            height: logoPaddedWrapper.height
                            smooth: true
                            antialiasing: true
                            property variant source: logoSource

                            property var outlineConfig: collection ? Cfg.PlatformBarConfig.getOutlineConfig(collection.shortName) : Cfg.PlatformBarConfig.getOutlineConfig("default")

                            // Conical gradient colors: use platform custom colors or animated defaults
                            property variant outlineColorsArray: outlineConfig ? (outlineConfig.outlineColors || null) : null
                            property color col1: (outlineColorsArray && outlineColorsArray.length >= 1) ? outlineColorsArray[0] : platformBar._borderAnim
                            property color col2: (outlineColorsArray && outlineColorsArray.length >= 2) ? outlineColorsArray[1] : platformBar._borderAnim2
                            property color col3: (outlineColorsArray && outlineColorsArray.length >= 3) ? outlineColorsArray[2] : platformBar._borderAnim3
                            property real gradAngle: platformBar._borderAngle * 0.0174533  // degrees to radians

                            property real outlineOpacity: outlineConfig ? outlineConfig.outlineOpacity : 1.0
                            property real outlineSize: outlineConfig ? outlineConfig.outlineSize : 1.0
                            property real outlineVerticalScale: outlineConfig ? outlineConfig.outlineVerticalScale : 0.6
                            property real outlineHorizontalScale: outlineConfig ? outlineConfig.outlineHorizontalScale : 2.0
                            property real alphaThreshold: outlineConfig ? outlineConfig.alphaThreshold : 0.08
                            property real soft: outlineConfig ? outlineConfig.soft : 0.02
                            // px = 1 texel in UV space, based on the padded wrapper size
                            property vector2d px: Qt.vector2d(1.0 / Math.max(1, logoPaddedWrapper.width), 1.0 / Math.max(1, logoPaddedWrapper.height))

                            visible: isCurrent && platformImage.status === Image.Ready && !(collection && collection.shortName === "ra") && platformBar.logoOutlineEnabled && (outlineConfig ? outlineConfig.enableOutline : true)

                            fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform sampler2D source;
        uniform lowp float outlineOpacity;
        uniform highp float outlineSize;
        uniform highp float outlineVerticalScale;
        uniform highp float outlineHorizontalScale;
        uniform lowp float alphaThreshold;
        uniform lowp float soft;
        uniform highp vec2 px;
        uniform lowp vec4 col1;
        uniform lowp vec4 col2;
        uniform lowp vec4 col3;
        uniform highp float gradAngle;

        lowp float sampleCov(sampler2D tex, highp vec2 coord, lowp float thresh, lowp float s) {
            if (coord.x < 0.0 || coord.x > 1.0 || coord.y < 0.0 || coord.y > 1.0) return 0.0;
            return smoothstep(thresh, thresh + s, texture2D(tex, coord).a);
        }

        void main() {
            highp vec2 uv = qt_TexCoord0;
            lowp vec4 baseCol = texture2D(source, uv);
            lowp float a0 = baseCol.a;

            highp vec2 o = vec2(
                px.x * outlineSize * outlineHorizontalScale,
                px.y * outlineSize * outlineVerticalScale
            );

            // Ring 1: 16 samples at 22.5 deg intervals
            highp float C1 = 0.92388;
            highp float S1 = 0.38268;
            highp float C2 = 0.70711;
            lowp float cov = 0.0;
            cov += sampleCov(source, uv + vec2( o.x, 0.0), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2(-o.x, 0.0), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2(0.0,  o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2(0.0, -o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2( C1*o.x,  S1*o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2(-C1*o.x, -S1*o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2( S1*o.x,  C1*o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2(-S1*o.x, -C1*o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2( C2*o.x,  C2*o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2(-C2*o.x, -C2*o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2(-C2*o.x,  C2*o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2( C2*o.x, -C2*o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2(-S1*o.x,  C1*o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2( S1*o.x, -C1*o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2(-C1*o.x,  S1*o.y), alphaThreshold, soft);
            cov += sampleCov(source, uv + vec2( C1*o.x, -S1*o.y), alphaThreshold, soft);
            cov /= 16.0;

            // Ring 2: 8 samples at 0.55x radius
            highp vec2 oi = o * 0.55;
            highp float CI = 0.98079;
            highp float SI = 0.19509;
            highp float CJ = 0.83147;
            highp float SJ = 0.55557;
            lowp float inner = 0.0;
            inner += sampleCov(source, uv + vec2( CI*oi.x,  SI*oi.y), alphaThreshold, soft);
            inner += sampleCov(source, uv + vec2(-CI*oi.x, -SI*oi.y), alphaThreshold, soft);
            inner += sampleCov(source, uv + vec2( SJ*oi.x,  CJ*oi.y), alphaThreshold, soft);
            inner += sampleCov(source, uv + vec2(-SJ*oi.x, -CJ*oi.y), alphaThreshold, soft);
            inner += sampleCov(source, uv + vec2(-SI*oi.x,  CI*oi.y), alphaThreshold, soft);
            inner += sampleCov(source, uv + vec2( SI*oi.x, -CI*oi.y), alphaThreshold, soft);
            inner += sampleCov(source, uv + vec2(-CJ*oi.x,  SJ*oi.y), alphaThreshold, soft);
            inner += sampleCov(source, uv + vec2( CJ*oi.x, -SJ*oi.y), alphaThreshold, soft);
            inner /= 8.0;

            lowp float sdf = cov * 0.6 + inner * 0.4;
            lowp float baseMask = smoothstep(alphaThreshold, alphaThreshold + soft * 2.0, a0);
            lowp float edge = smoothstep(0.02, 0.55, sdf) * (1.0 - baseMask);

            // Conical gradient color (same technique as clock / RA Hub)
            highp vec2 center = uv - vec2(0.5);
            highp float a = atan(center.y, center.x) + gradAngle;
            highp float t = fract(a / 6.2831853);
            lowp vec4 gradColor;
            if (t < 0.333)
                gradColor = mix(col1, col2, t * 3.0);
            else if (t < 0.666)
                gradColor = mix(col2, col3, (t - 0.333) * 3.0);
            else
                gradColor = mix(col3, col1, (t - 0.666) * 3.0);

            vec3 final_color = gradColor.rgb;

            lowp float aBase = a0;
            lowp float aOutline = outlineOpacity * edge;
            lowp float outA = aBase + aOutline * (1.0 - aBase);
            lowp vec3 outRGB = vec3(0.0);

            if (outA > 1e-6) {
                outRGB = (baseCol.rgb * aBase + final_color * aOutline * (1.0 - aBase)) / outA;
            }

            gl_FragColor = vec4(outRGB, outA);
        }
"
                        }

                        Text {
                            id: platformName
                            anchors.centerIn: parent
                            text: {
                                if (!collection) return "";
                                if (collection.shortName === "ra") return "RA";
                                return collection.name;
                            }
                            color: {
                                if (!collection) return "white";
                                if (collection.shortName === "ra" && isCurrent) return "#FFD700";  // Gold for RA
                                return isCurrent ? "#4A9EFF" : "white";
                            }
                            font.pixelSize: {
                                if (collection && collection.shortName === "ra") return isCurrent ? platformBar._fontSizeMedium * 1.2 : platformBar._fontSizeSmall;
                                return isCurrent ? platformBar._fontSizeMedium : platformBar._fontSizeSmall;
                            }
                            font.bold: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            visible: platformImage.status === Image.Error || (collection && collection.shortName === "ra")

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            Behavior on font.pixelSize {
                                NumberAnimation { duration: 150 }
                            }
                        }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (listView.currentIndex !== index) {
                            listView.currentIndex = index;
                        }
                    }
                }
            }
        }

        onCurrentIndexChanged: {
            if (!_startupApplied) return;

            if (currentIndex >= 0 && currentIndex < getTotalCount()) {
                pendingCollectionIndex = currentIndex;
            }

            if (!isScrollingAsyncMode) {
                isScrollingAsyncMode = true;
            }

            scrollStartDeferTimer.restart();
            collectionDebounce.restart();
        }

        Keys.onLeftPressed: {
            platformBar.selectPrevPlatform();
            event.accepted = true;
        }

        Keys.onRightPressed: {
            platformBar.selectNextPlatform();
            event.accepted = true;
        }
    }

    Item {
        id: leftCoverButton
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.leftMargin: 20
        width: 60
        height: 60

        opacity: isCoverSelected ? 1.0 : 0.0
        scale: isCoverSelected ? 1.0 : 0.7
        visible: opacity > 0

        property real pressedScale: 1.0
        property real gradientPhase: 0.0

        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 400; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
        }
        Behavior on pressedScale {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }

        NumberAnimation on gradientPhase {
            from: 0
            to: 1
            duration: 3000
            loops: Animation.Infinite
            easing.type: Easing.InOutSine
            running: isCoverSelected  // Stop animation when invisible (CPU optimization)
        }

        // Gradient triangle using Canvas
        Canvas {
            id: leftTriangleCanvas
            anchors.centerIn: parent
            width: 50
            height: 50
            scale: parent.pressedScale
            layer.enabled: true
            layer.effect: DropShadow {
                id: leftTriangleGlow
                horizontalOffset: 0
                verticalOffset: 0
                radius: platformBar.leftGlowIntensity > 0 ? 16 : 4
                samples: platformBar.leftGlowIntensity > 0 ? 33 : 9
                color: platformBar.leftGlowIntensity > 0 ? "#CC5588FF" : "#445588FF"
                spread: 0.3
            }

            property real animPhase: parent.gradientPhase

            onAnimPhaseChanged: {
                requestPaint();
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                // Create diagonal linear gradient
                var gradient = ctx.createLinearGradient(0, 0, width, height);

                var phase = animPhase;

                if (phase < 0.25) {
                    // Blue -> Purple
                    var t = phase * 4;
                    gradient.addColorStop(0, platformBar.interpolateColor("#3366FF", "#9933FF", t));
                    gradient.addColorStop(0.5, "#9933FF");
                    gradient.addColorStop(1, platformBar.interpolateColor("#4D7FE6", "#BB66FF", t));
                } else if (phase < 0.5) {
                    // Purple -> Light blue
                    var t = (phase - 0.25) * 4;
                    gradient.addColorStop(0, platformBar.interpolateColor("#9933FF", "#6B8EFF", t));
                    gradient.addColorStop(0.5, platformBar.interpolateColor("#9933FF", "#4D7FE6", t));
                    gradient.addColorStop(1, "#BB66FF");
                } else if (phase < 0.75) {
                    // Light blue -> Purple
                    var t = (phase - 0.5) * 4;
                    gradient.addColorStop(0, platformBar.interpolateColor("#6B8EFF", "#9933FF", t));
                    gradient.addColorStop(0.5, "#4D7FE6");
                    gradient.addColorStop(1, platformBar.interpolateColor("#BB66FF", "#9933FF", t));
                } else {
                    // Purple -> Blue
                    var t = (phase - 0.75) * 4;
                    gradient.addColorStop(0, platformBar.interpolateColor("#9933FF", "#3366FF", t));
                    gradient.addColorStop(0.5, platformBar.interpolateColor("#4D7FE6", "#9933FF", t));
                    gradient.addColorStop(1, "#9933FF");
                }

                ctx.fillStyle = gradient;

                var cornerRadius = 4;  // Corner radius for rounded edges

                // Equilateral triangle calculation:
                // Height = lato * sqrt(3) / 2
                // If vertical base = height * 0.6, then side = height * 0.6

                var triangleHeight = height * 0.6;  // Triangle height (vertical base)
                var triangleWidth = triangleHeight * 0.866;  // Width (sqrt(3)/2 ≈ 0.866)

                var centerX = width / 2;
                var centerY = height / 2;

                // Equilateral triangle vertices (pointing left)
                var p1x = centerX - triangleWidth * 0.577;  // Left tip (1/sqrt(3) ≈ 0.577)
                var p1y = centerY;
                var p2x = centerX + triangleWidth * 0.289;  // Top right (1/(2*sqrt(3)) ≈ 0.289)
                var p2y = centerY - triangleHeight / 2;
                var p3x = centerX + triangleWidth * 0.289;  // Bottom right
                var p3y = centerY + triangleHeight / 2;

                // Draw with rounded corners using arcTo
                ctx.beginPath();

                ctx.moveTo(p1x + cornerRadius * 0.7, p1y - cornerRadius * 0.5);

                ctx.lineTo(p2x - cornerRadius, p2y + cornerRadius * 0.5);
                ctx.arcTo(p2x, p2y, p2x, p2y + cornerRadius, cornerRadius);

                ctx.lineTo(p3x, p3y - cornerRadius);
                ctx.arcTo(p3x, p3y, p3x - cornerRadius, p3y, cornerRadius);

                ctx.lineTo(p1x + cornerRadius, p1y + cornerRadius * 0.5);
                ctx.arcTo(p1x, p1y, p1x + cornerRadius * 0.7, p1y - cornerRadius * 0.5, cornerRadius);

                ctx.closePath();
                ctx.fill();
            }

            Component.onCompleted: {
                requestPaint();
            }
        }

        Text {
            id: leftL1Text
            anchors.left: leftTriangleCanvas.right
            anchors.leftMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18
            text: "L1"
            color: "#FFFFFF"
            font.pixelSize: 16
            font.bold: true
            opacity: 0.9
            layer.enabled: true
            layer.effect: DropShadow {
                id: leftTextGlow
                horizontalOffset: 0
                verticalOffset: 0
                radius: platformBar.leftGlowIntensity > 0 ? 12 : 3
                samples: platformBar.leftGlowIntensity > 0 ? 25 : 7
                color: platformBar.leftGlowIntensity > 0 ? "#CC5588FF" : "#445588FF"
                spread: 0.3
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onPressed: {
                parent.pressedScale = 0.9
                platformBar.leftGlowIntensity = 1.0
            }

            onReleased: {
                parent.pressedScale = 1.0
                platformBar.leftGlowIntensity = 0.0
            }

            onClicked: {
                if (coverFlowRef && coverFlowRef.isCoverSelected) {
                    coverFlowRef.scrollPrevCoverInSelectedMode()
                }
            }
        }
    }

    Item {
        id: rightCoverButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.rightMargin: 20
        width: 60
        height: 60

        opacity: isCoverSelected ? 1.0 : 0.0
        scale: isCoverSelected ? 1.0 : 0.7
        visible: opacity > 0

        property real pressedScale: 1.0
        property real gradientPhase: 0.0

        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 400; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
        }
        Behavior on pressedScale {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }

        NumberAnimation on gradientPhase {
            from: 0
            to: 1
            duration: 3000
            loops: Animation.Infinite
            easing.type: Easing.InOutSine
            running: isCoverSelected  // Stop animation when invisible (CPU optimization)
        }

        Text {
            id: rightR1Text
            anchors.right: rightTriangleCanvas.left
            anchors.rightMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18
            text: "R1"
            color: "#FFFFFF"
            font.pixelSize: 16
            font.bold: true
            opacity: 0.9
            layer.enabled: true
            layer.effect: DropShadow {
                id: rightTextGlow
                horizontalOffset: 0
                verticalOffset: 0
                radius: platformBar.rightGlowIntensity > 0 ? 12 : 3
                samples: platformBar.rightGlowIntensity > 0 ? 25 : 7
                color: platformBar.rightGlowIntensity > 0 ? "#CC5588FF" : "#445588FF"
                spread: 0.3
            }
        }

        // Gradient triangle using Canvas
        Canvas {
            id: rightTriangleCanvas
            anchors.centerIn: parent
            width: 50
            height: 50
            scale: parent.pressedScale
            layer.enabled: true
            layer.effect: DropShadow {
                id: rightTriangleGlow
                horizontalOffset: 0
                verticalOffset: 0
                radius: platformBar.rightGlowIntensity > 0 ? 16 : 4
                samples: platformBar.rightGlowIntensity > 0 ? 33 : 9
                color: platformBar.rightGlowIntensity > 0 ? "#CC5588FF" : "#445588FF"
                spread: 0.3
            }

            property real animPhase: parent.gradientPhase

            onAnimPhaseChanged: {
                requestPaint();
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                // Create diagonal linear gradient
                var gradient = ctx.createLinearGradient(0, 0, width, height);

                var phase = animPhase;

                if (phase < 0.25) {
                    // Blue -> Purple
                    var t = phase * 4;
                    gradient.addColorStop(0, platformBar.interpolateColor("#3366FF", "#9933FF", t));
                    gradient.addColorStop(0.5, "#9933FF");
                    gradient.addColorStop(1, platformBar.interpolateColor("#4D7FE6", "#BB66FF", t));
                } else if (phase < 0.5) {
                    // Purple -> Light blue
                    var t = (phase - 0.25) * 4;
                    gradient.addColorStop(0, platformBar.interpolateColor("#9933FF", "#6B8EFF", t));
                    gradient.addColorStop(0.5, platformBar.interpolateColor("#9933FF", "#4D7FE6", t));
                    gradient.addColorStop(1, "#BB66FF");
                } else if (phase < 0.75) {
                    // Light blue -> Purple
                    var t = (phase - 0.5) * 4;
                    gradient.addColorStop(0, platformBar.interpolateColor("#6B8EFF", "#9933FF", t));
                    gradient.addColorStop(0.5, "#4D7FE6");
                    gradient.addColorStop(1, platformBar.interpolateColor("#BB66FF", "#9933FF", t));
                } else {
                    // Purple -> Blue
                    var t = (phase - 0.75) * 4;
                    gradient.addColorStop(0, platformBar.interpolateColor("#9933FF", "#3366FF", t));
                    gradient.addColorStop(0.5, platformBar.interpolateColor("#4D7FE6", "#9933FF", t));
                    gradient.addColorStop(1, "#9933FF");
                }

                ctx.fillStyle = gradient;

                var cornerRadius = 4;  // Corner radius for rounded edges

                // Equilateral triangle calculation:
                // Height = lato * sqrt(3) / 2
                // If vertical base = height * 0.6, then side = height * 0.6

                var triangleHeight = height * 0.6;  // Triangle height (vertical base)
                var triangleWidth = triangleHeight * 0.866;  // Width (sqrt(3)/2 ≈ 0.866)

                var centerX = width / 2;
                var centerY = height / 2;

                // Equilateral triangle vertices (pointing right)
                var p1x = centerX + triangleWidth * 0.577;  // Right tip (1/sqrt(3) ≈ 0.577)
                var p1y = centerY;
                var p2x = centerX - triangleWidth * 0.289;  // Top left (1/(2*sqrt(3)) ≈ 0.289)
                var p2y = centerY - triangleHeight / 2;
                var p3x = centerX - triangleWidth * 0.289;  // Bottom left
                var p3y = centerY + triangleHeight / 2;

                // Draw with rounded corners using arcTo
                ctx.beginPath();

                ctx.moveTo(p1x - cornerRadius * 0.7, p1y - cornerRadius * 0.5);

                ctx.lineTo(p2x + cornerRadius, p2y + cornerRadius * 0.5);
                ctx.arcTo(p2x, p2y, p2x, p2y + cornerRadius, cornerRadius);

                ctx.lineTo(p3x, p3y - cornerRadius);
                ctx.arcTo(p3x, p3y, p3x + cornerRadius, p3y, cornerRadius);

                ctx.lineTo(p1x - cornerRadius, p1y + cornerRadius * 0.5);
                ctx.arcTo(p1x, p1y, p1x - cornerRadius * 0.7, p1y - cornerRadius * 0.5, cornerRadius);

                ctx.closePath();
                ctx.fill();
            }

            Component.onCompleted: {
                requestPaint();
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onPressed: {
                parent.pressedScale = 0.9
                platformBar.rightGlowIntensity = 1.0
            }

            onReleased: {
                parent.pressedScale = 1.0
                platformBar.rightGlowIntensity = 0.0
            }

            onClicked: {
                if (coverFlowRef && coverFlowRef.isCoverSelected) {
                    coverFlowRef.scrollNextCoverInSelectedMode()
                }
            }
        }
    }

    // ── Button Legend Bar (visible in isSelected mode, centered between L1 and R1) ──
    Item {
        id: selectedLegendBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: screenMetrics ? screenMetrics.legendBarMargin : 22
        width: selectedLegendRow.width + 32
        height: screenMetrics ? screenMetrics.legendBarHeight : 36

        opacity: isCoverSelected ? 1.0 : 0.0
        scale: isCoverSelected ? 1.0 : 0.85
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack; easing.overshoot: 1.0 } }

        // Convenience aliases for readability
        readonly property int _bs:  screenMetrics ? screenMetrics.legendBadgeSize     : 22
        readonly property int _pw:  screenMetrics ? screenMetrics.legendPillWidth      : 26
        readonly property int _sw:  screenMetrics ? screenMetrics.legendSelectWidth    : 56
        readonly property int _fl:  screenMetrics ? screenMetrics.legendFontSize       : 13
        readonly property int _fb:  screenMetrics ? screenMetrics.legendBadgeFontSize  : 12
        readonly property int _fp:  screenMetrics ? screenMetrics.legendPillFontSize   : 10
        readonly property int _sepH: screenMetrics ? screenMetrics.legendSeparatorH    : 16

        Row {
            id: selectedLegendRow
            anchors.centerIn: parent
            spacing: 16

            // [L2] [R2] Zoom (left side)
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: selectedLegendBar._pw; height: selectedLegendBar._bs; radius: 4
                    color: "#20FFFFFF"; border.color: "#40FFFFFF"; border.width: 1
                    Text { anchors.centerIn: parent; text: "L2"; color: "#AAAACC"; font.pixelSize: selectedLegendBar._fp; font.bold: true }
                }
                Rectangle {
                    width: selectedLegendBar._pw; height: selectedLegendBar._bs; radius: 4
                    color: "#20FFFFFF"; border.color: "#40FFFFFF"; border.width: 1
                    Text { anchors.centerIn: parent; text: "R2"; color: "#AAAACC"; font.pixelSize: selectedLegendBar._fp; font.bold: true }
                }
                Text { text: T.t("gc_legend_zoom", platformBar.lang); color: "#8888AA"; font.pixelSize: selectedLegendBar._fl; anchors.verticalCenter: parent.verticalCenter }
            }

            // Separator
            Rectangle { width: 1; height: selectedLegendBar._sepH; color: "#30FFFFFF"; anchors.verticalCenter: parent.verticalCenter }

            // (A) Play
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: selectedLegendBar._bs; height: selectedLegendBar._bs; radius: selectedLegendBar._bs / 2
                    color: "#20FFFFFF"; border.color: "#40FFFFFF"; border.width: 1
                    Text { anchors.centerIn: parent; text: "A"; color: "#AAAACC"; font.pixelSize: selectedLegendBar._fb; font.bold: true }
                }
                Text { text: T.t("gc_legend_play", platformBar.lang); color: "#8888AA"; font.pixelSize: selectedLegendBar._fl; anchors.verticalCenter: parent.verticalCenter }
            }

            // (X) More
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: selectedLegendBar._bs; height: selectedLegendBar._bs; radius: selectedLegendBar._bs / 2
                    color: "#20FFFFFF"; border.color: "#40FFFFFF"; border.width: 1
                    Text { anchors.centerIn: parent; text: "X"; color: "#AAAACC"; font.pixelSize: selectedLegendBar._fb; font.bold: true }
                }
                Text { text: T.t("gc_legend_more", platformBar.lang); color: "#8888AA"; font.pixelSize: selectedLegendBar._fl; anchors.verticalCenter: parent.verticalCenter }
            }

            // (Y) Favourite
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: selectedLegendBar._bs; height: selectedLegendBar._bs; radius: selectedLegendBar._bs / 2
                    color: "#20FFFFFF"; border.color: "#40FFFFFF"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Y"; color: "#AAAACC"; font.pixelSize: selectedLegendBar._fb; font.bold: true }
                }
                Text { text: T.t("gc_legend_fav", platformBar.lang); color: "#8888AA"; font.pixelSize: selectedLegendBar._fl; anchors.verticalCenter: parent.verticalCenter }
            }

            // [SELECT] RA
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: selectedLegendBar._sw; height: selectedLegendBar._bs; radius: 4
                    color: "#20FFFFFF"; border.color: "#40FFFFFF"; border.width: 1
                    Text { anchors.centerIn: parent; text: "SELECT"; color: "#AAAACC"; font.pixelSize: selectedLegendBar._fp; font.bold: true }
                }
                Text { text: T.t("gc_legend_ra", platformBar.lang); color: "#8888AA"; font.pixelSize: selectedLegendBar._fl; anchors.verticalCenter: parent.verticalCenter }
            }

            // Separator
            Rectangle { width: 1; height: selectedLegendBar._sepH; color: "#30FFFFFF"; anchors.verticalCenter: parent.verticalCenter }

            // (B) Back
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: selectedLegendBar._bs; height: selectedLegendBar._bs; radius: selectedLegendBar._bs / 2
                    color: "#20FFFFFF"; border.color: "#40FFFFFF"; border.width: 1
                    Text { anchors.centerIn: parent; text: "B"; color: "#AAAACC"; font.pixelSize: selectedLegendBar._fb; font.bold: true }
                }
                Text { text: T.t("gc_legend_back", platformBar.lang); color: "#8888AA"; font.pixelSize: selectedLegendBar._fl; anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }

    Component.onCompleted: {
        _loadFavouriteMap();
        updateLastPlayedGames();
        updateFavouriteGames();
        updateGameCubeGames();
        buildOrderedPlatforms();
        // Initial index is now set by buildOrderedPlatforms based on startup_platform

        // Auto-hide
        var ah = api.memory.get("platformbar_autohide");
        autoHideEnabled = (ah === "true");
        if (autoHideEnabled) {
            autoHideTimer.start();
        }
    }

    // Build the ordered platform list from saved order + available collections
    function buildOrderedPlatforms() {
        if (!collections) { orderedPlatforms = []; return; }

        // RA always visible
        raVisible = true;

        // LP & Fav visibility
        var lpSetting = api.memory.get("lastplayed_visible");
        lastPlayedVisible = (lpSetting === "true");
        var favSetting = api.memory.get("favourite_visible");
        favouriteVisible = (favSetting === "true");

        var swapSetting = api.memory.get("lpfav_swapped");
        lpFavSwapped = (swapSetting === "true");

        var spSetting = api.memory.get("startup_platform");
        startupPlatform = (spSetting && spSetting !== "") ? spSetting : "lastplayed";

        var savedOrderStr = api.memory.get("platform_order");
        var savedOrder = [];
        if (savedOrderStr && savedOrderStr !== "") {
            try { savedOrder = JSON.parse(savedOrderStr); } catch(e) { savedOrder = []; }
        }

        // Build list of available platforms in original order
        var available = {};
        var originalOrder = [];
        for (var i = 0; i < collections.count; i++) {
            var c = collections.get(i);
            if (c && c.games && c.games.count > 0) {
                available[c.shortName] = true;
                originalOrder.push(c.shortName);
            }
        }

        // Add gc if games detected
        if (gameCubeGames.length > 0) {
            available["gc"] = true;
            var wiiIdx = -1;
            for (var w = 0; w < originalOrder.length; w++) {
                if (originalOrder[w].toLowerCase() === "wii") { wiiIdx = w; break; }
            }
            if (wiiIdx >= 0) {
                originalOrder.splice(wiiIdx + 1, 0, "gc");
            } else {
                originalOrder.push("gc");
            }
        }

        var result = [];
        var added = {};

        // Saved order first
        for (var s = 0; s < savedOrder.length; s++) {
            if (available[savedOrder[s]] && !added[savedOrder[s]]) {
                result.push(savedOrder[s]);
                added[savedOrder[s]] = true;
            }
        }

        // Remaining in original order
        for (var r = 0; r < originalOrder.length; r++) {
            if (!added[originalOrder[r]]) {
                result.push(originalOrder[r]);
                added[originalOrder[r]] = true;
            }
        }

        orderedPlatforms = result;

        // Set initial index based on startup_platform setting (once)
        if (_startupApplied) return;

        // For "first_platform", we need real platforms to be loaded
        if (startupPlatform === "first_platform" && result.length === 0) return;

        var targetIndex = _firstRealIndex;  // default: first after RA
        if (startupPlatform === "first_platform") {
            // First real platform after RA, LP, Fav
            var specialCount = (raVisible ? 1 : 0) + (lastPlayedVisible ? 1 : 0) + (favouriteVisible ? 1 : 0);
            targetIndex = specialCount;  // first actual platform
        } else if (startupPlatform === "lastplayed") {
            // Find lastplayed's index
            var total = getTotalCount();
            for (var fi = _firstRealIndex; fi < total; fi++) {
                var fc = getCollectionAt(fi);
                if (fc && fc.shortName === "lastplayed") { targetIndex = fi; break; }
            }
        } else if (startupPlatform === "favourites") {
            var total2 = getTotalCount();
            for (var fi2 = _firstRealIndex; fi2 < total2; fi2++) {
                var fc2 = getCollectionAt(fi2);
                if (fc2 && fc2.shortName === "favourites") { targetIndex = fi2; break; }
            }
        }

        // Validate targetIndex is in bounds
        var maxIndex = getTotalCount() - 1;
        if (targetIndex > maxIndex) targetIndex = _firstRealIndex;

        _startupApplied = true;
        console.log("[PlatformBar] Startup: setting index to", targetIndex, "for startup_platform:", startupPlatform)
        Qt.callLater(function() {
            listView.currentIndex = targetIndex;
            // Force-emit the correct collection immediately after setting index
            // since onCurrentIndexChanged was suppressed before _startupApplied
            var startupCollection = getCollectionAt(targetIndex);
            if (startupCollection) {
                console.log("[PlatformBar] Startup: emitting collection", startupCollection.shortName || startupCollection.name)
                collectionChanged(startupCollection);
            }
        });
    }

    // Apply new order from the reorder panel
    function applyNewOrder(orderArray, lpVisible, raVis, favVis) {
        lastPlayedVisible = lpVisible;
        raVisible = true;
        if (favVis !== undefined) favouriteVisible = favVis;

        // Reload swap + startup settings from memory
        var swapSetting = api.memory.get("lpfav_swapped");
        lpFavSwapped = (swapSetting === "true");

        var spSetting = api.memory.get("startup_platform");
        startupPlatform = (spSetting && spSetting !== "") ? spSetting : "lastplayed";

        orderedPlatforms = orderArray.slice();
        resetCachedCollections();

        // Force ListView recreation
        listView.model = 0;
        listView.model = Qt.binding(function() { return platformBar.platformCount; });

        // Navigate to the chosen startup platform
        var firstReal = _firstRealIndex;
        var targetIndex = firstReal;

        if (startupPlatform === "first_platform") {
            var specialCount = (raVisible ? 1 : 0) + (lastPlayedVisible ? 1 : 0) + (favouriteVisible ? 1 : 0);
            targetIndex = specialCount;
        } else if (startupPlatform === "lastplayed" || startupPlatform === "favourites") {
            var targetSN = startupPlatform === "lastplayed" ? "lastplayed" : "favourites";
            var total = getTotalCount();
            for (var i = firstReal; i < total; i++) {
                var c = getCollectionAt(i);
                if (c && c.shortName === targetSN) { targetIndex = i; break; }
            }
        }

        // Validate bounds
        var maxIndex = getTotalCount() - 1;
        if (targetIndex > maxIndex) targetIndex = firstReal;

        // Force index change + explicit collection update
        // (if index is same as post-reset default, onCurrentIndexChanged won't fire)
        listView.currentIndex = -1;
        listView.currentIndex = targetIndex;

        // Explicitly emit collectionChanged so the carousel updates immediately
        var targetCollection = getCollectionAt(targetIndex);
        if (targetCollection) {
            collectionChanged(targetCollection);
        }
    }
}
