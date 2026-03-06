import QtQuick 2.15

Item {
    id: tracker

    // Keys for api.memory
    readonly property string _pendingKey: "af_playtime_pending"
    readonly property string _dbKey: "af_playtime_db"

    // In-memory cache of the play time database
    property var _db: ({})
    property int _dbVersion: 0  // Bumped to force binding re-evaluation

    // Public API

    // Call this BEFORE game.launch()
    function trackLaunch(game) {
        if (!game) return;

        var gamePath = _getGamePath(game);
        if (!gamePath) {
            console.log("[PlaytimeTracker] No game path found, skipping tracking");
            return;
        }

        var now = Math.floor(Date.now() / 1000);

        // Save pending session
        var pending = {
            path: gamePath,
            title: game.title || "Unknown",
            startTime: now
        };

        _memSet(_pendingKey, JSON.stringify(pending));
        console.log("[PlaytimeTracker] 🕐 Tracked launch:", pending.title, "at", new Date(now * 1000).toLocaleTimeString());

        // Increment play count immediately (we know the game is being launched)
        if (!_db[gamePath]) {
            _db[gamePath] = { time: 0, count: 0, lastPlayed: 0 };
        }
        _db[gamePath].count += 1;
        _db[gamePath].lastPlayed = now;
        _saveDb();
    }

    // Get accumulated play time in seconds for a game
    function getPlayTime(game) {
        // Force dependency on _dbVersion for binding reactivity
        var v = _dbVersion;
        if (!game) return 0;
        var path = _getGamePath(game);
        if (!path || !_db[path]) return 0;
        return _db[path].time || 0;
    }

    // Get play count for a game
    function getPlayCount(game) {
        var v = _dbVersion;
        if (!game) return 0;
        var path = _getGamePath(game);
        if (!path || !_db[path]) return 0;
        return _db[path].count || 0;
    }

    // Get formatted play time string (e.g., "2h 15m", "45m", "0m")
    function getFormattedPlayTime(game) {
        var totalSec = getPlayTime(game);
        var h = Math.floor(totalSec / 3600);
        var m = Math.floor((totalSec % 3600) / 60);
        if (h > 0) return h + "h " + m + "m";
        if (m > 0) return m + "m";
        if (totalSec > 0) return "<1m";
        return "0m";
    }

    // Get last played timestamp for a game (Unix epoch seconds)
    function getLastPlayed(game) {
        var v = _dbVersion;
        if (!game) return 0;
        var path = _getGamePath(game);
        if (!path || !_db[path]) return 0;
        return _db[path].lastPlayed || 0;
    }

    // Initialization: resolve pending sessions on theme load

    Component.onCompleted: {
        _loadDb();
        _resolvePendingSession();
        console.log("[PlaytimeTracker] ✅ Initialized. Tracking", Object.keys(_db).length, "games");
    }

    // Internal

    function _resolvePendingSession() {
        var pendingStr = _memGet(_pendingKey);
        if (!pendingStr) return;

        try {
            var pending = JSON.parse(pendingStr);
            if (!pending.path || !pending.startTime) return;

            var now = Math.floor(Date.now() / 1000);
            var elapsed = now - pending.startTime;

            // Sanity check: ignore sessions longer than 24 hours or negative
            if (elapsed <= 0 || elapsed > 86400) {
                console.log("[PlaytimeTracker] ⚠ Discarding invalid session:", elapsed, "seconds");
                _memUnset(_pendingKey);
                return;
            }

            // Add to database
            if (!_db[pending.path]) {
                _db[pending.path] = { time: 0, count: 0, lastPlayed: 0 };
            }
            _db[pending.path].time += elapsed;
            // count was already incremented at launch time
            // lastPlayed was already set at launch time

            _saveDb();
            _memUnset(_pendingKey);

            var h = Math.floor(elapsed / 3600);
            var m = Math.floor((elapsed % 3600) / 60);
            var s = elapsed % 60;
            console.log("[PlaytimeTracker] ✅ Resolved session for", pending.title,
                        "— Duration:", h + "h " + m + "m " + s + "s",
                        "— Total:", Math.floor(_db[pending.path].time / 3600) + "h " +
                        Math.floor((_db[pending.path].time % 3600) / 60) + "m");

            _dbVersion++;

        } catch (e) {
            console.log("[PlaytimeTracker] Error resolving pending session:", e);
            _memUnset(_pendingKey);
        }
    }

    function _getGamePath(game) {
        if (!game) return "";
        // Try to get the file path (most reliable identifier)
        try {
            if (game.files && game.files.count > 0) {
                var f = game.files.get(0);
                if (f && f.path) return f.path;
            }
        } catch (e) {}
        // Fallback: use title as identifier
        return game.title || "";
    }

    function _loadDb() {
        var dbStr = _memGet(_dbKey);
        if (!dbStr) {
            _db = {};
            return;
        }
        try {
            _db = JSON.parse(dbStr);
        } catch (e) {
            console.log("[PlaytimeTracker] Error loading database:", e);
            _db = {};
        }
    }

    function _saveDb() {
        try {
            _memSet(_dbKey, JSON.stringify(_db));
        } catch (e) {
            console.log("[PlaytimeTracker] Error saving database:", e);
        }
    }

    // api.memory wrappers with safety checks
    function _memSet(key, value) {
        if (typeof api !== "undefined" && api.memory) {
            api.memory.set(key, value);
        }
    }
    function _memGet(key) {
        if (typeof api !== "undefined" && api.memory) {
            return api.memory.get(key);
        }
        return null;
    }
    function _memUnset(key) {
        if (typeof api !== "undefined" && api.memory) {
            api.memory.unset(key);
        }
    }
}
