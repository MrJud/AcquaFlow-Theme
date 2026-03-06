import QtQuick 2.15
import ".."
import ".." as Components

Item {
    id: root

    property string side: "left"
    property real coverPaintedHeight: 0
    property real coverPaintedY: 0
    property var perspectiveFactors: ({ top: 0, bottom: 0 })
    property real normalizedAngle: 0
    property color topColor: "gray"
    property color bottomColor: "darkgray"
    property real perspectiveStrength: 0.4
    property bool isFallbackSide: false
    property bool isTrue3D: false
    property bool isInFastMode: false
    property bool reflectionFade: false

    visible: width > 0 && height > 0

    // When the CoverSide becomes visible (e.g. when width transitions from 0 → positive),
    // the Canvas backing store may not be ready on the first frame (Android/GLES).
    // Schedule a delayed repaint to guarantee the Canvas paints after initialization.
    onVisibleChanged: {
        if (visible && width > 0 && height > 0) {
            if (retryPaintTimer) retryPaintTimer.restart();
        }
    }

    Components.EdgeAntialiasing {
        id: antialiasedCanvas
        anchors.fill: parent
        sourceItem: canvas
    }

    onSideChanged: canvas.scheduleRepaint()
    onCoverPaintedHeightChanged: canvas.scheduleRepaint()
    onCoverPaintedYChanged: canvas.scheduleRepaint()
    onPerspectiveFactorsChanged: canvas.scheduleRepaint()
    // Immediate repaint on normalizedAngle for max smoothness
    onNormalizedAngleChanged: canvas.requestPaint()
    onTopColorChanged: canvas.scheduleRepaint()
    onBottomColorChanged: canvas.scheduleRepaint()
    onPerspectiveStrengthChanged: canvas.scheduleRepaint()
    onIsFallbackSideChanged: canvas.scheduleRepaint()
    onIsTrue3DChanged: canvas.scheduleRepaint()
    onReflectionFadeChanged: canvas.scheduleRepaint()

    Canvas {
        id: canvas
        anchors.fill: parent

        property bool needsRepaint: true

        // Safety timer: ensures Canvas repaints after its backing store is fully
        // allocated following a resize from 0 width (Android/GLES race condition).
        Timer {
            id: retryPaintTimer
            interval: 32
            repeat: false
            onTriggered: {
                if (canvas.width > 0 && canvas.height > 0) {
                    canvas.needsRepaint = true;
                    canvas.requestPaint();
                }
            }
        }

        function scheduleRepaint() {
            needsRepaint = true;
            if (root.isInFastMode) {
                Qt.callLater(function() {
                    if (needsRepaint) canvas.requestPaint();
                });
            } else {
                canvas.requestPaint();
            }
        }

        onWidthChanged: {
            scheduleRepaint();
            // When width transitions from 0 → positive, the immediate requestPaint may fire
            // before the backing store is ready. Schedule a retry after one+ frames.
            if (canvas.width > 0 && canvas.height > 0)
                retryPaintTimer.restart();
        }
        onHeightChanged: scheduleRepaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            if (canvas.width <= 0 || canvas.height <= 0) return;
            if (!needsRepaint) return;

            var ctx = getContext("2d");
            if (!ctx) return;

            ctx.clearRect(0, 0, canvas.width, canvas.height);

            paintWithColor(ctx);
        }

        function paintWithColor(ctx) {
            var angle = root.normalizedAngle || 0;
            var strength = root.perspectiveStrength || 0.4;

            var topY = root.coverPaintedY || 0;
            var bottomY = topY + (root.coverPaintedHeight || canvas.height);
            var gradient = ctx.createLinearGradient(0, topY, 0, bottomY);
            gradient.addColorStop(0, root.topColor.toString());
            gradient.addColorStop(1, root.bottomColor.toString());
            ctx.fillStyle = gradient;

            ctx.beginPath();
            defineShapeForSide(ctx, angle, strength);
            ctx.fill();

            // Reflection darkening: overlay a semi-transparent black gradient
            // on top of the painted trapezoid to darken it, matching the cover reflection style.
            // Uses source-atop so the dark overlay only affects already-painted pixels.
            if (root.reflectionFade) {
                ctx.save();
                ctx.globalCompositeOperation = "source-atop";
                var fadeGradient = ctx.createLinearGradient(0, topY, 0, bottomY);
                fadeGradient.addColorStop(0.0, "rgba(0,0,0,0.55)");
                fadeGradient.addColorStop(0.5, "rgba(0,0,0,0.35)");
                fadeGradient.addColorStop(1.0, "rgba(0,0,0,0.15)");
                ctx.fillStyle = fadeGradient;
                ctx.fillRect(0, 0, canvas.width, canvas.height);
                ctx.restore();
            }
        }

        function defineShapeForSide(ctx, angle, strength) {
            var topY = root.coverPaintedY || 0;
            var bottomY = topY + (root.coverPaintedHeight || 0);

            if (root.side === "left") {
                if (root.isTrue3D) {
                    var topFactor = root.perspectiveFactors.top || 0;
                    var bottomFactor = root.perspectiveFactors.bottom || 0;

                    var baseHeight = root.coverPaintedHeight || 0;
                    var angleMultiplier = Math.abs(angle) * strength;

                    var topShift = baseHeight * topFactor * angleMultiplier;
                    var bottomShift = baseHeight * bottomFactor * angleMultiplier;

                    var nearTopY = topY;
                    var nearBottomY = bottomY;

                    var farTopY = topY + (angle > 0 ? topShift : -topShift);
                    var farBottomY = nearBottomY - (angle > 0 ? bottomShift : -bottomShift);

                    ctx.moveTo(width, nearTopY);
                    ctx.lineTo(0, farTopY);
                    ctx.lineTo(0, farBottomY);
                    ctx.lineTo(width, nearBottomY);
                } else {
                    var localBaseShiftFactor = angle * strength;
                    var baseShift = (root.coverPaintedHeight || 0) * localBaseShiftFactor;
                    var topFactor = root.perspectiveFactors.top || 0;
                    var bottomFactor = root.perspectiveFactors.bottom || 0;

                    var topY_far = (root.coverPaintedY || 0) + (baseShift * topFactor);
                    var bottomY_far = ((root.coverPaintedY || 0) + (root.coverPaintedHeight || 0)) - (baseShift * bottomFactor);

                    ctx.moveTo(0, topY_far);
                    ctx.lineTo(canvas.width, root.coverPaintedY || 0);
                    ctx.lineTo(canvas.width, (root.coverPaintedY || 0) + (root.coverPaintedHeight || 0));
                    ctx.lineTo(0, bottomY_far);
                }
            } else if (root.side === "right") {
                if (root.isTrue3D) {
                    var topFactor = root.perspectiveFactors.top || 0;
                    var bottomFactor = root.perspectiveFactors.bottom || 0;

                    var baseHeight = root.coverPaintedHeight || 0;
                    var angleMultiplier = Math.abs(angle) * strength;

                    var topShift = baseHeight * topFactor * angleMultiplier;
                    var bottomShift = baseHeight * bottomFactor * angleMultiplier;

                    var nearTopY = topY;
                    var nearBottomY = bottomY;

                    var farTopY = topY + (angle < 0 ? topShift : -topShift);
                    var farBottomY = nearBottomY - (angle < 0 ? bottomShift : -bottomShift);

                    ctx.moveTo(0, nearTopY);
                    ctx.lineTo(width, farTopY);
                    ctx.lineTo(width, farBottomY);
                    ctx.lineTo(0, nearBottomY);
                } else {
                    var localBaseShiftFactor = angle * strength;
                    var baseShift = (root.coverPaintedHeight || 0) * localBaseShiftFactor;
                    var topFactor = root.perspectiveFactors.top || 0;
                    var bottomFactor = root.perspectiveFactors.bottom || 0;

                    var topY_far = (root.coverPaintedY || 0) + (baseShift * topFactor);
                    var bottomY_far = ((root.coverPaintedY || 0) + (root.coverPaintedHeight || 0)) - (baseShift * bottomFactor);

                    ctx.moveTo(0, root.coverPaintedY || 0);
                    ctx.lineTo(canvas.width, topY_far);
                    ctx.lineTo(canvas.width, bottomY_far);
                    ctx.lineTo(0, (root.coverPaintedY || 0) + (root.coverPaintedHeight || 0));
                }
            }
            ctx.closePath();

            if (root.isFallbackSide && (root.side === "left" || root.side === "right")) {
                ctx.beginPath();
                ctx.strokeStyle = Qt.rgba(1.0, 1.0, 1.0, 0.6);
                ctx.lineWidth = Math.max(1, canvas.width * 0.05);

                var glassY1 = root.coverPaintedY || 0;
                var glassY2 = glassY1 + (root.coverPaintedHeight || 0);

                if (root.side === "left") {
                    var glassX = canvas.width - (ctx.lineWidth * 0.5);
                    ctx.moveTo(glassX, glassY1);
                    ctx.lineTo(glassX, glassY2);
                } else {
                    var glassX = ctx.lineWidth * 0.5;
                    ctx.moveTo(glassX, glassY1);
                    ctx.lineTo(glassX, glassY2);
                }
                ctx.stroke();

                if (Math.abs(root.normalizedAngle) > 0.05) {
                    ctx.shadowColor = "rgba(255, 255, 255, 0.3)";
                    ctx.shadowBlur = 3;
                    ctx.stroke();
                    ctx.shadowColor = "transparent";
                    ctx.shadowBlur = 0;
                }
            }
        }
    }
}
