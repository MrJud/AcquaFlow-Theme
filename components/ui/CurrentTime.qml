import QtQuick 2.15
import ".."

Item {
    id: root

    property string timeString: ""
    property string ampmString: ""
    property var gameModel: null

    // Configurable properties (set from outside or loaded from api.memory)
    property bool use24h: true
    property int  fontIndex: 0
    property int  colorIndex: 1
    property bool fillMode: true
    property bool rainbow: false
    property int  settingsVersion: 0  // bump to force reload

    // Color palette (must match ClockSettingsPanel)
    readonly property var colorPalette: [
        { name: "Teal",    outline: "#1ABC9C" },
        { name: "Bianco",  outline: "#FFFFFF" },
        { name: "Azzurro", outline: "#5DADE2" },
        { name: "Viola",   outline: "#A569BD" },
        { name: "Rosa",    outline: "#EC7063" },
        { name: "Arancio", outline: "#F39C12" },
        { name: "Verde",   outline: "#2ECC71" },
        { name: "Rosso",   outline: "#E74C3C" },
        { name: "Oro",     outline: "#F1C40F" },
        { name: "Ciano",   outline: "#00BCD4" }
    ]

    // Rainbow animated colors (matches RetroAchievements hub panel borders — 3 offset phases)
    property color _borderAnim: "#58d8f0"
    SequentialAnimation {
        running: root.rainbow && root.visible
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "_borderAnim"; to: "#70b0f8"; duration: 1800; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#4060f0"; duration: 1400; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#2888f0"; duration: 1600; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#18b0d8"; duration: 2000; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#18c8a8"; duration: 1200; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#20a0e0"; duration: 1000; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#80a0f0"; duration: 1800; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#f0a0c8"; duration: 2200; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#d898e0"; duration: 1500; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#a8d0f0"; duration: 1000; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#58d8f0"; duration: 1800; easing.type: Easing.InOutSine   }
    }
    property color _borderAnim2: "#2090e0"
    SequentialAnimation {
        running: root.rainbow && root.visible
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#18c8a8"; duration: 2200; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#50d8f0"; duration: 1600; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#d898e0"; duration: 2000; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#f0a0c8"; duration: 1400; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#80a0f0"; duration: 1800; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#38b8d8"; duration: 1200; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#2090e0"; duration: 1600; easing.type: Easing.InOutCubic  }
    }
    property color _borderAnim3: "#20b8a0"
    SequentialAnimation {
        running: root.rainbow && root.visible
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#a8d0f0"; duration: 1800; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#e08050"; duration: 2400; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#40d8d0"; duration: 1600; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#70b0f8"; duration: 2000; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#f0a0c8"; duration: 1400; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#20b8a0"; duration: 1800; easing.type: Easing.InOutQuad   }
    }
    // Gradient rotation (slow continuous spin, same as RA Hub)
    property real _borderAngle: 0
    NumberAnimation {
        running: root.rainbow && root.visible
        target: root; property: "_borderAngle"
        loops: Animation.Infinite
        from: 0; to: 360; duration: 10000
    }
    // Glow breathing pulse
    property real _glowPulse: 0.0
    SequentialAnimation {
        running: root.rainbow && root.visible
        loops: Animation.Infinite
        NumberAnimation { target: root; property: "_glowPulse"; to: 1.0;  duration: 2400; easing.type: Easing.InOutSine }
        NumberAnimation { target: root; property: "_glowPulse"; to: 0.45; duration: 2800; easing.type: Easing.InOutSine }
        NumberAnimation { target: root; property: "_glowPulse"; to: 0.85; duration: 1800; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "_glowPulse"; to: 0.30; duration: 2200; easing.type: Easing.InOutSine }
    }

    property color _outlineColor: rainbow
        ? _borderAnim
        : colorPalette[Math.min(colorIndex, colorPalette.length - 1)].outline

    // Font Loaders
    FontLoader { id: font0; source: "../../assets/fonts/watch/Electrolize.ttf" }
    FontLoader { id: font1; source: "../../assets/fonts/watch/Rajdhani.ttf" }
    FontLoader { id: font2; source: "../../assets/fonts/watch/Audiowide.ttf" }
    FontLoader { id: font3; source: "../../assets/fonts/watch/Quantico.ttf" }
    FontLoader { id: font4; source: "../../assets/fonts/watch/Michroma.ttf" }
    FontLoader { id: font5; source: "../../assets/fonts/watch/ChakraPetch.ttf" }
    FontLoader { id: font6; source: "../../assets/fonts/watch/Bungee.ttf" }
    FontLoader { id: font7; source: "../../assets/fonts/watch/BlackOpsOne.ttf" }
    FontLoader { id: font8; source: "../../assets/fonts/watch/ShareTech.ttf" }
    FontLoader { id: font9; source: "../../assets/fonts/watch/VT323.ttf" }

    function getFontFamily(idx) {
        switch (idx) {
            case 0: return font0.name;
            case 1: return font1.name;
            case 2: return font2.name;
            case 3: return font3.name;
            case 4: return font4.name;
            case 5: return font5.name;
            case 6: return font6.name;
            case 7: return font7.name;
            case 8: return font8.name;
            case 9: return font9.name;
        }
        return font0.name;
    }

    property string _fontFamily: getFontFamily(fontIndex)

    Component.onCompleted: {
        loadSettings();
        updateTime();
        timeUpdateTimer.start();
    }

    onSettingsVersionChanged: loadSettings()

    function loadSettings() {
        var fmt = api.memory.get("clock_format");
        use24h = (fmt !== "12h");

        var fi = api.memory.get("clock_font_index");
        if (fi !== undefined && fi !== "" && !isNaN(parseInt(fi))) {
            var p = parseInt(fi);
            fontIndex = (p >= 0 && p < 10) ? p : 0;
        } else {
            fontIndex = 0;
        }
        _fontFamily = getFontFamily(fontIndex);

        var ci = api.memory.get("clock_color_index");
        if (ci !== undefined && ci !== "" && !isNaN(parseInt(ci))) {
            var pc = parseInt(ci);
            colorIndex = (pc >= 0 && pc < colorPalette.length) ? pc : 1;
        } else {
            colorIndex = 1;
        }
        var fm = api.memory.get("clock_fill_mode");
        fillMode = (fm === undefined || fm === "") ? true : (fm === "filled");

        var rb = api.memory.get("clock_rainbow");
        rainbow = (rb === "on");
    }

    function updateTime() {
        var now = new Date();
        var hours = now.getHours();
        var minutes = now.getMinutes();

        if (!use24h) {
            ampmString = hours >= 12 ? "PM" : "AM";
            hours = hours % 12;
            if (hours === 0) hours = 12;
            var formattedMinutes = minutes < 10 ? "0" + minutes : minutes;
            timeString = hours + ":" + formattedMinutes;
        } else {
            ampmString = "";
            var formattedHours24 = hours < 10 ? "0" + hours : hours;
            var formattedMinutes24 = minutes < 10 ? "0" + minutes : minutes;
            timeString = formattedHours24 + ":" + formattedMinutes24;
        }
    }

    Timer {
        id: timeUpdateTimer
        interval: 1000
        repeat: true
        onTriggered: root.updateTime()
    }

    // OUTLINE MODE (ShaderEffect alpha-mask technique)

    // Source: 8-direction expanded text for outline border
    Item {
        id: outlineSource
        anchors.fill: parent
        visible: false

        Repeater {
            model: [
                {dx:-1,dy:-1},{dx:0,dy:-1},{dx:1,dy:-1},
                {dx:-1,dy:0},              {dx:1,dy:0},
                {dx:-1,dy:1}, {dx:0,dy:1}, {dx:1,dy:1}
            ]
            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: modelData.dx
                anchors.verticalCenterOffset: modelData.dy
                text: root.timeString
                color: "white"
                font.pixelSize: 64
                font.bold: true
                font.family: root._fontFamily
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Mask: center text used to cut out the interior (alpha mask)
    Item {
        id: textMask
        anchors.fill: parent
        visible: false

        Text {
            anchors.centerIn: parent
            text: root.timeString
            color: "white"
            font.pixelSize: 64
            font.bold: true
            font.family: root._fontFamily
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Fill source: solid text for filled mode
    Item {
        id: fillSource
        anchors.fill: parent
        visible: false

        Text {
            anchors.centerIn: parent
            text: root.timeString
            color: "white"
            font.pixelSize: 64
            font.bold: true
            font.family: root._fontFamily
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // OUTLINE — non-rainbow: single color with alpha mask
    ShaderEffect {
        anchors.fill: parent
        visible: !root.fillMode && !root.rainbow
        property variant src: ShaderEffectSource { sourceItem: outlineSource }
        property variant msk: ShaderEffectSource { sourceItem: textMask }
        property color outlineCol: root._outlineColor
        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;
            uniform sampler2D src;
            uniform sampler2D msk;
            uniform lowp vec4 outlineCol;
            void main() {
                lowp float s = texture2D(src, qt_TexCoord0).a;
                lowp float m = texture2D(msk, qt_TexCoord0).a;
                gl_FragColor = outlineCol * s * (1.0 - m) * qt_Opacity;
            }
        "
    }

    // OUTLINE — rainbow: conical gradient with 3 colors + alpha mask
    ShaderEffect {
        anchors.fill: parent
        visible: !root.fillMode && root.rainbow
        property variant src: ShaderEffectSource { sourceItem: outlineSource }
        property variant msk: ShaderEffectSource { sourceItem: textMask }
        property color col1: root._borderAnim
        property color col2: root._borderAnim2
        property color col3: root._borderAnim3
        property real angle: root._borderAngle * 0.0174533  // degrees to radians
        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;
            uniform sampler2D src;
            uniform sampler2D msk;
            uniform lowp vec4 col1;
            uniform lowp vec4 col2;
            uniform lowp vec4 col3;
            uniform highp float angle;
            void main() {
                lowp float s = texture2D(src, qt_TexCoord0).a;
                lowp float m = texture2D(msk, qt_TexCoord0).a;
                highp vec2 center = qt_TexCoord0 - vec2(0.5);
                highp float a = atan(center.y, center.x) + angle;
                highp float t = fract(a / 6.2831853);
                lowp vec4 c;
                if (t < 0.333)
                    c = mix(col1, col2, t * 3.0);
                else if (t < 0.666)
                    c = mix(col2, col3, (t - 0.333) * 3.0);
                else
                    c = mix(col3, col1, (t - 0.666) * 3.0);
                gl_FragColor = c * s * (1.0 - m) * qt_Opacity;
            }
        "
    }

    // Semi-transparent interior text (outline mode)
    Text {
        visible: !root.fillMode
        anchors.centerIn: parent
        text: root.timeString
        color: "#33FFFFFF"
        font.pixelSize: 64
        font.bold: true
        font.family: root._fontFamily
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // FILLED — non-rainbow: solid color text
    Text {
        visible: root.fillMode && !root.rainbow
        anchors.centerIn: parent
        text: root.timeString
        color: root._outlineColor
        font.pixelSize: 64
        font.bold: true
        font.family: root._fontFamily
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // FILLED — rainbow: conical gradient on text
    ShaderEffect {
        anchors.fill: parent
        visible: root.fillMode && root.rainbow
        property variant src: ShaderEffectSource { sourceItem: fillSource }
        property color col1: root._borderAnim
        property color col2: root._borderAnim2
        property color col3: root._borderAnim3
        property real angle: root._borderAngle * 0.0174533
        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;
            uniform sampler2D src;
            uniform lowp vec4 col1;
            uniform lowp vec4 col2;
            uniform lowp vec4 col3;
            uniform highp float angle;
            void main() {
                lowp float s = texture2D(src, qt_TexCoord0).a;
                highp vec2 center = qt_TexCoord0 - vec2(0.5);
                highp float a = atan(center.y, center.x) + angle;
                highp float t = fract(a / 6.2831853);
                lowp vec4 c;
                if (t < 0.333)
                    c = mix(col1, col2, t * 3.0);
                else if (t < 0.666)
                    c = mix(col2, col3, (t - 0.333) * 3.0);
                else
                    c = mix(col3, col1, (t - 0.666) * 3.0);
                gl_FragColor = c * s * qt_Opacity;
            }
        "
    }

    // AM/PM

    Text {
        visible: !root.use24h && root.ampmString !== ""
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        anchors.topMargin: 28
        text: root.ampmString
        color: root._outlineColor
        opacity: 0.6
        font.pixelSize: 18
        font.bold: true
        font.family: root._fontFamily
        horizontalAlignment: Text.AlignHCenter
    }
}
