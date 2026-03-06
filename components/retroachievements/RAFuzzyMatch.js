.pragma library

// RAFuzzyMatch.js — Fuzzy game title matching for RA

// Normalize a game title for comparison
// Strips region tags, articles, punctuation, whitespace
function normalize(title) {
    if (!title) return "";
    var s = title.toLowerCase();

    s = s.replace(/\s*[\(\[][^\)\]]*[\)\]]\s*/g, " ");

    // Remove common prefixes/suffixes that RA shuffles
    // "The Legend of Zelda" vs "Legend of Zelda, The"
    s = s.replace(/,\s*(the|a|an|le|la|les|el|los|das|der|die)\s*$/i, "");
    s = s.replace(/^(the|a|an|le|la|les|el|los|das|der|die)\s+/i, "");

    s = s.replace(/[^a-z0-9]/g, "");

    return s;
}

// Levenshtein distance (edit distance)
function levenshtein(a, b) {
    if (a === b) return 0;
    if (a.length === 0) return b.length;
    if (b.length === 0) return a.length;

    // Optimization: if lengths differ too much, skip full computation
    if (Math.abs(a.length - b.length) > Math.max(a.length, b.length) * 0.5) {
        return Math.max(a.length, b.length);
    }

    // Single-row DP for memory efficiency
    var row = [];
    for (var i = 0; i <= b.length; i++) row[i] = i;

    for (var i = 1; i <= a.length; i++) {
        var prev = i;
        for (var j = 1; j <= b.length; j++) {
            var cost = a[i - 1] === b[j - 1] ? 0 : 1;
            var val = Math.min(
                row[j] + 1,  // deletion
                prev + 1,  // insertion
                row[j - 1] + cost  // substitution
            );
            row[j - 1] = prev;
            prev = val;
        }
        row[b.length] = prev;
    }
    return row[b.length];
}

// Similarity score (0.0 to 1.0)
// Combines multiple heuristics for best results
function similarity(titleA, titleB) {
    var a = normalize(titleA);
    var b = normalize(titleB);

    if (a === "" || b === "") return 0;

    // Perfect match after normalization
    if (a === b) return 1.0;

    // Contains check (one title is substring of the other)
    var containsScore = 0;
    if (a.indexOf(b) >= 0) {
        containsScore = b.length / a.length;  // e.g. 0.8 if short is 80% of long
    } else if (b.indexOf(a) >= 0) {
        containsScore = a.length / b.length;
    }

    // Levenshtein-based similarity
    var maxLen = Math.max(a.length, b.length);
    var dist = levenshtein(a, b);
    var levScore = 1.0 - (dist / maxLen);

    // Common prefix bonus (titles often start the same)
    var prefixLen = 0;
    var minLen = Math.min(a.length, b.length);
    for (var i = 0; i < minLen; i++) {
        if (a[i] === b[i]) prefixLen++;
        else break;
    }
    var prefixScore = prefixLen / maxLen;

    // Weighted combination
    return Math.max(
        containsScore * 0.95,  // substring match is very strong
        levScore * 0.85 + prefixScore * 0.15  // edit distance + prefix bonus
    );
}

// Find best match from a list of titles
// candidates: array of { title: string, ... }
// Returns: { match: candidate, score: number } or null
function findBestMatch(searchTitle, candidates, minScore) {
    if (!candidates || candidates.length === 0) return null;
    if (minScore === undefined) minScore = 0.6;

    var bestScore = 0;
    var bestMatch = null;

    for (var i = 0; i < candidates.length; i++) {
        var score = similarity(searchTitle, candidates[i].title || candidates[i].Title || "");
        if (score > bestScore) {
            bestScore = score;
            bestMatch = candidates[i];
        }
        // Early exit on perfect match
        if (score >= 1.0) break;
    }

    if (bestScore >= minScore) {
        return { match: bestMatch, score: bestScore };
    }
    return null;
}

// Find best match for a Pegasus game in RA games
// pegasusTitle: the game title from Pegasus
// raGames: array of RA game objects with .title
// Returns best matching RA game or null
function matchPegasusToRA(pegasusTitle, raGames, minScore) {
    return findBestMatch(pegasusTitle, raGames, minScore || 0.65);
}
