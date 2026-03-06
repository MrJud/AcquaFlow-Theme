import QtQuick 2.15
import ".."
import "../config/SamplingConfigs.js" as SamplingConfigs

Item {
    id: root

    signal colorReady(var item, var url, color topColor, color bottomColor)

    // PERF: sourceSize matching — use same dimensions as coverLoader/coverImage prefetcher
    // so the QML pixmap cache is hit instead of re-decoding the image from scratch.
    property int refWidth: 240
    property int refHeight: 400

    // ── Inline fallback sampling config ──────────────────────────────────
    readonly property var _fallbackConfig: ({
        points: [
            { x: 0.50, y: 0.12, weight: 1.2, radius: 14 },
            { x: 0.25, y: 0.35, weight: 1.0, radius: 12 },
            { x: 0.75, y: 0.35, weight: 1.0, radius: 12 },
            { x: 0.50, y: 0.60, weight: 1.0, radius: 14 },
            { x: 0.50, y: 0.88, weight: 1.2, radius: 14 }
        ],
        minLuminance: 0.04,
        minSaturation: 0.04
    })

    // Resolve sampling config from the top-level JS import (QML scope — safe).
    function _getSamplingConfig(platform) {
        try {
            var cfg = SamplingConfigs.getSamplingConfig(platform);
            if (cfg && cfg.points && cfg.points.length > 0)
                return cfg;
        } catch (e) {
            console.log("[ColorSampler] SamplingConfigs.getSamplingConfig failed: " + e);
        }
        return _fallbackConfig;
    }

    function sample(item, imageUrl, platform) {
        if (colorCache[imageUrl]) {
            var cachedColors = colorCache[imageUrl];
            root.colorReady(item, imageUrl, cachedColors.top, cachedColors.bottom);
            return;
        }

        if (Object.keys(colorCache).length > 150) {
            return;
        }

        // PERF: Queue requests instead of silently dropping them
        // This ensures all visible covers get sampled eventually.
        if (currentRequest) {
            // If this URL is already being processed, upgrade the item reference
            if (currentRequest.url === imageUrl) {
                if (item && !currentRequest.item) {
                    currentRequest.item = item;
                }
                return;
            }
            // Avoid duplicate entries in the queue — upgrade item if presample queued it
            for (var i = 0; i < _pendingQueue.length; ++i) {
                if (_pendingQueue[i].url === imageUrl) {
                    if (item && !_pendingQueue[i].item) {
                        _pendingQueue[i].item = item;
                    }
                    return;
                }
            }
            if (_pendingQueue.length < 30) {  // cap queue to prevent unbounded growth
                _pendingQueue.push({ "item": item, "url": imageUrl, "platform": platform || "default" });
            }
            return;
        }

        _startSampling(item, imageUrl, platform);
    }

    // Pre-sample an image URL to populate the cache ahead of time.
    // Called by the prefetcher so colors are ready when covers appear.
    // No item reference — results go only into colorCache.
    function presample(imageUrl, platform) {
        if (!imageUrl || imageUrl === "") return;
        if (colorCache[imageUrl]) return;

        if (currentRequest && currentRequest.url === imageUrl) return;
        for (var i = 0; i < _pendingQueue.length; ++i) {
            if (_pendingQueue[i].url === imageUrl) return;
        }

        if (currentRequest) {
            if (_pendingQueue.length < 30) {
                _pendingQueue.push({ "item": null, "url": imageUrl, "platform": platform || "default" });
            }
            return;
        }

        _startSampling(null, imageUrl, platform);
    }

    function _startSampling(item, imageUrl, platform) {
        currentRequest = { "item": item, "url": imageUrl, "platform": platform || "default" };
        // Resolve config synchronously (cached after first call)
        _resolveConfig(platform || "default");
        // Start timeout failsafe in case loadImage silently fails
        _loadTimeout.restart();
        // If already loaded in Canvas cache, paint immediately; otherwise load
        if (samplerCanvas.isImageLoaded(imageUrl)) {
            _loadTimeout.stop();
            samplerCanvas.requestPaint();
        } else {
            samplerCanvas.loadImage(imageUrl);
        }
    }

    function _processNextInQueue() {
        while (_pendingQueue.length > 0) {
            var next = _pendingQueue.shift();
            // Skip if already cached while waiting in queue
            if (colorCache[next.url]) {
                root.colorReady(next.item, next.url, colorCache[next.url].top, colorCache[next.url].bottom);
                continue;
            }
            _startSampling(next.item, next.url, next.platform);
            return;
        }
    }

    // Weighted average of an array of color candidate objects
    function _weightedAverage(colors) {
        var totalWeight = 0;
        var rSum = 0, gSum = 0, bSum = 0;

        for (var i = 0; i < colors.length; i++) {
            var c = colors[i];
            var w = c.weight || 1.0;
            rSum += c.r * w;
            gSum += c.g * w;
            bSum += c.b * w;
            totalWeight += w;
        }

        if (totalWeight <= 0) totalWeight = 1;
        return Qt.rgba(rSum / totalWeight, gSum / totalWeight, bSum / totalWeight, 1.0);
    }

    property var colorCache: ({})
    property var currentRequest: null
    property var _pendingQueue: []

    // Failsafe: if loadImage silently fails, move on after 3s
    Timer {
        id: _loadTimeout
        interval: 3000
        repeat: false
        onTriggered: {
            if (root.currentRequest) {
                root.currentRequest = null;
                root._processNextInQueue();
            }
        }
    }

    // ── Pre-resolved config cache ────────────────────────────────────────
    property var _configCache: ({})

    function _resolveConfig(platform) {
        if (_configCache[platform]) return _configCache[platform];
        var cfg = _getSamplingConfig(platform);
        _configCache[platform] = cfg;
        return cfg;
    }

    // We use a Canvas with loadImage() to ensure Android compatibility.
    // On Android's QML Canvas, drawImage(Image_element) silently renders black pixels.
    // loadImage(url) + onImageLoaded → drawImage(url) is the reliable path.

    Canvas {
        id: samplerCanvas
        width: 10
        height: 10
        visible: false

        onImageLoaded: {
            _loadTimeout.stop();
            requestPaint();
        }

        onPaint: {
            if (!root.currentRequest) return;

            var imageUrl = root.currentRequest.url;

            // Check the image is loaded in the Canvas (not just the Image element)
            if (!isImageLoaded(imageUrl)) {
                loadImage(imageUrl);
                return;
            }

            var ctx = getContext("2d");
            if (!ctx) {
                root.currentRequest = null;
                root._processNextInQueue();
                return;
            }

            // Use pre-resolved config
            var platform = root.currentRequest.platform;
            var config = root._configCache[platform] || root._fallbackConfig;
            var samplePoints = config.points;
            var minLum = config.minLuminance !== undefined ? config.minLuminance : 0.04;
            var minSat = config.minSaturation !== undefined ? config.minSaturation : 0.04;

            // Draw the full image onto our 10x10 canvas so we can sample
            // Using the URL string as source (not Image element) — required on Android
            var cw = samplerCanvas.width;   // 10
            var ch = samplerCanvas.height;  // 10

            ctx.clearRect(0, 0, cw, ch);
            try {
                ctx.drawImage(imageUrl, 0, 0, cw, ch);
            } catch (drawErr) {
                root.currentRequest = null;
                root._processNextInQueue();
                return;
            }

            var candidateColors = [];

            for (var i = 0; i < samplePoints.length; i++) {
                var sp = samplePoints[i];

                // Map normalized coords to our canvas pixels
                var px = Math.max(0, Math.min(Math.round(sp.x * (cw - 1)), cw - 1));
                var py = Math.max(0, Math.min(Math.round(sp.y * (ch - 1)), ch - 1));

                var pixelData;
                try {
                    pixelData = ctx.getImageData(px, py, 1, 1).data;
                } catch (readErr) {
                    continue;
                }

                if (!pixelData || pixelData.length < 4) continue;
                var alpha = pixelData[3];
                if (alpha < 10) {
                    continue;
                }

                var r = pixelData[0] / 255;
                var g = pixelData[1] / 255;
                var b = pixelData[2] / 255;

                if (r < 0.005 && g < 0.005 && b < 0.005) {
                    continue;
                }

                var maxC = Math.max(r, g, b);
                var minC = Math.min(r, g, b);
                var luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
                var saturation = maxC > 0.001 ? (maxC - minC) / maxC : 0;
                var weight = sp.weight || 1.0;

                candidateColors.push({
                    color: Qt.rgba(r, g, b, 1.0),
                    r: r, g: g, b: b,
                    saturation: saturation,
                    luminance: luminance,
                    weight: weight,
                    y: sp.y
                });
            }

            var finalTopColor;
            var finalBottomColor;

            var validColors = candidateColors.filter(function(c) {
                return c.luminance > minLum && c.saturation > minSat;
            });

            if (validColors.length >= 2) {
                validColors.sort(function(a, b) { return a.y - b.y; });
                var midY = (validColors[0].y + validColors[validColors.length - 1].y) / 2;
                var topColors = validColors.filter(function(c) { return c.y <= midY; });
                var bottomColors = validColors.filter(function(c) { return c.y > midY; });
                if (topColors.length === 0) topColors = [validColors[0]];
                if (bottomColors.length === 0) bottomColors = [validColors[validColors.length - 1]];
                finalTopColor = root._weightedAverage(topColors);
                finalBottomColor = root._weightedAverage(bottomColors);
            } else if (validColors.length === 1) {
                finalTopColor = validColors[0].color;
                finalBottomColor = Qt.darker(validColors[0].color, 1.3);
            } else if (candidateColors.length > 0) {
                candidateColors.sort(function(a, b) {
                    return (b.saturation * b.luminance * b.weight) - (a.saturation * a.luminance * a.weight);
                });
                var best = candidateColors[0];
                finalTopColor = best.luminance < 0.1 ? Qt.lighter(best.color, 1.4) : best.color;
                finalBottomColor = Qt.darker(finalTopColor, 1.3);
            } else {
                root.currentRequest = null;
                root._processNextInQueue();
                return;
            }

            root.colorReady(root.currentRequest.item, root.currentRequest.url, finalTopColor, finalBottomColor);
            root.colorCache[root.currentRequest.url] = { top: finalTopColor, bottom: finalBottomColor };

            root.currentRequest = null;

            // PERF: Process next queued request immediately
            root._processNextInQueue();
        }
    }
}
