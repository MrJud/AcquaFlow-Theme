import QtQuick 2.0
import ".."
import "RAConsoleMap.js" as ConsoleMap
import "RAFuzzyMatch.js" as FuzzyMatch

// This component fetches and holds the achievement data for a given game.
Item {
    id: root

    // The RetroAchievements ID of the current game
    property int gameId: 0
    property string ra_user: ""
    property string ra_api_key: ""

    // Properties to hold the fetched data
    property bool isLoading: false
    property bool hasError: false
    property string errorText: ""

    property int numAwarded: 0
    property int possibleScore: 0
    property int numAchievements: 0
    property string gameTitle: ""
    property string consoleName: ""
    property string imageIcon: ""
    property var achievements: []  // Array of achievement objects

    // Cache for gameId lookups (title+platform → RA gameId)
    property var _gameIdCache: ({})

    Component.onCompleted: {
        loadCredentials();
        _loadGameIdCache();
    }

    function loadCredentials() {
        ra_user = api.memory.get("ra_user") || "";
        ra_api_key = api.memory.get("ra_api_key") || "";
    }

    // Main entry point: look up a Pegasus game and fetch its achievements
    function lookupAndFetch(title, platformShortName) {
        console.log("[RA] lookupAndFetch called — title:", title, "platform:", platformShortName);
        if (!title || title === "") {
            console.log("[RA] lookupAndFetch: empty title, aborting");
            return;
        }
        if (ra_user === "" || ra_api_key === "") {
            console.log("[RA] credentials empty, reloading...");
            loadCredentials();
            if (ra_user === "" || ra_api_key === "") {
                console.log("[RA] credentials still empty after reload — user:", ra_user, "key:", ra_api_key);
                hasError = true;
                errorText = "RA credentials not set";
                return;
            }
        }
        console.log("[RA] credentials OK — user:", ra_user);

        root.gameId = 0;
        root.numAwarded = 0;
        root.numAchievements = 0;
        root.achievements = [];
        root.gameTitle = "";
        root.hasError = false;

        var cacheKey = (platformShortName || "") + ":" + title.toLowerCase();
        if (_gameIdCache[cacheKey]) {
            console.log("[RA] Cache hit:", title, "→ id", _gameIdCache[cacheKey]);
            root.gameId = _gameIdCache[cacheKey];
            return;  // onGameIdChanged will call fetchGameProgress
        }

        var consoleId = ConsoleMap.getConsoleId(platformShortName || "");
        if (consoleId <= 0) {
            console.log("[RA] No console mapping for:", platformShortName);
            root.hasError = true;
            root.errorText = "Platform not supported";
            return;
        }

        root.isLoading = true;
        console.log("[RA] Looking up:", title, "on console", consoleId, "(", platformShortName, ")");

        var xhr = new XMLHttpRequest();
        var url = "https://retroachievements.org/API/API_GetGameList.php"
            + "?z=" + encodeURIComponent(ra_user)
            + "&y=" + encodeURIComponent(ra_api_key)
            + "&i=" + consoleId
            + "&f=" + encodeURIComponent(title.substring(0, 40))
            + "&h=1";

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (!data || !Array.isArray(data) || data.length === 0) {
                            console.log("[RA] No games found for:", title);
                            root.isLoading = false;
                            root.hasError = true;
                            root.errorText = "Game not found on RA";
                            return;
                        }
                        var result = FuzzyMatch.findBestMatch(title, data, 0.55);
                        if (result && result.match) {
                            var gid = result.match.ID || result.match.GameID || 0;
                            console.log("[RA] Matched:", title, "→", result.match.Title, "(id:", gid, "score:", result.score.toFixed(2), ")");
                            _gameIdCache[cacheKey] = gid;
                            _saveGameIdCache();
                            root.gameId = gid;  // triggers fetchGameProgress
                        } else {
                            console.log("[RA] No fuzzy match for:", title, "among", data.length, "results");
                            root.isLoading = false;
                            root.hasError = true;
                            root.errorText = "Game not matched";
                        }
                    } catch (e) {
                        console.log("[RA] Lookup parse error:", e);
                        root.isLoading = false;
                        root.hasError = true;
                        root.errorText = "Lookup failed";
                    }
                } else {
                    console.log("[RA] Lookup HTTP error:", xhr.status);
                    root.isLoading = false;
                    root.hasError = true;
                    root.errorText = "API error";
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }

    function _loadGameIdCache() {
        try {
            var raw = api.memory.get("ra_gameid_cache");
            if (raw) _gameIdCache = JSON.parse(raw);
        } catch (e) { _gameIdCache = {}; }
    }

    function _saveGameIdCache() {
        try {
            api.memory.set("ra_gameid_cache", JSON.stringify(_gameIdCache));
        } catch (e) {}
    }

    // Fetches game progress from the RetroAchievements API
    function fetchGameProgress() {
        if (gameId <= 0 || ra_user === "" || ra_api_key === "") {
            hasError = true;
            errorText = "RA credentials not set";
            return;
        }

        root.isLoading = true;
        root.hasError = false;
        root.errorText = "";
        root.numAwarded = 0;
        root.numAchievements = 0;
        root.achievements = [];

        var xhr = new XMLHttpRequest();
        var url = "https://retroachievements.org/API/API_GetGameInfoAndUserProgress.php"
                + "?z=" + encodeURIComponent(ra_user)
                + "&y=" + encodeURIComponent(ra_api_key)
                + "&u=" + encodeURIComponent(ra_user)
                + "&g=" + gameId;

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                root.isLoading = false;
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if(response.NumAchievements === null) {
                            root.hasError = true;
                            root.errorText = "Game not found on RA";
                            return;
                        }
                        root.numAwarded = response.NumAwarded;
                        root.numAchievements = response.NumAchievements;
                        root.possibleScore = response.PossibleScore;
                        root.gameTitle = response.Title;
                        root.consoleName = response.ConsoleName;
                        root.imageIcon = "https://media.retroachievements.org" + response.ImageIcon;

                        var achs = [];
                        for (var key in response.Achievements) {
                            achs.push(response.Achievements[key]);
                        }
                        root.achievements = achs;

                    } catch (e) {
                        root.hasError = true;
                        root.errorText = "Failed to parse API response.";
                        console.log(errorText + " " + e);
                    }
                } else {
                    root.hasError = true;
                    root.errorText = "API Request Failed (Status: " + xhr.status + ")";
                    console.log(errorText);
                }
            }
        }

        xhr.open("GET", url);
        xhr.send();
    }

    // Trigger fetch when gameId changes
    onGameIdChanged: {
        if (gameId > 0) {
            fetchGameProgress();
        }
    }
}
