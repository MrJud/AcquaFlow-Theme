.pragma library

var platformMappings = {
    "gamecube": "gc",
    "nintendo gamecube": "gc",
    "ngc": "gc"
};

// Detect GameCube games that might be grouped under Wii collection
function detectGameCubePlatform(game, collectionPlatform) {
    if (!game || collectionPlatform !== "wii") {
        return collectionPlatform;
    }

    var debugLog = false;

    if (game.collections && game.collections.length > 0) {
        for (var i = 0; i < game.collections.length; i++) {
            var coll = game.collections[i];
            if (coll && coll.shortName) {
                var collName = String(coll.shortName).toLowerCase();
                if (collName === "gc" || collName === "gamecube") {
                    if (debugLog) console.log("[Utils] ✓ DETECTED as GameCube from game.collections!");
                    return "gc";
                }
            }
        }
    }

    var pathsToCheck = [];

    if (game.file) pathsToCheck.push(String(game.file));
    if (game.path) pathsToCheck.push(String(game.path));
    if (game.launch) {
        if (typeof game.launch === "string") {
            pathsToCheck.push(game.launch);
        } else if (game.launch.toString) {
            pathsToCheck.push(game.launch.toString());
        }
    }

    if (game.files && game.files.length > 0) {
        pathsToCheck.push(String(game.files[0]));
    }

    if (debugLog) {
        console.log("[Utils] detectGameCubePlatform for:", game.title);
        console.log("[Utils]   Paths to check:", pathsToCheck.length);
    }

    for (var j = 0; j < pathsToCheck.length; j++) {
        var gamePath = pathsToCheck[j].toLowerCase();

        if (debugLog) {
            console.log("[Utils]   Checking path:", gamePath);
        }

        if (gamePath.indexOf("/gc/") !== -1 ||
            gamePath.indexOf("\\gc\\") !== -1 ||
            gamePath.indexOf("/gamecube/") !== -1 ||
            gamePath.indexOf("\\gamecube\\") !== -1 ||
            gamePath.indexOf(".gcm") !== -1 ||
            gamePath.indexOf(".gcz") !== -1) {

            if (debugLog) {
                console.log("[Utils]   ✓ DETECTED as GameCube from path!");
            }
            return "gc";
        }
    }

    if (game.assets && game.assets.boxFront) {
        var assetPath = String(game.assets.boxFront).toLowerCase();

        if (debugLog) {
            console.log("[Utils]   Checking asset path:", assetPath);
        }

        if (assetPath.indexOf("/gamecube/") !== -1 ||
            assetPath.indexOf("\\gamecube\\") !== -1 ||
            assetPath.indexOf("/gc/") !== -1 ||
            assetPath.indexOf("\\gc\\") !== -1) {

            if (debugLog) {
                console.log("[Utils]   ✓ DETECTED as GameCube from asset path!");
            }
            return "gc";
        }
    }

    // No title-based detection — only real path and collection
    if (debugLog) {
        console.log("[Utils]   → Remains as Wii");
    }

    return collectionPlatform;
}

function normalizePlatformName(platformName) {
    if (!platformName) return "default";

    var normalized = platformName.toLowerCase().trim();

    if (platformMappings[normalized]) {
        return platformMappings[normalized];
    }

    return normalized;
}

function getDefaultCover() {
    return "assets/default_cover.png";
}

function getDefaultBackCover() {
    return "assets/default_back_cover.png";
}

function getGameCover(game) {
    if (!game) return getDefaultCover();

    // Only boxFront
    if (game.assets && game.assets.boxFront) return game.assets.boxFront;

    return getDefaultCover();
}

// Helper function to extract filename without extension from a path
function getFilenameWithoutExtension(filePath) {
    if (!filePath) return "";

    var lastSlashIndex = Math.max(filePath.lastIndexOf('/'), filePath.lastIndexOf('\\'));
    var filenameWithExtension = filePath;
    if (lastSlashIndex !== -1) {
        filenameWithExtension = filePath.substring(lastSlashIndex + 1);
    }

    var dotIndex = filenameWithExtension.lastIndexOf('.');
    if (dotIndex !== -1) {
        return filenameWithExtension.substring(0, dotIndex);
    }
    return filenameWithExtension;
}

function getCleanGameTitleForFilename(game) {
    if (!game) return "Titolo sconosciuto";

    // Prefer game.assets.boxBack if available
    if (game.assets && game.assets.boxBack) {
        var filename = getFilenameWithoutExtension(game.assets.boxBack);
        if (filename) return filename;
    }

    if (game.assets && game.assets.boxFront) {
        var filename = getFilenameWithoutExtension(game.assets.boxFront);
        if (filename) return filename;
    }

    var title = game.shortTitle || game.title;
    if (!title) return "Titolo sconosciuto";

    return String(title).trim();
}

function getGameBox2DBack(game, fallbackPlatform, customBoxbackPath) {
    if (!game) {
        return "";
    }

    var platform = game.platform;
    if (!platform && fallbackPlatform) {
        platform = fallbackPlatform;
    }

    if (!platform) {
        return "";
    }

    var cleanTitle = getCleanGameTitleForFilename(game);
    if (!cleanTitle || cleanTitle === "Titolo sconosciuto") {
        return "";
    }

    // Use custom boxback folder if provided
    if (customBoxbackPath && customBoxbackPath !== "") {
        return "ABSOLUTE:" + customBoxbackPath + "/" + cleanTitle;
    }

    var path = "assets/BoxBack/" + platform.toLowerCase() + "/" + cleanTitle;
    return path;
}

function getPlatformSide1(platform) {
    if (!platform) {
        return "assets/images/Side/default/Side1.png";
    }

    var platformPath = "assets/images/Side/" + platform.toLowerCase() + "/Side1.png";

    return platformPath;
}

function getPlatformSide2(platform) {
    if (!platform) {
        return "assets/images/Side/default/Side2.png";
    }

    var platformPath = "assets/images/Side/" + platform.toLowerCase() + "/Side2.png";

    return platformPath;
}

function getDefaultSide1() {
    return "assets/images/Side/default/Side1.png";
}

function getDefaultSide2() {
    return "assets/images/Side/default/Side2.png";
}

function getPlatformSide3(platform) {
    if (!platform) {
        return "assets/images/Side/default/Side3.png";
    }

    var platformPath = "assets/images/Side/" + platform.toLowerCase() + "/Side3.png";

    return platformPath;
}

function getPlatformSide4(platform) {
    if (!platform) {
        return "assets/images/Side/default/Side4.png";
    }

    var platformPath = "assets/images/Side/" + platform.toLowerCase() + "/Side4.png";

    return platformPath;
}

function getDefaultSide3() {
    return "assets/images/Side/default/Side3.png";
}

function getDefaultSide4() {
    return "assets/images/Side/default/Side4.png";
}

function getCollectionLayoutSettings() {
    return {
        singleGame: {
            items: 5,
            phantomOpacity: 0.9
        },

        smallCollection: {
            maxGames: 6,
            items: 7,  // Fixed item count for compactness
            phantomOpacity: 0.8
        },

        mediumCollection: {
            maxGames: 12,  // Max threshold for medium collections
            items: 11,  // Intermediate item count
            phantomOpacity: 0.6  // Semi-visible phantom covers
        },

        largeCollection: {
            items: 15,  // Max number di items
            phantomOpacity: 0.5  // Semi-visible phantom covers
        }
    };
}

function getGameBackground(game) {
    if (!game) return "";

    if (!game.assets) return "";

    // Priority: fanart > screenshot > titlescreen > background
    if (game.assets.fanart) return game.assets.fanart;
    if (game.assets.screenshot) return game.assets.screenshot;
    if (game.assets.titlescreen) return game.assets.titlescreen;
    if (game.assets.background) return game.assets.background;

    return "";
}

function getGameLogo(game) {
    if (game && game.assets && game.assets.logo) {
        return game.assets.logo;
    }
    return "";
}

function getGameVideo(game) {
    if (!game) return "";

    var gamePath = "";

    if (game.path) {
        gamePath = game.path;
    } else if (game.file) {
        gamePath = game.file;
        var lastSlash = Math.max(gamePath.lastIndexOf('/'), gamePath.lastIndexOf('\\'));
        if (lastSlash !== -1) {
            gamePath = gamePath.substring(0, lastSlash);
        }
    } else if (game.assets && game.assets.video) {
        return game.assets.video;
    }

    if (gamePath) {
        // Remove file extension if present
        var dotIndex = gamePath.lastIndexOf('.');
        var slashIndex = Math.max(gamePath.lastIndexOf('/'), gamePath.lastIndexOf('\\'));
        if (dotIndex > slashIndex) {
            gamePath = gamePath.substring(0, dotIndex);
        }

        // Try common video extensions
        var videoExtensions = ['.mp4', '.avi', '.mkv', '.webm', '.mov', '.wmv'];
        for (var i = 0; i < videoExtensions.length; i++) {
            var videoPath = gamePath + "/media/video" + videoExtensions[i];
            if (i === 0) {
                return videoPath;
            }
        }
    }

    return "";
}

// Format duration in readable format
function formatPlayTime(minutes) {
    if (!minutes || minutes === 0) return "";

    var hours = Math.floor(minutes / 60);
    var mins = minutes % 60;

    if (hours > 0) {
        return hours + "h " + mins + "m";
    } else {
        return mins + "m";
    }
}

// Format release date
function formatReleaseDate(date, lang) {
    if (!date) return lang === "en" ? "Unknown date" : "Data sconosciuta";

    var d = new Date(date);
    if (isNaN(d.getTime())) return lang === "en" ? "Invalid date" : "Data non valida";

    var locale = lang === "en" ? "en-US" : "it-IT";
    return d.toLocaleDateString(locale, {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

function isGameFavorite(game) {
    return game && game.favorite === true;
}

function getGameRating(game) {
    if (!game || !game.rating) return 0;
    return Math.round(game.rating * 5);  // Convert from 0-1 to 0-5
}

function formatLastPlayed(game, neverText, lang) {
    if (!game) return neverText || (lang === "en" ? "Never" : "Mai");

    var lastPlayedDate = game.lastPlayed || game.last_played || (game.playTime && game.playTime.lastPlayed);

    if (!lastPlayedDate) return neverText || (lang === "en" ? "Never" : "Mai");

    var date = new Date(lastPlayedDate);
    if (isNaN(date.getTime())) return neverText || (lang === "en" ? "Never" : "Mai");

    var now = new Date();
    var diffInMs = now - date;
    var diffInDays = Math.floor(diffInMs / (1000 * 60 * 60 * 24));

    if (diffInDays === 0) {
        return lang === "en" ? "Today" : "Oggi";
    } else if (diffInDays === 1) {
        return lang === "en" ? "Yesterday" : "Ieri";
    } else if (diffInDays < 7) {
        return lang === "en" ? diffInDays + " days ago" : diffInDays + " giorni fa";
    } else if (diffInDays < 30) {
        var weeks = Math.floor(diffInDays / 7);
        if (lang === "en") return weeks === 1 ? "1 week ago" : weeks + " weeks ago";
        return weeks === 1 ? "1 settimana fa" : weeks + " settimane fa";
    } else if (diffInDays < 365) {
        var months = Math.floor(diffInDays / 30);
        if (lang === "en") return months === 1 ? "1 month ago" : months + " months ago";
        return months === 1 ? "1 mese fa" : months + " mesi fa";
    } else {
        var years = Math.floor(diffInDays / 365);
        if (lang === "en") return years === 1 ? "1 year ago" : years + " years ago";
        return years === 1 ? "1 anno fa" : years + " anni fa";
    }
}

function formatDeveloper(game, unknownText) {
    if (!game) return unknownText || "Unknown";

    var developer = game.developer || game.publisher || game.studio;

    if (!developer || developer.trim() === "") {
        return unknownText || "Unknown";
    }

    return developer.trim();
}

// Format game genres
function formatGenre(game, unknownText, maxGenres, separator) {
    if (!game) return unknownText || "Unknown";

    // Default values
    maxGenres = maxGenres || 3;
    separator = separator || ", ";

    var genres = game.genre || game.genres || game.genreList;

    if (!genres) return unknownText || "Unknown";

    if (typeof genres === "string") {
        genres = genres.split(",").map(function(g) { return g.trim(); });
    }

    if (Array.isArray(genres)) {
        // Filter empty genres
        genres = genres.filter(function(g) { return g && g.trim() !== ""; });

        if (genres.length === 0) return unknownText || "Unknown";

        if (genres.length > maxGenres) {
            genres = genres.slice(0, maxGenres);
        }

        return genres.join(separator);
    }

    if (typeof genres === "object" && genres.toString) {
        var genreString = genres.toString().trim();
        if (genreString && genreString !== "[object Object]") {
            return genreString;
        }
    }

    return unknownText || "Unknown";
}

// Fuzzy Game Title Matching

// Normalize a title: strip region tags, articles, punctuation
function fuzzyNormalize(title) {
    if (!title) return "";
    var s = title.toLowerCase();
    s = s.replace(/\s*[\(\[][^\)\]]*[\)\]]\s*/g, " ");
    // Remove trailing articles: "Legend of Zelda, The" → "Legend of Zelda"
    s = s.replace(/,\s*(the|a|an|le|la|les|el|los|das|der|die)\s*$/i, "");
    // Remove leading articles
    s = s.replace(/^(the|a|an|le|la|les|el|los|das|der|die)\s+/i, "");
    s = s.replace(/[^a-z0-9]/g, "");
    return s;
}

// Levenshtein distance (single-row DP)
function fuzzyLevenshtein(a, b) {
    if (a === b) return 0;
    if (a.length === 0) return b.length;
    if (b.length === 0) return a.length;
    if (Math.abs(a.length - b.length) > Math.max(a.length, b.length) * 0.5)
        return Math.max(a.length, b.length);

    var row = [];
    for (var i = 0; i <= b.length; i++) row[i] = i;
    for (var i = 1; i <= a.length; i++) {
        var prev = i;
        for (var j = 1; j <= b.length; j++) {
            var cost = a[i - 1] === b[j - 1] ? 0 : 1;
            var val = Math.min(row[j] + 1, prev + 1, row[j - 1] + cost);
            row[j - 1] = prev;
            prev = val;
        }
        row[b.length] = prev;
    }
    return row[b.length];
}

// Similarity score 0.0–1.0 between two titles
function fuzzySimilarity(titleA, titleB) {
    var a = fuzzyNormalize(titleA);
    var b = fuzzyNormalize(titleB);
    if (a === "" || b === "") return 0;
    if (a === b) return 1.0;

    // Substring check
    var containsScore = 0;
    if (a.indexOf(b) >= 0) containsScore = b.length / a.length;
    else if (b.indexOf(a) >= 0) containsScore = a.length / b.length;

    // Levenshtein similarity
    var maxLen = Math.max(a.length, b.length);
    var levScore = 1.0 - (fuzzyLevenshtein(a, b) / maxLen);

    // Common prefix bonus
    var prefixLen = 0;
    var minLen = Math.min(a.length, b.length);
    for (var i = 0; i < minLen; i++) {
        if (a[i] === b[i]) prefixLen++;
        else break;
    }
    var prefixScore = prefixLen / maxLen;

    return Math.max(containsScore * 0.95, levScore * 0.85 + prefixScore * 0.15);
}

// Find best fuzzy match from candidates array
// candidates: [{ title: "...", ... }]
// Returns: { match: candidate, score: number } or null
function fuzzyMatchGame(searchTitle, candidates, minScore) {
    if (!candidates || candidates.length === 0) return null;
    if (minScore === undefined) minScore = 0.60;

    var bestScore = 0;
    var bestMatch = null;
    for (var i = 0; i < candidates.length; i++) {
        var score = fuzzySimilarity(searchTitle, candidates[i].title || "");
        if (score > bestScore) {
            bestScore = score;
            bestMatch = candidates[i];
        }
        if (score >= 1.0) break;
    }
    return bestScore >= minScore ? { match: bestMatch, score: bestScore } : null;
}
