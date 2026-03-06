import QtQuick 2.15
import QtGraphicalEffects 1.15
import ".."

Rectangle {
    id: menuButton
    width: 80
    height: 80
    radius: 40

    // Customization properties
    property bool hovered: false
    property bool pressed: false
    property bool focused: false  // Focus property for navigation
    property string fillDirection: "bottom"  // "bottom", "left", "right"
    property color baseColor: "#2C3E50"
    property color hoverColor: "#34495E"
    property color pressedColor: "#E74C3C"
    property color focusColor: "#3498DB"  // Color for the cerchio di focus
    property color iconColor: "#ECF0F1"
    property real iconSize: 32
    property QtObject screenMetrics: null

    // Segnali
    signal clicked()
    signal pressAndHold()
    signal raLoginClicked()

    color: "transparent"
    border.width: 0
    border.color: "transparent"
    opacity: 0.9

    // Unified outline + fill (main circle + badge merged)
    Item {
        id: unifiedOverlay
        x: 0; y: 0
        width: parent.width + 6; height: parent.height + 6
        z: 0

        // Unified background fill
        Item {
            id: bgFillItem
            anchors.fill: parent
            layer.enabled: true

            Rectangle {
                x: 0; y: 0
                width: menuButton.width; height: menuButton.height; radius: menuButton.width / 2
                color: "transparent"
            }
            Rectangle {
                x: Math.round(menuButton.width * 0.66); y: Math.round(menuButton.height * 0.66)
                width: Math.round(menuButton.width * 0.375); height: Math.round(menuButton.height * 0.375); radius: Math.round(menuButton.width * 0.1875)
                color: "transparent"
            }
        }

        // Source: both circles filled with border color
        Item {
            id: shapeSource
            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                x: 0; y: 0
                width: menuButton.width; height: menuButton.height; radius: menuButton.width / 2
                color: "#3498DB"
            }
            Rectangle {
                x: Math.round(menuButton.width * 0.66); y: Math.round(menuButton.height * 0.66)
                width: Math.round(menuButton.width * 0.375); height: Math.round(menuButton.height * 0.375); radius: Math.round(menuButton.width * 0.1875)
                color: "#3498DB"
            }
        }

        // Mask: shrunk by 2px
        Item {
            id: shapeMask
            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                x: 2; y: 2
                width: menuButton.width - 4; height: menuButton.height - 4; radius: (menuButton.width - 4) / 2
                color: "white"
            }
            Rectangle {
                x: Math.round(menuButton.width * 0.66) + 2; y: Math.round(menuButton.height * 0.66) + 2
                width: Math.round(menuButton.width * 0.375) - 4; height: Math.round(menuButton.height * 0.375) - 4; radius: (Math.round(menuButton.width * 0.375) - 4) / 2
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
        id: menuWaterFillContainer
        anchors.fill: parent
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: menuButton.width
                height: menuButton.height
                radius: menuButton.radius
            }
        }
        Canvas {
            id: menuWaterCanvas
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
                ctx.fillStyle = "#CC3498DB";
                ctx.fill();
                for (var i = 0; i < _drops.length; i++) {
                    var d = _drops[i];
                    ctx.globalAlpha = Math.max(0, d.alpha);
                    ctx.beginPath();
                    ctx.arc(d.x, d.y, d.r, 0, Math.PI * 2);
                    ctx.fillStyle = "#3498DB";
                    ctx.fill();
                }
                ctx.globalAlpha = 1.0;
            }
            Timer {
                interval: 16; repeat: true
                running: menuWaterCanvas._level > 0.005 || menuWaterCanvas._target > 0.5
                onTriggered: {
                    var c = menuWaterCanvas;
                    var diff = c._target - c._level;
                    c._velocity = c._velocity * 0.95 + diff * 0.035;
                    c._level = Math.max(0, Math.min(1, c._level + c._velocity));
                    c._wavePhase = (c._wavePhase + 0.07) % (Math.PI * 2);
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
        menuWaterCanvas._dir = fillDirection === "right" ? 1 : (fillDirection === "left" ? -1 : 0);
        menuWaterCanvas._target = focused ? 1.0 : 0.0;
        if (!focused) menuWaterCanvas._drops = [];
    }

    // Focus circle (visible when button is focused)
    Rectangle {
        id: focusRing
        anchors.centerIn: parent
        width: parent.width + 10
        height: parent.height + 10
        radius: width / 2
        color: "transparent"
        border.color: menuButton.focusColor
        border.width: 3
        opacity: menuButton.focused ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    // Focus label (zoom-in dal basso quando focalizzato)
    Rectangle {
        id: menuFocusLabel
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height + 8
        width: Math.max(menuFocusLabelText.implicitWidth + 16, 40)
        height: screenMetrics ? Math.max(20, Math.min(26, Math.round(22 * screenMetrics.scaleRatio))) : 22
        radius: height / 2
        color: "#CC1a1a2e"
        border.color: "#66FFFFFF"
        border.width: 1
        transformOrigin: Item.Top
        scale: menuButton.focused ? 1.0 : 0.0
        opacity: menuButton.focused ? 1.0 : 0.0
        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutBack }
        }
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        Text {
            id: menuFocusLabelText
            anchors.centerIn: parent
            text: "Menu"
            font.pixelSize: screenMetrics ? Math.max(10, Math.min(13, Math.round(11 * screenMetrics.scaleRatio))) : 11
            font.bold: true
            color: "white"
        }
    }

    Item {
        id: menuIcon
        anchors.centerIn: parent
        width: iconSize
        height: iconSize

        Rectangle {
            id: line1
            width: iconSize * 0.8
            height: 2.5
            color: iconColor
            radius: 1
            anchors.horizontalCenter: parent.horizontalCenter
            y: pressed ? (iconSize * 0.4) : (iconSize * 0.2)
            rotation: pressed ? 45 : 0
        }

        // Seconda linea
        Rectangle {
            id: line2
            width: iconSize * 0.8
            height: 2.5
            color: iconColor
            radius: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            opacity: pressed ? 0 : 1
        }

        // Terza linea
        Rectangle {
            id: line3
            width: iconSize * 0.8
            height: 2.5
            color: iconColor
            radius: 1
            anchors.horizontalCenter: parent.horizontalCenter
            y: pressed ? (iconSize * 0.4) : (iconSize * 0.8 - 2.5)
            rotation: pressed ? -45 : 0
        }

        // Animation dell'icona
        scale: menuButton.pressed ? 0.9 : (menuButton.hovered ? 1.1 : 1.0)
    }

    // Mouse input area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: menuButton.hovered = true
        onExited: menuButton.hovered = false
        onPressed: menuButton.pressed = true
        onReleased: menuButton.pressed = false
        onClicked: {
            menuButton.clicked()
        }
        onPressAndHold: menuButton.pressAndHold()
    }

    // Badge (filled square = Select) text only, outline by unifiedOverlay
    Item {
        x: Math.round(menuButton.width * 0.66); y: Math.round(menuButton.height * 0.66)
        width: Math.round(menuButton.width * 0.375); height: Math.round(menuButton.height * 0.375)
        z: 2
        Rectangle {
            anchors.centerIn: parent
            width: Math.round(menuButton.width * 0.125); height: Math.round(menuButton.width * 0.125)
            radius: 1
            color: "white"
        }
    }

    // Animation di comparsa semplificata
    Component.onCompleted: {
        opacity = 0
        scale = 0.5
        opacityAnimation.start()
        scaleAnimation.start()
    }

    NumberAnimation {
        id: opacityAnimation
        target: menuButton
        property: "opacity"
        from: 0
        to: 0.9
        duration: 300
    }

    NumberAnimation {
        id: scaleAnimation
        target: menuButton
        property: "scale"
        from: 0.5
        to: 1.0
        duration: 300
    }
}
