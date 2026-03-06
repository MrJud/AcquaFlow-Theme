import QtQuick 2.15
import ".."
import QtGraphicalEffects 1.15
import "../../utils.js" as Utils
import "../config/GameCardConfig.js" as Config
import "../config/Translations.js" as T

Item {
    id: gameActionPanelRoot
    anchors.fill: parent
    visible: false
    z: 9999
    focus: visible

    property string lang: "it"
    property var game: null
    property int currentButton: 0
    property bool showDescription: false
    property var platformBarRef: null
    property var playtimeTracker: null
    property string currentPlatform: ""
    property QtObject raServiceRef: null  // Explicit RA service reference (passed from CoverFlow)
    property int _favVersion: 0  // Bumped after favourite toggle to force binding re-eval

    // Reactive screen dimensions — passed to Config layout functions so bindings
    // re-evaluate automatically on any resolution, without relying on the JS module vars.
    readonly property real _sw: width
    readonly property real _sh: height

    // Expose internal panel items for theme.qml Select toggle
    property alias statsPanel: playStatsPanel
    property alias raBarAnimRef: raBarAnim
    property alias raBarFillRef: raBarFill
    property alias playTimeBarAnimRef: playTimeBarAnim
    property alias playTimeBarFillRef: playTimeBarFill

    function bounceSelectIcon() { selectIconRoot.bounce(); }

    // Direct favourite animation trigger — called from CoverFlow after toggleFavourite
    function applyFavouriteState(isFav) {
        _favVersion++;
        // Directly drive the animation (binding re-eval is unreliable in V4)
        favFillAnim.stop();
        if (isFav) {
            favFillAnim.from = favIconRoot._fillLevel; favFillAnim.to = 1;
        } else {
            favFillAnim.from = favIconRoot._fillLevel; favFillAnim.to = 0;
        }
        favFillAnim.start();
        favHeartbeatAnim.restart();
        favHeartCanvas.requestPaint();
    }

    signal playClicked(var game)
    signal detailsClicked(var game)
    signal favouriteClicked(var game)
    signal closed()

    onVisibleChanged: {
        if (visible) {
            Config.setScreenDimensions(parent.width, parent.height);
            currentButton = 0;
            playButtonScope.focus = true;
        }
    }

    Component.onCompleted: {
        Config.setScreenDimensions(parent.width, parent.height);
    }

    Item {
        id: contentContainer
        anchors.fill: parent
        width: parent.width
        height: parent.height

        Item {
            id: elementsContainer
            width: Config.getContainerSize(_sw, _sh).width
            height: Config.getContainerSize(_sw, _sh).height
            x: Config.getContainerPosition(_sw, _sh).x
            y: Config.getContainerPosition(_sw, _sh).y

            Item {
                id: logoContainer
                width: Config.getLogoSize(_sw, _sh).width
                height: Config.getLogoSize(_sw, _sh).height
                x: Config.getLogoPosition(_sw, _sh).x
                y: Config.getLogoPosition(_sw, _sh).y

            Image {
                id: gameLogo
                anchors.fill: parent
                visible: source !== ""
                fillMode: Image.PreserveAspectFit
                source: game ? Utils.getGameLogo(game) : ""
                opacity: 0.0
                scale: Config.getLogoScale()

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                }

                onStatusChanged: {
                    if (status === Image.Ready && visible) {
                        opacity = 1.0;
                    } else if (status === Image.Error || !visible) {
                        opacity = 0.0;
                    }
                }

                onVisibleChanged: {
                    if (visible && status === Image.Ready) {
                        opacity = 1.0;
                    } else {
                        opacity = 0.0;
                    }
                }
            }

            // Fallback: show title if logo unavailable
            Text {
                id: titleFallback
                anchors.centerIn: parent
                visible: gameLogo.source === "" || gameLogo.status === Image.Error
                text: game ? game.title || T.t("gc_unknown_game", gameActionPanelRoot.lang) : ""
                color: "white"
                font.pixelSize: 16
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width * 0.9
            }
        }

            // Last played (visible only when description is NOT shown)
            Item {
                id: lastPlayedContainer
                width: Config.getLastPlayedSize(_sw, _sh).width
                height: Math.max(Config.getLastPlayedConfig().labelFontSize, Config.getLastPlayedConfig().valueFontSize) + (Config.getLastPlayedConfig().backgroundPaddingY * 2)
                x: Config.getLastPlayedPosition(_sw, _sh).x
                y: Config.getLastPlayedPosition(_sw, _sh).y
                visible: !gameActionPanelRoot.showDescription
                opacity: 0.0

                Rectangle {
                    id: lastPlayedBackground
                    width: lastPlayedLabel.contentWidth + Config.getLastPlayedConfig().spacing + lastPlayedValue.contentWidth + (Config.getLastPlayedConfig().backgroundPaddingX * 2)
                    height: Math.max(lastPlayedLabel.contentHeight, lastPlayedValue.contentHeight) + (Config.getLastPlayedConfig().backgroundPaddingY * 2)
                    color: Config.getLastPlayedConfig().backgroundColor
                    opacity: Config.getLastPlayedConfig().backgroundOpacity
                    radius: Config.getLastPlayedConfig().backgroundRadius

                    x: Config.getLastPlayedConfig().alignment === "center" ? (parent.width - width) / 2 :
                       Config.getLastPlayedConfig().alignment === "right" ? parent.width - width : 0
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    id: textContainer
                    width: lastPlayedLabel.contentWidth + Config.getLastPlayedConfig().spacing + lastPlayedValue.contentWidth
                    height: Math.max(lastPlayedLabel.contentHeight, lastPlayedValue.contentHeight)

                    x: Config.getLastPlayedConfig().alignment === "center" ? (parent.width - width) / 2 :
                       Config.getLastPlayedConfig().alignment === "right" ? parent.width - width : 0
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: lastPlayedLabel
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: T.t("gc_lastplayed_label", gameActionPanelRoot.lang)
                        color: Config.getLastPlayedConfig().labelColor
                        font.pixelSize: Config.getLastPlayedConfig().labelFontSize
                        font.weight: Config.getLastPlayedConfig().labelWeight === "Bold" ? Font.Bold : Font.Normal
                        font.family: "Arial"
                        opacity: Config.getLastPlayedConfig().labelOpacity
                    }

                    Text {
                        id: lastPlayedValue
                        anchors.left: lastPlayedLabel.right
                        anchors.leftMargin: Config.getLastPlayedConfig().spacing
                        anchors.verticalCenter: parent.verticalCenter
                        text: game ? Utils.formatLastPlayed(game, T.t("gc_never", gameActionPanelRoot.lang), gameActionPanelRoot.lang) : T.t("gc_never", gameActionPanelRoot.lang)
                        color: Config.getLastPlayedConfig().valueColor
                        font.pixelSize: Config.getLastPlayedConfig().valueFontSize
                        font.weight: Config.getLastPlayedConfig().valueWeight === "Bold" ? Font.Bold : Font.Normal
                        font.family: "Arial"
                        opacity: Config.getLastPlayedConfig().valueOpacity
                    }
                }

                NumberAnimation {
                    id: lastPlayedFadeInAnimation
                    target: lastPlayedContainer
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: Config.getLastPlayedConfig().fadeInDuration
                    easing.type: Config.getLastPlayedConfig().fadeInEasing === "OutQuad" ? Easing.OutQuad :
                                Config.getLastPlayedConfig().fadeInEasing === "OutCubic" ? Easing.OutCubic :
                                Config.getLastPlayedConfig().fadeInEasing === "OutExpo" ? Easing.OutExpo : Easing.OutQuad
                    running: false
                }

                NumberAnimation {
                    id: lastPlayedFadeOutAnimation
                    target: lastPlayedContainer
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: Config.getLastPlayedConfig().fadeOutDuration
                    easing.type: Config.getLastPlayedConfig().fadeOutEasing === "InQuad" ? Easing.InQuad :
                                Config.getLastPlayedConfig().fadeOutEasing === "InCubic" ? Easing.InCubic :
                                Config.getLastPlayedConfig().fadeOutEasing === "InExpo" ? Easing.InExpo : Easing.InQuad
                    running: false
                }

                onVisibleChanged: {
                    if (visible) {
                        lastPlayedFadeOutAnimation.stop();
                        lastPlayedFadeInAnimation.start();
                    } else {
                        lastPlayedFadeInAnimation.stop();
                        lastPlayedFadeOutAnimation.start();
                    }
                }
            }

            // Game developer (visible only when description is NOT shown)
            Item {
                id: developerContainer
                width: Config.getDeveloperSize(_sw, _sh).width
                height: Math.max(Config.getDeveloperConfig().labelFontSize, Config.getDeveloperConfig().valueFontSize) + (Config.getDeveloperConfig().backgroundPaddingY * 2)
                x: Config.getDeveloperPosition(_sw, _sh).x
                y: Config.getDeveloperPosition(_sw, _sh).y
                visible: !gameActionPanelRoot.showDescription
                opacity: 0.0

                Rectangle {
                    id: developerBackground
                    width: developerLabel.contentWidth + Config.getDeveloperConfig().spacing + developerValue.contentWidth + (Config.getDeveloperConfig().backgroundPaddingX * 2)
                    height: Math.max(developerLabel.contentHeight, developerValue.contentHeight) + (Config.getDeveloperConfig().backgroundPaddingY * 2)
                    color: Config.getDeveloperConfig().backgroundColor
                    opacity: Config.getDeveloperConfig().backgroundOpacity
                    radius: Config.getDeveloperConfig().backgroundRadius

                    x: Config.getDeveloperConfig().alignment === "center" ? (parent.width - width) / 2 :
                       Config.getDeveloperConfig().alignment === "right" ? parent.width - width : 0
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    id: developerTextContainer
                    width: developerLabel.contentWidth + Config.getDeveloperConfig().spacing + developerValue.contentWidth
                    height: Math.max(developerLabel.contentHeight, developerValue.contentHeight)

                    x: Config.getDeveloperConfig().alignment === "center" ? (parent.width - width) / 2 :
                       Config.getDeveloperConfig().alignment === "right" ? parent.width - width : 0
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: developerLabel
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: T.t("gc_dev_label", gameActionPanelRoot.lang)
                        color: Config.getDeveloperConfig().labelColor
                        font.pixelSize: Config.getDeveloperConfig().labelFontSize
                        font.weight: Config.getDeveloperConfig().labelWeight === "Bold" ? Font.Bold : Font.Normal
                        font.family: "Arial"
                        opacity: Config.getDeveloperConfig().labelOpacity
                    }

                    Text {
                        id: developerValue
                        anchors.left: developerLabel.right
                        anchors.leftMargin: Config.getDeveloperConfig().spacing
                        anchors.verticalCenter: parent.verticalCenter
                        text: game ? Utils.formatDeveloper(game, T.t("gc_unknown", gameActionPanelRoot.lang)) : T.t("gc_unknown", gameActionPanelRoot.lang)
                        color: Config.getDeveloperConfig().valueColor
                        font.pixelSize: Config.getDeveloperConfig().valueFontSize
                        font.weight: Config.getDeveloperConfig().valueWeight === "Bold" ? Font.Bold : Font.Normal
                        font.family: "Arial"
                        opacity: Config.getDeveloperConfig().valueOpacity
                    }
                }

                NumberAnimation {
                    id: developerFadeInAnimation
                    target: developerContainer
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: Config.getDeveloperConfig().fadeInDuration
                    easing.type: Config.getDeveloperConfig().fadeInEasing === "OutQuad" ? Easing.OutQuad :
                                Config.getDeveloperConfig().fadeInEasing === "OutCubic" ? Easing.OutCubic :
                                Config.getDeveloperConfig().fadeInEasing === "OutExpo" ? Easing.OutExpo : Easing.OutQuad
                    running: false
                }

                NumberAnimation {
                    id: developerFadeOutAnimation
                    target: developerContainer
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: Config.getDeveloperConfig().fadeOutDuration
                    easing.type: Config.getDeveloperConfig().fadeOutEasing === "InQuad" ? Easing.InQuad :
                                Config.getDeveloperConfig().fadeOutEasing === "InCubic" ? Easing.InCubic :
                                Config.getDeveloperConfig().fadeOutEasing === "InExpo" ? Easing.InExpo : Easing.InQuad
                    running: false
                }

                onVisibleChanged: {
                    if (visible) {
                        developerFadeOutAnimation.stop();
                        developerFadeInAnimation.start();
                    } else {
                        developerFadeInAnimation.stop();
                        developerFadeOutAnimation.start();
                    }
                }
            }

            // Game genre (visible only when description is NOT shown)
            Item {
                id: genreContainer
                width: Config.getGenreSize(_sw, _sh).width
                height: Config.getGenreConfig().fontSize + (Config.getGenreConfig().backgroundPaddingY * 2)
                x: Config.getGenrePosition(_sw, _sh).x
                y: Config.getGenrePosition(_sw, _sh).y
                visible: !gameActionPanelRoot.showDescription
                opacity: 0.0

                Rectangle {
                    id: genreBackground
                    width: Config.getGenreConfig().fixedWidth
                    height: genreValue.contentHeight + (Config.getGenreConfig().backgroundPaddingY * 2)
                    color: Config.getGenreConfig().backgroundColor
                    opacity: Config.getGenreConfig().backgroundOpacity
                    radius: Config.getGenreConfig().backgroundRadius

                    x: Config.getGenreConfig().alignment === "center" ? (parent.width - width) / 2 :
                       Config.getGenreConfig().alignment === "right" ? parent.width - width : 0
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    id: genreTextContainer
                    width: Config.getGenreConfig().fixedWidth - (Config.getGenreConfig().backgroundPaddingX * 2)
                    height: genreValue.contentHeight
                    clip: true

                    x: (Config.getGenreConfig().alignment === "center" ? (parent.width - Config.getGenreConfig().fixedWidth) / 2 :
                        Config.getGenreConfig().alignment === "right" ? parent.width - Config.getGenreConfig().fixedWidth : 0) + Config.getGenreConfig().backgroundPaddingX
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: genreValue
                        x: 0
                        anchors.verticalCenter: parent.verticalCenter
                        text: game ? Utils.formatGenre(game, T.t("gc_unknown", gameActionPanelRoot.lang), Config.getGenreConfig().maxGenres, Config.getGenreConfig().separator) : T.t("gc_unknown", gameActionPanelRoot.lang)
                        color: Config.getGenreConfig().color
                        font.pixelSize: Config.getGenreConfig().fontSize
                        font.weight: Config.getGenreConfig().weight === "Bold" ? Font.Bold : Font.Normal
                        font.family: "Arial"
                        opacity: Config.getGenreConfig().opacity

                        // Horizontal scroll animation when text is too long
                        SequentialAnimation {
                            id: genreScrollAnimation
                            running: false
                            loops: Animation.Infinite

                            PauseAnimation {
                                duration: Config.getGenreConfig().scrollPause
                            }

                            NumberAnimation {
                                target: genreValue
                                property: "x"
                                from: 0
                                to: genreValue.contentWidth > genreTextContainer.width ? -(genreValue.contentWidth - genreTextContainer.width) : 0
                                duration: genreValue.contentWidth > genreTextContainer.width ?
                                         Math.max(0, (genreValue.contentWidth - genreTextContainer.width) * 1000 / Config.getGenreConfig().scrollSpeed) : 0
                                easing.type: Easing.Linear
                            }

                            PauseAnimation {
                                duration: Config.getGenreConfig().scrollPause
                            }

                            NumberAnimation {
                                target: genreValue
                                property: "x"
                                from: genreValue.contentWidth > genreTextContainer.width ? -(genreValue.contentWidth - genreTextContainer.width) : 0
                                to: 0
                                duration: genreValue.contentWidth > genreTextContainer.width && Config.getGenreConfig().scrollReturn ?
                                         Math.max(0, (genreValue.contentWidth - genreTextContainer.width) * 1000 / Config.getGenreConfig().scrollSpeed) : 0
                                easing.type: Easing.Linear
                            }
                        }

                        onTextChanged: {
                            genreScrollAnimation.stop();
                            if (contentWidth > genreTextContainer.width) {
                                genreScrollAnimation.start();
                            }
                        }
                    }
                }

                NumberAnimation {
                    id: genreFadeInAnimation
                    target: genreContainer
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: Config.getGenreConfig().fadeInDuration
                    easing.type: Config.getGenreConfig().fadeInEasing === "OutQuad" ? Easing.OutQuad :
                                Config.getGenreConfig().fadeInEasing === "OutCubic" ? Easing.OutCubic :
                                Config.getGenreConfig().fadeInEasing === "OutExpo" ? Easing.OutExpo : Easing.OutQuad
                    running: false
                }

                NumberAnimation {
                    id: genreFadeOutAnimation
                    target: genreContainer
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: Config.getGenreConfig().fadeOutDuration
                    easing.type: Config.getGenreConfig().fadeOutEasing === "InQuad" ? Easing.InQuad :
                                Config.getGenreConfig().fadeOutEasing === "InCubic" ? Easing.InCubic :
                                Config.getGenreConfig().fadeOutEasing === "InExpo" ? Easing.InExpo : Easing.InQuad
                    running: false
                }

                onVisibleChanged: {
                    if (visible) {
                        genreFadeOutAnimation.stop();
                        genreFadeInAnimation.start();
                    } else {
                        genreFadeInAnimation.stop();
                        genreFadeOutAnimation.start();
                    }
                }
            }

            // Stats Panel (switchable: PlayStats / RetroAchievements)
            Item {
                id: playStatsPanel
                width: elementsContainer.width * 0.80
                height: elementsContainer.height * 0.32
                x: (elementsContainer.width - width) / 2
                y: elementsContainer.height * 0.43
                visible: !gameActionPanelRoot.showDescription
                opacity: 0.0

                // 0 = Play Stats, 1 = RetroAchievements
                property int panelPage: 0

                // Smooth 3-color flow per game
                property color accentColor: color1
                property color color1: "#FFD700"
                property color color2: "#FF6B6B"
                property color color3: "#4FC3F7"
                property real _phase: 0.0  // 0..3 continuous phase

                function _hashStr(s) {
                    var h = 0;
                    for (var i = 0; i < s.length; i++) {
                        h = ((h << 5) - h + s.charCodeAt(i)) | 0;
                    }
                    return Math.abs(h);
                }

                function _hsvToColor(h, s, v) {
                    var c = v * s;
                    var x = c * (1 - Math.abs((h / 60) % 2 - 1));
                    var m = v - c;
                    var r, g, b;
                    if (h < 60)       { r = c; g = x; b = 0; }
                    else if (h < 120) { r = x; g = c; b = 0; }
                    else if (h < 180) { r = 0; g = c; b = x; }
                    else if (h < 240) { r = 0; g = x; b = c; }
                    else if (h < 300) { r = x; g = 0; b = c; }
                    else              { r = c; g = 0; b = x; }
                    var ri = Math.round((r + m) * 255);
                    var gi = Math.round((g + m) * 255);
                    var bi = Math.round((b + m) * 255);
                    return Qt.rgba(ri / 255, gi / 255, bi / 255, 1.0);
                }

                function _lerpColor(a, b, t) {
                    return Qt.rgba(
                        a.r + (b.r - a.r) * t,
                        a.g + (b.g - a.g) * t,
                        a.b + (b.b - a.b) * t,
                        1.0
                    );
                }

                function _smoothStep(t) {
                    // Hermite smooth interpolation for organic feel
                    return t * t * (3.0 - 2.0 * t);
                }

                function _updateAccent() {
                    var p = _phase % 3.0;
                    var segment = Math.floor(p);
                    var t = _smoothStep(p - segment);
                    if (segment === 0)
                        accentColor = _lerpColor(color1, color2, t);
                    else if (segment === 1)
                        accentColor = _lerpColor(color2, color3, t);
                    else
                        accentColor = _lerpColor(color3, color1, t);
                }

                function generateGameColors() {
                    var title = game ? (game.title || "default") : "default";
                    var seed = _hashStr(title);
                    var h1 = (seed * 137) % 360;
                    var h2 = (h1 + 110 + (seed % 40)) % 360;
                    var h3 = (h2 + 110 + ((seed >> 4) % 40)) % 360;
                    color1 = _hsvToColor(h1, 0.85, 1.0);
                    color2 = _hsvToColor(h2, 0.85, 1.0);
                    color3 = _hsvToColor(h3, 0.85, 1.0);
                    _phase = 0.0;
                    accentColor = color1;
                }

                Connections {
                    target: gameActionPanelRoot
                    function onGameChanged() { playStatsPanel.generateGameColors(); }
                }

                // Continuous smooth animation driven by NumberAnimation on _phase
                NumberAnimation on _phase {
                    id: colorFlowAnim
                    from: 0.0; to: 3.0
                    duration: 6000  // full cycle 6 seconds
                    loops: Animation.Infinite
                    running: playStatsPanel.visible && playStatsPanel.opacity > 0
                }
                on_PhaseChanged: _updateAccent()

                // Blurred background rectangle
                Rectangle {
                    id: statsBg
                    anchors.fill: parent
                    radius: 16
                    color: "#1A000000"

                    // Inner subtle gradient overlay
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#12FFFFFF" }
                            GradientStop { position: 1.0; color: "#05FFFFFF" }
                        }
                    }
                }

                // Content — Play Stats page (mirrors RA panel layout)
                Item {
                    id: playStatsContent
                    anchors.fill: parent
                    anchors.margins: 14
                    visible: playStatsPanel.panelPage === 0
                    opacity: visible ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 250 } }

                    // Big play time at top center
                    Text {
                        id: playTimeBig
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            if (!game) return "0m";
                            var tracked = gameActionPanelRoot.playtimeTracker
                                ? gameActionPanelRoot.playtimeTracker.getPlayTime(game) : 0;
                            var builtin = game.playTime || 0;
                            var totalSec = Math.max(tracked, builtin);
                            var h = Math.floor(totalSec / 3600);
                            var m = Math.floor((totalSec % 3600) / 60);
                            if (h > 0) return h + "h " + m + "m";
                            if (m > 0) return m + "m";
                            if (totalSec > 0) return "<1m";
                            return "0m";
                        }
                        color: "#FFFFFF"
                        font.pixelSize: 48
                        font.bold: true
                        font.family: "Arial"
                    }

                    // Progress bar below big number
                    Rectangle {
                        id: playTimeBarBg
                        anchors.top: playTimeBig.bottom
                        anchors.topMargin: 10
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 14
                        radius: 7
                        color: "#33FFFFFF"

                        property real maxHours: 30
                        property real playHours: {
                            var tracked = gameActionPanelRoot.playtimeTracker
                                ? gameActionPanelRoot.playtimeTracker.getPlayTime(game) : 0;
                            var builtin = game ? (game.playTime || 0) : 0;
                            return Math.max(tracked, builtin) / 3600;
                        }
                        property real barValue: Math.min(1.0, playHours / maxHours)

                        Rectangle {
                            id: playTimeBarFill
                            width: 0
                            height: parent.height
                            radius: 7
                            color: playStatsPanel.accentColor

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: playStatsPanel.accentColor }
                                    GradientStop { position: 0.6; color: Qt.lighter(playStatsPanel.accentColor, 1.15) }
                                    GradientStop { position: 1.0; color: Qt.darker(playStatsPanel.accentColor, 1.2) }
                                }
                            }

                            NumberAnimation {
                                id: playTimeBarAnim
                                target: playTimeBarFill
                                property: "width"
                                from: 0
                                to: playTimeBarBg.width * playTimeBarBg.barValue
                                duration: 800
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    // "Play Time" label below bar
                    Text {
                        id: playTimeSubLabel
                        anchors.top: playTimeBarBg.bottom
                        anchors.topMargin: 6
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: T.t("gc_playtime", gameActionPanelRoot.lang)
                        color: "#AAAAAA"
                        font.pixelSize: 16
                        font.family: "Arial"
                    }

                    // Rating stars centered below label with big gap
                    Item {
                        id: starsContainer
                        anchors.top: playTimeSubLabel.bottom
                        anchors.topMargin: 50
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: starsRow.width + ratingText.width + 10
                        height: 36

                        Row {
                            id: starsRow
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            property real ratingValue: game ? (game.rating || 0) : 0
                            property int fullStars: Math.floor(ratingValue * 5)
                            property bool halfStar: (ratingValue * 5 - fullStars) >= 0.25

                            Repeater {
                                model: 5
                                Canvas {
                                    width: 32; height: 32
                                    property int starIndex: index
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.clearRect(0, 0, width, height);
                                        var cx = width / 2, cy = height / 2;
                                        var outerR = 14, innerR = 6;

                                        ctx.beginPath();
                                        for (var i = 0; i < 10; i++) {
                                            var r = (i % 2 === 0) ? outerR : innerR;
                                            var angle = -Math.PI / 2 + i * Math.PI / 5;
                                            var px = cx + Math.cos(angle) * r;
                                            var py = cy + Math.sin(angle) * r;
                                            if (i === 0) ctx.moveTo(px, py);
                                            else ctx.lineTo(px, py);
                                        }
                                        ctx.closePath();

                                        if (starIndex < starsRow.fullStars) {
                                            ctx.fillStyle = "#FFD700";
                                        } else if (starIndex === starsRow.fullStars && starsRow.halfStar) {
                                            ctx.fillStyle = "#80FFD700";
                                        } else {
                                            ctx.fillStyle = "#44FFFFFF";
                                        }
                                        ctx.fill();
                                        ctx.strokeStyle = "#FFD700";
                                        ctx.lineWidth = 1;
                                        ctx.stroke();
                                    }
                                    Component.onCompleted: requestPaint()
                                    Connections {
                                        target: gameActionPanelRoot
                                        function onGameChanged() { requestPaint(); }
                                    }
                                }
                            }
                        }

                        Text {
                            id: ratingText
                            anchors.left: starsRow.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: game && game.rating ? (game.rating * 5).toFixed(1) + "/5" : T.t("gc_na", gameActionPanelRoot.lang)
                            color: "#FFD700"
                            font.pixelSize: 22
                            font.bold: true
                            font.family: "Arial"
                        }
                    }

                    // "L1 + R1 for more" hint
                    Row {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6

                        Rectangle {
                            width: 32; height: 20; radius: 4
                            color: "#33FFFFFF"
                            border.width: 1
                            border.color: "#55FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: "L1"; color: "#CCFFFFFF"
                                font.pixelSize: 11; font.bold: true; font.family: "Arial"
                            }
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "+"; color: "#77FFFFFF"
                            font.pixelSize: 13; font.bold: true; font.family: "Arial"
                        }
                        Rectangle {
                            width: 32; height: 20; radius: 4
                            color: "#33FFFFFF"
                            border.width: 1
                            border.color: "#55FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: "R1"; color: "#CCFFFFFF"
                                font.pixelSize: 11; font.bold: true; font.family: "Arial"
                            }
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: T.t("gc_for_more", gameActionPanelRoot.lang); color: "#77FFFFFF"
                            font.pixelSize: 12; font.family: "Arial"
                        }
                    }
                }

                // RetroAchievements page
                Item {
                    id: raPageContent
                    anchors.fill: parent
                    anchors.margins: 14
                    visible: playStatsPanel.panelPage === 1
                    opacity: visible ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 250 } }

                    // RA data — updated imperatively via Connections signal handlers.
                    // Bypasses V4 binding engine entirely to avoid sub-property tracking issues.
                    property var _detail: null
                    property int awarded: 0
                    property int total: 0
                    property real pct: 0
                    property var achList: []
                    property bool raLoading: false
                    property bool raError: false

                    // Imperative refresh — reads current state directly from RAService
                    function _refreshRaData() {
                        var svc = gameActionPanelRoot.raServiceRef;
                        if (!svc) {
                            _detail = null; awarded = 0; total = 0; pct = 0;
                            achList = []; raLoading = false; raError = false;
                            return;
                        }
                        var d = svc.gameDetail || null;
                        var newAwarded = d ? (d.numAwarded || 0) : 0;
                        var newTotal   = d ? (d.numAchievements || 0) : 0;
                        var newPct     = newTotal > 0 ? newAwarded / newTotal : 0;
                        _detail   = d;
                        awarded   = newAwarded;
                        total     = newTotal;
                        pct       = newPct;
                        achList   = svc.gameAchievements || [];
                        raLoading = svc.detailLoading || false;
                        raError   = svc.detailError || false;
                        console.log("[GameCard-RA] _refreshRaData: " +
                                    (d ? d.title : "null") + " " +
                                    newAwarded + "/" + newTotal + " (" +
                                    Math.round(newPct * 100) + "%)");
                    }

                    // Listen to RAService signals directly — imperative, no bindings
                    Connections {
                        target: gameActionPanelRoot.raServiceRef
                        function onGameDetailChanged()       { raPageContent._refreshRaData() }
                        function onGameAchievementsChanged()  { raPageContent._refreshRaData() }
                        function onDetailLoadingChanged()     { raPageContent._refreshRaData() }
                        function onDetailErrorChanged()       { raPageContent._refreshRaData() }
                    }

                    // When RA data arrives, replay the progress bar animation.
                    onPctChanged: {
                        if (playStatsPanel.panelPage === 1 && gameActionPanelRoot.visible) {
                            raBarAnim.stop();
                            raBarFill.width = 0;
                            if (pct > 0) {
                                raBarAnim.start();
                            }
                        }
                    }

                    // Big percentage at top center
                    Text {
                        id: raBigPct
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: raPageContent.total > 0 ? Math.round(raPageContent.pct * 100) + "%" : "—"
                        color: "#FFFFFF"
                        font.pixelSize: 48
                        font.bold: true
                        font.family: "Arial"
                    }

                    // Progress bar below percentage
                    Rectangle {
                        id: raBarBg
                        anchors.top: raBigPct.bottom
                        anchors.topMargin: 10
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 14
                        radius: 7
                        color: "#33FFFFFF"

                        Rectangle {
                            id: raBarFill
                            width: 0
                            height: parent.height
                            radius: 7
                            color: playStatsPanel.accentColor

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: playStatsPanel.accentColor }
                                    GradientStop { position: 0.6; color: Qt.lighter(playStatsPanel.accentColor, 1.15) }
                                    GradientStop { position: 1.0; color: Qt.darker(playStatsPanel.accentColor, 1.2) }
                                }
                            }

                            NumberAnimation {
                                id: raBarAnim
                                target: raBarFill
                                property: "width"
                                from: 0
                                to: raBarBg.width * raPageContent.pct
                                duration: 800
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    // Bottom row: [2 trophies] [RA info + check] [2 trophies] centered
                    Row {
                        id: raBottomRow
                        anchors.top: raBarBg.bottom
                        anchors.topMargin: 42
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: 68
                        spacing: 14

                        // Helper: sorted unlocked achievements
                        property var sortedUnlocked: {
                            var list = raPageContent.achList;
                            if (!list || list.length === 0) return [];
                            var unlocked = [];
                            for (var i = 0; i < list.length; i++) {
                                if (list[i].unlocked) unlocked.push(list[i]);
                            }
                            unlocked.sort(function(a, b) {
                                if (b.dateEarned > a.dateEarned) return 1;
                                if (b.dateEarned < a.dateEarned) return -1;
                                return 0;
                            });
                            return unlocked.slice(0, 4);
                        }

                        // Left 2 trophies
                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Repeater {
                                model: raBottomRow.sortedUnlocked.slice(0, 2)
                                Rectangle {
                                    width: 62; height: 62; radius: 31
                                    color: "#22FFFFFF"
                                    clip: true
                                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                    Image {
                                        anchors.fill: parent
                                        source: modelData.badgeUrl || ""
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true; asynchronous: true
                                    }
                                }
                            }
                        }

                        // Center: RA check icon + text
                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            // Checkmark icon (from RetroAchievementsInfo)
                            Image {
                                width: 46; height: 46
                                anchors.verticalCenter: parent.verticalCenter
                                source: "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiByeD0iNSIgZmlsbD0iI0ZGRkZGRiIgZmlsbC1vcGFjaXR5PSIwLjEiLz4KPHN2ZyB4PSI1IiB5PSI1IiB3aWR0aD0iMzAiIGhlaWdodD0iMzAiIHZpZXdCb3g9IjAgMCAzMCAzMCIgZmlsbD0ibm9uZSI+CjxwYXRoIGQ9Ik0xNSAyQzcuODIgMiAyIDcuODIgMiAxNXM1LjgyIDEzIDEzIDEzczEzLTUuODIgMTMtMTNTMjIuMTggMiAxNSAyem0wIDIzYy01LjUxIDAtMTAtNC40OS0xMC0xMFM5LjQ5IDUgMTUgNXMxMCA0LjQ5IDEwIDEwLTQuNDkgMTAtMTAgMTB6IiBmaWxsPSIjRkZGRkZGIi8+CjxwYXRoIGQ9Im0xMS41IDEyLjUgMiAyIDQtNCIgc3Ryb2tlPSIjRkZGRkZGIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8L3N2Zz4KPC9zdmc+"
                                smooth: true
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                Text {
                                    text: T.t("gc_ra", gameActionPanelRoot.lang)
                                    color: "#FFFFFF"
                                    font.pixelSize: 18
                                    font.bold: true
                                    font.family: "Arial"
                                }

                                Text {
                                    text: raPageContent.raLoading ? T.t("gc_loading", gameActionPanelRoot.lang)
                                        : (raPageContent.total > 0 ? T.t("gc_unlocked", gameActionPanelRoot.lang) + raPageContent.awarded + " / " + raPageContent.total : "")
                                    color: "#AAFFFFFF"
                                    font.pixelSize: 15
                                    font.family: "Arial"
                                }
                            }
                        }

                        // Right 2 trophies
                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Repeater {
                                model: raBottomRow.sortedUnlocked.slice(2, 4)
                                Rectangle {
                                    width: 62; height: 62; radius: 31
                                    color: "#22FFFFFF"
                                    clip: true
                                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                    Image {
                                        anchors.fill: parent
                                        source: modelData.badgeUrl || ""
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true; asynchronous: true
                                    }
                                }
                            }
                        }
                    }

                    // "L1 + R1 for more" hint
                    Row {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6

                        // L1 button badge
                        Rectangle {
                            width: 32; height: 20; radius: 4
                            color: "#33FFFFFF"
                            border.width: 1
                            border.color: "#55FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "L1"
                                color: "#CCFFFFFF"
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "Arial"
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "+"
                            color: "#77FFFFFF"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "Arial"
                        }

                        // R1 button badge
                        Rectangle {
                            width: 32; height: 20; radius: 4
                            color: "#33FFFFFF"
                            border.width: 1
                            border.color: "#55FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "R1"
                                color: "#CCFFFFFF"
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "Arial"
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: T.t("gc_for_more", gameActionPanelRoot.lang)
                            color: "#77FFFFFF"
                            font.pixelSize: 12
                            font.family: "Arial"
                        }
                    }
                }

                // Page indicator dots (cycling accent color = active)
                Row {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    Repeater {
                        model: 2
                        Rectangle {
                            width: 8; height: 8; radius: 4
                            color: index === playStatsPanel.panelPage ? playStatsPanel.accentColor : "#55FFFFFF"

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                onClicked: {
                                    playStatsPanel.panelPage = index;
                                    if (index === 1) {
                                        raBarAnim.stop(); raBarFill.width = 0; raBarAnim.start();
                                    } else {
                                        playTimeBarAnim.stop(); playTimeBarFill.width = 0; playTimeBarAnim.start();
                                    }
                                }
                            }
                        }
                    }
                }

                // Fade in/out animations
                NumberAnimation {
                    id: statsFadeIn
                    target: playStatsPanel
                    property: "opacity"
                    from: 0.0; to: 1.0
                    duration: 600
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    id: statsFadeOut
                    target: playStatsPanel
                    property: "opacity"
                    from: 1.0; to: 0.0
                    duration: 400
                    easing.type: Easing.InQuad
                }

                onVisibleChanged: {
                    if (visible) {
                        panelPage = 0;  // Reset to play stats on show
                        generateGameColors();
                        statsFadeOut.stop();
                        statsFadeIn.start();
                        // Animate bar after fade starts
                        playTimeBarAnim.stop();
                        playTimeBarFill.width = 0;
                        playTimeBarAnim.start();
                    } else {
                        statsFadeIn.stop();
                        statsFadeOut.start();
                    }
                }
            }

            // Game description with auto-scroll and fade (visible only when showDescription is true)
            Item {
                id: descriptionContainer
                width: Config.getDescriptionSize(_sw, _sh).width
                height: Config.getDescriptionSize(_sw, _sh).maxHeight
                x: Config.getDescriptionPosition(_sw, _sh).x
                y: Config.getDescriptionPosition(_sw, _sh).y
                visible: gameActionPanelRoot.showDescription && gameDescription.text !== ""
                opacity: 0.0
                clip: true

                Text {
                    id: gameDescription
                    width: parent.width
                    y: 0
                    text: game ? (game.description || game.summary || "") : ""
                    color: "white"
                    font.pixelSize: Config.getDescriptionConfig().fontSize
                    font.letterSpacing: Config.getDescriptionConfig().letterSpacing
                    font.family: "Arial"
                    lineHeight: Config.getDescriptionConfig().lineHeight
                    lineHeightMode: Text.ProportionalHeight
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    opacity: Config.getDescriptionConfig().opacity

                    property real scrollDuration: {
                        var heightDiff = contentHeight - descriptionContainer.height;
                        return Math.max(100, heightDiff * 1000 / Config.getDescriptionConfig().scrollSpeed);
                    }

                    SequentialAnimation {
                        id: scrollAnimation
                        running: false
                        loops: Animation.Infinite

                        PauseAnimation {
                            duration: Config.getDescriptionConfig().scrollPause
                        }

                        NumberAnimation {
                            target: gameDescription
                            property: "y"
                            from: 0
                            to: -(gameDescription.contentHeight - descriptionContainer.height)
                            duration: gameDescription.scrollDuration
                            easing.type: Easing.Linear
                        }

                        PauseAnimation {
                            duration: Config.getDescriptionConfig().scrollEndPause
                        }

                        NumberAnimation {
                            target: gameDescription
                            property: "y"
                            to: 0
                            duration: 500
                            easing.type: Easing.OutQuad
                        }
                    }

                    onContentHeightChanged: {
                        if (contentHeight > descriptionContainer.height && descriptionContainer.visible && descriptionContainer.opacity > 0.5) {
                            scrollAnimation.start();
                        } else {
                            scrollAnimation.stop();
                            y = 0;
                        }
                    }
                }

                NumberAnimation {
                    id: fadeInAnimation
                    target: descriptionContainer
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: Config.getDescriptionConfig().fadeInDuration
                    easing.type: Config.getDescriptionConfig().fadeInEasing === "OutQuad" ? Easing.OutQuad :
                                Config.getDescriptionConfig().fadeInEasing === "OutCubic" ? Easing.OutCubic :
                                Config.getDescriptionConfig().fadeInEasing === "OutExpo" ? Easing.OutExpo : Easing.OutQuad
                    running: false

                    onFinished: {
                        if (gameDescription.contentHeight > descriptionContainer.height) {
                            scrollAnimation.start();
                        }
                    }
                }

                NumberAnimation {
                    id: fadeOutAnimation
                    target: descriptionContainer
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: Config.getDescriptionConfig().fadeOutDuration
                    easing.type: Config.getDescriptionConfig().fadeOutEasing === "InQuad" ? Easing.InQuad :
                                Config.getDescriptionConfig().fadeOutEasing === "InCubic" ? Easing.InCubic :
                                Config.getDescriptionConfig().fadeOutEasing === "InExpo" ? Easing.InExpo : Easing.InQuad
                    running: false

                    onFinished: {
                        scrollAnimation.stop();
                        gameDescription.y = 0;
                        // Guard: don't interfere if panel was reopened during fade-out
                        if (!gameActionPanelRoot.showDescription) {
                            descriptionContainer.opacity = 0;
                        }
                    }
                }

                onVisibleChanged: {
                    if (visible) {
                        fadeOutAnimation.stop();
                        fadeInAnimation.start();
                    } else {
                        fadeInAnimation.stop();
                        fadeOutAnimation.start();
                    }
                }
            }

            // Play button positioned relative to container
            FocusScope {
                id: playButtonScope
                width: Config.getButtonSize("play", _sw, _sh).width
                height: Config.getButtonSize("play", _sw, _sh).height
                x: Config.getButtonPosition("play", _sw, _sh).x
                y: Config.getButtonPosition("play", _sw, _sh).y
                focus: gameActionPanelRoot.visible && gameActionPanelRoot.currentButton === 0

                Image {
                    source: parent.focus ? "../../assets/images/icons/Play_selected.png" : "../../assets/images/icons/Play.png"
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    opacity: Config.getButtonOpacity("play")

                    scale: parent.focus ? Config.getFocusScale() : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: Config.getAnimationSpeed()
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: gameActionPanelRoot.playClicked(gameActionPanelRoot.game)
                        onEntered: gameActionPanelRoot.currentButton = 0
                    }
                }
            }

            // Info button geometric — "More" with blue outline, badge X, water fill
            FocusScope {
                id: detailsButtonScope
                width: Config.getButtonSize("info", _sw, _sh).width
                height: Config.getButtonSize("info", _sw, _sh).height
                x: Config.getButtonPosition("info", _sw, _sh).x
                y: Config.getButtonPosition("info", _sw, _sh).y
                focus: gameActionPanelRoot.visible && gameActionPanelRoot.currentButton === 1

                property real _iconSize: Math.min(width, height) * 0.2
                property bool _active: gameActionPanelRoot.showDescription

                Item {
                    id: infoIconRoot
                    anchors.centerIn: parent
                    width: detailsButtonScope._iconSize
                    height: detailsButtonScope._iconSize
                    opacity: Config.getButtonOpacity("info")

                    scale: detailsButtonScope.focus ? Config.getFocusScale() : 1.0
                    Behavior on scale { NumberAnimation { duration: Config.getAnimationSpeed() } }

                    // Water fill (circular mask)
                    Item {
                        id: infoWaterFillContainer
                        anchors.fill: parent
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: infoIconRoot.width
                                height: infoIconRoot.height
                                radius: width / 2
                            }
                        }
                        Rectangle {
                            id: infoWaterFillRect
                            width: parent.width; height: parent.height
                            color: "#CC3498DB"
                            x: 0; y: parent.height
                        }
                        NumberAnimation {
                            id: infoWfAnimY; target: infoWaterFillRect; property: "y"
                            duration: 400; easing.type: Easing.OutQuad
                        }
                    }

                    // Unified outline (main circle + badge merged)
                    Item {
                        id: infoOutlineOverlay
                        anchors.fill: parent
                        z: 1

                        // Background fill
                        Item {
                            anchors.fill: parent
                            layer.enabled: true
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width; height: parent.height
                                radius: width / 2
                                color: detailsButtonScope._active ? "#333498DB" : "#22FFFFFF"
                            }
                        }

                        // Source: filled circle
                        Item {
                            id: infoShapeSource
                            anchors.fill: parent
                            visible: false; layer.enabled: true
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width; height: parent.height
                                radius: width / 2; color: "#3498DB"
                            }
                        }

                        // Mask: shrunk 2px
                        Item {
                            id: infoShapeMask
                            anchors.fill: parent
                            visible: false; layer.enabled: true
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - 4; height: parent.height - 4
                                radius: width / 2; color: "white"
                            }
                        }

                        // Ring
                        OpacityMask {
                            anchors.fill: parent
                            source: infoShapeSource
                            maskSource: infoShapeMask
                            invert: true
                        }
                    }

                    // Three dots "more" icon
                    Row {
                        anchors.centerIn: parent
                        spacing: infoIconRoot.width * 0.08
                        z: 2
                        Repeater {
                            model: 3
                            Rectangle {
                                width: infoIconRoot.width * 0.1
                                height: width
                                radius: width / 2
                                color: detailsButtonScope._active ? "#FFFFFF" : "#ECF0F1"
                            }
                        }
                    }

                    // Focus ring
                    Rectangle {
                        id: infoFocusRing
                        anchors.centerIn: parent
                        width: parent.width + 10; height: parent.height + 10
                        radius: width / 2
                        color: "transparent"
                        border.color: "#3498DB"; border.width: 3
                        visible: gameActionPanelRoot.showDescription
                        opacity: visible ? 1.0 : 0.0
                        scale: visible ? infoFocusRing._pulseScale : 1.0
                        property real _pulseScale: 1.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        SequentialAnimation on _pulseScale {
                            running: gameActionPanelRoot.showDescription
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 1.1; duration: 800; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 1.1; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                        }
                    }
                }

                // Water fill reacts to showDescription
                Connections {
                    target: gameActionPanelRoot
                    function onShowDescriptionChanged() {
                        infoWfAnimY.stop();
                        var ph = infoWaterFillContainer.height;
                        if (gameActionPanelRoot.showDescription) {
                            infoWaterFillRect.y = ph;
                            infoWfAnimY.from = ph; infoWfAnimY.to = 0;
                        } else {
                            infoWfAnimY.from = 0; infoWfAnimY.to = ph;
                        }
                        infoWfAnimY.start();
                    }
                    function onVisibleChanged() {
                        if (!gameActionPanelRoot.visible) return;
                        infoWaterFillRect.y = infoWaterFillContainer.height;
                    }
                }

                MouseArea {
                    anchors.centerIn: parent
                    width: infoIconRoot.width * infoIconRoot.scale
                    height: infoIconRoot.height * infoIconRoot.scale
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        gameActionPanelRoot.showDescription = !gameActionPanelRoot.showDescription;
                        gameActionPanelRoot.detailsClicked(gameActionPanelRoot.game);
                    }
                    onEntered: gameActionPanelRoot.currentButton = 1
                }
            }

            // Select button geometric — trophy/clock icon, yellow outline, badge Select (filled square)
            FocusScope {
                id: selectButtonScope
                width: Config.getButtonSize("select", _sw, _sh).width
                height: Config.getButtonSize("select", _sw, _sh).height
                x: Config.getButtonPosition("select", _sw, _sh).x
                y: Config.getButtonPosition("select", _sw, _sh).y
                focus: gameActionPanelRoot.visible && gameActionPanelRoot.currentButton === 2

                property real _iconSize: Math.min(width, height) * 0.2
                property bool _isRaPage: playStatsPanel.panelPage === 1

                // Blurred transparent background circle
                Rectangle {
                    id: selectBlurBg
                    anchors.centerIn: parent
                    width: selectButtonScope._iconSize + 8
                    height: selectButtonScope._iconSize + 8
                    radius: width / 2
                    color: "#33000000"
                    border.color: "#22FFD700"
                    border.width: 1
                    layer.enabled: true
                    layer.effect: Item {
                        // Simulated blur via stacked translucent layers
                    }
                }

                Item {
                    id: selectIconRoot
                    anchors.centerIn: parent
                    width: selectButtonScope._iconSize
                    height: selectButtonScope._iconSize
                    opacity: Config.getButtonOpacity("select")

                    property real _baseScale: selectButtonScope.focus ? Config.getFocusScale() : 1.0
                    scale: _baseScale
                    Behavior on _baseScale { NumberAnimation { duration: Config.getAnimationSpeed() } }

                    // Bounce animation triggered on Select press
                    SequentialAnimation {
                        id: selectBounceAnim
                        NumberAnimation { target: selectIconRoot; property: "scale"; to: selectIconRoot._baseScale * 1.35; duration: 100; easing.type: Easing.OutQuad }
                        NumberAnimation { target: selectIconRoot; property: "scale"; to: selectIconRoot._baseScale * 0.85; duration: 100; easing.type: Easing.InOutQuad }
                        NumberAnimation { target: selectIconRoot; property: "scale"; to: selectIconRoot._baseScale; duration: 150; easing.type: Easing.OutBack }
                    }

                    function bounce() { selectBounceAnim.stop(); selectBounceAnim.start(); }

                    // Outline circle (yellow)
                    Item {
                        id: selectOutlineOverlay
                        anchors.fill: parent
                        z: 1

                        // Background fill
                        Item {
                            anchors.fill: parent
                            layer.enabled: true
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width; height: parent.height
                                radius: width / 2
                                color: "#22FFD700"
                            }
                        }

                        // Source: filled circle with yellow border
                        Item {
                            id: selectShapeSource
                            anchors.fill: parent
                            visible: false; layer.enabled: true
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width; height: parent.height
                                radius: width / 2; color: "#FFD700"
                            }
                        }

                        // Mask: shrunk 2px
                        Item {
                            id: selectShapeMask
                            anchors.fill: parent
                            visible: false; layer.enabled: true
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - 4; height: parent.height - 4
                                radius: width / 2; color: "white"
                            }
                        }

                        // Ring (outline only)
                        OpacityMask {
                            anchors.fill: parent
                            source: selectShapeSource
                            maskSource: selectShapeMask
                            invert: true
                        }
                    }

                    // Trophy icon (when on PlayStats page → shows RA icon to indicate switching to RA)
                    // Geometric trophy: cup body + handles + base
                    Item {
                        anchors.centerIn: parent
                        width: selectIconRoot.width * 0.5
                        height: selectIconRoot.height * 0.5
                        visible: !selectButtonScope._isRaPage
                        z: 2

                        // Cup body (trapezoid via rectangle with top trim)
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            width: parent.width * 0.6
                            height: parent.height * 0.55
                            radius: width * 0.15
                            color: "#FFD700"
                        }
                        // Left handle
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width * 0.05
                            anchors.top: parent.top
                            anchors.topMargin: parent.height * 0.05
                            width: parent.width * 0.18
                            height: parent.height * 0.35
                            radius: width * 0.5
                            color: "transparent"
                            border.color: "#FFD700"
                            border.width: 2
                        }
                        // Right handle
                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width * 0.05
                            anchors.top: parent.top
                            anchors.topMargin: parent.height * 0.05
                            width: parent.width * 0.18
                            height: parent.height * 0.35
                            radius: width * 0.5
                            color: "transparent"
                            border.color: "#FFD700"
                            border.width: 2
                        }
                        // Stem
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: parent.height * 0.05
                            width: parent.width * 0.12
                            height: parent.height * 0.25
                            color: "#FFD700"
                        }
                        // Base
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: parent.width * 0.45
                            height: parent.height * 0.12
                            radius: 2
                            color: "#FFD700"
                        }
                    }

                    // Clock icon (when on RA page → shows clock to indicate switching to PlayStats)
                    // Geometric clock: circle + hands
                    Item {
                        anchors.centerIn: parent
                        width: selectIconRoot.width * 0.45
                        height: selectIconRoot.height * 0.45
                        visible: selectButtonScope._isRaPage
                        z: 2

                        // Clock face (circle outline)
                        Rectangle {
                            id: clockFace
                            anchors.fill: parent
                            radius: width / 2
                            color: "transparent"
                            border.color: "#FFD700"
                            border.width: 2
                        }
                        // Hour hand (short)
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.verticalCenter
                            width: 2
                            height: parent.height * 0.25
                            color: "#FFD700"
                        }
                        // Minute hand (long, pointing to 2 o'clock)
                        Rectangle {
                            x: parent.width * 0.5 - 1
                            y: parent.height * 0.5 - parent.height * 0.06
                            width: parent.width * 0.3
                            height: 2
                            color: "#FFD700"
                            transformOrigin: Item.Left
                            rotation: -30
                        }
                        // Center dot
                        Rectangle {
                            anchors.centerIn: parent
                            width: 4; height: 4
                            radius: 2
                            color: "#FFD700"
                        }
                    }

                }

                MouseArea {
                    anchors.centerIn: parent
                    width: selectIconRoot.width * selectIconRoot.scale
                    height: selectIconRoot.height * selectIconRoot.scale
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        playStatsPanel.panelPage = (playStatsPanel.panelPage + 1) % 2;
                        if (playStatsPanel.panelPage === 1) {
                            raBarAnim.stop(); raBarFill.width = 0; raBarAnim.start();
                        } else {
                            playTimeBarAnim.stop(); playTimeBarFill.width = 0; playTimeBarAnim.start();
                        }
                        selectIconRoot.bounce();
                    }
                    onEntered: gameActionPanelRoot.currentButton = 2
                }
            }

            // Favourite button geometric — star, orange outline, badge Y, water fill, heartbeat
            FocusScope {
                id: favouriteButtonScope
                width: Config.getButtonSize("favourite", _sw, _sh).width
                height: Config.getButtonSize("favourite", _sw, _sh).height
                x: Config.getButtonPosition("favourite", _sw, _sh).x
                y: Config.getButtonPosition("favourite", _sw, _sh).y
                focus: gameActionPanelRoot.visible && gameActionPanelRoot.currentButton === 3

                property real _iconSize: Math.min(width, height) * 0.22
                property bool isGameFav: {
                    var v = gameActionPanelRoot._favVersion;  // force dependency
                    if (!gameActionPanelRoot.game || !gameActionPanelRoot.platformBarRef) return false;
                    return gameActionPanelRoot.platformBarRef.isGameFavourite(gameActionPanelRoot.game, gameActionPanelRoot.currentPlatform);
                }

                Item {
                    id: favIconRoot
                    anchors.centerIn: parent
                    width: favouriteButtonScope._iconSize
                    height: favouriteButtonScope._iconSize
                    opacity: Config.getButtonOpacity("favourite")

                    scale: favouriteButtonScope.focus ? Config.getFocusScale() : 1.0
                    Behavior on scale { NumberAnimation { duration: Config.getAnimationSpeed() } }

                    // Heart with water-fill inside heart shape
                    property real _fillLevel: 0.0  // 0=empty, 1=full

                    NumberAnimation {
                        id: favFillAnim
                        target: favIconRoot
                        property: "_fillLevel"
                        duration: 400
                        easing.type: Easing.OutQuad
                    }

                    Item {
                        id: favHeartItem
                        anchors.centerIn: parent
                        width: parent.width; height: parent.height
                        z: 2

                        // Heartbeat animation
                        SequentialAnimation {
                            id: favHeartbeatAnim
                            loops: 1
                            NumberAnimation { target: favHeartItem; property: "scale"; to: 1.35; duration: 120; easing.type: Easing.OutQuad }
                            NumberAnimation { target: favHeartItem; property: "scale"; to: 0.9; duration: 100; easing.type: Easing.InQuad }
                            NumberAnimation { target: favHeartItem; property: "scale"; to: 1.25; duration: 100; easing.type: Easing.OutQuad }
                            NumberAnimation { target: favHeartItem; property: "scale"; to: 1.0; duration: 200; easing.type: Easing.OutBack }
                        }

                        Canvas {
                            id: favHeartCanvas
                            anchors.fill: parent

                            property real fillLevel: favIconRoot._fillLevel
                            onFillLevelChanged: requestPaint()

                            function drawHeartPath(ctx, w, h) {
                                var cx = w / 2, cy = h / 2;
                                var hw = w * 0.48, hh = h * 0.44;
                                var bx = cx, by = cy + hh * 0.62;
                                ctx.moveTo(bx, by);
                                ctx.bezierCurveTo(bx, by - hh * 0.4, cx - hw * 0.65, cy + hh * 0.18, cx - hw * 0.52, cy - hh * 0.18);
                                ctx.bezierCurveTo(cx - hw * 0.52, cy - hh * 0.62, cx - hw * 0.22, cy - hh * 0.72, cx, cy - hh * 0.36);
                                ctx.bezierCurveTo(cx + hw * 0.22, cy - hh * 0.72, cx + hw * 0.52, cy - hh * 0.62, cx + hw * 0.52, cy - hh * 0.18);
                                ctx.bezierCurveTo(cx + hw * 0.65, cy + hh * 0.18, bx, by - hh * 0.4, bx, by);
                            }

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);

                                // Water fill clipped to heart
                                if (fillLevel > 0) {
                                    ctx.save();
                                    ctx.beginPath();
                                    drawHeartPath(ctx, width, height);
                                    ctx.closePath();
                                    ctx.clip();
                                    var fillY = height * (1.0 - fillLevel);
                                    ctx.fillStyle = "#CCF39C12";
                                    ctx.fillRect(0, fillY, width, height - fillY);
                                    ctx.restore();
                                }

                                // Heart outline
                                ctx.beginPath();
                                drawHeartPath(ctx, width, height);
                                ctx.closePath();

                                if (favouriteButtonScope.isGameFav && fillLevel >= 1.0) {
                                    ctx.strokeStyle = "#F5B041";
                                } else {
                                    ctx.strokeStyle = favouriteButtonScope.focus ? "#FFFFFF" : "rgba(255,255,255,0.6)";
                                }
                                ctx.lineWidth = Math.max(2, width * 0.05);
                                ctx.lineJoin = "round";
                                ctx.stroke();
                            }

                            Connections {
                                target: favouriteButtonScope
                                function onIsGameFavChanged() { favHeartCanvas.requestPaint(); }
                                function onFocusChanged() { favHeartCanvas.requestPaint(); }
                            }
                            Component.onCompleted: requestPaint()
                        }

                        // Glow when favourite
                        layer.enabled: favouriteButtonScope.isGameFav
                        layer.effect: Glow {
                            radius: 10; samples: 21; spread: 0.3
                            color: "#F39C12"; transparentBorder: true
                        }
                    }

                }

                Connections {
                    target: favouriteButtonScope
                    function onIsGameFavChanged() {
                        favFillAnim.stop();
                        if (favouriteButtonScope.isGameFav) {
                            favFillAnim.from = 0; favFillAnim.to = 1;
                        } else {
                            favFillAnim.from = 1; favFillAnim.to = 0;
                        }
                        favFillAnim.start();
                        favHeartbeatAnim.restart();
                    }
                }

                Connections {
                    target: gameActionPanelRoot
                    function onVisibleChanged() {
                        if (gameActionPanelRoot.visible) {
                            favIconRoot._fillLevel = favouriteButtonScope.isGameFav ? 1.0 : 0.0;
                        }
                    }
                }

                MouseArea {
                    anchors.centerIn: parent
                    width: favIconRoot.width * favIconRoot.scale
                    height: favIconRoot.height * favIconRoot.scale
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: gameActionPanelRoot.favouriteClicked(gameActionPanelRoot.game)
                    onEntered: gameActionPanelRoot.currentButton = 3
                }
            }

        }
    }

    Keys.onPressed: function(event) {
        if (!gameActionPanelRoot.visible) return;

        if (event.key === Qt.Key_Right) {
            currentButton = (currentButton + 1) % 4;
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            currentButton = (currentButton - 1 + 4) % 4;
            event.accepted = true;
        } else if (event.key === 1048578) {
            // X button - Set focus to info/details button and toggle description
            if (showDescription) {
                // Toggling OFF — deselect info button
                showDescription = false;
                currentButton = 0;
            } else {
                // Toggling ON — select info button
                currentButton = 1;
                showDescription = true;
            }
            detailsClicked(game);
            event.accepted = true;
        } else if (event.key === 1048579) {
            // Y button - Set focus to favourite button and trigger favourite action
            currentButton = 3;  // Focus on favourite button
            favouriteClicked(game);
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (playButtonScope.focus) playClicked(game);
            else if (detailsButtonScope.focus) {
                showDescription = !showDescription;
                detailsClicked(game);
            }
            else if (selectButtonScope.focus) {
                // Toggle panel page (PlayStats ↔ RA)
                playStatsPanel.panelPage = (playStatsPanel.panelPage + 1) % 2;
                if (playStatsPanel.panelPage === 1) {
                    raBarAnim.stop(); raBarFill.width = 0; raBarAnim.start();
                } else {
                    playTimeBarAnim.stop(); playTimeBarFill.width = 0; playTimeBarAnim.start();
                }
                selectIconRoot.bounce();
            }
            else if (favouriteButtonScope.focus) favouriteClicked(game);
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
            hide();
            event.accepted = true;
        }
    }

    PropertyAnimation {
        id: gameCardFadeInAnimation
        target: gameActionPanelRoot
        property: "opacity"
        from: 0
        to: 1
        duration: 200
        easing.type: Easing.OutQuad
    }

    SequentialAnimation {
        id: gameCardFadeOutAnimation
        PropertyAnimation {
            target: gameActionPanelRoot
            property: "opacity"
            from: 1
            to: 0
            duration: 150
            easing.type: Easing.InQuad
        }
        ScriptAction {
            script: {
                gameActionPanelRoot.visible = false;
                gameActionPanelRoot.closed();
            }
        }
    }

    function show(g) {
        if (!visible) {
            game = g;
            showDescription = false;
            visible = true;
            gameCardFadeInAnimation.start();
        } else {
            // Clear stale RA data immediately when switching to a different game
            if (game !== g) {
                raPageContent._detail = null;
                raPageContent.awarded = 0;
                raPageContent.total = 0;
                raPageContent.pct = 0;
                raPageContent.achList = [];
                raPageContent.raLoading = true;
            }
            game = g;
            showDescription = false;
            // Re-trigger stats panel animations when scrolling to a new game
            _refreshStatsAnimations();
        }
        // Sync RA panel to current RAService state immediately
        raPageContent._refreshRaData();
    }

    // Reset and replay bar animations + colors for the current game
    function _refreshStatsAnimations() {
        playStatsPanel.generateGameColors();
        // Replay playtime bar
        playTimeBarAnim.stop();
        playTimeBarFill.width = 0;
        playTimeBarAnim.start();
        // Replay RA bar if on RA page
        if (playStatsPanel.panelPage === 1) {
            raBarAnim.stop();
            raBarFill.width = 0;
            raBarAnim.start();
        }
    }

    function hide() {
        if (visible) {
            showDescription = false;
            // Stop metadata animations cleanly
            lastPlayedFadeInAnimation.stop();
            developerFadeInAnimation.stop();
            genreFadeInAnimation.stop();
            genreScrollAnimation.stop();
            scrollAnimation.stop();
            gameDescription.y = 0;
            gameCardFadeOutAnimation.start();
        }
    }
}
