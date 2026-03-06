import QtQuick 2.15
import QtGraphicalEffects 1.15
import ".."
import "../config/Translations.js" as T

Rectangle {
    id: root
    width: 130
    height: 80
    radius: 40

    property QtObject screenMetrics: null
    property string lang: "it"
    property bool isCoverSelected: false
    property bool focused: false
    property string fillDirection: "bottom"  // "bottom", "left", "right"
    property string currentViewMode: "carousel1"
    property string currentPlatform: ""

    signal viewChanged(string viewType)

    // View mode mapping for cyclic rotation
    function getNextViewMode() {
        if (currentViewMode === "carousel1") return "carousel2";
        if (currentViewMode === "carousel2") return "carousel3";
        if (currentViewMode === "carousel3") return "carousel4";
        return "carousel1";
    }

    readonly property string currentView: currentViewMode
    readonly property bool isGridMode: currentViewMode === "carousel2"

    // Semi-transparent + white border style
    color: "transparent"
    border.width: 0
    border.color: "transparent"
    opacity: isCoverSelected ? 0.0 : 0.9
    visible: !isCoverSelected && currentPlatform !== "lastplayed" && currentPlatform !== "favourites" && currentPlatform !== "search"

    Behavior on opacity {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // Outline + fill (rounded rectangle)
    Item {
        id: unifiedOverlay
        anchors.fill: parent
        z: 0

        // Background fill
        Rectangle {
            id: bgFillItem
            anchors.fill: parent
            radius: root.radius
            color: mouseArea.pressed ? "#33FFFFFF" : "#22FFFFFF"
        }

        // Source: shape filled white (for outline)
        Item {
            id: shapeSource
            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                anchors.fill: parent
                radius: root.radius
                color: "#FFFFFF"
            }
        }

        // Mask: shrunk by 2px (for outline)
        Item {
            id: shapeMask
            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                x: 2; y: 2
                width: parent.width - 4; height: parent.height - 4
                radius: root.radius - 2
                color: "white"
            }
        }

        // Outline ring
        OpacityMask {
            anchors.fill: parent
            source: shapeSource
            maskSource: shapeMask
            invert: true
        }
    }

    // Water fill effect — physics water
    Item {
        id: vsWaterFillContainer
        anchors.fill: parent
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: root.width; height: root.height; radius: root.radius
            }
        }
        Canvas {
            id: vsWaterCanvas
            anchors.fill: parent
            property real _level: 0.0
            property real _target: 0.0
            property real _velocity: 0.0
            property real _wavePhase: 0.0
            property real _dir: 0
            property var _drops: []
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                if (_level < 0.005 && _target < 0.5) return;
                var w = width, h = height;
                var baseY = h * (1.0 - _level);
                var tilt = _velocity * 120 * _dir;
                var leftY = baseY - tilt;
                var rightY = baseY + tilt;
                var amp = 4;
                ctx.beginPath();
                ctx.moveTo(0, h);
                for (var px = 0; px <= w; px += 2) {
                    var t = px / w;
                    var surfY = leftY + (rightY - leftY) * t
                        + Math.sin(t * Math.PI * 4 + _wavePhase) * amp;
                    ctx.lineTo(px, surfY);
                }
                ctx.lineTo(w, h);
                ctx.closePath();
                ctx.fillStyle = "#CCFFFFFF";
                ctx.fill();
                for (var i = 0; i < _drops.length; i++) {
                    var d = _drops[i];
                    ctx.globalAlpha = Math.max(0, d.alpha);
                    ctx.beginPath();
                    ctx.arc(d.x, d.y, d.r, 0, Math.PI * 2);
                    ctx.fillStyle = "#FFFFFF";
                    ctx.fill();
                }
                ctx.globalAlpha = 1.0;
            }
            Timer {
                interval: 16; repeat: true
                running: vsWaterCanvas._level > 0.005 || vsWaterCanvas._target > 0.5
                onTriggered: {
                    var c = vsWaterCanvas;
                    var diff = c._target - c._level;
                    c._velocity = c._velocity * 0.92 + diff * 0.06;
                    c._level = Math.max(0, Math.min(1, c._level + c._velocity));
                    c._wavePhase = (c._wavePhase + 0.10) % (Math.PI * 2);
                    if (Math.abs(c._velocity) > 0.01) {
                        var w = c.width, h = c.height;
                        var baseY = h * (1.0 - c._level);
                        var n = Math.floor(Math.random() * 2) + 1;
                        for (var j = 0; j < n; j++) {
                            var rx = Math.random() * w;
                            var t = rx / w;
                            var tilt = c._velocity * 120 * c._dir;
                            var surfY = (baseY - tilt) + tilt * 2 * t
                                + Math.sin(t * Math.PI * 4 + c._wavePhase) * 4;
                            c._drops.push({ x: rx, y: surfY,
                                vy: -(Math.random() * 2.5 + 1.5),
                                vx: (Math.random() - 0.5) * 2.0,
                                r: Math.random() * 2.5 + 0.8, alpha: 0.85 });
                        }
                    }
                    for (var i = c._drops.length - 1; i >= 0; i--) {
                        var d = c._drops[i];
                        d.y += d.vy; d.vy += 0.25; d.x += d.vx; d.alpha -= 0.03;
                        if (d.alpha <= 0) c._drops.splice(i, 1);
                    }
                    c.requestPaint();
                }
            }
        }
    }

    onFocusedChanged: {
        vsWaterCanvas._dir = fillDirection === "right" ? 1 : (fillDirection === "left" ? -1 : 0);
        vsWaterCanvas._target = focused ? 1.0 : 0.0;
        if (!focused) vsWaterCanvas._drops = [];
    }

    // Focus ring
    Rectangle {
        id: focusRing
        anchors.centerIn: parent
        width: parent.width + 10
        height: parent.height + 10
        radius: root.radius + 5
        color: "transparent"
        border.color: "#FFFFFF"
        border.width: 3
        opacity: root.focused ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    // Focus label (zoom-in dal basso quando focalizzato)
    Rectangle {
        id: vsFocusLabel
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height + 8
        width: Math.max(vsFocusLabelText.implicitWidth + 16, 40)
        height: screenMetrics ? Math.max(20, Math.min(26, Math.round(22 * screenMetrics.scaleRatio))) : 22
        radius: height / 2
        color: "#CC1a1a2e"
        border.color: "#66FFFFFF"
        border.width: 1
        transformOrigin: Item.Top
        scale: root.focused ? 1.0 : 0.0
        opacity: root.focused ? 1.0 : 0.0
        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutBack }
        }
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        Text {
            id: vsFocusLabelText
            anchors.centerIn: parent
            text: "View Mode"
            font.pixelSize: screenMetrics ? Math.max(10, Math.min(13, Math.round(11 * screenMetrics.scaleRatio))) : 11
            font.bold: true
            color: "white"
        }
    }

    // Content: Number + L1+R1 side by side
    Row {
        anchors.centerIn: parent
        spacing: 8

        // Carousel number
        Text {
            id: numberText
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (currentViewMode === "carousel1") return "1";
                if (currentViewMode === "carousel2") return "2";
                if (currentViewMode === "carousel3") return "3";
                if (currentViewMode === "carousel4") return "4";
                return "1";
            }
            font.pixelSize: screenMetrics ? screenMetrics.viewSwitcherFontLarge : 30
            font.bold: true
            color: root.focused ? "#1a1a1a" : "white"
            Behavior on color { ColorAnimation { duration: 300 } }

            Behavior on text {
                SequentialAnimation {
                    NumberAnimation {
                        target: root
                        property: "scale"
                        to: 0.85
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                    PropertyAction { target: numberText; property: "text" }
                    NumberAnimation {
                        target: root
                        property: "scale"
                        to: 1.0
                        duration: 100
                        easing.type: Easing.OutBack
                    }
                }
            }
        }

        // Separator
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: screenMetrics ? screenMetrics.viewSwitcherFontLarge : 30
            color: root.focused ? "#441a1a1a" : "#44FFFFFF"
            Behavior on color { ColorAnimation { duration: 300 } }
        }

        // L1+R1 label
        Text {
            id: badgeText
            anchors.verticalCenter: parent.verticalCenter
            text: "L1+R1"
            font.pixelSize: screenMetrics ? screenMetrics.viewSwitcherFontSmall : 14
            font.bold: true
            color: root.focused ? "#1a1a1a" : "white"
            opacity: 0.7
            Behavior on color { ColorAnimation { duration: 300 } }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            viewChanged("")
            scaleAnimation.restart()
        }
    }

    // Click animation
    SequentialAnimation {
        id: scaleAnimation
        NumberAnimation {
            target: root
            property: "scale"
            to: 0.9
            duration: 80
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root
            property: "scale"
            to: 1.0
            duration: 120
            easing.type: Easing.OutBack
        }
    }

    // Tooltip
    Rectangle {
        id: tooltip
        anchors.bottom: parent.top
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        width: tooltipText.width + 20
        height: 30
        radius: 5
        color: "#DD000000"
        border.color: "#60FFFFFF"
        border.width: 1
        opacity: mouseArea.containsMouse ? 1.0 : 0.0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: {
                if (currentViewMode === "carousel1") return T.t("vs_carousel1", root.lang);
                if (currentViewMode === "carousel2") return T.t("vs_carousel2", root.lang);
                if (currentViewMode === "carousel3") return T.t("vs_carousel3", root.lang);
                if (currentViewMode === "carousel4") return T.t("vs_carousel4", root.lang);
                return T.t("vs_carousel", root.lang);
            }
            color: "#FFFFFF"
            font.pixelSize: 12
        }
    }
}
