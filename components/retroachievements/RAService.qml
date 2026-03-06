import QtQuick 2.15
import ".."
import "RAConsoleMap.js" as ConsoleMap
import "RAFuzzyMatch.js" as FuzzyMatch

// RAService
// Centralized RetroAchievements API service with caching.
// Replaces the old per-game RetroAchievementsManager.
Item {
    id: service

    // Credentials
    property string raUser: ""
    property string raApiKey: ""
    property bool isLoggedIn: raUser !== "" && raApiKey !== ""

    // Profile data
    property bool profileLoading: false
    property bool profileError: false
    property var userProfile: null
    // { username, userPic, totalPoints, totalTruePoints, rank, memberSince }

    property var recentAchievements: []
    // [{ title, desc, gameTitle, points, badgeUrl, date, hardcoreMode }]

    // Completion data (all user games)
    property bool completionLoading: false
    property bool completionError: false
    property var completionGames: []
    // [{ gameId, title, consoleName, consoleId, imageIcon, earned, total, progress, lastPlayed, shortLa...

    // Recently played games (includes 0% progress)
    property bool recentlyPlayedLoading: false
    property bool recentlyPlayedError: false
    property var recentlyPlayedGames: []

    // Merged games (completion + recently played)
    property var allUserGames: []

    // Single game detail
    property bool detailLoading: false
    property bool detailError: false
    property var gameDetail: null
    property var gameAchievements: []

    // Cache TTLs
    readonly property int _profileTTL:    300000  // 5 min
    readonly property int _completionTTL: 900000  // 15 min
    readonly property int _detailTTL:     1800000  // 30 min

    readonly property string _baseUrl: "https://retroachievements.org/API/"

    // Init
    Component.onCompleted: loadCredentials()

    function loadCredentials() {
        raUser   = api.memory.get("ra_user")    || "";
        raApiKey = api.memory.get("ra_api_key") || "";
    }

    // API CALLS

    // User Profile + Recent Achievements
    function fetchUserSummary(forceRefresh) {
        if (!isLoggedIn) return;

        if (!forceRefresh) {
            var cached = _getCache("ra_profile_cache", _profileTTL);
            if (cached) {
                _applyProfile(cached);
                return;
            }
        }

        profileLoading = true;
        profileError = false;

        var url = _baseUrl + "API_GetUserSummary.php"
            + "?z=" + encodeURIComponent(raUser)
            + "&y=" + encodeURIComponent(raApiKey)
            + "&u=" + encodeURIComponent(raUser)
            + "&g=0&a=50";

        _httpGet(url, function(data) {
            profileLoading = false;
            _setCache("ra_profile_cache", data);
            _applyProfile(data);
        }, function(err) {
            profileLoading = false;
            profileError = true;
            console.log("[RAService] Profile error: " + err);
        });
    }

    // All Games with Progress
    function fetchCompletionProgress(forceRefresh) {
        if (!isLoggedIn) return;

        if (!forceRefresh) {
            var cached = _getCache("ra_completion_cache", _completionTTL);
            if (cached) {
                _applyCompletion(cached);
                return;
            }
        }

        completionLoading = true;
        completionError = false;

        var url = _baseUrl + "API_GetUserCompletionProgress.php"
            + "?z=" + encodeURIComponent(raUser)
            + "&y=" + encodeURIComponent(raApiKey)
            + "&u=" + encodeURIComponent(raUser)
            + "&c=500&o=0";

        _httpGet(url, function(data) {
            completionLoading = false;
            _setCache("ra_completion_cache", data);
            _applyCompletion(data);
        }, function(err) {
            completionLoading = false;
            completionError = true;
            console.log("[RAService] Completion error: " + err);
        });
    }

    // Recently Played Games (includes 0%)
    function fetchRecentlyPlayedGames() {
        if (!isLoggedIn) return;

        recentlyPlayedLoading = true;
        recentlyPlayedError = false;

        var url = _baseUrl + "API_GetUserRecentlyPlayedGames.php"
            + "?z=" + encodeURIComponent(raUser)
            + "&y=" + encodeURIComponent(raApiKey)
            + "&u=" + encodeURIComponent(raUser)
            + "&c=50&o=0";

        _httpGet(url, function(data) {
            recentlyPlayedLoading = false;
            _applyRecentlyPlayed(data);
        }, function(err) {
            recentlyPlayedLoading = false;
            recentlyPlayedError = true;
            console.log("[RAService] RecentlyPlayed error: " + err);
        });
    }

    // Single Game Detail + Achievements
    function fetchGameDetail(gameId, forceRefresh) {
        if (!isLoggedIn || gameId <= 0) return;

        var cacheKey = "ra_detail_" + gameId;

        if (!forceRefresh) {
            var cached = _getCache(cacheKey, _detailTTL);
            if (cached) {
                _applyGameDetail(cached);
                return;
            }
        }

        detailLoading = true;
        detailError = false;
        gameDetail = null;
        gameAchievements = [];

        var url = _baseUrl + "API_GetGameInfoAndUserProgress.php"
            + "?z=" + encodeURIComponent(raUser)
            + "&y=" + encodeURIComponent(raApiKey)
            + "&u=" + encodeURIComponent(raUser)
            + "&g=" + gameId;

        _httpGet(url, function(data) {
            detailLoading = false;
            _setCache(cacheKey, data);
            _applyGameDetail(data);
        }, function(err) {
            detailLoading = false;
            detailError = true;
            console.log("[RAService] Detail error: " + err);
        });
    }

    // DATA APPLIERS

    function _applyProfile(data) {
        userProfile = {
            username:        data.User || raUser,
            userPic:         data.UserPic ? ("https://media.retroachievements.org" + data.UserPic) : "",
            totalPoints:     data.TotalPoints     || 0,
            totalTruePoints: data.TotalTruePoints || 0,
            rank:            data.Rank             || 0,
            totalRanked:     data.TotalRanked      || 0,
            memberSince:     data.MemberSince      || ""
        };

        // Parse recent achievements
        var achs = [];
        if (data.RecentAchievements) {
            for (var gameId in data.RecentAchievements) {
                var gameAchs = data.RecentAchievements[gameId];
                for (var achId in gameAchs) {
                    var a = gameAchs[achId];
                    achs.push({
                        title:        a.Title       || "",
                        desc:         a.Description || "",
                        gameTitle:    a.GameTitle    || "",
                        gameId:       parseInt(gameId) || 0,
                        points:       a.Points       || 0,
                        badgeUrl:     a.BadgeName ? ("https://media.retroachievements.org/Badge/" + a.BadgeName + ".png") : "",
                        date:         a.DateAwarded  || "",
                        hardcoreMode: a.HardcoreMode || 0
                    });
                }
            }
        }
        // Sort by date descending
        achs.sort(function(a, b) {
            if (b.date > a.date) return 1;
            if (b.date < a.date) return -1;
            return 0;
        });
        recentAchievements = achs;
        console.log("[RAService] Profile loaded: " + userProfile.username +
                    " | " + userProfile.totalPoints + " pts | rank #" + userProfile.rank +
                    " | " + achs.length + " recent achievements");
    }

    function _applyCompletion(data) {
        var games = [];
        var results = data.Results || data;

        if (results && typeof results === "object") {
            // Could be array or object
            var arr = [];
            if (Array.isArray(results)) {
                arr = results;
            } else {
                for (var k in results) arr.push(results[k]);
            }

            for (var i = 0; i < arr.length; i++) {
                var g = arr[i];
                var maxP   = g.MaxPossible || g.NumPossibleAchievements || 0;
                var earned = g.NumAwarded  || g.NumAchieved || 0;
                if (maxP <= 0) continue;  // skip games with no achievements

                games.push({
                    gameId:      g.GameID     || 0,
                    title:       g.Title      || "",
                    consoleName: g.ConsoleName || "",
                    consoleId:   g.ConsoleID   || 0,
                    imageIcon:   g.ImageIcon ? ("https://media.retroachievements.org" + g.ImageIcon) : "",
                    earned:      earned,
                    total:       maxP,
                    progress:    maxP > 0 ? earned / maxP : 0,
                    lastPlayed:  g.MostRecentAwardedDate || g.LastPlayed || "",
                    shortLabel:  ConsoleMap.getShortLabel(g.ConsoleName || "")
                });
            }
        }

        // Sort by most recently played
        games.sort(function(a, b) {
            if (b.lastPlayed > a.lastPlayed) return 1;
            if (b.lastPlayed < a.lastPlayed) return -1;
            return 0;
        });

        completionGames = games;
        console.log("[RAService] Completion loaded: " + games.length + " games with achievements");
        _mergeAllGames();
    }

    function _applyRecentlyPlayed(data) {
        var games = [];
        if (data && Array.isArray(data)) {
            for (var i = 0; i < data.length; i++) {
                var g = data[i];
                var maxP   = g.NumPossibleAchievements || g.AchievementsTotal || 0;
                var earned = g.NumAchieved || 0;
                if (maxP <= 0) continue;

                games.push({
                    gameId:      g.GameID      || 0,
                    title:       g.Title       || "",
                    consoleName: g.ConsoleName || "",
                    consoleId:   g.ConsoleID    || 0,
                    imageIcon:   g.ImageIcon ? ("https://media.retroachievements.org" + g.ImageIcon) : "",
                    earned:      earned,
                    total:       maxP,
                    progress:    maxP > 0 ? earned / maxP : 0,
                    lastPlayed:  g.LastPlayed || "",
                    shortLabel:  ConsoleMap.getShortLabel(g.ConsoleName || "")
                });
            }
        }
        recentlyPlayedGames = games;
        console.log("[RAService] RecentlyPlayed loaded: " + games.length + " games");
        _mergeAllGames();
    }

    // Merge completion + recently played
    function _mergeAllGames() {
        var merged = [];
        var seen = {};

        // First add all completion games (they have definitive progress data)
        for (var i = 0; i < completionGames.length; i++) {
            var g = completionGames[i];
            merged.push(g);
            seen[g.gameId] = true;
        }

        // Then add recently played games that aren't already in completion
        for (var j = 0; j < recentlyPlayedGames.length; j++) {
            var rp = recentlyPlayedGames[j];
            if (!seen[rp.gameId]) {
                merged.push(rp);
                seen[rp.gameId] = true;
            }
        }

        // Sort by most recently played
        merged.sort(function(a, b) {
            if (b.lastPlayed > a.lastPlayed) return 1;
            if (b.lastPlayed < a.lastPlayed) return -1;
            return 0;
        });

        allUserGames = merged;
        console.log("[RAService] Merged games: " + merged.length + " total (" + completionGames.length + " completion + " + recentlyPlayedGames.length + " recent)");
    }

    function _applyGameDetail(data) {
        gameDetail = {
            gameId:         data.ID              || 0,
            title:          data.Title           || "",
            consoleName:    data.ConsoleName      || "",
            imageIcon:      data.ImageIcon  ? ("https://media.retroachievements.org" + data.ImageIcon)  : "",
            imageTitle:     data.ImageTitle  ? ("https://media.retroachievements.org" + data.ImageTitle) : "",
            imageIngame:    data.ImageIngame ? ("https://media.retroachievements.org" + data.ImageIngame): "",
            imageBoxArt:    data.ImageBoxArt ? ("https://media.retroachievements.org" + data.ImageBoxArt): "",
            numAchievements: data.NumAchievements       || 0,
            numAwarded:      data.NumAwardedToUser      || 0,
            possibleScore:   data.PossibleScore          || 0,
            scoreAchieved:   data.UserCompletion         || "0%",
            shortLabel:      ConsoleMap.getShortLabel(data.ConsoleName || "")
        };

        var achs = [];
        if (data.Achievements) {
            for (var key in data.Achievements) {
                var a = data.Achievements[key];
                var numPlayers = a.NumDistinctPlayersCasual || a.NumDistinctPlayers || 1;
                var numEarned  = a.NumAwarded || 0;
                var rarity     = numPlayers > 0 ? (numEarned / numPlayers * 100) : 50;

                achs.push({
                    id:            a.ID           || 0,
                    title:         a.Title        || "",
                    desc:          a.Description  || "",
                    points:        a.Points       || 0,
                    trueRatio:     a.TrueRatio    || 0,
                    badgeUrl:      a.BadgeName ? ("https://media.retroachievements.org/Badge/" + a.BadgeName + ".png") : "",
                    badgeLockedUrl:a.BadgeName ? ("https://media.retroachievements.org/Badge/" + a.BadgeName + "_lock.png") : "",
                    unlocked:      !!(a.DateEarned && a.DateEarned !== ""),
                    dateEarned:    a.DateEarned   || "",
                    rarity:        Math.round(rarity * 10) / 10,
                    displayOrder:  a.DisplayOrder || 0
                });
            }
        }
        // Sort by display order then by ID
        achs.sort(function(a, b) {
            if (a.displayOrder !== b.displayOrder) return a.displayOrder - b.displayOrder;
            return a.id - b.id;
        });

        gameAchievements = achs;
        console.log("[RAService] Detail loaded: " + gameDetail.title +
                    " | " + gameDetail.numAwarded + "/" + gameDetail.numAchievements +
                    " | " + achs.length + " achievements");
    }

    // GAME MATCHING (Pegasus ↔ RA)

    // Persistent mapping cache: { "normalized_title|platform": gameId }
    property var _gameIdCache: ({})
    property bool _gameIdCacheLoaded: false

    function _loadGameIdCache() {
        if (_gameIdCacheLoaded) return;
        try {
            var raw = api.memory.get("ra_gameid_map");
            if (raw && raw !== "") _gameIdCache = JSON.parse(raw);
        } catch (e) { _gameIdCache = {}; }
        _gameIdCacheLoaded = true;
    }

    function _saveGameIdCache() {
        try {
            api.memory.set("ra_gameid_map", JSON.stringify(_gameIdCache));
        } catch (e) {
            console.log("[RAService] GameId cache save error: " + e);
        }
    }

    // Search RA API for a game by name on a platform
    // Calls API_GetGameList with console ID + search filter
    // callback(gameId) — returns best matching gameId or 0
    function searchRAGame(gameTitle, pegasusShortName, callback) {
        if (!isLoggedIn || !gameTitle) {
            if (callback) callback(0);
            return;
        }

        _loadGameIdCache();

        // Check persistent cache first
        var cacheKey = FuzzyMatch.normalize(gameTitle) + "|" + (pegasusShortName || "");
        if (_gameIdCache[cacheKey] && _gameIdCache[cacheKey] > 0) {
            console.log("[RAService] GameId cache hit: " + gameTitle + " → " + _gameIdCache[cacheKey]);
            if (callback) callback(_gameIdCache[cacheKey]);
            return;
        }

        // Try to match against allUserGames (already loaded from API)
        if (allUserGames.length > 0) {
            var localResult = _fuzzyMatchLocal(gameTitle, pegasusShortName);
            if (localResult && localResult.gameId > 0) {
                _gameIdCache[cacheKey] = localResult.gameId;
                _saveGameIdCache();
                console.log("[RAService] Local fuzzy match: " + gameTitle + " → " + localResult.title + " (score: local, id: " + localResult.gameId + ")");
                if (callback) callback(localResult.gameId);
                return;
            }
        }

        // API search fallback: GetGameList for the console
        var consoleId = ConsoleMap.getConsoleId(pegasusShortName || "");
        if (consoleId <= 0) {
            console.log("[RAService] No console ID for platform: " + pegasusShortName);
            if (callback) callback(0);
            return;
        }

        var url = _baseUrl + "API_GetGameList.php"
            + "?z=" + encodeURIComponent(raUser)
            + "&y=" + encodeURIComponent(raApiKey)
            + "&i=" + consoleId
            + "&f=" + encodeURIComponent(gameTitle.substring(0, 40))
            + "&h=1";  // only games with achievements

        console.log("[RAService] API search: \"" + gameTitle + "\" on console " + consoleId);

        _httpGet(url, function(data) {
            if (!data || !Array.isArray(data) || data.length === 0) {
                console.log("[RAService] API search: no results for \"" + gameTitle + "\"");
                if (callback) callback(0);
                return;
            }

            // Fuzzy match against API results
            var result = FuzzyMatch.findBestMatch(gameTitle, data, 0.60);
            if (result && result.match) {
                var gid = result.match.ID || result.match.GameID || 0;
                console.log("[RAService] API fuzzy match: \"" + gameTitle + "\" → \"" +
                    (result.match.Title || "") + "\" (score: " + result.score.toFixed(2) + ", id: " + gid + ")");
                _gameIdCache[cacheKey] = gid;
                _saveGameIdCache();
                if (callback) callback(gid);
            } else {
                console.log("[RAService] API search: no fuzzy match for \"" + gameTitle + "\" among " + data.length + " results");
                if (callback) callback(0);
            }
        }, function(err) {
            console.log("[RAService] API search error: " + err);
            if (callback) callback(0);
        });
    }

    // Local fuzzy match against already-loaded games
    function _fuzzyMatchLocal(gameTitle, pegasusShortName) {
        // Filter by platform if possible
        var candidates = [];
        for (var i = 0; i < allUserGames.length; i++) {
            var g = allUserGames[i];
            if (pegasusShortName && pegasusShortName !== "") {
                var raPlatform = ConsoleMap.getPegasusShortName(g.consoleName || "");
                if (raPlatform !== pegasusShortName) continue;
            }
            candidates.push(g);
        }

        // If no platform match, try all games
        if (candidates.length === 0) candidates = allUserGames;

        var result = FuzzyMatch.findBestMatch(gameTitle, candidates, 0.65);
        return result ? result.match : null;
    }

    // Match a Pegasus game to RA and get full details
    // This is the main entry point for Pegasus → RA matching
    function lookupPegasusGame(gameTitle, pegasusShortName, callback) {
        searchRAGame(gameTitle, pegasusShortName, function(gameId) {
            if (gameId > 0 && callback) {
                callback(gameId);
            } else if (callback) {
                callback(0);
            }
        });
    }

    // CACHE HELPERS

    function _getCache(key, ttl) {
        try {
            var raw = api.memory.get(key);
            if (!raw || raw === "") return null;
            var obj = JSON.parse(raw);
            if (!obj || !obj.timestamp) return null;
            if (Date.now() - obj.timestamp > ttl) return null;
            return obj.data;
        } catch (e) {
            return null;
        }
    }

    function _setCache(key, data) {
        try {
            api.memory.set(key, JSON.stringify({
                data: data,
                timestamp: Date.now()
            }));
        } catch (e) {
            console.log("[RAService] Cache write error: " + e);
        }
    }

    function clearAllCache() {
        api.memory.set("ra_profile_cache", "");
        api.memory.set("ra_completion_cache", "");
        api.memory.set("ra_gameid_map", "");
        _gameIdCache = {};
        _gameIdCacheLoaded = false;
        console.log("[RAService] Cache cleared (profile + completion + gameId map)");
    }

    // HTTP HELPER

    function _httpGet(url, onSuccess, onError) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        onSuccess(data);
                    } catch (e) {
                        onError("JSON parse error: " + e);
                    }
                } else {
                    onError("HTTP " + xhr.status);
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }
}
