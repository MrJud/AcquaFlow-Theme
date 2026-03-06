import QtQuick 2.15
import QtGraphicalEffects 1.15
import ".."
import "../config/Translations.js" as T

Rectangle {
    id: searchButton

    // Geometry
    property real closedSize: 80
    property real expandedWidth: 500  // overridden by parent
    property QtObject screenMetrics: null

    width: closedSize
    height: closedSize
    radius: height / 2
    color: _bgColor
    clip: false

    Behavior on width  { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
    Behavior on radius { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
    Behavior on color  { ColorAnimation  { duration: 200 } }

    // Public API
    property string lang: "it"
    property bool isOpen: _state === "expanded" || _state === "editing"
    property bool isEditing: _state === "editing"
    property bool searchActive: _searchActive
    property string searchText: ""
    property var searchResults: []
    property var searchResultsCollection: null
    property var collections: null  // api.collections ref
    property var platformBarRef: null

    signal searchRequested(string query)
    signal searchClosed()
    signal clicked()
    signal pressAndHold()

    // Compat for CoverFlow top-bar focus system
    property bool hovered: false
    property bool pressed: false
    property bool focused: false
    property string fillDirection: "bottom"  // "bottom", "left", "right"

    // Internal
    property string _state: "closed"
    property bool _searchActive: false
    property bool _selectGuard: false  // blocks selectCover for a brief window after search

    Timer {
        id: selectGuardTimer
        interval: 500
        repeat: false
        onTriggered: searchButton._selectGuard = false
    }
    readonly property color _bgColor: {
        if (pressed && _state === "closed") return "transparent";
        if (_state === "editing") return "#1a2a3a";
        if (_state === "expanded") return "#1a2a3a";
        if (_searchActive && _state === "closed") return "transparent";
        return "transparent";
    }

    border.width: _state === "closed" ? 0 : 2
    border.color: {
        if (_state === "editing") return "#E67E22";
        if (_state === "expanded") return "#1ABC9C";
        return "transparent";
    }

    opacity: 0.9

    // Water fill effect — physics water
    Item {
        id: sbWaterFillContainer
        anchors.fill: parent
        visible: _state === "closed"
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: searchButton.closedSize
                height: searchButton.closedSize
                radius: searchButton.closedSize / 2
            }
        }
        Canvas {
            id: sbWaterCanvas
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
                ctx.fillStyle = "#CC1ABC9C";
                ctx.fill();
                for (var i = 0; i < _drops.length; i++) {
                    var d = _drops[i];
                    ctx.globalAlpha = Math.max(0, d.alpha);
                    ctx.beginPath();
                    ctx.arc(d.x, d.y, d.r, 0, Math.PI * 2);
                    ctx.fillStyle = "#1ABC9C";
                    ctx.fill();
                }
                ctx.globalAlpha = 1.0;
            }
            Timer {
                interval: 16; repeat: true
                running: (sbWaterCanvas._level > 0.005 || sbWaterCanvas._target > 0.5) && searchButton._state === "closed"
                onTriggered: {
                    var c = sbWaterCanvas;
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
        if (_state !== "closed") return;
        sbWaterCanvas._dir = fillDirection === "right" ? 1 : (fillDirection === "left" ? -1 : 0);
        sbWaterCanvas._target = focused ? 1.0 : 0.0;
        if (!focused) sbWaterCanvas._drops = [];
    }

    Rectangle {
        id: focusRing
        anchors.centerIn: parent
        width: searchButton.closedSize + 10
        height: searchButton.closedSize + 10
        radius: width / 2
        color: "transparent"
        border.color: "#1ABC9C"
        border.width: 3
        opacity: searchButton.focused && _state === "closed" ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    // Focus label (zoom-in dal basso quando focalizzato)
    Rectangle {
        id: searchFocusLabel
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height + 8
        width: Math.max(searchFocusLabelText.implicitWidth + 16, 40)
        height: screenMetrics ? Math.max(20, Math.min(26, Math.round(22 * screenMetrics.scaleRatio))) : 22
        radius: height / 2
        color: "#CC1a1a2e"
        border.color: "#66FFFFFF"
        border.width: 1
        transformOrigin: Item.Top
        scale: searchButton.focused && _state === "closed" ? 1.0 : 0.0
        opacity: searchButton.focused && _state === "closed" ? 1.0 : 0.0
        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutBack }
        }
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        Text {
            id: searchFocusLabelText
            anchors.centerIn: parent
            text: "Search"
            font.pixelSize: screenMetrics ? Math.max(10, Math.min(13, Math.round(11 * screenMetrics.scaleRatio))) : 11
            font.bold: true
            color: "white"
        }
    }

    Item {
        id: closedOutlineOverlay
        anchors.fill: parent
        visible: _state === "closed"
        z: 1

        // Unified background fill (single layer, no alpha overlap)
        Item {
            id: bgFillItem
            anchors.fill: parent
            layer.enabled: true

            Rectangle {
                anchors.centerIn: parent
                width: parent.width; height: parent.height
                radius: width / 2
                color: "transparent"
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: Math.round(searchButton.closedSize * 0.375); height: Math.round(searchButton.closedSize * 0.375); radius: Math.round(searchButton.closedSize * 0.1875)
                color: "transparent"
            }
        }

        // Source: both circles at exact size, filled green
        Item {
            id: shapeSource
            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                anchors.centerIn: parent
                width: parent.width; height: parent.height
                radius: width / 2
                color: "#1ABC9C"
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: Math.round(searchButton.closedSize * 0.375); height: Math.round(searchButton.closedSize * 0.375); radius: Math.round(searchButton.closedSize * 0.1875)
                color: "#1ABC9C"
            }
        }

        // Mask: both circles shrunk by 2px (inward), white
        Item {
            id: shapeMask
            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 4; height: parent.height - 4
                radius: width / 2
                color: "white"
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.bottomMargin: 2; anchors.rightMargin: 2
                width: Math.round(searchButton.closedSize * 0.375) - 4; height: Math.round(searchButton.closedSize * 0.375) - 4; radius: (Math.round(searchButton.closedSize * 0.375) - 4) / 2
                color: "white"
            }
        }

        // Result: exact MINUS shrunk = 2px inward outline ring, unified
        OpacityMask {
            anchors.fill: parent
            source: shapeSource
            maskSource: shapeMask
            invert: true
        }
    }

    // Magnifying-glass icon
    // Pinned to the right side so it never moves when the bar expands left.
    Item {
        id: searchIcon
        anchors.right: parent.right
        anchors.rightMargin: (closedSize - _iconSz) / 2
        anchors.verticalCenter: parent.verticalCenter
        width: _iconSz; height: _iconSz

        readonly property real _iconSz: screenMetrics ? screenMetrics.toolbarIconSize : 32

        // Lens circle
        Rectangle {
            width: searchIcon._iconSz * 0.594; height: width; radius: width / 2
            color: "transparent"
            border.color: searchButton._searchActive ? "#1ABC9C" : "#ECF0F1"; border.width: 2.5
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -2
            anchors.verticalCenterOffset: -2
            Behavior on border.color { ColorAnimation { duration: 300 } }
        }
        // Handle
        Rectangle {
            width: searchIcon._iconSz * 0.406; height: searchIcon._iconSz * 0.078; color: searchButton._searchActive ? "#1ABC9C" : "#ECF0F1"
            rotation: 45; radius: 1
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 8
            anchors.verticalCenterOffset: 8
            Behavior on color { ColorAnimation { duration: 300 } }
        }

        scale: searchButton.pressed ? 0.9 : 1.0
        Behavior on scale { NumberAnimation { duration: 120 } }

        // Glow when search is active
        layer.enabled: searchButton._searchActive
        layer.effect: Glow {
            radius: 10
            samples: 21
            spread: 0.4
            color: "#1ABC9C"
            transparentBorder: true
        }
    }

    // Cancel button (touch B equivalent, left side)
    Item {
        id: cancelButton
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: closedSize * 0.5
        height: closedSize * 0.5
        z: 10  // above main MouseArea
        opacity: (_state === "expanded" || _state === "editing") ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: cancelMA.pressed ? "#C0392B" : "#E74C3C"
            border.color: "#E74C3C"
            border.width: 1.5
            Behavior on color { ColorAnimation { duration: 120 } }

            // B label
            Text {
                anchors.centerIn: parent
                text: "B"
                color: "#FFFFFF"
                font.pixelSize: parent.width * 0.5
                font.bold: true
            }
        }

        MouseArea {
            id: cancelMA
            anchors.fill: parent
            onClicked: {
                if (searchButton._state === "editing")
                    searchButton.stopEditing();
                else
                    searchButton.exitSearch();
            }
        }
    }

    // Text area
    Item {
        id: textContainer
        anchors.left: cancelButton.right
        anchors.leftMargin: 8
        anchors.right: searchIcon.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        opacity: (_state === "expanded" || _state === "editing") ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        // Placeholder
        Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            text: T.t("search_placeholder", searchButton.lang)
            color: "#607080"
            font.pixelSize: 22
            font.italic: true
            visible: searchInput.text === "" && !searchInput.activeFocus
        }

        TextInput {
            id: searchInput
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 22
            color: "#e0f0ff"
            clip: true
            selectByMouse: true
            readOnly: _state !== "editing"
            cursorVisible: _state === "editing"
            inputMethodHints: Qt.ImhNoPredictiveText

            onAccepted: {
                if (text.trim().length > 0)
                    searchButton.executeSearch(text.trim());
            }
        }
    }

    // Hint label below
    Text {
        id: hintText
        anchors.top: parent.bottom
        anchors.topMargin: 6
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 14
        color: "#8090a0"
        opacity: _state === "expanded" ? 0.8 : (_state === "editing" ? 0.8 : 0)
        text: _state === "editing"
              ? T.t("search_hint_editing", searchButton.lang)
              : T.t("search_hint_default", searchButton.lang)
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    // Results badge (text only, fill+outline drawn by closedOutlineOverlay)
    Item {
        visible: _state === "closed"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: Math.round(searchButton.closedSize * 0.375); height: Math.round(searchButton.closedSize * 0.375)
        z: 2
        Text {
            anchors.centerIn: parent
            text: _searchActive && searchResults.length > 0
                  ? (searchResults.length > 99 ? "99" : searchResults.length.toString())
                  : "X"
            font.pixelSize: Math.round(searchButton.closedSize * 0.15)
            font.bold: true
            color: "white"
        }
    }

    // Mouse / touch
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: searchButton.hovered = true
        onExited:  searchButton.hovered = false
        onPressed: searchButton.pressed = true
        onReleased: searchButton.pressed = false
        onClicked: {
            if (_state === "closed") searchButton.open();
            else if (_state === "expanded") searchButton.startEditing();
            else if (_state === "editing") {
                // Tap while editing → execute search if text present
                if (searchInput.text.trim().length > 0)
                    searchButton.executeSearch(searchInput.text.trim());
            }
            else searchButton.clicked();
        }
        onPressAndHold: searchButton.pressAndHold()
    }

    // Appear animation
    Component.onCompleted: {
        opacity = 0; scale = 0.5;
        opacityAnim.start(); scaleAnim.start();
    }
    NumberAnimation { id: opacityAnim; target: searchButton; property: "opacity"; from: 0; to: 0.9; duration: 300 }
    NumberAnimation { id: scaleAnim;   target: searchButton; property: "scale";   from: 0.5; to: 1.0; duration: 300 }

    // Press simulation
    Timer { id: pressTimer; interval: 200; onTriggered: searchButton.pressed = false }
    function press() {
        searchButton.pressed = true;
        pressTimer.restart();
        if (_state === "closed") open(); else clicked();
    }

    function open() {
        if (_state !== "closed") return;
        width = expandedWidth;
        _state = "expanded";
        console.log("🔍 SearchButton → expanded");
    }

    function close() {
        searchInput.readOnly = true;
        searchInput.focus = false;
        searchInput.text = "";
        searchText = "";
        width = closedSize;
        _state = "closed";
        // Don't clear results/searchActive here — only exitSearch() does that
        console.log("🔍 SearchButton → closed");
    }

    function exitSearch() {
        // Called by X to fully exit search mode and restore platforms
        searchInput.readOnly = true;
        searchInput.focus = false;
        searchInput.text = "";
        searchText = "";
        searchResults = [];
        searchResultsCollection = null;
        _searchActive = false;
        _selectGuard = false;
        selectGuardTimer.stop();
        width = closedSize;
        _state = "closed";
        searchClosed();
        console.log("🔍 SearchButton → exitSearch");
    }

    function startEditing() {
        if (_state !== "expanded") return;
        _state = "editing";
        searchInput.readOnly = false;
        searchInput.forceActiveFocus();
        console.log("🔍 SearchButton → editing");
    }

    function stopEditing() {
        if (_state !== "editing") return;
        searchInput.readOnly = true;
        searchInput.focus = false;
        _state = "expanded";
        console.log("🔍 SearchButton → expanded (stopped editing)");
    }

    function toggle() {
        if (_state === "closed" && _searchActive) open();  // Re-open bar for new search
        else if (_state === "closed") open();
        else close();  // Close bar (keep searchActive)
    }

    // GAMEPAD INPUT

    function handleButton(event) {
        if (_state === "expanded") {
            if (event.key === Qt.Key_Return || event.key === 1048576) {
                startEditing(); event.accepted = true; return true;
            }
            if (event.key === Qt.Key_Escape || event.key === 1048577) {
                // B in expanded: close bar AND exit search mode
                exitSearch(); event.accepted = true; return true;
            }
        }
        if (_state === "editing") {
            if (event.key === Qt.Key_Escape || event.key === 1048577) {
                // B in editing: just go back to expanded (stop keyboard)
                stopEditing(); event.accepted = true; return true;
            }
            if (event.key === Qt.Key_Return || event.key === 1048576) {
                if (searchInput.text.trim().length > 0)
                    executeSearch(searchInput.text.trim());
                event.accepted = true; return true;
            }
            return false;  // let other keys through to TextInput
        }
        return false;
    }

    // SEARCH LOGIC

    function executeSearch(query) {
        console.log("🔍 Searching:", query);
        searchText = query;
        var results = [];
        var lq = query.toLowerCase();
        var words = lq.split(/\s+/);

        if (!collections) { console.warn("🔍 No collections"); return; }

        for (var i = 0; i < collections.count; i++) {
            var col = collections.get(i);
            if (!col || !col.games) continue;
            var sn = (col.shortName || "").toLowerCase();
            if (sn === "ra" || sn === "lastplayed" || sn === "favourites") continue;

            for (var j = 0; j < col.games.count; j++) {
                var g = col.games.get(j);
                if (!g) continue;
                var t = (g.title || "").toLowerCase();

                var score = -1;
                if (t === lq) score = 0;
                else if (t.indexOf(lq) !== -1) score = 1;
                else {
                    var ok = true;
                    for (var w = 0; w < words.length; w++) {
                        if (words[w].length > 0 && t.indexOf(words[w]) === -1) { ok = false; break; }
                    }
                    if (ok && words.length > 0) score = 2;
                }

                if (score >= 0) {
                    g.originalPlatformName = col.shortName;
                    g.originalPlatform = col;
                    results.push({ game: g, score: score });
                }
            }
        }

        results.sort(function(a, b) {
            if (a.score !== b.score) return a.score - b.score;
            return (a.game.title || "").localeCompare(b.game.title || "");
        });

        var list = [];
        for (var r = 0; r < results.length; r++) list.push(results[r].game);

        searchResults = list;
        console.log("🔍 Found", list.length, "results");

        searchResultsCollection = {
            name: T.t("search_results", searchButton.lang) + query,
            shortName: "search",
            summary: list.length + " " + T.t("search_results_suffix", searchButton.lang),
            games: {
                count: list.length,
                get: function(idx) {
                    return (idx >= 0 && idx < list.length) ? list[idx] : null;
                }
            }
        };

        // Collapse bar back to circle, set searchActive flag
        searchInput.readOnly = true;
        searchInput.focus = false;
        width = closedSize;
        _state = "closed";
        _searchActive = true;

        // Block selectCover for 500ms to prevent auto-repeat A from
        // selecting a cover immediately after search results load
        _selectGuard = true;
        selectGuardTimer.start();

        searchRequested(query);
    }
}
