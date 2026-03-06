import QtQuick 2.15
import QtGraphicalEffects 1.15
import ".." as Components
import "../config/Translations.js" as T

// RetroAchievements Hub — Liquid Glass overlay
// Frosted glass panels on blurred backdrop, Apple-style translucent UI
// 2D D-pad: Up/Down between rows, Left/Right across columns in trophy grid
Rectangle {
    id: root
    anchors.fill: parent
    color: "transparent"
    visible: false
    z: 10000

    // Background (mirrors user-selected background from Settings)
    Item {
        id: hubBackground
        anchors.fill: parent
        visible: root.visible

        // Gradient preset (reads from backgroundRef or falls back to preset1)
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: root.backgroundRef ? root.backgroundRef.gradC0 : "#040b14" }
                GradientStop { position: 0.3; color: root.backgroundRef ? root.backgroundRef.gradC1 : "#0b1a32" }
                GradientStop { position: 0.7; color: root.backgroundRef ? root.backgroundRef.gradC2 : "#0f2848" }
                GradientStop { position: 1.0; color: root.backgroundRef ? root.backgroundRef.gradC3 : "#081830" }
            }
        }

        // Decorative wave ribbon 1 (same as Background.qml)
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
                GradientStop { position: 0.35; color: root.backgroundRef ? root.backgroundRef.bgPresets[root.backgroundRef._presetIdx].accent : "#5890d0" }
                GradientStop { position: 0.65; color: root.backgroundRef ? root.backgroundRef.bgPresets[root.backgroundRef._presetIdx].accent : "#5890d0" }
                GradientStop { position: 1.0;  color: "transparent" }
            }
        }

        // Custom background image (shown when user selected "custom" in settings)
        Image {
            id: hubBgImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            source: (root.backgroundRef && root.backgroundRef.settingsBgSource === "custom" && root.backgroundRef.settingsCustomPath !== "")
                    ? "file://" + root.backgroundRef.settingsCustomPath : ""
            opacity: source != "" ? 1.0 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }
        }
    }

    // Public API
    property string lang: "it"
    property bool hubOpen: false
    property var backgroundRef: null  // reference to Background.qml component
    property string raUser: ""
    property string raApiKey: ""

    // Animated border color 1 (primary — rich multi-color journey)
    property color _borderAnim: "#7040c0"
    SequentialAnimation {
        id: _animBorder1
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "_borderAnim"; to: "#5848d8"; duration: 1800; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#4060f0"; duration: 1400; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#2888f0"; duration: 1600; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#18b0d8"; duration: 2000; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#18c8a8"; duration: 1200; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#20a0e0"; duration: 1000; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#6058e0"; duration: 1800; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#9040c0"; duration: 2200; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#a838a8"; duration: 1500; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#8040b8"; duration: 1000; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#7040c0"; duration: 1800; easing.type: Easing.InOutSine   }
    }
    // Animated border color 2 (offset — starts blue-cyan, different timing)
    property color _borderAnim2: "#2090e0"
    SequentialAnimation {
        id: _animBorder2
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#18c8a8"; duration: 2200; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#50d8f0"; duration: 1600; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#a838a8"; duration: 2000; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#e060a0"; duration: 1400; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#6058e0"; duration: 1800; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#38b8d8"; duration: 1200; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#2090e0"; duration: 1600; easing.type: Easing.InOutCubic  }
    }
    // Animated border color 3 (offset — starts teal-green, different timing)
    property color _borderAnim3: "#20b8a0"
    SequentialAnimation {
        id: _animBorder3
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#8040b8"; duration: 1800; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#e08050"; duration: 2400; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#40d8d0"; duration: 1600; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#5060e8"; duration: 2000; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#c848d0"; duration: 1400; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#20b8a0"; duration: 1800; easing.type: Easing.InOutQuad   }
    }
    // Border gradient rotation (slow continuous spin)
    property real _borderAngle: 0
    NumberAnimation {
        id: _animAngle
        target: root; property: "_borderAngle"
        loops: Animation.Infinite
        from: 0;  to: 360;  duration: 10000
    }

    // Glow breathing pulse (stronger range)
    property real _glowPulse: 0.0
    SequentialAnimation {
        id: _animGlow
        loops: Animation.Infinite
        NumberAnimation { target: root; property: "_glowPulse"; to: 1.0;  duration: 2400; easing.type: Easing.InOutSine }
        NumberAnimation { target: root; property: "_glowPulse"; to: 0.45; duration: 2800; easing.type: Easing.InOutSine }
        NumberAnimation { target: root; property: "_glowPulse"; to: 0.85; duration: 1800; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "_glowPulse"; to: 0.30; duration: 2200; easing.type: Easing.InOutSine }
    }

    // Resume button animated color (green → yellow → aqua green)
    property color _resumeAnim: "#2ECC71"
    SequentialAnimation {
        id: _animResume
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "_resumeAnim"; to: "#27AE60"; duration: 1600; easing.type: Easing.InOutSine }
        ColorAnimation { target: root; property: "_resumeAnim"; to: "#F1C40F"; duration: 2200; easing.type: Easing.InOutCubic }
        ColorAnimation { target: root; property: "_resumeAnim"; to: "#E8D44D"; duration: 1000; easing.type: Easing.InOutQuad }
        ColorAnimation { target: root; property: "_resumeAnim"; to: "#1ABC9C"; duration: 2000; easing.type: Easing.InOutSine }
        ColorAnimation { target: root; property: "_resumeAnim"; to: "#16A085"; duration: 1400; easing.type: Easing.OutCubic }
        ColorAnimation { target: root; property: "_resumeAnim"; to: "#2ECC71"; duration: 1800; easing.type: Easing.InOutSine }
    }

    // Entrance stagger animations
    property real _entTopBarOp: 0
    property real _entTopBarY: -12
    property real _entProfileOp: 0
    property real _entProfileY: 24
    property real _entProfileScale: 0.95
    property real _entClockOp: 0
    property real _entClockY: 22
    property real _entClockScale: 0.95
    property real _entLastPlayedOp: 0
    property real _entLastPlayedY: 22
    property real _entLastPlayedScale: 0.95
    property real _entBodyOp: 0
    property real _entBodyY: 35

    SequentialAnimation {
        id: _entranceTopBar
        PauseAnimation { duration: 0 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "_entTopBarOp"; to: 1; duration: 280; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "_entTopBarY"; to: 0; duration: 350; easing.type: Easing.OutQuint }
        }
    }
    SequentialAnimation {
        id: _entranceProfile
        PauseAnimation { duration: 80 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "_entProfileOp";    to: 1;    duration: 380; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "_entProfileY";     to: 0;    duration: 500; easing.type: Easing.OutQuint }
            NumberAnimation { target: root; property: "_entProfileScale"; to: 1.0;  duration: 450; easing.type: Easing.OutQuint }
        }
    }
    SequentialAnimation {
        id: _entranceClock
        PauseAnimation { duration: 200 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "_entClockOp";    to: 1;    duration: 380; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "_entClockY";     to: 0;    duration: 500; easing.type: Easing.OutQuint }
            NumberAnimation { target: root; property: "_entClockScale"; to: 1.0;  duration: 450; easing.type: Easing.OutQuint }
        }
    }
    SequentialAnimation {
        id: _entranceLastPlayed
        PauseAnimation { duration: 280 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "_entLastPlayedOp";    to: 1;    duration: 380; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "_entLastPlayedY";     to: 0;    duration: 500; easing.type: Easing.OutQuint }
            NumberAnimation { target: root; property: "_entLastPlayedScale"; to: 1.0;  duration: 450; easing.type: Easing.OutQuint }
        }
    }
    SequentialAnimation {
        id: _entranceBody
        PauseAnimation { duration: 400 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "_entBodyOp"; to: 1; duration: 420; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "_entBodyY";  to: 0; duration: 550; easing.type: Easing.OutQuint }
        }
    }

    // Brightened glow color
    readonly property color _glowColor: Qt.lighter(_borderAnim, 1.6)

    // Helper: apply alpha to a color
    function _ca(c, a) { return Qt.rgba(c.r, c.g, c.b, a); }

    // Derived colors at different opacities for focused/unfocused states
    readonly property color _borderFocused:   Qt.rgba(_borderAnim.r, _borderAnim.g, _borderAnim.b, 0.70)
    readonly property color _borderNormal:    Qt.rgba(_borderAnim.r, _borderAnim.g, _borderAnim.b, 0.40)
    readonly property color _borderSubtle:    Qt.rgba(_borderAnim.r, _borderAnim.g, _borderAnim.b, 0.30)

    // Random colors palette for game percentage badges
    readonly property var _badgeColors: [
        "#E74C3C", "#3498DB", "#2ECC71", "#9B59B6", "#F39C12",
        "#1ABC9C", "#E67E22", "#2980B9", "#27AE60", "#8E44AD",
        "#D35400", "#16A085", "#C0392B", "#7F8C8D", "#2C3E50"
    ]
    function _badgeColor(idx) { return _badgeColors[idx % _badgeColors.length]; }

    // Expose RAService so theme.qml / GameCard can use it
    property alias raService: raService

    // Placeholder data
    // Profile data (populated from RA API)
    property int totalPoints: 0
    property int totalTrophies: 0
    property int goldTrophies: 0
    property int silverTrophies: 0
    property int bronzeTrophies: 0
    property string rank: "—"

    // Recent trophies (populated from API)
    property var recentTrophies: []

    // Recent games (populated from API)
    property var recentGames: []

    // Last played game from Pegasus API
    property var _pegasusLastGame: null

    function _findLastPlayed() {
        try {
            if (typeof api === 'undefined' || !api.allGames) { _pegasusLastGame = null; return; }
            var best = null;
            var bestTime = 0;
            for (var i = 0; i < api.allGames.count; i++) {
                var g = api.allGames.get(i);
                var t = g.lastPlayed ? g.lastPlayed.getTime() : 0;
                if (t > bestTime) { bestTime = t; best = g; }
            }
            _pegasusLastGame = best;
            console.log("[Hub] Last played: " + (best ? best.title : "none"));
        } catch(e) { _pegasusLastGame = null; }
    }

    function _timeAgoStr(date) {
        if (!date) return "";
        var now = new Date();
        var diffMs = now.getTime() - date.getTime();
        var diffMins = Math.floor(diffMs / 60000);
        if (diffMins < 1) return "Just now";
        if (diffMins < 60) return diffMins + " min ago";
        var diffHrs = Math.floor(diffMins / 60);
        if (diffHrs < 24) return diffHrs + "h ago";
        var diffDays = Math.floor(diffHrs / 24);
        if (diffDays < 30) return diffDays + "d ago";
        return Math.floor(diffDays / 30) + "mo ago";
    }

    signal hubClosed()
    signal settingsRequested()
    signal launchGameRequested(string gameTitle, string consoleName)

    // Flat focus index:
    // 0          = profile card
    // .6       = trophy grid (3 cols × 2 rows)
    // .7+N-1   = game cards
    property int focusIndex: 0
    readonly property int _trophyCols: 3
    readonly property int _trophyCount: recentTrophies.length
    readonly property int _trophyRows: Math.ceil(_trophyCount / _trophyCols)
    readonly property int _gamesStart: 1 + _trophyCount
    readonly property int _totalItems: 1 + _trophyCount + recentGames.length

    property bool detailMode: false
    property var _selectedGameData: null
    property int _detailLevel: 1  // 1=status (with info rapide below fold), 3=full details
    property int _detailSection: 0  // Level 3: 0=tabs, 1=achievements
    property int _detailTabIdx: 0
    property int _detailAchIdx: 0
    property int _detailStatusFocus: 0  // Level 1: 0=trophyPreview, 1=viewAllBtn

    property var _detailTabs: [T.t("ra_tab_all", root.lang), T.t("ra_tab_unlocked", root.lang), T.t("ra_tab_locked", root.lang)]

    onLangChanged: {
        _detailTabs = [T.t("ra_tab_all", root.lang), T.t("ra_tab_unlocked", root.lang), T.t("ra_tab_locked", root.lang)];
        // Rebuild platform tabs with translated default
        var newPlats = [{ name: T.t("ra_all_platforms", root.lang), tag: "" }];
        for (var i = 1; i < _platforms.length; i++) newPlats.push(_platforms[i]);
        _platforms = newPlats;
    }

    // Achievements for selected game (populated from API)
    property var _gameAchievements: []
    // Last 3 unlocked trophies for Level 1 preview
    property var _lastUnlockedTrophies: []

    function openGameDetail(gameData) {
        _selectedGameData = gameData;
        _detailLevel = 1;
        _detailSection = 0;
        _detailTabIdx = 0;
        _detailAchIdx = 0;
        _detailStatusFocus = 0;
        _gameAchievements = [];
        _lastUnlockedTrophies = [];
        detailMode = true;
        if (detailFlick) detailFlick.contentY = 0;

        // Fetch real achievements from RA API (force refresh to get latest data)
        if (gameData && gameData.gameId && gameData.gameId > 0) {
            raService.fetchGameDetail(gameData.gameId, true);
        }
    }
    property bool _cameFromAllGames: false

    function closeGameDetail() {
        detailMode = false;
        if (statusView) statusView.contentY = 0;
        if (_cameFromAllGames) {
            _cameFromAllGames = false;
            allGamesMode = true;
        }
        // Refresh profile and games data when leaving detail view
        raService.fetchUserSummary(true);
        raService.fetchCompletionProgress(true);
        raService.fetchRecentlyPlayedGames();
    }

    property bool allGamesMode: false
    property int _agSection: 0  // 0=toggle, 1=platformTabs, 2=gameGrid
    property int _agPlatIdx: 0
    property int _agGridIdx: 0
    readonly property int _agCols: 4
    property int _agToggleIdx: 0  // 0=RA, 1=All
    property bool _agShowAllPegasus: false  // false=RA games only, true=all Pegasus games

    // All games (populated from API completionProgress)
    property var _allGames: []

    // All Pegasus games (from api.allGames + api.collections)
    property var _pegasusGames: []
    property var _pegasusPlatforms: [
        { name: T.t("ra_all_platforms", root.lang), tag: "" }
    ]

    // Platform filter tabs (dynamically rebuilt from game data)
    property var _platforms: [
        { name: T.t("ra_all_platforms", root.lang), tag: "" }
    ]

    function _buildPegasusGames() {
        if (typeof api === 'undefined' || !api.collections) return;
        var games = [];
        var platSet = {};
        for (var c = 0; c < api.collections.count; c++) {
            var col = api.collections.get(c);
            var platTag = col.shortName || col.name;
            var platName = col.name || platTag;
            for (var g = 0; g < col.games.count; g++) {
                var game = col.games.get(g);
                games.push({
                    title:      game.title || "",
                    platform:   platTag,
                    progress:   0,
                    earned:     0,
                    total:      0,
                    gameId:     0,
                    imageIcon:  game.assets.boxFront || game.assets.screenshot || "",
                    shortLabel: platTag,
                    isPegasus:  true,
                    pegasusGame: game
                });
                platSet[platTag] = platName;
            }
        }
        // Sort alphabetically
        games.sort(function(a, b) { return a.title.localeCompare(b.title); });
        _pegasusGames = games;

        // Rebuild pegasus platform tabs
        var plist = [{ name: T.t("ra_all_platforms", root.lang), tag: "" }];
        for (var p in platSet) {
            plist.push({ name: platSet[p], tag: p });
        }
        _pegasusPlatforms = plist;
        console.log("[Hub] Pegasus games built: " + games.length + " games, " + (plist.length - 1) + " platforms");
    }

    function _activeGames() {
        return _agShowAllPegasus ? _pegasusGames : _allGames;
    }

    function _activePlatforms() {
        return _agShowAllPegasus ? _pegasusPlatforms : _platforms;
    }

    function _filteredGames() {
        var plats = _activePlatforms();
        var tag = plats[_agPlatIdx] ? plats[_agPlatIdx].tag : "";
        var src = _activeGames();
        if (tag === "") return src;
        var result = [];
        for (var i = 0; i < src.length; i++) {
            if (src[i].platform === tag) result.push(src[i]);
        }
        return result;
    }

    function _platformCount(tag) {
        var src = _activeGames();
        if (tag === "") return src.length;
        var c = 0;
        for (var i = 0; i < src.length; i++) {
            if (src[i].platform === tag) c++;
        }
        return c;
    }

    function openAllGames() {
        _agSection = 0;
        _agToggleIdx = _agShowAllPegasus ? 1 : 0;
        _agPlatIdx = 0;
        _agGridIdx = 0;
        allGamesMode = true;
        allGamesFlick.contentY = 0;
        // Build Pegasus games list if not done
        if (_pegasusGames.length === 0) _buildPegasusGames();
    }
    function closeAllGames() {
        allGamesMode = false;
    }

    property bool allTrophiesMode: false
    property int _atSection: 0  // 0=filters, 1=trophyList
    property int _atFilterIdx: 0
    property int _atTrophyIdx: 0

    // All trophies (populated from API recent achievements)
    property var _allTrophies: []

    // Per-game badge cache (gameId → [{badgeUrl, badgeLockedUrl, unlocked, points}])
    property var _gameBadges: ({})
    property int _gameBadgesVersion: 0  // bump to trigger UI refresh
    property var _activeXhrs: []  // prevent GC of pending XHRs
    property var _badgeQueue: []  // serial fetch queue
    signal gameBadgesUpdated()  // imperative signal for delegates

    function _fetchBadgesForGames(games) {
        var queue = [];
        for (var i = 0; i < games.length; i++) {
            var gid = String(games[i].gameId || "");
            if (gid && gid !== "0" && !_gameBadges[gid]) queue.push(gid);
        }
        if (queue.length === 0) return;
        var merged = _badgeQueue.slice();
        for (var j = 0; j < queue.length; j++) {
            if (merged.indexOf(queue[j]) < 0) merged.push(queue[j]);
        }
        _badgeQueue = merged;
        console.log("[Hub] Badge queue: " + _badgeQueue.length + " games");
        if (_activeXhrs.length === 0) _fetchNextBadge();
    }

    function _fetchNextBadge() {
        if (_badgeQueue.length === 0) return;
        var gameId = _badgeQueue.shift();

        var user = raService.raUser || root.raUser;
        var key  = raService.raApiKey || root.raApiKey;
        if (!user || !key || !gameId || _gameBadges[String(gameId)]) {
            console.log("[Hub] Badge skip: gid=" + gameId);
            if (_badgeQueue.length > 0) _badgeTimer.start();
            return;
        }

        var url = "https://retroachievements.org/API/API_GetGameInfoAndUserProgress.php"
                  + "?z=" + encodeURIComponent(user) + "&y=" + encodeURIComponent(key)
                  + "&u=" + encodeURIComponent(user) + "&g=" + gameId;
        console.log("[Hub] Fetching badges gid=" + gameId);

        var xhr = new XMLHttpRequest();
        var xhrList = _activeXhrs;
        xhrList.push(xhr);
        _activeXhrs = xhrList;  // keep reference alive

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            console.log("[Hub] Badge XHR gid=" + gameId + " st=" + xhr.status + " len=" + (xhr.responseText || "").length);

            // Remove from active list
            var list = root._activeXhrs;
            var idx = list.indexOf(xhr);
            if (idx >= 0) { list.splice(idx, 1); root._activeXhrs = list; }

            var ok = (xhr.status === 200 || xhr.status === 0);
            if (ok && xhr.responseText) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    var badges = [];
                    if (data.Achievements) {
                        for (var key in data.Achievements) {
                            var a = data.Achievements[key];
                            badges.push({
                                badgeUrl:       a.BadgeName ? ("https://media.retroachievements.org/Badge/" + a.BadgeName + ".png") : "",
                                badgeLockedUrl: a.BadgeName ? ("https://media.retroachievements.org/Badge/" + a.BadgeName + "_lock.png") : "",
                                unlocked:       !!(a.DateEarned && a.DateEarned !== ""),
                                points:         a.Points || 0,
                                title:          a.Title || ""
                            });
                        }
                    }
                    badges.sort(function(a, b) {
                        if (a.unlocked !== b.unlocked) return b.unlocked ? 1 : -1;
                        return b.points - a.points;
                    });
                    var copy = {};
                    for (var k in root._gameBadges) copy[k] = root._gameBadges[k];
                    copy[String(gameId)] = badges;
                    root._gameBadges = copy;
                    root._gameBadgesVersion++;
                    root.gameBadgesUpdated();
                    console.log("[Hub] Badges OK gid=" + gameId + ": " + badges.length + " achs (v=" + root._gameBadgesVersion + ")");
                } catch (e) {
                    console.log("[Hub] Badge parse err gid=" + gameId + ": " + e);
                }
            } else {
                console.log("[Hub] Badge fail gid=" + gameId + " st=" + xhr.status);
            }
            // Next game after short delay
            if (root._badgeQueue.length > 0) _badgeTimer.start();
        };
        xhr.open("GET", url);
        xhr.send();
    }

    Timer {
        id: _badgeTimer
        interval: 500
        repeat: false
        onTriggered: root._fetchNextBadge()
    }

    function _trophyStatsTotal()   { return _allTrophies.length; }
    function _trophyStatsEarned()  { var c=0; for(var i=0;i<_allTrophies.length;i++) if(_allTrophies[i].unlocked) c++; return c; }
    function _trophyStatsPoints()  { var t=0,e=0; for(var i=0;i<_allTrophies.length;i++){t+=_allTrophies[i].points; if(_allTrophies[i].unlocked) e+=_allTrophies[i].points;} return {earned:e,total:t}; }

    function openAllTrophies() {
        _atSection = 0;
        _atFilterIdx = 0;
        _atTrophyIdx = 0;
        allTrophiesMode = true;
        allTrophiesFlick.contentY = 0;
    }
    function closeAllTrophies() {
        allTrophiesMode = false;
    }

    // RAService integration
    RAService {
        id: raService
    }

    Connections {
        target: raService
        function onUserProfileChanged()        { _rebuildProfile(); }
        function onRecentAchievementsChanged() { _rebuildTrophies(); }
        function onAllUserGamesChanged()       { _rebuildGames(); }
        function onGameAchievementsChanged()   { _rebuildDetailAchievements(); }
    }

    // Periodic refresh while Hub is open (every 5 minutes)
    Timer {
        id: _hubRefreshTimer
        interval: 300000  // 5 min
        running: root.hubOpen
        repeat: true
        onTriggered: {
            console.log("[Hub] Periodic refresh triggered");
            raService.fetchUserSummary(true);
            raService.fetchCompletionProgress(true);
            raService.fetchRecentlyPlayedGames();

            // If viewing a game detail, refresh that too
            if (detailMode && _selectedGameData && _selectedGameData.gameId > 0) {
                raService.fetchGameDetail(_selectedGameData.gameId, true);
            }
        }
    }

    function _rebuildProfile() {
        var p = raService.userProfile;
        if (!p) return;
        totalPoints = p.totalPoints || 0;
        rank = p.rank > 0 ? ("#" + p.rank) : "—";
        console.log("[Hub] Profile refreshed: " + p.username + " | " + totalPoints + " pts | rank " + rank);
    }

    function _rebuildTrophies() {
        var achs = raService.recentAchievements;
        if (!achs || achs.length === 0) return;

        // Recent trophies for the 3-col grid (top 6)
        var recent = [];
        for (var i = 0; i < Math.min(6, achs.length); i++) {
            recent.push({
                title:    achs[i].title,
                game:     achs[i].gameTitle,
                points:   achs[i].points,
                badgeUrl: achs[i].badgeUrl || ""
            });
        }
        recentTrophies = recent;

        // All trophies + trophy tier counts
        var all = [];
        var gCount = 0, sCount = 0, bCount = 0;
        for (var j = 0; j < achs.length; j++) {
            var a = achs[j];
            var color = "#4080c0";
            if (a.points >= 25) { color = "#d0a040"; gCount++; }
            else if (a.points >= 10) { color = "#c0c0c0"; sCount++; }
            else { color = "#cd7f32"; bCount++; }
            all.push({
                title:    a.title,
                desc:     a.desc,
                unlocked: true,
                date:     a.date,
                points:   a.points,
                rarity:   50,
                color:    color,
                game:     a.gameTitle,
                platform: "",
                badgeUrl: a.badgeUrl || ""
            });
        }
        _allTrophies = all;
        totalTrophies = all.length;
        goldTrophies = gCount;
        silverTrophies = sCount;
        bronzeTrophies = bCount;
        console.log("[Hub] Trophies refreshed: " + all.length + " total (G:" + gCount + " S:" + sCount + " B:" + bCount + ")");
    }

    function _rebuildGames() {
        var games = raService.allUserGames;
        if (!games || games.length === 0) return;

        // Recent games (top 5)
        var recent = [];
        for (var i = 0; i < Math.min(5, games.length); i++) {
            recent.push({
                title:      games[i].title,
                platform:   games[i].shortLabel,
                progress:   games[i].progress,
                earned:     games[i].earned,
                total:      games[i].total,
                gameId:     games[i].gameId,
                imageIcon:  games[i].imageIcon,
                shortLabel: games[i].shortLabel
            });
        }
        recentGames = recent;

        // All games
        var all = [];
        var platSet = {};
        for (var j = 0; j < games.length; j++) {
            var g = games[j];
            var tag = g.shortLabel || g.consoleName;
            all.push({
                title:      g.title,
                platform:   tag,
                progress:   g.progress,
                earned:     g.earned,
                total:      g.total,
                gameId:     g.gameId,
                imageIcon:  g.imageIcon,
                shortLabel: g.shortLabel
            });
            platSet[tag] = g.consoleName;
        }
        _allGames = all;

        // Rebuild platform tabs
        var plist = [{ name: T.t("ra_all_platforms", root.lang), tag: "" }];
        for (var p in platSet) {
            plist.push({ name: platSet[p], tag: p });
        }
        _platforms = plist;
        _agPlatIdx = 0;
        console.log("[Hub] Games refreshed: " + recent.length + " recent, " + all.length + " total, " + (plist.length - 1) + " platforms");

        // Fetch per-game achievement badges for recent games
        _badgeTimer.stop();
        _fetchBadgesForGames(recent);
    }

    function _rebuildDetailAchievements() {
        var achs = raService.gameAchievements;
        if (!achs || achs.length === 0) return;

        var result = [];
        for (var i = 0; i < achs.length; i++) {
            var a = achs[i];
            var color = "#4080c0";
            if (a.points >= 25) color = a.unlocked ? "#d0a040" : "#c06040";
            else if (a.points >= 10) color = a.unlocked ? "#40a060" : "#4080c0";
            result.push({
                title:          a.title,
                desc:           a.desc,
                unlocked:       a.unlocked,
                date:           a.dateEarned,
                points:         a.points,
                rarity:         a.rarity,
                trueRatio:      a.trueRatio || 0,
                color:          color,
                badgeUrl:       a.badgeUrl       || "",
                badgeLockedUrl: a.badgeLockedUrl || ""
            });
        }
        _gameAchievements = result;

        // Rebuild last 3 unlocked trophies for Level 1 preview
        var unlocked = [];
        for (var u = 0; u < result.length; u++) {
            if (result[u].unlocked) unlocked.push(result[u]);
        }
        unlocked.sort(function(a, b) { return (b.date || "").localeCompare(a.date || ""); });
        _lastUnlockedTrophies = unlocked.slice(0, 3);

        // Update selected game data with real counts from detail API
        if (raService.gameDetail && _selectedGameData) {
            var d = raService.gameDetail;
            _selectedGameData = {
                title:      d.title,
                platform:   d.shortLabel || _selectedGameData.platform,
                gameId:     d.gameId,
                imageIcon:  d.imageIcon,
                earned:     d.numAwarded,
                total:      d.numAchievements,
                progress:   d.numAchievements > 0 ? d.numAwarded / d.numAchievements : 0,
                shortLabel: d.shortLabel,
                consoleName: d.consoleName || _selectedGameData.consoleName || "",
                possibleScore: d.possibleScore || 0
            };
        }
        console.log("[Hub] Detail achievements refreshed: " + result.length + " items, " + _lastUnlockedTrophies.length + " unlocked preview");
    }

    // Open / Close (instant, no animation)
    Timer {
        id: _openFocusTimer
        interval: 80; repeat: false
        onTriggered: root.focusIndex = 0
    }

    function open() {
        raUser = api.memory.get("ra_user") || "";
        raApiKey = api.memory.get("ra_api_key") || "";

        // Stop & reset entrance to invisible FIRST
        _entranceTopBar.stop(); _entranceProfile.stop();
        _entranceClock.stop();  _entranceLastPlayed.stop();
        _entranceBody.stop();
        root._entTopBarOp = 0;      root._entTopBarY = -12;
        root._entProfileOp = 0;     root._entProfileY = 24;  root._entProfileScale = 0.95;
        root._entClockOp = 0;       root._entClockY = 22;    root._entClockScale = 0.95;
        root._entLastPlayedOp = 0;  root._entLastPlayedY = 22; root._entLastPlayedScale = 0.95;
        root._entBodyOp = 0;        root._entBodyY = 35;

        // Now set focus — layout resolves with everything at opacity 0
        root.focusIndex = 0;
        hubContent._hubTopFocus = -1;
        detailMode = false;
        allGamesMode = false;
        allTrophiesMode = false;

        // Stop decorative animations and reset
        _animBorder1.stop(); _animBorder2.stop(); _animBorder3.stop();
        _animAngle.stop();   _animGlow.stop();    _animResume.stop();
        root._borderAnim  = "#7040c0";
        root._borderAnim2 = "#2090e0";
        root._borderAnim3 = "#20b8a0";
        root._borderAngle = 0;
        root._glowPulse   = 0.0;
        root._resumeAnim  = "#2ECC71";

        root.visible = true;
        root.hubOpen = true;
        root.forceActiveFocus();

        // Start all animations
        _animBorder1.start(); _animBorder2.start(); _animBorder3.start();
        _animAngle.start();   _animGlow.start();    _animResume.start();
        _entranceTopBar.start(); _entranceProfile.start();
        _entranceClock.start();  _entranceLastPlayed.start();
        _entranceBody.start();

        // Fetch real data from RetroAchievements API (force refresh)
        raService.loadCredentials();
        raService.fetchUserSummary(true);
        raService.fetchCompletionProgress(true);
        raService.fetchRecentlyPlayedGames();
        _findLastPlayed();

        // Fetch badges for already-loaded games
        if (recentGames.length > 0)
            _fetchBadgesForGames(recentGames);
    }

    function close() {
        hubContent._hubTopFocus = -1;
        detailMode = false;
        allGamesMode = false;
        allTrophiesMode = false;

        // Stop all animations so they fully reset
        _animBorder1.stop(); _animBorder2.stop(); _animBorder3.stop();
        _animAngle.stop();   _animGlow.stop();    _animResume.stop();
        _entranceTopBar.stop(); _entranceProfile.stop();
        _entranceClock.stop();  _entranceLastPlayed.stop();
        _entranceBody.stop();

        root.visible = false;
        root.hubOpen = false;
        root.hubClosed();
    }

    // Main content
    Item {
        id: hubContent
        anchors.fill: parent
        opacity: (detailMode || allGamesMode || allTrophiesMode) ? 0 : 1
        x: (detailMode || allGamesMode || allTrophiesMode) ? -root.width * 0.15 : 0
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

        // Top bar: RA icon (left) + Settings icon (right)
        property int _hubTopFocus: -1  // -1=none, 0=RA icon, 1=settings icon

        Item {
            id: hubTopBar
            z: 10
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.round(root.height * 0.055)
            anchors.topMargin: Math.round(root.height * 0.008)
            opacity: root._entTopBarOp
            transform: Translate { y: root._entTopBarY }

            // Back-to-carousel icon (top-left) — Geometric circle with colord border
            Rectangle {
                id: raIconBtn
                anchors.left: parent.left
                anchors.leftMargin: Math.round(root.width * 0.028)
                anchors.verticalCenter: parent.verticalCenter
                width: Math.round(root.height * 0.044)
                height: width
                radius: width / 2
                color: raIconMA.pressed ? "#33E74C3C" : "#22FFFFFF"
                border.width: 2
                border.color: "#E74C3C"
                clip: false

                property bool focused: hubContent._hubTopFocus === 0

                scale: focused ? 1.15 : 1.0
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 150 } }

                // Water fill effect
                Item {
                    id: raIconWaterFill
                    anchors.fill: parent
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: raIconBtn.width; height: raIconBtn.height
                            radius: raIconBtn.radius
                        }
                    }
                    Rectangle {
                        id: raIconWaterRect
                        width: parent.width; height: parent.height
                        color: "#CCE74C3C"
                        x: 0; y: parent.height
                    }
                    NumberAnimation { id: raIconWfAnim; target: raIconWaterRect; property: "y"; duration: 400; easing.type: Easing.OutQuad }
                }

                onFocusedChanged: {
                    raIconWfAnim.stop();
                    var ph = raIconWaterFill.height;
                    if (focused) { raIconWaterRect.y = ph; raIconWfAnim.from = ph; raIconWfAnim.to = 0; }
                    else { raIconWfAnim.from = 0; raIconWfAnim.to = ph; }
                    raIconWfAnim.start();
                }

                // Focus ring
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 10; height: parent.height + 10
                    radius: width / 2
                    color: "transparent"
                    border.color: "#E74C3C"; border.width: 3
                    opacity: raIconBtn.focused ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    SequentialAnimation on scale {
                        running: raIconBtn.focused
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 1.1; duration: 800; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 1.1; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                    }
                }

                // Covers icon (3 stacked cards — carousel symbol)
                Canvas {
                    z: 10
                    anchors.centerIn: parent
                    width: parent.width * 0.58; height: parent.width * 0.58
                    onVisibleChanged: if (visible) requestPaint()
                    Component.onCompleted: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d"); ctx.reset();
                        var w = width, h = height;
                        ctx.strokeStyle = "#FFFFFF"; ctx.lineWidth = 2.0;
                        ctx.lineCap = "round"; ctx.lineJoin = "round";
                        // Back card (left, slightly rotated)
                        ctx.save(); ctx.translate(w*0.28, h*0.50);
                        ctx.rotate(-0.18);
                        ctx.strokeRect(-w*0.13, -h*0.28, w*0.26, h*0.40);
                        ctx.restore();
                        // Center card (front, larger)
                        ctx.lineWidth = 2;
                        ctx.strokeRect(w*0.30, h*0.18, w*0.40, h*0.58);
                        // Front card (right, slightly rotated)
                        ctx.lineWidth = 1.5;
                        ctx.save(); ctx.translate(w*0.72, h*0.50);
                        ctx.rotate(0.18);
                        ctx.strokeRect(-w*0.13, -h*0.28, w*0.26, h*0.40);
                        ctx.restore();
                    }
                }

                MouseArea {
                    id: raIconMA
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    onClicked: close()
                }
            }

            // Settings icon (top-right) — Geometric circle with colord border (matches carousel style)
            Rectangle {
                id: settingsIconBtn
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.028)
                anchors.verticalCenter: parent.verticalCenter
                width: Math.round(root.height * 0.044)
                height: width
                radius: width / 2
                color: settingsIconMA.pressed ? "#333498DB" : "#22FFFFFF"
                border.width: 2
                border.color: "#3498DB"
                clip: false

                property bool focused: hubContent._hubTopFocus === 1

                scale: focused ? 1.15 : 1.0
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 150 } }

                // Water fill effect
                Item {
                    id: settingsIconWaterFill
                    anchors.fill: parent
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: settingsIconBtn.width; height: settingsIconBtn.height
                            radius: settingsIconBtn.radius
                        }
                    }
                    Rectangle {
                        id: settingsIconWaterRect
                        width: parent.width; height: parent.height
                        color: "#CC3498DB"
                        x: 0; y: parent.height
                    }
                    NumberAnimation { id: settingsIconWfAnim; target: settingsIconWaterRect; property: "y"; duration: 400; easing.type: Easing.OutQuad }
                }

                onFocusedChanged: {
                    settingsIconWfAnim.stop();
                    var ph = settingsIconWaterFill.height;
                    if (focused) { settingsIconWaterRect.y = ph; settingsIconWfAnim.from = ph; settingsIconWfAnim.to = 0; }
                    else { settingsIconWfAnim.from = 0; settingsIconWfAnim.to = ph; }
                    settingsIconWfAnim.start();
                }

                // Focus ring
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 10; height: parent.height + 10
                    radius: width / 2
                    color: "transparent"
                    border.color: "#3498DB"; border.width: 3
                    opacity: settingsIconBtn.focused ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    SequentialAnimation on scale {
                        running: settingsIconBtn.focused
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 1.1; duration: 800; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 1.1; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                    }
                }

                // Hamburger icon (3 lines)
                Item {
                    anchors.centerIn: parent
                    width: parent.width * 0.40; height: parent.width * 0.40
                    Rectangle { width: parent.width * 0.8; height: 2.5; color: "white"; radius: 1; anchors.horizontalCenter: parent.horizontalCenter; y: parent.height * 0.2 }
                    Rectangle { width: parent.width * 0.8; height: 2.5; color: "white"; radius: 1; anchors.horizontalCenter: parent.horizontalCenter; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { width: parent.width * 0.8; height: 2.5; color: "white"; radius: 1; anchors.horizontalCenter: parent.horizontalCenter; y: parent.height * 0.8 - 2.5 }
                }

                MouseArea {
                    id: settingsIconMA
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    onClicked: settingsRequested()
                }
            }
        }

        // Fixed Profile section (above scroll)
        Item {
            id: profileSection
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: Math.round(root.height * 0.065)
            height: _psFocused ? root.height * 0.32 : root.height * 0.22
            z: 5
            Behavior on height { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

            readonly property bool _psFocused: root.focusIndex === 0

            property string _clockH: "00"
            property string _clockM: "00"
            property string _clockDate: ""

            function _updateClock() {
                var now = new Date();
                var h = now.getHours();
                var m = now.getMinutes();
                _clockH = (h < 10 ? "0" : "") + h;
                _clockM = (m < 10 ? "0" : "") + m;
                var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
                _clockDate = months[now.getMonth()] + " " + now.getDate();
            }

            Timer {
                interval: 1000; running: root.hubOpen; repeat: true
                onTriggered: profileSection._updateClock()
            }
            Component.onCompleted: profileSection._updateClock()

            // Clock font
            FontLoader { id: clockFont; source: "../../assets/fonts/watch/Rajdhani.ttf" }

            // Layout calculations
            readonly property real _sideMargin: Math.round(width * 0.025)
            readonly property real _gap: Math.round((width - _sideMargin * 2) * 0.012)
            readonly property real _innerW: width - _sideMargin * 2

            Item {
                id: profileRow
                anchors.fill: parent
                anchors.leftMargin: profileSection._sideMargin
                anchors.rightMargin: profileSection._sideMargin
                anchors.topMargin: Math.round(root.height * 0.008)
                anchors.bottomMargin: Math.round(root.height * 0.004)

                // Panel 1: Profile
                Components.GlassPanel {
                    id: profileCard
                    x: 0
                    height: parent.height
                    opacity: root._entProfileOp
                    scale: root._entProfileScale
                    transform: Translate { y: root._entProfileY }
                    width: profileSection._psFocused
                        ? Math.round(profileSection._innerW * 0.44)
                        : Math.round(profileSection._innerW - clockCard.width - profileSection._gap)
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                    glassRadius: 24
                    focused: root.focusIndex === 0
                    tintColor: focused
                        ? Qt.rgba(0.15, 0.12, 0.30, 0.12)
                        : Qt.rgba(0.08, 0.06, 0.20, 0.08)
                    borderColor: focused ? root._borderFocused : root._borderNormal
                    borderColor2: focused ? root._ca(root._borderAnim2, 0.70) : root._ca(root._borderAnim2, 0.40)
                    borderColor3: focused ? root._ca(root._borderAnim3, 0.70) : root._ca(root._borderAnim3, 0.40)
                    borderGradientAngle: root._borderAngle
                    borderWidth: focused ? 2 : 1.5
                    sheenOpacity: focused ? 0.12 : 0.05
                    glowColor: root._glowColor
                    glowIntensity: focused ? root._glowPulse : root._glowPulse * 0.35

                    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
                    scale: 1.0

                    Row {
                        anchors.fill: parent
                        anchors.margins: Math.round(parent.height * 0.12)
                        spacing: Math.round(profileCard.width * 0.04)

                                // Avatar
                                Item {
                                    width: Math.round(parent.height * 0.80)
                                    height: width
                                    anchors.verticalCenter: parent.verticalCenter
                                    scale: root.focusIndex === 0 ? 1.08 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width + 6; height: width; radius: Math.round(width * 0.18)
                                        color: "transparent"
                                        border.width: root.focusIndex === 0 ? 2.5 : 0
                                        border.color: root.focusIndex === 0 ? Qt.rgba(0.30, 0.60, 0.90, 0.7) : "transparent"
                                        Behavior on border.width { NumberAnimation { duration: 350 } }
                                        Behavior on border.color { ColorAnimation { duration: 350 } }
                                    }

                                    Rectangle {
                                        id: avatarRect
                                        anchors.fill: parent
                                        radius: Math.round(width * 0.15)
                                        color: Qt.rgba(0.06, 0.10, 0.20, 0.60)
                                        clip: true

                                        Image {
                                            id: avatarImage
                                            anchors.fill: parent
                                            source: raService.userProfile && raService.userProfile.userPic ? raService.userProfile.userPic : ""
                                            fillMode: Image.PreserveAspectCrop
                                            smooth: true; asynchronous: true
                                            opacity: status === Image.Ready ? (root.focusIndex === 0 ? 1.0 : 0.8) : 0
                                            Behavior on opacity { NumberAnimation { duration: 350 } }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: raUser.length > 0 ? raUser.charAt(0).toUpperCase() : "?"
                                            font.pixelSize: Math.round(parent.width * 0.45)
                                            font.bold: true
                                            color: "#5080a8"
                                            visible: avatarImage.status !== Image.Ready
                                        }
                                    }

                                    Rectangle {
                                        anchors.fill: parent; radius: Math.round(width * 0.15)
                                        color: "transparent"
                                        border.color: raUser !== "" ? Qt.rgba(0.30, 0.55, 0.80, root.focusIndex === 0 ? 0.5 : 0.25) : "#202838"
                                        border.width: 1.5
                                        Behavior on border.color { ColorAnimation { duration: 350 } }
                                    }
                                }

                                // User info
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Math.round(profileCard.height * 0.06)
                                    width: parent.width - Math.round(parent.height * 0.80) - parent.spacing

                                    Text {
                                        text: raUser !== "" ? raUser : T.t("ra_not_connected", root.lang)
                                        font.pixelSize: Math.round(root.height * 0.030)
                                        font.bold: true; font.letterSpacing: 0.5
                                        color: root.focusIndex === 0 ? "#f0f4ff" : "#e0e8f4"
                                        width: parent.width
                                        elide: Text.ElideRight
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }

                                    // Points row
                                    Row {
                                        spacing: Math.round(profileCard.width * 0.008)
                                        opacity: root.focusIndex === 0 ? 0.85 : 0.75
                                        Behavior on opacity { NumberAnimation { duration: 300 } }

                                        Canvas {
                                            width: Math.round(root.height * 0.020); height: width
                                            anchors.verticalCenter: parent.verticalCenter
                                            onVisibleChanged: if (visible) requestPaint()
                                            Component.onCompleted: requestPaint()
                                            onPaint: {
                                                var ctx = getContext("2d"); ctx.reset();
                                                var w = width, h = height, cx = w/2, cy = h/2, r = w*0.45;
                                                ctx.fillStyle = "#FFD700";
                                                ctx.beginPath();
                                                for (var i = 0; i < 5; i++) {
                                                    var a1 = (i * 72 - 90) * Math.PI / 180;
                                                    var a2 = ((i * 72) + 36 - 90) * Math.PI / 180;
                                                    ctx.lineTo(cx + r * Math.cos(a1), cy + r * Math.sin(a1));
                                                    ctx.lineTo(cx + r * 0.4 * Math.cos(a2), cy + r * 0.4 * Math.sin(a2));
                                                }
                                                ctx.closePath(); ctx.fill();
                                            }
                                        }

                                        Text {
                                            text: totalPoints > 0 ? totalPoints.toLocaleString() + " " + T.t("ra_points_suffix", root.lang) : "\u2014"
                                            font.pixelSize: Math.round(root.height * 0.018)
                                            color: "#a0b8cc"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    // Rank + badges
                                    Row {
                                        spacing: Math.round(profileCard.width * 0.020)
                                        opacity: root.focusIndex === 0 ? 0.85 : 0.75
                                        Behavior on opacity { NumberAnimation { duration: 300 } }

                                        Text {
                                            text: T.t("ra_rank", root.lang)
                                            font.pixelSize: Math.round(root.height * 0.016)
                                            color: "#6080a0"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            text: rank !== "" && rank !== "0" ? rank : "\u2014"
                                            font.pixelSize: Math.round(root.height * 0.016)
                                            font.bold: true; color: "#40b080"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Item { width: Math.round(profileCard.width * 0.01); height: 1 }

                                        Repeater {
                                            model: [
                                                { count: goldTrophies,   clr: "#FFD700" },
                                                { count: silverTrophies, clr: "#A8B0B8" },
                                                { count: bronzeTrophies, clr: "#CD7F32" }
                                            ]
                                            Rectangle {
                                                width: Math.round(root.height * 0.022); height: width; radius: width * 0.5
                                                color: modelData.clr
                                                anchors.verticalCenter: parent.verticalCenter
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.count
                                                    font.pixelSize: Math.round(parent.width * 0.48)
                                                    font.bold: true; color: "#ffffff"
                                                    style: Text.Outline; styleColor: Qt.rgba(0, 0, 0, 0.35)
                                                }
                                            }
                                        }

                                        Item { width: Math.round(profileCard.width * 0.008); height: 1 }

                                        Text {
                                            text: totalTrophies > 0 ? (T.t("ra_total_prefix", root.lang) + totalTrophies) : "\u2014"
                                            font.pixelSize: Math.round(root.height * 0.016)
                                            color: "#587890"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }
                        }

                        // Panel 2: Clock
                        Components.GlassPanel {
                            id: clockCard
                            x: profileCard.width + profileSection._gap
                            height: parent.height
                            opacity: root._entClockOp
                            scale: root._entClockScale
                            transform: Translate { y: root._entClockY }
                            width: profileSection._psFocused
                                ? Math.round(profileSection._innerW * 0.17)
                                : Math.round(profileSection._innerW * 0.22)
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                            glassRadius: 24
                            focused: profileSection._psFocused
                            tintColor: profileSection._psFocused
                                ? Qt.rgba(0.12, 0.10, 0.28, 0.12)
                                : Qt.rgba(0.08, 0.06, 0.20, 0.10)
                            borderColor: profileSection._psFocused ? root._borderFocused : root._borderSubtle
                            borderColor2: profileSection._psFocused ? root._ca(root._borderAnim2, 0.70) : root._ca(root._borderAnim2, 0.30)
                            borderColor3: profileSection._psFocused ? root._ca(root._borderAnim3, 0.70) : root._ca(root._borderAnim3, 0.30)
                            borderGradientAngle: root._borderAngle
                            borderWidth: profileSection._psFocused ? 2 : 1.5
                            sheenOpacity: profileSection._psFocused ? 0.10 : 0.05
                            glowColor: root._glowColor
                            glowIntensity: profileSection._psFocused ? root._glowPulse * 0.8 : root._glowPulse * 0.25

                            Column {
                                anchors.centerIn: parent
                                spacing: -Math.round(clockCard.height * 0.02)

                                // Date
                                Text {
                                    text: profileSection._clockDate
                                    font.pixelSize: Math.round(clockCard.height * 0.10)
                                    font.family: clockFont.name
                                    font.weight: Font.DemiBold
                                    color: Qt.rgba(root._borderAnim.r, root._borderAnim.g, root._borderAnim.b, 0.65)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.letterSpacing: 1.5
                                    font.capitalization: Font.AllUppercase
                                }

                                // Hours
                                Text {
                                    text: profileSection._clockH
                                    font.pixelSize: Math.round(clockCard.height * 0.30)
                                    font.family: clockFont.name
                                    font.weight: Font.Bold
                                    color: "#e0e8ff"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                // Separator line (animated color)
                                Rectangle {
                                    width: Math.round(clockCard.width * 0.40)
                                    height: 2; radius: 1
                                    color: Qt.rgba(root._borderAnim.r, root._borderAnim.g, root._borderAnim.b, 0.6)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                // Minutes
                                Text {
                                    text: profileSection._clockM
                                    font.pixelSize: Math.round(clockCard.height * 0.30)
                                    font.family: clockFont.name
                                    font.weight: Font.Bold
                                    color: Qt.rgba(root._borderAnim.r, root._borderAnim.g, root._borderAnim.b, 0.85)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        // Panel 3: Last Played Game (Pegasus API)
                        Components.GlassPanel {
                            id: lastPlayedCard
                            anchors.right: parent.right
                            height: parent.height
                            width: profileSection._psFocused
                                ? Math.round(profileSection._innerW - profileCard.width - clockCard.width - profileSection._gap * 2)
                                : 0
                            visible: width > 2
                            opacity: root._entLastPlayedOp * (profileSection._psFocused ? 1.0 : 0.0)
                            scale: root._entLastPlayedScale
                            transform: Translate { y: root._entLastPlayedY }
                            clip: true
                            Behavior on width   { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

                            glassRadius: 24
                            focused: profileSection._psFocused
                            tintColor: profileSection._psFocused
                                ? Qt.rgba(0.10, 0.08, 0.24, 0.12)
                                : Qt.rgba(0.06, 0.08, 0.18, 0.10)
                            borderColor: profileSection._psFocused ? root._borderFocused : root._borderSubtle
                            borderColor2: profileSection._psFocused ? root._ca(root._borderAnim2, 0.70) : root._ca(root._borderAnim2, 0.30)
                            borderColor3: profileSection._psFocused ? root._ca(root._borderAnim3, 0.70) : root._ca(root._borderAnim3, 0.30)
                            borderGradientAngle: root._borderAngle
                            borderWidth: profileSection._psFocused ? 2 : 1.5
                            sheenOpacity: profileSection._psFocused ? 0.10 : 0.05
                            glowColor: root._glowColor
                            glowIntensity: profileSection._psFocused ? root._glowPulse * 0.8 : root._glowPulse * 0.25

                            Row {
                                anchors.fill: parent
                                anchors.margins: Math.round(parent.height * 0.10)
                                spacing: Math.round(lastPlayedCard.width * 0.04)
                                visible: lastPlayedCard.width > 20

                                // Game cover art
                                Rectangle {
                                    id: lpCoverRect
                                    width: Math.round(parent.height * 0.82)
                                    height: width
                                    anchors.verticalCenter: parent.verticalCenter
                                    radius: 14
                                    color: Qt.rgba(0.06, 0.10, 0.20, 0.60)
                                    clip: true

                                    Image {
                                        id: lastGameCover
                                        anchors.fill: parent
                                        source: root._pegasusLastGame
                                            ? (root._pegasusLastGame.assets.boxFront || root._pegasusLastGame.assets.screenshot || "") : ""
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true; asynchronous: true
                                        opacity: status === Image.Ready ? 1.0 : 0
                                        Behavior on opacity { NumberAnimation { duration: 300 } }
                                    }

                                    // Fallback gamepad icon
                                    Canvas {
                                        anchors.centerIn: parent
                                        width: Math.round(parent.width * 0.5); height: width
                                        visible: lastGameCover.status !== Image.Ready
                                        onVisibleChanged: if (visible) requestPaint()
                                        Component.onCompleted: requestPaint()
                                        onPaint: {
                                            var ctx = getContext("2d"); ctx.reset();
                                            var w = width, h = height;
                                            ctx.fillStyle = "#405878";
                                            ctx.beginPath();
                                            ctx.roundedRect(w*0.1, h*0.25, w*0.8, h*0.45, 6, 6);
                                            ctx.fill();
                                            ctx.fillStyle = "#5a7898";
                                            ctx.fillRect(w*0.22, h*0.35, w*0.08, h*0.22);
                                            ctx.fillRect(w*0.15, h*0.42, w*0.22, h*0.08);
                                            ctx.beginPath();
                                            ctx.arc(w*0.68, h*0.40, w*0.04, 0, Math.PI*2); ctx.fill();
                                            ctx.beginPath();
                                            ctx.arc(w*0.76, h*0.48, w*0.04, 0, Math.PI*2); ctx.fill();
                                        }
                                    }

                                    Rectangle {
                                        anchors.fill: parent; radius: parent.radius
                                        color: "transparent"
                                        border.color: Qt.rgba(0.30, 0.55, 0.80, 0.25)
                                        border.width: 1
                                    }
                                }

                                // Game info + resume area (anchored to cover top/bottom)
                                Item {
                                    width: parent.width - lpCoverRect.width - parent.spacing
                                    height: lpCoverRect.height
                                    anchors.verticalCenter: parent.verticalCenter

                                    // Top-aligned info
                                    Column {
                                        id: lpInfoCol
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        spacing: Math.round(lastPlayedCard.height * 0.03)

                                        // "LAST PLAYED" label
                                        Text {
                                            text: "LAST PLAYED"
                                            font.pixelSize: Math.round(root.height * 0.013)
                                            font.bold: true; font.letterSpacing: 2.0
                                            color: Qt.rgba(root._borderAnim.r, root._borderAnim.g, root._borderAnim.b, 0.85)
                                        }

                                        // Game title
                                        Text {
                                            text: root._pegasusLastGame ? root._pegasusLastGame.title : "\u2014"
                                            font.pixelSize: Math.round(root.height * 0.025)
                                            font.bold: true
                                            color: "#e8f0ff"
                                            width: parent.width
                                            elide: Text.ElideRight
                                            maximumLineCount: 2
                                            wrapMode: Text.WordWrap
                                        }

                                        // Platform badge + time ago
                                        Row {
                                            spacing: Math.round(lastPlayedCard.width * 0.025)

                                            Rectangle {
                                                visible: lpPlatText.text !== ""
                                                width: lpPlatText.width + Math.round(lastPlayedCard.width * 0.035)
                                                height: lpPlatText.height + 6
                                                radius: 8
                                                color: Qt.rgba(root._borderAnim.r, root._borderAnim.g, root._borderAnim.b, 0.20)
                                                anchors.verticalCenter: parent.verticalCenter

                                                Text {
                                                    id: lpPlatText
                                                    anchors.centerIn: parent
                                                    text: {
                                                        if (!root._pegasusLastGame) return "";
                                                        try {
                                                            if (root._pegasusLastGame.collections && root._pegasusLastGame.collections.count > 0) {
                                                                var cn = root._pegasusLastGame.collections.get(0).name;
                                                                if (cn !== "lastplayed" && cn !== "favorites") return cn;
                                                                if (root._pegasusLastGame.collections.count > 1) return root._pegasusLastGame.collections.get(1).name;
                                                            }
                                                        } catch(e) {}
                                                        return "";
                                                    }
                                                    font.pixelSize: Math.round(root.height * 0.013)
                                                    font.bold: true
                                                    color: "#c0d0e8"
                                                }
                                            }

                                            Text {
                                                text: root._pegasusLastGame && root._pegasusLastGame.lastPlayed
                                                    ? root._timeAgoStr(root._pegasusLastGame.lastPlayed) : ""
                                                font.pixelSize: Math.round(root.height * 0.013)
                                                color: "#708090"
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }

                                    // Bottom-aligned Resume button
                                    Rectangle {
                                        id: resumeBtn
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        visible: root._pegasusLastGame !== null
                                        width: _resumeRow.width + Math.round(root.height * 0.036)
                                        height: _resumeRow.height + Math.round(root.height * 0.018)
                                        radius: 14
                                        color: Qt.rgba(root._resumeAnim.r, root._resumeAnim.g, root._resumeAnim.b,
                                                       profileSection._psFocused ? 0.22 : 0.12)
                                        border.color: Qt.rgba(root._resumeAnim.r, root._resumeAnim.g, root._resumeAnim.b,
                                                              profileSection._psFocused ? 0.85 : 0.50)
                                        border.width: profileSection._psFocused ? 1.8 : 1
                                        Behavior on border.width { NumberAnimation { duration: 300 } }

                                        Row {
                                            id: _resumeRow
                                            anchors.centerIn: parent
                                            spacing: Math.round(root.height * 0.010)

                                            Rectangle {
                                                width: Math.round(root.height * 0.028); height: width; radius: width * 0.5
                                                color: root._resumeAnim
                                                anchors.verticalCenter: parent.verticalCenter

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "A"
                                                    font.pixelSize: Math.round(parent.width * 0.52)
                                                    font.bold: true; color: "#ffffff"
                                                    style: Text.Outline; styleColor: Qt.rgba(0, 0, 0, 0.30)
                                                }
                                            }

                                            Text {
                                                text: "Resume now"
                                                font.pixelSize: Math.round(root.height * 0.020)
                                                font.bold: true
                                                color: Qt.rgba(root._resumeAnim.r, root._resumeAnim.g, root._resumeAnim.b, 0.95)
                                                style: Text.Outline; styleColor: Qt.rgba(0, 0, 0, 0.15)
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

        }  // profileSection

        // Scrollable body (trophies + games — scrolls below fixed profile)
        Flickable {
            id: bodyFlick
            anchors.top: profileSection.bottom
            anchors.topMargin: Math.round(root.height * 0.012)
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            opacity: root._entBodyOp
            transform: Translate { y: root._entBodyY }
            anchors.bottomMargin: Math.round(root.height * 0.01)
            contentHeight: bodyCol.height + root.height * 0.05
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Behavior on contentY { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            Column {
                id: bodyCol
                width: parent.width
                spacing: Math.round(root.height * 0.04)

                // SECTION 2 — Trofei Recenti (3 columns)
                Item {
                    id: trophiesSection
                    width: parent.width
                    height: trophiesBox.height + Math.round(root.height * 0.004)

                    Components.GlassPanel {
                        id: trophiesBox
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Math.round(parent.width * 0.025)
                        anchors.rightMargin: Math.round(parent.width * 0.025)
                        height: trophiesBoxCol.height + Math.round(root.height * 0.020)
                        glassRadius: 24
                        tintColor: Qt.rgba(0.06, 0.08, 0.18, 0.10)
                        borderColor: root._borderNormal
                        borderColor2: root._ca(root._borderAnim2, 0.40)
                        borderColor3: root._ca(root._borderAnim3, 0.40)
                        borderGradientAngle: root._borderAngle
                        borderWidth: 1.5
                        sheenOpacity: 0.05
                        glowColor: root._glowColor
                        glowIntensity: root._glowPulse * 0.30

                    Column {
                        id: trophiesBoxCol
                        width: parent.width - Math.round(root.width * 0.03)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: Math.round(root.height * 0.008)
                        spacing: Math.round(root.height * 0.012)

                        // Section header
                        Item {
                            id: trophiesHeader
                            width: parent.width
                            height: Math.round(root.height * 0.045)

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Math.round(root.width * 0.010)

                                Canvas {
                                    width: Math.round(root.height * 0.034)
                                    height: width
                                    anchors.verticalCenter: parent.verticalCenter
                                    onVisibleChanged: if (visible) requestPaint()
                                    Component.onCompleted: requestPaint()
                                    onPaint: {
                                        var ctx = getContext("2d"); ctx.reset();
                                        var w = width, h = height;
                                        ctx.strokeStyle = "#e8c050"; ctx.lineWidth = 2.0;
                                        ctx.lineCap = "round"; ctx.lineJoin = "round";
                                        ctx.beginPath();
                                        ctx.moveTo(w*0.25, h*0.12); ctx.lineTo(w*0.75, h*0.12);
                                        ctx.lineTo(w*0.68, h*0.50);
                                        ctx.quadraticCurveTo(w*0.5, h*0.65, w*0.32, h*0.50);
                                        ctx.closePath(); ctx.stroke();
                                        ctx.beginPath(); ctx.arc(w*0.22, h*0.32, w*0.10, -Math.PI*0.5, Math.PI*0.5); ctx.stroke();
                                        ctx.beginPath(); ctx.arc(w*0.78, h*0.32, w*0.10, Math.PI*0.5, -Math.PI*0.5); ctx.stroke();
                                        ctx.beginPath(); ctx.moveTo(w*0.5, h*0.60); ctx.lineTo(w*0.5, h*0.75); ctx.stroke();
                                        ctx.beginPath(); ctx.moveTo(w*0.32, h*0.82); ctx.lineTo(w*0.68, h*0.82); ctx.stroke();
                                        ctx.beginPath(); ctx.moveTo(w*0.36, h*0.75); ctx.lineTo(w*0.64, h*0.75); ctx.stroke();
                                    }
                                }
                                Text {
                                    text: T.t("ra_recent_trophies", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.024)
                                    font.weight: Font.DemiBold
                                    font.letterSpacing: 0.3
                                    color: "#a0b8d8"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Row {
                                id: viewAllTrophiesRow
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Math.round(root.width * 0.008)
                                opacity: 1.0

                                Rectangle {
                                    width: Math.round(root.height * 0.028)
                                    height: width; radius: width * 0.5
                                    color: "#c8a840"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Y"
                                        font.pixelSize: Math.round(parent.width * 0.52)
                                        font.bold: true
                                        color: "#ffffff"
                                    }
                                }

                                Text {
                                    text: T.t("ra_all_trophies_btn", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.020)
                                    font.weight: Font.DemiBold
                                    color: "#c0d0e0"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: viewAllTrophiesRow
                                anchors.margins: -8
                                onClicked: openAllTrophies()
                            }
                        }

                        // Grid 3 columns
                        Grid {
                            id: trophyGrid
                            columns: 3
                            spacing: Math.round(root.height * 0.010)
                            width: parent.width

                            Repeater {
                                model: recentTrophies

                                Components.GlassPanel {
                                    id: trophyCard
                                    property int fi: index + 1
                                    property bool isFocused: root.focusIndex === fi
                                    width: Math.floor((trophyGrid.width - trophyGrid.spacing * 2) / 3)
                                    height: Math.round(root.height * 0.11)
                                    glassRadius: 16
                                    focused: isFocused
                                    tintColor: isFocused ? Qt.rgba(0.10, 0.12, 0.25, 0.12) : tCma.containsMouse ? Qt.rgba(0.06, 0.10, 0.22, 0.10) : Qt.rgba(0.04, 0.06, 0.15, 0.08)
                                    borderColor: isFocused ? root._borderFocused : root._borderSubtle
                                    borderColor2: isFocused ? root._ca(root._borderAnim2, 0.70) : root._ca(root._borderAnim2, 0.30)
                                    borderColor3: isFocused ? root._ca(root._borderAnim3, 0.70) : root._ca(root._borderAnim3, 0.30)
                                    borderGradientAngle: root._borderAngle
                                    borderWidth: isFocused ? 1.5 : 1
                                    scale: isFocused ? 1.03 : 1.0
                                    glowColor: root._glowColor
                                    glowIntensity: isFocused ? root._glowPulse * 0.85 : root._glowPulse * 0.18

                                    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

                                    MouseArea {
                                        id: tCma
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: root.focusIndex = trophyCard.fi
                                    }

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: Math.round(parent.height * 0.14)
                                        spacing: Math.round(parent.width * 0.06)

                                        // Trophy badge image
                                        Rectangle {
                                            width: Math.round(parent.height * 0.68)
                                            height: width; radius: width * 0.5
                                            color: Qt.rgba(0.10, 0.14, 0.28, 0.50)
                                            border.color: Qt.rgba(0.20, 0.28, 0.48, 0.40)
                                            border.width: 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            clip: true

                                            Image {
                                                anchors.fill: parent
                                                anchors.margins: 1
                                                source: modelData.badgeUrl || ""
                                                fillMode: Image.PreserveAspectCrop
                                                smooth: true
                                                asynchronous: true
                                                visible: status === Image.Ready
                                            }
                                            Canvas {
                                                anchors.centerIn: parent
                                                width: parent.width * 0.60; height: parent.width * 0.60
                                                visible: !modelData.badgeUrl || modelData.badgeUrl === ""
                                                onVisibleChanged: if (visible) requestPaint()
                                                Component.onCompleted: if (visible) requestPaint()
                                                onPaint: {
                                                    var ctx = getContext("2d"); ctx.reset();
                                                    var w = width, h = height;
                                                    ctx.strokeStyle = "#e8c050"; ctx.lineWidth = 2.0;
                                                    ctx.lineCap = "round"; ctx.lineJoin = "round";
                                                    ctx.beginPath();
                                                    ctx.moveTo(w*0.25, h*0.12); ctx.lineTo(w*0.75, h*0.12);
                                                    ctx.lineTo(w*0.68, h*0.50);
                                                    ctx.quadraticCurveTo(w*0.5, h*0.65, w*0.32, h*0.50);
                                                    ctx.closePath(); ctx.stroke();
                                                    ctx.beginPath(); ctx.arc(w*0.22, h*0.32, w*0.10, -Math.PI*0.5, Math.PI*0.5); ctx.stroke();
                                                    ctx.beginPath(); ctx.arc(w*0.78, h*0.32, w*0.10, Math.PI*0.5, -Math.PI*0.5); ctx.stroke();
                                                    ctx.beginPath(); ctx.moveTo(w*0.5, h*0.60); ctx.lineTo(w*0.5, h*0.75); ctx.stroke();
                                                    ctx.beginPath(); ctx.moveTo(w*0.32, h*0.82); ctx.lineTo(w*0.68, h*0.82); ctx.stroke();
                                                    ctx.beginPath(); ctx.moveTo(w*0.36, h*0.75); ctx.lineTo(w*0.64, h*0.75); ctx.stroke();
                                                }
                                            }
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width - Math.round(parent.height * 0.68) - Math.round(parent.width * 0.06)
                                            spacing: Math.round(root.height * 0.003)

                                            Text {
                                                text: modelData.title
                                                font.pixelSize: Math.round(root.height * 0.019)
                                                font.bold: true
                                                color: trophyCard.isFocused ? "#f0f4ff" : "#d0e0f0"
                                                Behavior on color { ColorAnimation { duration: 250 } }
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }
                                            Text {
                                                text: modelData.game
                                                font.pixelSize: Math.round(root.height * 0.015)
                                                color: "#6888a0"
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }
                                            Text {
                                                text: modelData.points + " " + T.t("ra_points_suffix", root.lang)
                                                font.pixelSize: Math.round(root.height * 0.015)
                                                font.bold: true
                                                color: "#d4a543"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    }  // close trophiesBox GlassPanel
                }

                Item {
                    id: gamesSection
                    width: parent.width
                    height: gamesBox.height + Math.round(root.height * 0.004)

                    Components.GlassPanel {
                        id: gamesBox
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Math.round(parent.width * 0.025)
                        anchors.rightMargin: Math.round(parent.width * 0.025)
                        height: gamesBoxCol.height + Math.round(root.height * 0.020)
                        glassRadius: 24
                        tintColor: Qt.rgba(0.06, 0.08, 0.18, 0.10)
                        borderColor: root._borderNormal
                        borderColor2: root._ca(root._borderAnim2, 0.40)
                        borderColor3: root._ca(root._borderAnim3, 0.40)
                        borderGradientAngle: root._borderAngle
                        borderWidth: 1.5
                        sheenOpacity: 0.05
                        glowColor: root._glowColor
                        glowIntensity: root._glowPulse * 0.30

                    Column {
                        id: gamesBoxCol
                        width: parent.width - Math.round(root.width * 0.03)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: Math.round(root.height * 0.008)
                        spacing: Math.round(root.height * 0.012)

                        // Section header
                        Item {
                            id: gamesHeader
                            width: parent.width
                            height: Math.round(root.height * 0.045)

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Math.round(root.width * 0.010)

                                Canvas {
                                    width: Math.round(root.height * 0.034)
                                    height: width
                                    anchors.verticalCenter: parent.verticalCenter
                                    onVisibleChanged: if (visible) requestPaint()
                                    Component.onCompleted: requestPaint()
                                    onPaint: {
                                        var ctx = getContext("2d"); ctx.reset();
                                        var w = width, h = height;
                                        ctx.strokeStyle = "#90c0f0"; ctx.lineWidth = 1.8;
                                        ctx.lineCap = "round"; ctx.lineJoin = "round";
                                        // Controller body
                                        ctx.beginPath();
                                        ctx.moveTo(w*0.28, h*0.22);
                                        ctx.lineTo(w*0.72, h*0.22);
                                        ctx.quadraticCurveTo(w*0.88, h*0.22, w*0.88, h*0.42);
                                        ctx.quadraticCurveTo(w*0.92, h*0.68, w*0.78, h*0.78);
                                        ctx.lineTo(w*0.62, h*0.78);
                                        ctx.quadraticCurveTo(w*0.56, h*0.62, w*0.50, h*0.62);
                                        ctx.quadraticCurveTo(w*0.44, h*0.62, w*0.38, h*0.78);
                                        ctx.lineTo(w*0.22, h*0.78);
                                        ctx.quadraticCurveTo(w*0.08, h*0.68, w*0.12, h*0.42);
                                        ctx.quadraticCurveTo(w*0.12, h*0.22, w*0.28, h*0.22);
                                        ctx.closePath(); ctx.stroke();
                                        // D-pad cross
                                        ctx.beginPath();
                                        ctx.moveTo(w*0.28, h*0.44); ctx.lineTo(w*0.42, h*0.44);
                                        ctx.moveTo(w*0.35, h*0.36); ctx.lineTo(w*0.35, h*0.52);
                                        ctx.stroke();
                                        // Face buttons (4 dots)
                                        ctx.fillStyle = "#90c0f0";
                                        ctx.beginPath(); ctx.arc(w*0.65, h*0.36, w*0.030, 0, Math.PI*2); ctx.fill();
                                        ctx.beginPath(); ctx.arc(w*0.65, h*0.52, w*0.030, 0, Math.PI*2); ctx.fill();
                                        ctx.beginPath(); ctx.arc(w*0.58, h*0.44, w*0.030, 0, Math.PI*2); ctx.fill();
                                        ctx.beginPath(); ctx.arc(w*0.72, h*0.44, w*0.030, 0, Math.PI*2); ctx.fill();
                                    }
                                }
                                Text {
                                    text: T.t("ra_recent_games", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.024)
                                    font.weight: Font.DemiBold
                                    font.letterSpacing: 0.3
                                    color: "#a0b8d8"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Row {
                                id: viewAllRow
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Math.round(root.width * 0.008)
                                opacity: 1.0

                                // X button badge
                                Rectangle {
                                    width: Math.round(root.height * 0.028)
                                    height: width; radius: width * 0.5
                                    color: "#5090c0"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "X"
                                        font.pixelSize: Math.round(parent.width * 0.52)
                                        font.bold: true
                                        color: "#ffffff"
                                    }
                                }

                                Text {
                                    text: T.t("ra_all_games_btn", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.020)
                                    font.weight: Font.DemiBold
                                    color: "#c0d0e0"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: viewAllRow
                                anchors.margins: -8
                                onClicked: openAllGames()
                            }
                        }

                        // Games list
                        Column {
                            id: gamesCol
                            width: parent.width
                            spacing: Math.round(root.height * 0.010)

                            Repeater {
                                model: recentGames

                                Components.GlassPanel {
                                    id: gameCard
                                    property int fi: index + root._gamesStart
                                    property bool isFocused: root.focusIndex === fi
                                    width: gamesCol.width
                                    height: Math.round(root.height * 0.110)
                                    glassRadius: 16
                                    focused: isFocused
                                    tintColor: isFocused ? Qt.rgba(0.10, 0.12, 0.25, 0.12) : gCma.containsMouse ? Qt.rgba(0.06, 0.10, 0.22, 0.10) : Qt.rgba(0.04, 0.06, 0.15, 0.08)
                                    borderColor: isFocused ? root._borderFocused : root._borderSubtle
                                    borderColor2: isFocused ? root._ca(root._borderAnim2, 0.70) : root._ca(root._borderAnim2, 0.30)
                                    borderColor3: isFocused ? root._ca(root._borderAnim3, 0.70) : root._ca(root._borderAnim3, 0.30)
                                    borderGradientAngle: root._borderAngle
                                    borderWidth: isFocused ? 1.5 : 1
                                    scale: isFocused ? 1.02 : 1.0
                                    glowColor: root._glowColor
                                    glowIntensity: isFocused ? root._glowPulse * 0.85 : root._glowPulse * 0.18

                                    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

                                    MouseArea {
                                        id: gCma
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            root.focusIndex = gameCard.fi;
                                            if (index >= 0 && index < recentGames.length)
                                                root.openGameDetail(recentGames[index]);
                                        }
                                    }

                                    // Single row: icon + title/count + progress bar + percentage
                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: Math.round(parent.height * 0.12)
                                        spacing: Math.round(parent.width * 0.015)

                                        // Game icon from RA
                                        Rectangle {
                                            width: Math.round(parent.height * 0.85)
                                            height: Math.round(parent.height * 0.85)
                                            radius: 8
                                            color: Qt.rgba(0.05, 0.08, 0.16, 0.50)
                                            border.color: Qt.rgba(0.12, 0.20, 0.36, 0.35)
                                            border.width: 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            clip: true

                                            Image {
                                                anchors.fill: parent
                                                anchors.margins: 1
                                                source: modelData.imageIcon || ""
                                                fillMode: Image.PreserveAspectCrop
                                                smooth: true
                                                asynchronous: true
                                                visible: status === Image.Ready
                                            }

                                            // Platform badge overlay (bottom-right)
                                            Rectangle {
                                                anchors.bottom: parent.bottom
                                                anchors.right: parent.right
                                                anchors.margins: 2
                                                width: Math.round(parent.width * 0.6)
                                                height: Math.round(parent.height * 0.30)
                                                radius: 4
                                                color: "#c8962c"
                                                visible: modelData.platform && modelData.platform !== ""

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.platform
                                                    font.pixelSize: Math.max(6, Math.round(parent.width * 0.30))
                                                    font.bold: true
                                                    color: "#ffffff"
                                                }
                                            }
                                        }

                                        // Title + count
                                        Column {
                                            id: titleCol
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width - Math.round(parent.height * 0.85) - badgeRow.width - progressBarItem.width - percentBadge.width - parent.spacing * 5
                                            spacing: Math.round(root.height * 0.003)

                                            // Capture game data
                                            property int _earned: modelData.earned || 0
                                            property int _total: modelData.total || 0
                                            property real _progress: modelData.progress || 0
                                            property var _badges: []
                                            property string _gid: String(modelData.gameId || "")

                                            Connections {
                                                target: root
                                                function onGameBadgesUpdated() {
                                                    titleCol._badges = root._gameBadges[titleCol._gid] || [];
                                                }
                                            }
                                            Component.onCompleted: {
                                                titleCol._badges = root._gameBadges[titleCol._gid] || [];
                                            }

                                            Text {
                                                text: modelData.title
                                                font.pixelSize: Math.round(root.height * 0.021)
                                                font.bold: true
                                                font.weight: gameCard.isFocused ? Font.Bold : Font.DemiBold
                                                color: gameCard.isFocused ? "#f0f4ff" : "#b8c8e0"
                                                elide: Text.ElideRight
                                                width: parent.width
                                                Behavior on color { ColorAnimation { duration: 300 } }
                                            }

                                            Text {
                                                text: modelData.earned + " / " + modelData.total + " " + T.t("ra_trophies_suffix", root.lang)
                                                font.pixelSize: Math.round(root.height * 0.015)
                                                color: gameCard.isFocused ? "#7098b0" : "#506878"
                                                Behavior on color { ColorAnimation { duration: 300 } }
                                            }
                                        }

                                        // Trophy badge icons (between title and progress bar)
                                        Row {
                                            id: badgeRow
                                            spacing: Math.round(root.width * 0.005)
                                            anchors.verticalCenter: parent.verticalCenter
                                            visible: titleCol._badges.length > 0
                                            rightPadding: Math.round(root.width * 0.012)

                                            Repeater {
                                                model: Math.min(titleCol._badges.length, 5)

                                                Rectangle {
                                                    width: Math.round(root.height * 0.052)
                                                    height: width
                                                    radius: width * 0.5
                                                    color: Qt.rgba(0.06, 0.08, 0.16, 0.50)
                                                    border.color: {
                                                        var b = titleCol._badges[index];
                                                        if (!b) return Qt.rgba(0.22, 0.26, 0.38, 0.35);
                                                        if (!b.unlocked) return Qt.rgba(0.22, 0.26, 0.38, 0.35);
                                                        return b.points >= 25 ? "#d0a040" : b.points >= 10 ? "#b0b0b0" : "#cd7f32";
                                                    }
                                                    border.width: 1.2
                                                    clip: true
                                                    opacity: (titleCol._badges[index] && titleCol._badges[index].unlocked) ? 1.0 : 0.45

                                                    Image {
                                                        anchors.fill: parent
                                                        anchors.margins: 1
                                                        source: {
                                                            var b = titleCol._badges[index];
                                                            if (!b) return "";
                                                            return b.unlocked ? (b.badgeUrl || "") : (b.badgeLockedUrl || "");
                                                        }
                                                        fillMode: Image.PreserveAspectCrop
                                                        smooth: true
                                                        asynchronous: true
                                                    }
                                                }
                                            }

                                            Text {
                                                visible: titleCol._badges.length > 5
                                                text: "+" + (titleCol._badges.length - 5)
                                                font.pixelSize: Math.round(root.height * 0.012)
                                                color: "#607888"
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        // Inline progress bar
                                        Item {
                                            id: progressBarItem
                                            width: Math.round(gameCard.width * 0.22)
                                            height: Math.round(root.height * 0.014)
                                            anchors.verticalCenter: parent.verticalCenter

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: height * 0.5
                                                color: Qt.rgba(0.08, 0.08, 0.12, 0.60)
                                                border.color: Qt.rgba(0.20, 0.25, 0.35, 0.35)
                                                border.width: 1
                                            }
                                            Rectangle {
                                                width: parent.width * modelData.progress
                                                height: parent.height
                                                radius: height * 0.5
                                                opacity: gameCard.isFocused ? 1.0 : 0.70
                                                Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                                                Behavior on opacity { NumberAnimation { duration: 300 } }

                                                // Simple color cycle animation
                                                property color _sliderColor: "#7040c0"
                                                SequentialAnimation on _sliderColor {
                                                    running: root.hubOpen
                                                    loops: Animation.Infinite
                                                    ColorAnimation { to: "#5050e0"; duration: 2500; easing.type: Easing.InOutSine }
                                                    ColorAnimation { to: "#2888f0"; duration: 2500; easing.type: Easing.InOutSine }
                                                    ColorAnimation { to: "#20b8c8"; duration: 2500; easing.type: Easing.InOutSine }
                                                    ColorAnimation { to: "#2888f0"; duration: 2500; easing.type: Easing.InOutSine }
                                                    ColorAnimation { to: "#7040c0"; duration: 2500; easing.type: Easing.InOutSine }
                                                }
                                                color: _sliderColor

                                                // Highlight sheen on top
                                                Rectangle {
                                                    anchors.top: parent.top
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    height: parent.height * 0.45
                                                    radius: parent.radius
                                                    color: Qt.rgba(1, 1, 1, 0.20)
                                                }
                                            }
                                        }

                                        // Percentage badge
                                        Rectangle {
                                            id: percentBadge
                                            width: Math.round(root.height * 0.048)
                                            height: Math.round(root.height * 0.048)
                                            radius: width * 0.22
                                            color: root._badgeColor(index)
                                            border.width: 0
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                anchors.centerIn: parent
                                                text: Math.round(modelData.progress * 100) + "%"
                                                font.pixelSize: Math.round(root.height * 0.015)
                                                font.bold: true
                                                color: "#ffffff"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    }  // close gamesBox GlassPanel
                }

                // Bottom padding
                Item { width: 1; height: root.height * 0.08 }
            }
        }
    }

    // GAME DETAIL VIEW (3-Level Hierarchy)
    Item {
        id: detailView
        anchors.fill: parent
        opacity: detailMode ? 1 : 0
        x: detailMode ? 0 : root.width * 0.15
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

        // Detail background — translucent tint over blur
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0.04, 0.08, 0.15, 0.50) }
                GradientStop { position: 0.4; color: Qt.rgba(0.05, 0.10, 0.18, 0.45) }
                GradientStop { position: 1.0; color: Qt.rgba(0.02, 0.05, 0.10, 0.55) }
            }
        }

        // Header
        Rectangle {
            id: detailHeader
            width: parent.width
            height: Math.round(parent.height * 0.065)
            color: Qt.rgba(0.04, 0.08, 0.16, 0.55)
            z: 10

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: Qt.rgba(0.10, 0.18, 0.34, 0.40)
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Math.round(parent.width * 0.025)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(parent.width * 0.012)

                Text {
                    text: "\u2190"
                    font.pixelSize: Math.round(detailHeader.height * 0.44)
                    color: "#6888a0"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: _detailLevel === 3 ? T.t("ra_back_summary", root.lang) : T.t("ra_back_games", root.lang)
                    font.pixelSize: Math.round(detailHeader.height * 0.34)
                    color: "#6888a0"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_detailLevel === 3) {
                        _detailLevel = 1;
                    } else {
                        closeGameDetail();
                    }
                }
            }
        }

        // LEVEL 1: STATUS VIEW (clean, scrollable)
        Flickable {
            id: statusView
            anchors.top: detailHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: _detailLevel <= 2
            opacity: _detailLevel <= 2 ? 1 : 0
            clip: true
            contentHeight: statusCol.height + Math.round(root.height * 0.02)
            boundsBehavior: Flickable.StopAtBounds

            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on contentY { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            Column {
                id: statusCol
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Math.round(root.height * 0.02)
                width: parent.width * 0.85
                spacing: Math.round(root.height * 0.016)

                // Game icon + Title + Platform
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Math.round(root.width * 0.035)

                    // Game icon (rounded square)
                    Rectangle {
                        width: Math.round(root.height * 0.13)
                        height: width
                        radius: 16
                        color: Qt.rgba(0.10, 0.18, 0.34, 0.45)
                        border.color: Qt.rgba(0.14, 0.22, 0.36, 0.30)
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            source: _selectedGameData ? (_selectedGameData.imageIcon || "") : ""
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            asynchronous: true
                            visible: status === Image.Ready
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "\uD83C\uDFAE"
                            font.pixelSize: Math.round(parent.width * 0.40)
                            opacity: 0.4
                            visible: !_selectedGameData || !_selectedGameData.imageIcon
                        }
                    }

                    // Title + Platform
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Math.round(root.height * 0.008)
                        width: statusCol.width - Math.round(root.height * 0.13) - playNowBtn.width - Math.round(root.width * 0.035) * 2

                        Text {
                            text: _selectedGameData ? _selectedGameData.title : ""
                            font.pixelSize: Math.round(root.height * 0.026)
                            font.bold: true
                            color: "#d0e0f0"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Rectangle {
                            width: Math.max(statusPlatLbl.implicitWidth + Math.round(root.width * 0.02), Math.round(root.width * 0.06))
                            height: Math.round(root.height * 0.026)
                            radius: 6
                            color: "#c8962c"

                            Text {
                                id: statusPlatLbl
                                anchors.centerIn: parent
                                text: _selectedGameData ? (_selectedGameData.shortLabel || _selectedGameData.platform || "") : ""
                                font.pixelSize: Math.max(7, Math.round(parent.height * 0.55))
                                font.bold: true
                                color: "#ffffff"
                            }
                        }
                    }

                    // Play Now button (top-right) — uses Play.png directly
                    Item {
                        id: playNowBtn
                        width: Math.round(root.height * 0.35)
                        height: width
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            anchors.fill: parent
                            source: "../../assets/images/icons/Play.png"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            asynchronous: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (_selectedGameData) {
                                    var cn = _selectedGameData.consoleName || "";
                                    launchGameRequested(_selectedGameData.title, cn);
                                }
                            }
                        }
                    }
                }

                // Spacer
                Item { width: 1; height: Math.round(root.height * 0.006) }

                // BIG Percentage
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        var pct = _selectedGameData ? Math.round(_selectedGameData.progress * 100) : 0;
                        return pct + "%";
                    }
                    font.pixelSize: Math.round(root.height * 0.095)
                    font.bold: true
                    color: {
                        var pct = _selectedGameData ? Math.round(_selectedGameData.progress * 100) : 0;
                        if (pct >= 100) return "#40d080";
                        if (pct >= 75) return "#60c0ff";
                        if (pct >= 50) return "#d4a543";
                        return "#6090c0";
                    }
                }

                // Progress Bar
                Item {
                    width: parent.width * 0.70
                    height: Math.round(root.height * 0.012)
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: height * 0.5
                        color: Qt.rgba(0.10, 0.16, 0.27, 0.40)
                    }
                    Rectangle {
                        width: parent.width * Math.min(1, _selectedGameData ? _selectedGameData.progress : 0)
                        height: parent.height
                        radius: height * 0.5
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#3080d0" }
                            GradientStop { position: 1.0; color: "#9050d8" }
                        }
                        Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                    }
                }

                // Subtitle: X/Y trofei
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        var earned = _selectedGameData ? _selectedGameData.earned : 0;
                        var total = _selectedGameData ? _selectedGameData.total : 0;
                        return earned + "/" + total + " " + T.t("ra_trophies_suffix", root.lang);
                    }
                    font.pixelSize: Math.round(root.height * 0.017)
                    color: "#6888a0"
                }

                // Spacer
                Item { width: 1; height: Math.round(root.height * 0.010) }

                // Last 3 unlocked trophies
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Math.round(root.height * 0.008)
                    visible: _gameAchievements.length > 0

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: T.t("ra_last_unlocked", root.lang)
                        font.pixelSize: Math.round(root.height * 0.015)
                        color: "#506880"
                        visible: _lastUnlockedTrophies.length > 0
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Math.round(root.width * 0.030)

                        Repeater {
                            model: _lastUnlockedTrophies

                            Column {
                                spacing: Math.round(root.height * 0.004)

                                // Trophy badge (circular)
                                Rectangle {
                                    width: Math.round(root.height * 0.060)
                                    height: width
                                    radius: width * 0.5
                                    color: modelData.color || "#4080c0"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    clip: true
                                    border.color: "#2a5080"
                                    border.width: 1

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        source: modelData.badgeUrl || ""
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        asynchronous: true
                                        visible: status === Image.Ready
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: "\uD83C\uDFC6"
                                        font.pixelSize: Math.round(parent.width * 0.40)
                                        visible: !modelData.badgeUrl || modelData.badgeUrl === ""
                                    }
                                }

                                // Trophy name
                                Text {
                                    text: modelData.title || ""
                                    font.pixelSize: Math.round(root.height * 0.012)
                                    color: "#7898b0"
                                    width: Math.round(root.width * 0.17)
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        // Placeholder if no trophies yet
                        Text {
                            visible: _lastUnlockedTrophies.length === 0
                            text: T.t("ra_no_trophies", root.lang)
                            font.pixelSize: Math.round(root.height * 0.015)
                            color: "#3a5068"
                            font.italic: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Spacer
                Item { width: 1; height: Math.round(root.height * 0.006) }

                // "Visualizza dettagli" Button
                Rectangle {
                    id: viewDetailsBtn
                    width: Math.round(root.width * 0.40)
                    height: Math.round(root.height * 0.045)
                    radius: height * 0.5
                    color: _detailStatusFocus === 1 ? Qt.rgba(0.10, 0.18, 0.34, 0.55) : Qt.rgba(0.05, 0.09, 0.18, 0.45)
                    border.color: _detailStatusFocus === 1 ? "#60b0ff" : Qt.rgba(0.10, 0.18, 0.34, 0.30)
                    border.width: _detailStatusFocus === 1 ? 2 : 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: Math.round(root.width * 0.010)

                        Text {
                            text: T.t("ra_view_details", root.lang)
                            font.pixelSize: Math.round(root.height * 0.017)
                            font.bold: true
                            color: _detailStatusFocus === 1 ? "#60b0ff" : "#6888a0"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Item {
                            width: yBtnLbl.implicitWidth + Math.round(root.width * 0.012)
                            height: yBtnLbl.implicitHeight + Math.round(root.height * 0.006)
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: "transparent"
                                border.color: "#3a5068"
                                border.width: 1
                            }
                            Text {
                                id: yBtnLbl
                                anchors.centerIn: parent
                                text: "Y"
                                font.pixelSize: Math.round(root.height * 0.013)
                                font.bold: true
                                color: "#3a5068"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root._detailLevel = 3
                    }
                }

                // Spacer before info rapide
                Item { width: 1; height: Math.round(root.height * 0.04) }

                // Info Rapide (horizontal adaptive pills, centered)
                Item {
                    width: parent.width
                    height: infoRapideFlow.height
                    Row {
                        id: infoRapideFlow
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Math.round(root.width * 0.014)

                        // Punti
                        Rectangle {
                            height: Math.round(root.height * 0.045)
                            width: puntiRow.implicitWidth + Math.round(root.width * 0.036)
                            radius: height * 0.5
                            color: Qt.rgba(0.06, 0.13, 0.23, 0.45)
                            border.color: Qt.rgba(0.12, 0.22, 0.36, 0.30)
                            border.width: 1

                            Row {
                                id: puntiRow
                                anchors.centerIn: parent
                                spacing: Math.round(root.width * 0.010)

                                Text {
                                    text: T.t("ra_stat_points", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.015)
                                    color: "#6888a0"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: {
                                        var earned = 0;
                                        var total = 0;
                                        for (var i = 0; i < _gameAchievements.length; i++) {
                                            total += _gameAchievements[i].points;
                                            if (_gameAchievements[i].unlocked) earned += _gameAchievements[i].points;
                                        }
                                        var ps = _selectedGameData ? (_selectedGameData.possibleScore || 0) : 0;
                                        if (ps > 0) total = ps;
                                        return earned + "/" + total;
                                    }
                                    font.pixelSize: Math.round(root.height * 0.016)
                                    font.bold: true
                                    color: "#d4a543"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        // Rarest trophy
                        Rectangle {
                            height: Math.round(root.height * 0.045)
                            width: rarestRow.implicitWidth + Math.round(root.width * 0.036)
                            radius: height * 0.5
                            color: Qt.rgba(0.06, 0.13, 0.23, 0.45)
                            border.color: Qt.rgba(0.12, 0.22, 0.36, 0.30)
                            border.width: 1

                            Row {
                                id: rarestRow
                                anchors.centerIn: parent
                                spacing: Math.round(root.width * 0.010)

                                Text {
                                    text: "Pi\u00f9 raro"
                                    font.pixelSize: Math.round(root.height * 0.015)
                                    color: "#6888a0"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: {
                                        var rarest = null;
                                        for (var i = 0; i < _gameAchievements.length; i++) {
                                            var a = _gameAchievements[i];
                                            if (a.unlocked && (!rarest || a.rarity < rarest.rarity)) {
                                                rarest = a;
                                            }
                                        }
                                        return rarest ? (rarest.title + " (" + rarest.rarity + "%)") : "\u2014";
                                    }
                                    font.pixelSize: Math.round(root.height * 0.016)
                                    font.bold: true
                                    color: "#ff6060"
                                    anchors.verticalCenter: parent.verticalCenter
                                    maximumLineCount: 1
                                    elide: Text.ElideRight
                                    width: Math.min(implicitWidth, Math.round(root.width * 0.30))
                                }
                            }
                        }

                        Rectangle {
                            height: Math.round(root.height * 0.045)
                            width: nextRow.implicitWidth + Math.round(root.width * 0.036)
                            radius: height * 0.5
                            color: Qt.rgba(0.06, 0.13, 0.23, 0.45)
                            border.color: Qt.rgba(0.12, 0.22, 0.36, 0.30)
                            border.width: 1

                            Row {
                                id: nextRow
                                anchors.centerIn: parent
                                spacing: Math.round(root.width * 0.010)

                                Text {
                                    text: T.t("ra_stat_goal", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.015)
                                    color: "#6888a0"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: {
                                        var pct = _selectedGameData ? Math.round(_selectedGameData.progress * 100) : 0;
                                        if (pct >= 100) return T.t("ra_stat_completed", root.lang);
                                        var milestones = [25, 50, 75, 100];
                                        for (var i = 0; i < milestones.length; i++) {
                                            if (pct < milestones[i]) return milestones[i] + "%";
                                        }
                                        return "100%";
                                    }
                                    font.pixelSize: Math.round(root.height * 0.016)
                                    font.bold: true
                                    color: "#60b0ff"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        // Punti Hardcore
                        Rectangle {
                            height: Math.round(root.height * 0.045)
                            width: hardcoreRow.implicitWidth + Math.round(root.width * 0.036)
                            radius: height * 0.5
                            color: Qt.rgba(0.06, 0.13, 0.23, 0.45)
                            border.color: Qt.rgba(0.12, 0.22, 0.36, 0.30)
                            border.width: 1

                            Row {
                                id: hardcoreRow
                                anchors.centerIn: parent
                                spacing: Math.round(root.width * 0.010)

                                Text {
                                    text: T.t("ra_stat_hardcore", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.015)
                                    color: "#6888a0"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: {
                                        var tr = 0;
                                        for (var i = 0; i < _gameAchievements.length; i++) {
                                            if (_gameAchievements[i].unlocked) tr += (_gameAchievements[i].trueRatio || 0);
                                        }
                                        return tr > 0 ? tr.toString() : "\u2014";
                                    }
                                    font.pixelSize: Math.round(root.height * 0.016)
                                    font.bold: true
                                    color: "#e07030"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }

                // Bottom padding
                Item { width: 1; height: Math.round(root.height * 0.04) }
            }
        }

        // LEVEL 3: FULL DETAILS (scrollable)
        Item {
            id: fullDetailsView
            anchors.top: detailHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: _detailLevel === 3
            opacity: _detailLevel === 3 ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Flickable {
                id: detailFlick
                anchors.fill: parent
                contentHeight: detailCol.height + root.height * 0.05
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Behavior on contentY { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                Column {
                    id: detailCol
                    width: parent.width
                    spacing: 0

                    // Compact game header
                    Item {
                        width: parent.width
                        height: Math.round(root.height * 0.09)

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: Math.round(parent.width * 0.025)
                            anchors.rightMargin: Math.round(parent.width * 0.025)
                            anchors.topMargin: Math.round(root.height * 0.012)
                            spacing: Math.round(root.width * 0.02)

                            // Small icon
                            Rectangle {
                                width: Math.round(parent.height * 0.70)
                                height: width; radius: 10
                                color: Qt.rgba(0.10, 0.18, 0.34, 0.45)
                                anchors.verticalCenter: parent.verticalCenter
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    source: _selectedGameData ? (_selectedGameData.imageIcon || "") : ""
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true; asynchronous: true
                                    visible: status === Image.Ready
                                }
                            }

                            // Title + progress summary
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Math.round(root.height * 0.004)

                                Text {
                                    text: _selectedGameData ? _selectedGameData.title : ""
                                    font.pixelSize: Math.round(root.height * 0.020)
                                    font.bold: true
                                    color: "#d0e0f0"
                                    elide: Text.ElideRight
                                    width: detailCol.width - Math.round(root.height * 0.09 * 0.70) - Math.round(root.width * 0.08)
                                }
                                Text {
                                    text: {
                                        var e = _selectedGameData ? _selectedGameData.earned : 0;
                                        var t = _selectedGameData ? _selectedGameData.total : 0;
                                        var p = _selectedGameData ? Math.round(_selectedGameData.progress * 100) : 0;
                                        return e + "/" + t + " " + T.t("ra_trophies_suffix", root.lang) + " \u00b7 " + p + "%";
                                    }
                                    font.pixelSize: Math.round(root.height * 0.015)
                                    color: "#6888a0"
                                }
                            }
                        }
                    }

                    // Filter Tabs
                    Item {
                        id: tabsSection
                        width: parent.width
                        height: Math.round(root.height * 0.058)

                        Rectangle {
                            anchors.fill: parent
                            anchors.leftMargin: Math.round(parent.width * 0.025)
                            anchors.rightMargin: Math.round(parent.width * 0.025)
                            anchors.topMargin: Math.round(root.height * 0.008)
                            radius: 14
                            color: Qt.rgba(0.04, 0.08, 0.16, 0.50)
                            border.color: (_detailSection === 0) ? Qt.rgba(0.18, 0.44, 0.63, 0.55) : Qt.rgba(0.10, 0.18, 0.34, 0.30)
                            border.width: (_detailSection === 0) ? 2 : 1

                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: Math.round(parent.width * 0.01)
                                anchors.rightMargin: Math.round(parent.width * 0.01)

                                Repeater {
                                    model: _detailTabs

                                    Item {
                                        width: Math.floor(parent.width / _detailTabs.length)
                                        height: parent.height

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: Math.round(parent.height * 0.15)
                                            radius: 10
                                            color: _detailTabIdx === index ? Qt.rgba(0.10, 0.18, 0.34, 0.50) : "transparent"
                                            border.color: _detailTabIdx === index ? Qt.rgba(0.18, 0.44, 0.63, 0.55) : "transparent"
                                            border.width: _detailTabIdx === index ? 1 : 0

                                            Behavior on color { ColorAnimation { duration: 150 } }

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData
                                                font.pixelSize: Math.round(root.height * 0.017)
                                                font.bold: _detailTabIdx === index
                                                color: _detailTabIdx === index ? "#60b0ff" : "#6888a0"
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                root._detailSection = 0;
                                                root._detailTabIdx = index;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Achievement count label
                    Item {
                        width: parent.width
                        height: Math.round(root.height * 0.035)

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: Math.round(parent.width * 0.035)
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                var tab = root._detailTabIdx;
                                var achs = root._gameAchievements;
                                if (!achs || achs.length === 0) return "";
                                var count = 0;
                                if (tab === 0) count = achs.length;
                                else if (tab === 1) {
                                    for (var i = 0; i < achs.length; i++) { if (achs[i].unlocked) count++; }
                                } else {
                                    for (var j = 0; j < achs.length; j++) { if (!achs[j].unlocked) count++; }
                                }
                                return count + " " + T.t("ra_trophies_suffix", root.lang);
                            }
                            font.pixelSize: Math.round(root.height * 0.014)
                            color: "#506880"
                        }
                    }

                    // Achievement List
                    Item {
                        id: achSection
                        width: parent.width
                        height: achCol.height + Math.round(root.height * 0.02)

                        Column {
                            id: achCol
                            width: parent.width
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Math.round(parent.width * 0.025)
                            anchors.rightMargin: Math.round(parent.width * 0.025)
                            anchors.topMargin: Math.round(root.height * 0.008)
                            spacing: Math.round(root.height * 0.010)

                            Repeater {
                                model: {
                                    var tab = root._detailTabIdx;
                                    var achs = root._gameAchievements;
                                    if (!achs || achs.length === 0) return [];
                                    if (tab === 0) return achs;
                                    if (tab === 1) {
                                        var u = [];
                                        for (var i = 0; i < achs.length; i++) { if (achs[i].unlocked) u.push(achs[i]); }
                                        return u;
                                    }
                                    var l = [];
                                    for (var j = 0; j < achs.length; j++) { if (!achs[j].unlocked) l.push(achs[j]); }
                                    return l;
                                }

                                Rectangle {
                                    id: achCard
                                    property bool isFocused: _detailSection === 1 && _detailAchIdx === index
                                    width: achCol.width - Math.round(root.width * 0.05)
                                    height: Math.round(root.height * 0.100)
                                    radius: 16
                                    color: isFocused ? Qt.rgba(0.08, 0.16, 0.28, 0.55) : achMa.containsMouse ? Qt.rgba(0.06, 0.13, 0.23, 0.50) : Qt.rgba(0.04, 0.08, 0.16, 0.40)
                                    border.color: isFocused ? Qt.rgba(0.18, 0.44, 0.63, 0.55) : Qt.rgba(0.10, 0.18, 0.34, 0.30)
                                    border.width: isFocused ? 2 : 1
                                    clip: true

                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }

                                    MouseArea {
                                        id: achMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            root._detailSection = 1;
                                            root._detailAchIdx = index;
                                        }
                                    }

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: Math.round(parent.height * 0.12)
                                        spacing: Math.round(parent.width * 0.020)

                                        // Trophy badge image
                                        Rectangle {
                                            width: Math.round(parent.height * 0.72)
                                            height: width; radius: width * 0.5
                                            color: modelData.unlocked ? modelData.color : "#1a2040"
                                            opacity: modelData.unlocked ? 1.0 : 0.5
                                            anchors.verticalCenter: parent.verticalCenter
                                            clip: true

                                            Image {
                                                anchors.fill: parent
                                                anchors.margins: 1
                                                source: modelData.unlocked ? (modelData.badgeUrl || "") : (modelData.badgeLockedUrl || modelData.badgeUrl || "")
                                                fillMode: Image.PreserveAspectCrop
                                                smooth: true
                                                asynchronous: true
                                                visible: status === Image.Ready
                                                opacity: modelData.unlocked ? 1.0 : 0.4
                                            }
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.unlocked ? "\uD83C\uDFC6" : "\uD83D\uDD12"
                                                font.pixelSize: Math.round(parent.width * 0.42)
                                                visible: !(modelData.badgeUrl && modelData.badgeUrl !== "")
                                            }
                                        }

                                        // Title + Description + Date
                                        Column {
                                            width: parent.width - Math.round(parent.height * 0.72) - achPointsBadge.width - parent.spacing * 2 - Math.round(root.width * 0.01)
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: Math.round(root.height * 0.004)

                                            Text {
                                                text: modelData.title
                                                font.pixelSize: Math.round(root.height * 0.018)
                                                font.bold: true
                                                color: modelData.unlocked ? "#d0e0f0" : "#5a7090"
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }
                                            Text {
                                                text: modelData.desc
                                                font.pixelSize: Math.round(root.height * 0.014)
                                                color: modelData.unlocked ? "#7898b0" : "#3a5068"
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }
                                            Text {
                                                text: modelData.unlocked ? ("\u2705 " + modelData.date) : ""
                                                font.pixelSize: Math.round(root.height * 0.012)
                                                color: "#40a070"
                                                visible: modelData.unlocked
                                            }
                                        }

                                        // Right column: points + rarity
                                        Column {
                                            id: achPointsBadge
                                            width: Math.round(root.width * 0.09)
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: Math.round(root.height * 0.005)

                                            Rectangle {
                                                width: parent.width
                                                height: Math.round(root.height * 0.028)
                                                radius: height * 0.5
                                                color: modelData.unlocked ? Qt.rgba(0.10, 0.18, 0.34, 0.55) : Qt.rgba(0.07, 0.12, 0.18, 0.35)
                                                border.color: modelData.unlocked ? "#d4a543" : Qt.rgba(0.14, 0.22, 0.36, 0.30)
                                                border.width: 1
                                                anchors.horizontalCenter: parent.horizontalCenter

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.points + " " + T.t("ra_pts_suffix", root.lang)
                                                    font.pixelSize: Math.round(root.height * 0.014)
                                                    font.bold: true
                                                    color: modelData.unlocked ? "#d4a543" : "#4a5868"
                                                }
                                            }

                                            Row {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                spacing: Math.round(root.width * 0.004)

                                                Text {
                                                    text: "\uD83C\uDFC6"
                                                    font.pixelSize: Math.round(root.height * 0.011)
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                                Text {
                                                    text: modelData.rarity.toFixed(1) + "%"
                                                    font.pixelSize: Math.round(root.height * 0.012)
                                                    font.bold: true
                                                    color: modelData.rarity < 15 ? "#ff6060" :
                                                           modelData.rarity < 35 ? "#d4a543" :
                                                           modelData.rarity < 60 ? "#60b0ff" : "#40b080"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Bottom padding
                    Item { width: 1; height: root.height * 0.06 }
                }
            }
        }
    }

    // ALL GAMES VIEW (4-column grid by platform)
    Item {
        id: allGamesView
        anchors.fill: parent
        opacity: allGamesMode ? 1 : 0
        x: allGamesMode ? 0 : root.width * 0.15
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

        // Background — translucent tint over blur
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0.04, 0.08, 0.15, 0.50) }
                GradientStop { position: 0.4; color: Qt.rgba(0.05, 0.10, 0.18, 0.45) }
                GradientStop { position: 1.0; color: Qt.rgba(0.02, 0.05, 0.10, 0.55) }
            }
        }

        Rectangle {
            id: agHeader
            width: parent.width
            height: Math.round(parent.height * 0.065)
            color: Qt.rgba(0.04, 0.08, 0.16, 0.55)
            z: 10

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: Qt.rgba(0.10, 0.18, 0.34, 0.40)
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Math.round(parent.width * 0.025)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(parent.width * 0.012)

                Text {
                    text: "\u2190"
                    font.pixelSize: Math.round(agHeader.height * 0.44)
                    color: "#6888a0"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: T.t("ra_back_home", root.lang)
                    font.pixelSize: Math.round(agHeader.height * 0.34)
                    color: "#6888a0"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Toggle: RA games / All games
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(parent.width * 0.025)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(root.width * 0.008)

                Rectangle {
                    property bool isSelected: !root._agShowAllPegasus
                    property bool isFocused: root._agSection === 0 && root._agToggleIdx === 0
                    width: raToggleText.implicitWidth + Math.round(root.width * 0.024)
                    height: Math.round(agHeader.height * 0.60)
                    radius: height * 0.5
                    color: isSelected ? Qt.rgba(0.15, 0.30, 0.55, 0.60) : isFocused ? Qt.rgba(0.12, 0.20, 0.35, 0.50) : Qt.rgba(0.08, 0.12, 0.20, 0.40)
                    border.color: isFocused ? "#80c0ff" : isSelected ? Qt.rgba(0.30, 0.55, 0.80, 0.60) : Qt.rgba(0.15, 0.25, 0.40, 0.30)
                    border.width: isFocused ? 2.5 : isSelected ? 1.5 : 1
                    anchors.verticalCenter: parent.verticalCenter
                    scale: isFocused ? 1.08 : 1.0

                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Text {
                        id: raToggleText
                        anchors.centerIn: parent
                        text: "\uD83C\uDFC6 RA"
                        font.pixelSize: Math.round(root.height * 0.016)
                        font.bold: isSelected || isFocused
                        color: isFocused ? "#80c0ff" : isSelected ? "#60b0ff" : "#5a7890"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root._agSection = 0;
                            root._agToggleIdx = 0;
                            root._agShowAllPegasus = false;
                            root._agPlatIdx = 0;
                            root._agGridIdx = 0;
                        }
                    }
                }

                Rectangle {
                    property bool isSelected: root._agShowAllPegasus
                    property bool isFocused: root._agSection === 0 && root._agToggleIdx === 1
                    width: allToggleText.implicitWidth + Math.round(root.width * 0.024)
                    height: Math.round(agHeader.height * 0.60)
                    radius: height * 0.5
                    color: isSelected ? Qt.rgba(0.15, 0.30, 0.55, 0.60) : isFocused ? Qt.rgba(0.12, 0.20, 0.35, 0.50) : Qt.rgba(0.08, 0.12, 0.20, 0.40)
                    border.color: isFocused ? "#80c0ff" : isSelected ? Qt.rgba(0.30, 0.55, 0.80, 0.60) : Qt.rgba(0.15, 0.25, 0.40, 0.30)
                    border.width: isFocused ? 2.5 : isSelected ? 1.5 : 1
                    anchors.verticalCenter: parent.verticalCenter
                    scale: isFocused ? 1.08 : 1.0

                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Text {
                        id: allToggleText
                        anchors.centerIn: parent
                        text: "\uD83C\uDFAE All"
                        font.pixelSize: Math.round(root.height * 0.016)
                        font.bold: isSelected || isFocused
                        color: isFocused ? "#80c0ff" : isSelected ? "#60b0ff" : "#5a7890"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root._agSection = 0;
                            root._agToggleIdx = 1;
                            root._agShowAllPegasus = true;
                            root._agPlatIdx = 0;
                            root._agGridIdx = 0;
                            if (root._pegasusGames.length === 0) root._buildPegasusGames();
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: closeAllGames()
            }
        }

        // Scrollable body
        Flickable {
            id: allGamesFlick
            anchors.top: agHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            contentHeight: agBody.height + root.height * 0.05
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Behavior on contentY { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            Column {
                id: agBody
                width: parent.width
                spacing: 0

                // Title section
                Item {
                    width: parent.width
                    height: Math.round(root.height * 0.12)

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: Math.round(parent.width * 0.035)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Math.round(root.height * 0.006)

                        Text {
                            text: T.t("ra_all_games_title", root.lang)
                            font.pixelSize: Math.round(root.height * 0.036)
                            font.bold: true
                            color: "#d0e0f0"
                        }
                        Text {
                            text: _filteredGames().length + " " + T.t("ra_games_available", root.lang)
                                  + (_agShowAllPegasus ? "" : " (RetroAchievements)")
                            font.pixelSize: Math.round(root.height * 0.018)
                            color: "#6888a0"
                        }
                    }
                }

                // Search bar
                Item {
                    width: parent.width
                    height: Math.round(root.height * 0.065)

                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: Math.round(parent.width * 0.035)
                        anchors.rightMargin: Math.round(parent.width * 0.035)
                        anchors.topMargin: Math.round(root.height * 0.005)
                        anchors.bottomMargin: Math.round(root.height * 0.005)
                        radius: 14
                        color: Qt.rgba(0.04, 0.08, 0.16, 0.50)
                        border.color: Qt.rgba(0.10, 0.18, 0.34, 0.30)
                        border.width: 1

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Math.round(parent.width * 0.020)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Math.round(root.width * 0.010)

                            Text {
                                text: "\uD83D\uDD0D"
                                font.pixelSize: Math.round(root.height * 0.022)
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: 0.6
                            }
                            Text {
                                text: T.t("ra_search_games", root.lang)
                                font.pixelSize: Math.round(root.height * 0.019)
                                color: "#4a6880"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // Platform filter tabs
                Item {
                    id: agPlatTabs
                    width: parent.width
                    height: Math.round(root.height * 0.065)

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Math.round(parent.width * 0.035)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Math.round(root.width * 0.010)

                        Repeater {
                            model: _activePlatforms()

                            Rectangle {
                                property bool isActive: _agPlatIdx === index
                                property bool isSectionFocused: _agSection === 1
                                width: platTabText.implicitWidth + Math.round(root.width * 0.030)
                                height: Math.round(root.height * 0.042)
                                radius: height * 0.5
                                color: isActive ? Qt.rgba(0.10, 0.18, 0.34, 0.50) : "transparent"
                                border.color: isActive && isSectionFocused ? Qt.rgba(0.18, 0.44, 0.63, 0.55) :
                                              isActive ? Qt.rgba(0.16, 0.25, 0.40, 0.45) : Qt.rgba(0.10, 0.18, 0.34, 0.25)
                                border.width: isActive && isSectionFocused ? 2 : 1

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                Text {
                                    id: platTabText
                                    anchors.centerIn: parent
                                    text: modelData.name + "  (" + _platformCount(modelData.tag) + ")"
                                    font.pixelSize: Math.round(root.height * 0.017)
                                    font.bold: isActive
                                    color: isActive ? "#60b0ff" : "#6888a0"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        root._agSection = 1;
                                        root._agPlatIdx = index;
                                        root._agGridIdx = 0;
                                    }
                                }
                            }
                        }
                    }
                }

                // Game cards grid (4 columns)
                Item {
                    id: agGridSection
                    width: parent.width
                    height: agGrid.height + Math.round(root.height * 0.02)

                    Grid {
                        id: agGrid
                        columns: 4
                        spacing: Math.round(root.width * 0.015)
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Math.round(parent.width * 0.035)
                        anchors.rightMargin: Math.round(parent.width * 0.035)
                        anchors.topMargin: Math.round(root.height * 0.010)

                        Repeater {
                            id: agRepeater
                            model: _filteredGames()

                            Rectangle {
                                id: agCard
                                property bool isFocused: _agSection === 2 && _agGridIdx === index
                                property bool isZeroProgress: modelData.earned === 0
                                property bool isPegasusOnly: !!(modelData.isPegasus) && modelData.gameId === 0
                                width: Math.floor((agGrid.width - agGrid.spacing * 3) / 4)
                                height: Math.round(root.height * 0.26)
                                radius: 18
                                color: isFocused ? Qt.rgba(0.10, 0.20, 0.32, 0.55) : agCardMa.containsMouse ? Qt.rgba(0.06, 0.13, 0.23, 0.50) : Qt.rgba(0.04, 0.08, 0.16, 0.40)
                                border.color: isFocused ? Qt.rgba(0.30, 0.62, 0.88, 0.55) : Qt.rgba(0.10, 0.18, 0.34, 0.30)
                                border.width: isFocused ? 2.5 : 1
                                clip: true
                                scale: isFocused ? 1.04 : 1.0

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                                MouseArea {
                                    id: agCardMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        root._agSection = 2;
                                        root._agGridIdx = index;
                                        var filtered = root._filteredGames();
                                        if (index >= 0 && index < filtered.length) {
                                            var gd = filtered[index];
                                            root._cameFromAllGames = true;
                                            root.allGamesMode = false;
                                            root.openGameDetail(gd);
                                        }
                                    }
                                }

                                // Card image area
                                Rectangle {
                                    id: cardImageArea
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: parent.height * 0.60
                                    radius: parent.radius
                                    color: Qt.rgba(0.05, 0.08, 0.14, 0.50)

                                    // Bottom corners square
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        width: parent.width
                                        height: parent.radius
                                        color: parent.color
                                    }

                                    // Placeholder gradient
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: Qt.rgba(0.08, 0.14, 0.24, 0.50) }
                                            GradientStop { position: 1.0; color: Qt.rgba(0.04, 0.08, 0.14, 0.50) }
                                        }
                                        opacity: 0.8
                                        visible: !agCardImage.visible
                                    }

                                    // Game icon from RA
                                    Image {
                                        id: agCardImage
                                        anchors.fill: parent
                                        source: modelData.imageIcon || ""
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        asynchronous: true
                                        visible: status === Image.Ready
                                        // Desaturate 0% progress games (only RA games)
                                        opacity: (agCard.isZeroProgress && !agCard.isPegasusOnly) ? 0.55 : 1.0
                                    }

                                    // Desaturation dark overlay for 0% games
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        color: "#000000"
                                        opacity: (agCard.isZeroProgress && !agCard.isPegasusOnly) && agCardImage.visible ? 0.30 : 0
                                        Behavior on opacity { NumberAnimation { duration: 200 } }
                                    }

                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: Math.round(parent.height * 0.08)
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: nonIniText.implicitWidth + Math.round(root.width * 0.016)
                                        height: Math.round(root.height * 0.026)
                                        radius: height * 0.5
                                        color: "#88101828"
                                        border.color: "#506888a0"
                                        border.width: 1
                                        visible: agCard.isZeroProgress && !agCard.isPegasusOnly

                                        Text {
                                            id: nonIniText
                                            anchors.centerIn: parent
                                            text: T.t("ra_not_started", root.lang)
                                            font.pixelSize: Math.round(root.height * 0.013)
                                            font.bold: true
                                            color: "#8898a8"
                                        }
                                    }

                                    // Placeholder icon (fallback)
                                    Text {
                                        anchors.centerIn: parent
                                        text: "\uD83C\uDFAE"
                                        font.pixelSize: Math.round(parent.height * 0.35)
                                        opacity: 0.3
                                        visible: !agCardImage.visible
                                    }

                                    // Progress % circle (top-left) — only for RA games
                                    Rectangle {
                                        x: Math.round(parent.width * 0.06)
                                        y: Math.round(parent.height * 0.08)
                                        width: Math.round(root.height * 0.038)
                                        height: width; radius: width * 0.5
                                        color: "#20000000"
                                        visible: !agCard.isPegasusOnly
                                        border.color: modelData.progress >= 1.0 ? "#40d080" :
                                                      modelData.progress >= 0.7 ? "#60b0ff" :
                                                      modelData.progress >= 0.4 ? "#c0c0c0" :
                                                      agCard.isZeroProgress ? "#4a5868" : "#7090a8"
                                        border.width: 2

                                        Text {
                                            anchors.centerIn: parent
                                            text: Math.round(modelData.progress * 100) + "%"
                                            font.pixelSize: Math.round(parent.width * 0.36)
                                            font.bold: true
                                            color: parent.border.color
                                        }
                                    }

                                    // Platform badge (top-right)
                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.rightMargin: Math.round(parent.width * 0.06)
                                        y: Math.round(parent.height * 0.08)
                                        width: platBadgeText.implicitWidth + Math.round(root.width * 0.012)
                                        height: Math.round(root.height * 0.028)
                                        radius: 6
                                        color: modelData.progress >= 1.0 ? "#2a8050" : "#2a5080"

                                        Text {
                                            id: platBadgeText
                                            anchors.centerIn: parent
                                            text: modelData.platform
                                            font.pixelSize: Math.round(root.height * 0.015)
                                            font.bold: true
                                            color: "#ffffff"
                                        }
                                    }
                                }

                                // Card info area
                                Column {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: Math.round(parent.width * 0.08)
                                    anchors.bottomMargin: Math.round(parent.height * 0.06)
                                    spacing: Math.round(root.height * 0.004)

                                    Text {
                                        text: modelData.title
                                        font.pixelSize: Math.round(root.height * 0.019)
                                        font.bold: true
                                        color: agCard.isPegasusOnly ? "#d0e0f0" : agCard.isZeroProgress ? "#8098b0" : "#d0e0f0"
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    // Trophy count, platform for Pegasus, or "Inizia a giocare"
                                    Text {
                                        text: agCard.isPegasusOnly
                                              ? modelData.platform
                                              : agCard.isZeroProgress
                                                ? T.t("ra_no_trophies_start", root.lang)
                                                : modelData.earned + "/" + modelData.total + " " + T.t("ra_trophies_suffix", root.lang)
                                        font.pixelSize: Math.round(root.height * 0.015)
                                        color: agCard.isPegasusOnly ? "#6888a0" : agCard.isZeroProgress ? "#4a6070" : "#6888a0"
                                        font.italic: agCard.isZeroProgress && !agCard.isPegasusOnly
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }
                                }
                            }  // close agCard Rectangle
                        }  // close Repeater (agRepeater)
                    }  // close Grid (agGrid)
                }  // close Item (agGridSection)

                // Bottom padding
                Item { width: 1; height: root.height * 0.06 }
            }
        }
    }

    // ALL TROPHIES VIEW
    Item {
        id: allTrophiesView
        anchors.fill: parent
        opacity: allTrophiesMode ? 1 : 0
        x: allTrophiesMode ? 0 : root.width * 0.15
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

        // Background — translucent tint over blur
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0.04, 0.08, 0.15, 0.50) }
                GradientStop { position: 0.4; color: Qt.rgba(0.05, 0.10, 0.18, 0.45) }
                GradientStop { position: 1.0; color: Qt.rgba(0.02, 0.05, 0.10, 0.55) }
            }
        }

        Rectangle {
            id: atHeader
            width: parent.width
            height: Math.round(parent.height * 0.065)
            color: Qt.rgba(0.04, 0.08, 0.16, 0.55)
            z: 10

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: Qt.rgba(0.10, 0.18, 0.34, 0.40)
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Math.round(parent.width * 0.025)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(parent.width * 0.012)

                Text {
                    text: "\u2190"
                    font.pixelSize: Math.round(atHeader.height * 0.44)
                    color: "#6888a0"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: T.t("ra_back_home", root.lang)
                    font.pixelSize: Math.round(atHeader.height * 0.34)
                    color: "#6888a0"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: closeAllTrophies()
            }
        }

        // Scrollable body
        Flickable {
            id: allTrophiesFlick
            anchors.top: atHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            contentHeight: atBody.height + root.height * 0.05
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Behavior on contentY { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            Column {
                id: atBody
                width: parent.width
                spacing: 0

                // Title
                Item {
                    width: parent.width
                    height: Math.round(root.height * 0.08)

                    Text {
                        text: T.t("ra_all_trophies_title", root.lang)
                        font.pixelSize: Math.round(root.height * 0.036)
                        font.bold: true
                        color: "#d0e0f0"
                        anchors.left: parent.left
                        anchors.leftMargin: Math.round(parent.width * 0.035)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // 4 Stat Cards
                Item {
                    width: parent.width
                    height: Math.round(root.height * 0.095)

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: Math.round(parent.width * 0.035)
                        anchors.rightMargin: Math.round(parent.width * 0.035)
                        spacing: Math.round(parent.width * 0.015)

                        // Trofei Totali
                        Rectangle {
                            width: Math.floor((parent.width - parent.spacing * 3) / 4)
                            height: parent.height
                            radius: 16
                            color: Qt.rgba(0.05, 0.09, 0.18, 0.45)
                            border.color: Qt.rgba(0.10, 0.18, 0.34, 0.30); border.width: 1

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: Math.round(parent.width * 0.10)
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Math.round(root.height * 0.004)

                                Text {
                                    text: T.t("ra_total_trophies", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.015)
                                    color: "#6888a0"
                                }
                                Row {
                                    spacing: 0
                                    Text {
                                        text: "" + _trophyStatsEarned()
                                        font.pixelSize: Math.round(root.height * 0.030)
                                        font.bold: true
                                        color: "#d0e0f0"
                                    }
                                    Text {
                                        text: "/" + _trophyStatsTotal()
                                        font.pixelSize: Math.round(root.height * 0.030)
                                        color: "#5a7090"
                                        anchors.baseline: parent.children[0].baseline
                                    }
                                }
                            }
                        }

                        // Punti
                        Rectangle {
                            width: Math.floor((parent.width - parent.spacing * 3) / 4)
                            height: parent.height
                            radius: 16
                            color: Qt.rgba(0.05, 0.09, 0.18, 0.45)
                            border.color: Qt.rgba(0.10, 0.18, 0.34, 0.30); border.width: 1

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: Math.round(parent.width * 0.10)
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Math.round(root.height * 0.004)

                                Text {
                                    text: T.t("ra_stat_points", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.015)
                                    color: "#6888a0"
                                }
                                Row {
                                    spacing: 0
                                    Text {
                                        text: "" + _trophyStatsPoints().earned
                                        font.pixelSize: Math.round(root.height * 0.030)
                                        font.bold: true
                                        color: "#d0e0f0"
                                    }
                                    Text {
                                        text: "/" + _trophyStatsPoints().total
                                        font.pixelSize: Math.round(root.height * 0.030)
                                        color: "#5a7090"
                                        anchors.baseline: parent.children[0].baseline
                                    }
                                }
                            }
                        }

                        // Completamento
                        Rectangle {
                            width: Math.floor((parent.width - parent.spacing * 3) / 4)
                            height: parent.height
                            radius: 16
                            color: Qt.rgba(0.05, 0.09, 0.18, 0.45)
                            border.color: Qt.rgba(0.10, 0.18, 0.34, 0.30); border.width: 1

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: Math.round(parent.width * 0.10)
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Math.round(root.height * 0.004)

                                Text {
                                    text: T.t("ra_completion", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.015)
                                    color: "#6888a0"
                                }
                                Text {
                                    text: (_trophyStatsTotal() > 0 ? Math.round(_trophyStatsEarned() / _trophyStatsTotal() * 100) : 0) + "%"
                                    font.pixelSize: Math.round(root.height * 0.030)
                                    font.bold: true
                                    color: "#d0e0f0"
                                }
                            }
                        }

                        // Results
                        Rectangle {
                            width: Math.floor((parent.width - parent.spacing * 3) / 4)
                            height: parent.height
                            radius: 16
                            color: Qt.rgba(0.05, 0.09, 0.18, 0.45)
                            border.color: Qt.rgba(0.10, 0.18, 0.34, 0.30); border.width: 1

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: Math.round(parent.width * 0.10)
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Math.round(root.height * 0.004)

                                Text {
                                    text: T.t("ra_results", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.015)
                                    color: "#6888a0"
                                }
                                Text {
                                    text: "" + _trophyStatsTotal()
                                    font.pixelSize: Math.round(root.height * 0.030)
                                    font.bold: true
                                    color: "#d0e0f0"
                                }
                            }
                        }
                    }
                }

                // Search bar
                Item {
                    width: parent.width
                    height: Math.round(root.height * 0.070)

                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: Math.round(parent.width * 0.035)
                        anchors.rightMargin: Math.round(parent.width * 0.035)
                        anchors.topMargin: Math.round(root.height * 0.010)
                        anchors.bottomMargin: Math.round(root.height * 0.005)
                        radius: 14
                        color: Qt.rgba(0.04, 0.08, 0.16, 0.50)
                        border.color: Qt.rgba(0.10, 0.18, 0.34, 0.30); border.width: 1

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Math.round(parent.width * 0.020)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Math.round(root.width * 0.010)

                            Text {
                                text: "\uD83D\uDD0D"
                                font.pixelSize: Math.round(root.height * 0.022)
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: 0.6
                            }
                            Text {
                                text: T.t("ra_search_trophies", root.lang)
                                font.pixelSize: Math.round(root.height * 0.019)
                                color: "#4a6880"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // Filtri e Ordinamento
                Item {
                    id: atFiltersSection
                    width: parent.width
                    height: Math.round(root.height * 0.115)

                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: Math.round(parent.width * 0.035)
                        anchors.rightMargin: Math.round(parent.width * 0.035)
                        anchors.topMargin: Math.round(root.height * 0.008)
                        anchors.bottomMargin: Math.round(root.height * 0.008)
                        radius: 16
                        color: Qt.rgba(0.04, 0.08, 0.16, 0.50)
                        border.color: (_atSection === 0) ? Qt.rgba(0.18, 0.44, 0.63, 0.55) : Qt.rgba(0.10, 0.18, 0.34, 0.30)
                        border.width: (_atSection === 0) ? 2 : 1

                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        Column {
                            anchors.fill: parent
                            anchors.margins: Math.round(parent.height * 0.10)
                            spacing: Math.round(root.height * 0.010)

                            // Title row
                            Row {
                                spacing: Math.round(root.width * 0.008)

                                Text {
                                    text: "\u2630"
                                    font.pixelSize: Math.round(root.height * 0.019)
                                    color: "#6888a0"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: T.t("ra_filters", root.lang)
                                    font.pixelSize: Math.round(root.height * 0.019)
                                    font.bold: true
                                    color: "#c0d0e0"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // Filter dropdowns row
                            Row {
                                width: parent.width
                                spacing: Math.round(parent.width * 0.015)

                                Repeater {
                                    model: [
                                        { label: T.t("ra_filter_status", root.lang), value: T.t("ra_filter_all", root.lang) },
                                        { label: T.t("ra_filter_game", root.lang),   value: T.t("ra_filter_all_games", root.lang) },
                                        { label: T.t("ra_filter_type", root.lang),   value: T.t("ra_filter_all_types", root.lang) },
                                        { label: T.t("ra_filter_sort", root.lang),   value: T.t("ra_filter_recent", root.lang) }
                                    ]

                                    Column {
                                        width: Math.floor((parent.width - parent.spacing * 3) / 4)
                                        spacing: Math.round(root.height * 0.004)

                                        Text {
                                            text: modelData.label
                                            font.pixelSize: Math.round(root.height * 0.014)
                                            color: "#5a7090"
                                        }

                                        Rectangle {
                                            property bool isActive: _atSection === 0 && _atFilterIdx === index
                                            width: parent.width
                                            height: Math.round(root.height * 0.038)
                                            radius: 10
                                            color: isActive ? Qt.rgba(0.08, 0.16, 0.28, 0.55) : Qt.rgba(0.05, 0.09, 0.18, 0.45)
                                            border.color: isActive ? Qt.rgba(0.18, 0.44, 0.63, 0.55) : Qt.rgba(0.10, 0.18, 0.34, 0.30)
                                            border.width: isActive ? 2 : 1

                                            Behavior on color { ColorAnimation { duration: 150 } }
                                            Behavior on border.color { ColorAnimation { duration: 150 } }

                                            Row {
                                                anchors.fill: parent
                                                anchors.leftMargin: Math.round(parent.width * 0.08)
                                                anchors.rightMargin: Math.round(parent.width * 0.08)

                                                Text {
                                                    text: modelData.value
                                                    font.pixelSize: Math.round(root.height * 0.016)
                                                    color: "#c0d0e0"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    elide: Text.ElideRight
                                                    width: parent.width - dropArrow.width
                                                }
                                                Text {
                                                    id: dropArrow
                                                    text: "\u25BE"
                                                    font.pixelSize: Math.round(root.height * 0.018)
                                                    color: "#5a7090"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    root._atSection = 0;
                                                    root._atFilterIdx = index;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Trophy List
                Item {
                    id: atListSection
                    width: parent.width
                    height: atListCol.height + Math.round(root.height * 0.02)

                    Column {
                        id: atListCol
                        width: parent.width
                        anchors.leftMargin: Math.round(parent.width * 0.035)
                        anchors.rightMargin: Math.round(parent.width * 0.035)
                        spacing: 0

                        Repeater {
                            model: _allTrophies

                            Column {
                                width: parent.width
                                spacing: 0

                                // Trophy card
                                Rectangle {
                                    id: atTrophyCard
                                    property bool isFocused: _atSection === 1 && _atTrophyIdx === index
                                    width: parent.width - Math.round(root.width * 0.07)
                                    x: Math.round(root.width * 0.035)
                                    height: Math.round(root.height * 0.110)
                                    radius: 16
                                    color: isFocused ? Qt.rgba(0.08, 0.16, 0.28, 0.55) : atTcMa.containsMouse ? Qt.rgba(0.06, 0.13, 0.23, 0.50) : Qt.rgba(0.04, 0.08, 0.16, 0.40)
                                    border.color: isFocused ? Qt.rgba(0.18, 0.44, 0.63, 0.55) : modelData.unlocked ? Qt.rgba(0.10, 0.18, 0.34, 0.30) : Qt.rgba(0.07, 0.12, 0.18, 0.25)
                                    border.width: isFocused ? 2 : 1
                                    clip: true

                                    // Colord left accent
                                    Rectangle {
                                        width: 3
                                        height: parent.height
                                        color: modelData.unlocked ? modelData.color : "#283040"
                                        radius: 2
                                    }

                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }

                                    MouseArea {
                                        id: atTcMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            root._atSection = 1;
                                            root._atTrophyIdx = index;
                                        }
                                    }

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: Math.round(parent.width * 0.020)
                                        anchors.rightMargin: Math.round(parent.width * 0.020)
                                        anchors.topMargin: Math.round(parent.height * 0.10)
                                        anchors.bottomMargin: Math.round(parent.height * 0.10)
                                        spacing: Math.round(parent.width * 0.018)

                                        // Trophy badge image
                                        Rectangle {
                                            width: Math.round(parent.height * 0.72)
                                            height: width; radius: width * 0.5
                                            color: modelData.unlocked ? modelData.color : Qt.rgba(0.10, 0.13, 0.22, 0.50)
                                            opacity: modelData.unlocked ? 1.0 : 0.5
                                            anchors.verticalCenter: parent.verticalCenter
                                            clip: true

                                            Image {
                                                anchors.fill: parent
                                                anchors.margins: 1
                                                source: modelData.badgeUrl || ""
                                                fillMode: Image.PreserveAspectCrop
                                                smooth: true
                                                asynchronous: true
                                                visible: status === Image.Ready
                                                opacity: modelData.unlocked ? 1.0 : 0.4
                                            }
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.unlocked ? "\uD83C\uDFC6" : "\uD83D\uDD12"
                                                font.pixelSize: Math.round(parent.width * 0.42)
                                                visible: !(modelData.badgeUrl && modelData.badgeUrl !== "")
                                            }
                                        }

                                        // Title + Desc + Date
                                        Column {
                                            width: parent.width - Math.round(parent.height * 0.72) - atPtsBadge.width - parent.spacing * 2 - Math.round(root.width * 0.01)
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: Math.round(root.height * 0.003)

                                            Text {
                                                text: modelData.title
                                                font.pixelSize: Math.round(root.height * 0.020)
                                                font.bold: true
                                                color: modelData.unlocked ? "#d0e0f0" : "#5a7090"
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }
                                            Text {
                                                text: modelData.desc
                                                font.pixelSize: Math.round(root.height * 0.015)
                                                color: modelData.unlocked ? "#7898b0" : "#3a5068"
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }
                                            Text {
                                                text: modelData.unlocked ? ("\u2705 " + T.t("ra_unlocked_date", root.lang) + " " + modelData.date) : ""
                                                font.pixelSize: Math.round(root.height * 0.013)
                                                color: "#40a070"
                                                visible: modelData.unlocked
                                            }
                                        }

                                        // Right: points + rarity
                                        Column {
                                            id: atPtsBadge
                                            width: Math.round(root.width * 0.09)
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: Math.round(root.height * 0.006)

                                            Rectangle {
                                                width: parent.width
                                                height: Math.round(root.height * 0.028)
                                                radius: height * 0.5
                                                color: modelData.unlocked ? Qt.rgba(0.10, 0.18, 0.34, 0.55) : Qt.rgba(0.07, 0.12, 0.18, 0.35)
                                                border.color: modelData.unlocked ? "#40a070" : Qt.rgba(0.14, 0.22, 0.36, 0.30)
                                                border.width: 1
                                                anchors.horizontalCenter: parent.horizontalCenter

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.points + " " + T.t("ra_pts_suffix", root.lang)
                                                    font.pixelSize: Math.round(root.height * 0.014)
                                                    font.bold: true
                                                    color: modelData.unlocked ? "#40a070" : "#4a5868"
                                                }
                                            }

                                            Row {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                spacing: Math.round(root.width * 0.004)

                                                Text {
                                                    text: "\uD83C\uDFC6"
                                                    font.pixelSize: Math.round(root.height * 0.012)
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                                Text {
                                                    text: modelData.rarity.toFixed(1) + "%"
                                                    font.pixelSize: Math.round(root.height * 0.013)
                                                    font.bold: true
                                                    color: modelData.rarity < 15 ? "#ff6060" :
                                                           modelData.rarity < 35 ? "#d4a543" :
                                                           modelData.rarity < 60 ? "#60b0ff" : "#40b080"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }
                                        }
                                    }
                                }

                                // Game tag below card
                                Item {
                                    width: parent.width
                                    height: Math.round(root.height * 0.035)

                                    Row {
                                        x: Math.round(root.width * 0.040)
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: Math.round(root.width * 0.006)

                                        Text {
                                            text: "\uD83C\uDFAE"
                                            font.pixelSize: Math.round(root.height * 0.013)
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Rectangle {
                                            height: Math.round(root.height * 0.024)
                                            width: gameTagText.implicitWidth + Math.round(root.width * 0.016)
                                            radius: height * 0.5
                                            color: Qt.rgba(0.05, 0.08, 0.14, 0.50)
                                            border.color: Qt.rgba(0.10, 0.16, 0.28, 0.35)
                                            border.width: 1
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                id: gameTagText
                                                anchors.centerIn: parent
                                                text: modelData.game + " \u2022 " + modelData.platform
                                                font.pixelSize: Math.round(root.height * 0.013)
                                                color: "#6888a0"
                                            }
                                        }
                                    }
                                }

                                // Separator
                                Rectangle {
                                    width: parent.width - Math.round(root.width * 0.07)
                                    x: Math.round(root.width * 0.035)
                                    height: 1
                                    color: Qt.rgba(0.06, 0.10, 0.16, 0.35)
                                }
                            }
                        }
                    }
                }

                // Bottom padding
                Item { width: 1; height: root.height * 0.06 }
            }
        }
    }

    // 2D Keyboard / Gamepad handler
    focus: hubOpen

    Keys.onPressed: {
        if (!hubOpen) return;
        event.accepted = true;

        // ALL TROPHIES VIEW MODE
        if (allTrophiesMode) {
            // B → back to hub
            if (event.key === Qt.Key_Escape || event.key === 1048577) {
                closeAllTrophies();
                return;
            }

            var atCount = _allTrophies.length;

            if (event.key === Qt.Key_Down) {
                if (_atSection === 0) {
                    _atSection = 1;
                    _atTrophyIdx = 0;
                } else if (_atSection === 1 && _atTrophyIdx < atCount - 1) {
                    _atTrophyIdx++;
                }
                scrollAllTrophiesToFocused();
                return;
            }

            if (event.key === Qt.Key_Up) {
                if (_atSection === 1) {
                    if (_atTrophyIdx > 0) {
                        _atTrophyIdx--;
                    } else {
                        _atSection = 0;
                        _atFilterIdx = 0;
                    }
                }
                scrollAllTrophiesToFocused();
                return;
            }

            if (event.key === Qt.Key_Right) {
                if (_atSection === 0 && _atFilterIdx < 3) {
                    _atFilterIdx++;
                }
                return;
            }

            if (event.key === Qt.Key_Left) {
                if (_atSection === 0 && _atFilterIdx > 0) {
                    _atFilterIdx--;
                }
                return;
            }
            return;
        }

        // ALL GAMES VIEW MODE
        if (allGamesMode) {
            // B → back to hub
            if (event.key === Qt.Key_Escape || event.key === 1048577) {
                closeAllGames();
                return;
            }

            var filtered = _filteredGames();
            var agCount = filtered.length;
            var agCols = _agCols;

            if (event.key === Qt.Key_Down) {
                if (_agSection === 0) {
                    // Toggle → platform tabs
                    _agSection = 1;
                } else if (_agSection === 1) {
                    // Platform tabs → first game card
                    _agSection = 2;
                    _agGridIdx = 0;
                } else if (_agSection === 2) {
                    var nextIdx = _agGridIdx + agCols;
                    if (nextIdx < agCount) {
                        _agGridIdx = nextIdx;
                    }
                }
                scrollAllGamesToFocused();
                return;
            }

            if (event.key === Qt.Key_Up) {
                if (_agSection === 2) {
                    var prevIdx = _agGridIdx - agCols;
                    if (prevIdx >= 0) {
                        _agGridIdx = prevIdx;
                    } else {
                        // First row → platform tabs
                        _agSection = 1;
                    }
                } else if (_agSection === 1) {
                    // Platform tabs → toggle
                    _agSection = 0;
                    _agToggleIdx = _agShowAllPegasus ? 1 : 0;
                }
                scrollAllGamesToFocused();
                return;
            }

            if (event.key === Qt.Key_Right) {
                if (_agSection === 0) {
                    if (_agToggleIdx < 1) _agToggleIdx = 1;
                } else if (_agSection === 1) {
                    var plats = _activePlatforms();
                    if (_agPlatIdx < plats.length - 1) {
                        _agPlatIdx++;
                        _agGridIdx = 0;
                    }
                } else if (_agSection === 2) {
                    var rCol = _agGridIdx % agCols;
                    if (rCol < agCols - 1 && _agGridIdx < agCount - 1) {
                        _agGridIdx++;
                    }
                }
                return;
            }

            if (event.key === Qt.Key_Left) {
                if (_agSection === 0) {
                    if (_agToggleIdx > 0) _agToggleIdx = 0;
                } else if (_agSection === 1) {
                    if (_agPlatIdx > 0) {
                        _agPlatIdx--;
                        _agGridIdx = 0;
                    }
                } else if (_agSection === 2) {
                    var lCol = _agGridIdx % agCols;
                    if (lCol > 0) {
                        _agGridIdx--;
                    }
                }
                return;
            }

            // A → confirm toggle selection or open game detail
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === 1048576) {
                if (_agSection === 0) {
                    // Toggle confirm
                    if (_agToggleIdx === 0 && _agShowAllPegasus) {
                        _agShowAllPegasus = false;
                        _agPlatIdx = 0;
                        _agGridIdx = 0;
                    } else if (_agToggleIdx === 1 && !_agShowAllPegasus) {
                        _agShowAllPegasus = true;
                        _agPlatIdx = 0;
                        _agGridIdx = 0;
                        if (_pegasusGames.length === 0) _buildPegasusGames();
                    }
                } else if (_agSection === 2 && _agGridIdx >= 0 && _agGridIdx < agCount) {
                    _cameFromAllGames = true;
                    allGamesMode = false;
                    openGameDetail(filtered[_agGridIdx]);
                }
                return;
            }
            return;
        }

        // DETAIL VIEW MODE (3-Level Hierarchy)
        if (detailMode) {

            // Level 3 (Full Details)
            if (_detailLevel === 3) {
                // B → back to Level 1
                if (event.key === Qt.Key_Escape || event.key === 1048577) {
                    _detailLevel = 1;
                    _detailSection = 0;
                    _detailAchIdx = 0;
                    return;
                }

                // Compute filtered count for navigation
                var filteredCount = 0;
                var tab3 = _detailTabIdx;
                if (tab3 === 0) {
                    filteredCount = _gameAchievements.length;
                } else {
                    for (var fc = 0; fc < _gameAchievements.length; fc++) {
                        if (tab3 === 1 && _gameAchievements[fc].unlocked) filteredCount++;
                        if (tab3 === 2 && !_gameAchievements[fc].unlocked) filteredCount++;
                    }
                }
                var tabCount3 = _detailTabs.length;

                if (event.key === Qt.Key_Down) {
                    if (_detailSection === 0) {
                        if (filteredCount > 0) {
                            _detailSection = 1;
                            _detailAchIdx = 0;
                        }
                    } else if (_detailSection === 1 && _detailAchIdx < filteredCount - 1) {
                        _detailAchIdx++;
                    }
                    scrollDetailToFocused();
                    return;
                }

                if (event.key === Qt.Key_Up) {
                    if (_detailSection === 1) {
                        if (_detailAchIdx > 0) {
                            _detailAchIdx--;
                        } else {
                            _detailSection = 0;
                        }
                    }
                    scrollDetailToFocused();
                    return;
                }

                if (event.key === Qt.Key_Right) {
                    if (_detailSection === 0 && _detailTabIdx < tabCount3 - 1) {
                        _detailTabIdx++;
                        _detailAchIdx = 0;
                    }
                    return;
                }

                if (event.key === Qt.Key_Left) {
                    if (_detailSection === 0 && _detailTabIdx > 0) {
                        _detailTabIdx--;
                        _detailAchIdx = 0;
                    }
                    return;
                }
                return;
            }

            // Level 1 (Status View)
            // B → close game detail
            if (event.key === Qt.Key_Escape || event.key === 1048577) {
                statusView.contentY = 0;
                closeGameDetail();
                return;
            }

            // A → launch game
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === 1048576) {
                if (_selectedGameData) {
                    var cn = _selectedGameData.consoleName || "";
                    launchGameRequested(_selectedGameData.title, cn);
                }
                return;
            }

            // Y → open Level 3 full details
            if (event.key === 1048579) {
                _detailLevel = 3;
                _detailSection = 0;
                _detailTabIdx = 0;
                _detailAchIdx = 0;
                if (detailFlick) detailFlick.contentY = 0;
                return;
            }

            // Up/Down → scroll statusView
            if (event.key === Qt.Key_Down) {
                var maxY = Math.max(0, statusView.contentHeight - statusView.height);
                statusView.contentY = Math.min(statusView.contentY + Math.round(root.height * 0.08), maxY);
                return;
            }
            if (event.key === Qt.Key_Up) {
                statusView.contentY = Math.max(statusView.contentY - Math.round(root.height * 0.08), 0);
                return;
            }
            return;
        }

        // MAIN HUB MODE
        // B → close hub (go back to platform)
        if (event.key === Qt.Key_Escape || event.key === 1048577) {
            close();
            return;
        }

        // R1 → close hub (go to next platform)
        if (event.key === Qt.Key_PageDown || event.key === Qt.Key_E || event.key === 1048583) {
            close();
            return;
        }

        // L1 → do nothing (already at leftmost)
        if (event.key === Qt.Key_PageUp || event.key === Qt.Key_Q || event.key === 1048580) {
            return;
        }

        // TOP BAR FOCUSED
        if (hubContent._hubTopFocus >= 0) {
            if (event.key === Qt.Key_Down) {
                hubContent._hubTopFocus = -1;
                root.focusIndex = 0;
                return;
            }
            if (event.key === Qt.Key_Right) {
                if (hubContent._hubTopFocus === 0) hubContent._hubTopFocus = 1;
                return;
            }
            if (event.key === Qt.Key_Left) {
                if (hubContent._hubTopFocus === 1) hubContent._hubTopFocus = 0;
                return;
            }
            // A → activate focused icon
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === 1048576) {
                if (hubContent._hubTopFocus === 0) {
                    close();  // RA icon → close hub
                } else if (hubContent._hubTopFocus === 1) {
                    settingsRequested();  // Settings icon → open menu
                }
                return;
            }
            return;
        }

        // A / Enter → profile: launch last played, games: open detail
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === 1048576) {
            if (root.focusIndex === 0 && root._pegasusLastGame) {
                root._pegasusLastGame.launch();
                return;
            }
            var _gi = root.focusIndex - root._gamesStart;
            if (_gi >= 0 && _gi < recentGames.length) {
                openGameDetail(recentGames[_gi]);
            }
            return;
        }

        // X → open all games view
        if (event.key === 1048578) {
            openAllGames();
            return;
        }

        // Y → open all trophies view
        if (event.key === 1048579) {
            openAllTrophies();
            return;
        }

        var fi = root.focusIndex;
        var cols = root._trophyCols;
        var tc = root._trophyCount;
        var gs = root._gamesStart;
        var total = root._totalItems;

        if (event.key === Qt.Key_Down) {
            if (fi === 0) {
                root.focusIndex = 1;
            } else if (fi >= 1 && fi <= tc) {
                var col = (fi - 1) % cols;
                var row = Math.floor((fi - 1) / cols);
                var nextRow = row + 1;
                var nextIdx = nextRow * cols + col + 1;
                if (nextIdx <= tc) {
                    root.focusIndex = nextIdx;
                } else {
                    root.focusIndex = gs;
                }
            } else if (fi >= gs && fi < total - 1) {
                root.focusIndex = fi + 1;
            }
            return;
        }

        if (event.key === Qt.Key_Up) {
            if (fi === 0) {
                // Go to top bar
                hubContent._hubTopFocus = 0;
                return;
            }
            if (fi >= gs) {
                if (fi === gs) {
                    if (tc > 0) {
                        var lastRowStart = (root._trophyRows - 1) * cols + 1;
                        root.focusIndex = Math.min(lastRowStart, tc);
                    } else {
                        root.focusIndex = 0;
                    }
                } else {
                    root.focusIndex = fi - 1;
                }
            } else if (fi >= 1 && fi <= tc) {
                var tCol = (fi - 1) % cols;
                var tRow = Math.floor((fi - 1) / cols);
                if (tRow > 0) {
                    root.focusIndex = (tRow - 1) * cols + tCol + 1;
                } else {
                    root.focusIndex = 0;
                }
            }
            return;
        }

        if (event.key === Qt.Key_Right) {
            if (fi >= 1 && fi <= tc) {
                var rCol = (fi - 1) % cols;
                if (rCol < cols - 1 && fi < tc) {
                    root.focusIndex = fi + 1;
                }
            }
            return;
        }

        if (event.key === Qt.Key_Left) {
            if (fi >= 1 && fi <= tc) {
                var lCol = (fi - 1) % cols;
                if (lCol > 0) {
                    root.focusIndex = fi - 1;
                }
            }
            return;
        }
    }

    function scrollDetailToFocused() {
        if (_detailLevel !== 3) return;  // Only scroll in Level 3
        if (_detailSection === 0) {
            detailFlick.contentY = 0;
        } else {
            // Scroll to focused achievement (Level 3 layout)
            var compactHeaderH = root.height * 0.09;
            var tabsH = root.height * 0.058;
            var countLabelH = root.height * 0.035;
            var achItemH = root.height * 0.100 + root.height * 0.010;
            var targetY = compactHeaderH + tabsH + countLabelH + _detailAchIdx * achItemH;
            var scrollY = Math.max(0, targetY - detailFlick.height * 0.35);
            scrollY = Math.min(scrollY, Math.max(0, detailFlick.contentHeight - detailFlick.height));
            detailFlick.contentY = scrollY;
        }
    }

    function scrollAllGamesToFocused() {
        if (_agSection <= 1) {
            allGamesFlick.contentY = 0;
        } else {
            var headerH = root.height * 0.12 + root.height * 0.065 + root.height * 0.065;
            var cardH = root.height * 0.26 + root.width * 0.015;
            var gridRow = Math.floor(_agGridIdx / _agCols);
            var targetY = headerH + gridRow * cardH;
            var scrollY = Math.max(0, targetY - allGamesFlick.height * 0.30);
            scrollY = Math.min(scrollY, Math.max(0, allGamesFlick.contentHeight - allGamesFlick.height));
            allGamesFlick.contentY = scrollY;
        }
    }

    function scrollAllTrophiesToFocused() {
        if (_atSection === 0) {
            allTrophiesFlick.contentY = 0;
        } else {
            // title + stats + search + filters heights
            var topH = root.height * 0.08 + root.height * 0.095 + root.height * 0.070 + root.height * 0.115;
            var itemH = root.height * 0.110 + root.height * 0.035 + 1;  // card + gameTag + separator
            var targetY = topH + _atTrophyIdx * itemH;
            var scrollY = Math.max(0, targetY - allTrophiesFlick.height * 0.35);
            scrollY = Math.min(scrollY, Math.max(0, allTrophiesFlick.contentHeight - allTrophiesFlick.height));
            allTrophiesFlick.contentY = scrollY;
        }
    }

    onFocusIndexChanged: scrollToFocused()

    function scrollToFocused() {
        var targetY = 0;
        if (focusIndex === 0) {
            bodyFlick.contentY = 0;
            return;
        } else if (focusIndex >= 1 && focusIndex <= _trophyCount) {
            var tRow = Math.floor((focusIndex - 1) / _trophyCols);
            targetY = tRow * root.height * 0.12;
        } else {
            var gIdx = focusIndex - _gamesStart;
            targetY = trophiesSection.height + gIdx * root.height * 0.125;
        }
        var scrollY = Math.max(0, targetY - bodyFlick.height * 0.30);
        scrollY = Math.min(scrollY, Math.max(0, bodyFlick.contentHeight - bodyFlick.height));
        bodyFlick.contentY = scrollY;
    }

    onHubOpenChanged: {
        if (hubOpen) {
            forceActiveFocus();
            _findLastPlayed();
        }
    }
}  // root Rectangle
