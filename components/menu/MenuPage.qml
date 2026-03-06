import QtQuick 2.15
import ".."
import "../../components/config/Translations.js" as T

// XMB – Cross Media Bar inspired menu (PlayStation dashboard style)
Item {
    id: menuPage
    width: parent.width
    height: parent.height
    visible: false
    opacity: 0

    property bool isOpen: false
    property int currentCategoryIndex: 0
    property int currentSubItemIndex: 0
    property bool inSubItems: false
    property bool reorderMode: false
    property bool raLoginMode: false
    property bool bgSettingsMode: false
    property bool clockSettingsMode: false
    property bool uiSettingsMode: false
    property bool languageSettingsMode: false
    property bool logsMode: false
    property bool fileBrowserMode: false
    property string _fbPlatformShortName: ""
    property bool _needsRestart: false
    property var collections: null
    property int gcGameCount: 0

    // Language
    property string lang: "it"
    onLangChanged: rebuildMenuModel()

    // Backward compat alias
    property bool isSubMenuVisible: inSubItems

    // XMB Layout (proportional to screen – tuned for readability)
    readonly property real _iconSz:      Math.round(height * 0.075)
    readonly property real _iconSelSz:   Math.round(height * 0.120)
    readonly property real _iconSpacing: Math.round(width * 0.082)
    readonly property real _catX:        Math.round(width * 0.28)
    readonly property real _catY:        Math.round(height * 0.38)
    readonly property real _subH:        Math.round(height * 0.054)
    readonly property real _subSelH:     Math.round(height * 0.086)
    readonly property real _subStartY:   _catY + _iconSelSz * 0.5 + Math.round(height * 0.048)
    readonly property real _fTitle:      Math.max(16, Math.round(height * 0.030))
    readonly property real _fItem:       Math.max(14, Math.round(height * 0.024))
    readonly property real _fItemSel:    Math.max(16, Math.round(height * 0.030))
    readonly property real _fSub:        Math.max(11, Math.round(height * 0.018))

    // Data
    property var menuCategories: buildMenuModel()

    function buildMenuModel() {
        var l = lang;
        return [
            { id: "settings",  title: T.t("menu_settings", l),  icon: "\u2699", subItems: [
                { id: "theme_settings",      title: T.t("menu_theme", l),     subtitle: "Coming Soon" },
                { id: "background_settings", title: T.t("menu_background", l), subtitle: T.t("menu_background_sub", l) },
                { id: "clock_settings",      title: T.t("menu_clock", l),     subtitle: T.t("menu_clock_sub", l) },
                { id: "text_settings",       title: T.t("menu_text", l),      subtitle: "Coming Soon" },
                { id: "ui_settings",         title: T.t("menu_ui", l),        subtitle: T.t("menu_ui_sub", l) },
                { id: "controls_settings",   title: T.t("menu_controls", l),  subtitle: "Coming Soon" },
                { id: "audio_settings",      title: T.t("menu_audio", l),     subtitle: "Coming Soon" },
                { id: "language_settings",   title: T.t("menu_language", l),  subtitle: T.t("menu_language_sub", l) }
            ]},
            { id: "platforms", title: T.t("menu_platforms", l), icon: "\u25C6", subItems: [] },
            { id: "ra",        title: T.t("menu_ra", l),       icon: "\u2605", subItems: [
                { id: "ra_login", title: T.t("menu_ra_login", l), subtitle: T.t("menu_ra_login_sub", l) },
                { id: "ra_view",  title: T.t("menu_ra_view", l),  subtitle: T.t("menu_ra_view_sub", l) }
            ]},
            { id: "about",     title: T.t("menu_about", l),    icon: "\u2139", subItems: [
                { id: "version_info", title: T.t("menu_version", l), subtitle: T.t("branding", l) },
                { id: "credits",      title: T.t("menu_credits", l), subtitle: T.t("menu_credits_sub", l) },
                { id: "logs",         title: T.t("menu_logs", l),    subtitle: T.t("menu_logs_sub", l) }
            ]},
            { id: "exit",      title: T.t("menu_exit", l),     icon: "\u2715", subItems: [] }
        ];
    }

    function rebuildMenuModel() {
        var savedCat = currentCategoryIndex;
        var savedSub = currentSubItemIndex;
        menuCategories = buildMenuModel();
        updatePlatformSubItems();
        currentCategoryIndex = savedCat;
        currentSubItemIndex = savedSub;
    }

    signal menuItemSelected(string itemId)
    signal menuClosed()
    signal platformSelected(string platformShortName)
    signal platformOrderChanged(var orderArray, bool lpVisible, bool raVis, bool favVis)
    signal bgSettingsApplied(bool useArtwork, bool useVideo, string bgSource, string customPath, int blurIntensity)
    signal clockSettingsApplied(bool use24h, int fontIndex, int colorIndex)
    signal uiSettingsApplied(bool platformBarAutoHide, bool showLogoOutline, bool showBattery, bool showWifi, string screenSizeMode)
    signal languageSettingsApplied(string lang)
    signal boxbackPathChanged()

    // Menu gradient presets (darker versions of the 5 bg presets)
    readonly property var menuPresets: [
        { c0: "#040b14", c1: "#0b1a32", c2: "#0f2848", c3: "#081830", accent: "#5890d0" },
        { c0: "#0a0614", c1: "#140e24", c2: "#1e1440", c3: "#160c2e", accent: "#8868c0" },
        { c0: "#040c08", c1: "#081610", c2: "#0c2418", c3: "#061c10", accent: "#4a9868" },
        { c0: "#0c0804", c1: "#180e0a", c2: "#281810", c3: "#20140c", accent: "#c08850" },
        { c0: "#080c12", c1: "#0e141e", c2: "#161e2c", c3: "#101824", accent: "#7898b8" }
    ]

    property int _menuPresetIdx: 0

    function refreshMenuGradient() {
        var src = api.memory.get("bg_source");
        if (src && src.indexOf("preset") === 0) {
            var n = parseInt(src.replace("preset", ""));
            if (n >= 1 && n <= 5) _menuPresetIdx = n - 1;
            else _menuPresetIdx = 0;
        } else {
            _menuPresetIdx = 0;
        }
    }

    // BACKGROUND

    // Deep gradient (dynamic based on preset)
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0;  color: menuPage.menuPresets[menuPage._menuPresetIdx].c0 }
            GradientStop { position: 0.30; color: menuPage.menuPresets[menuPage._menuPresetIdx].c1 }
            GradientStop { position: 0.60; color: menuPage.menuPresets[menuPage._menuPresetIdx].c2 }
            GradientStop { position: 1.0;  color: menuPage.menuPresets[menuPage._menuPresetIdx].c3 }
        }
    }

    // Decorative wave ribbon 1
    Rectangle {
        width: parent.width * 2.4
        height: parent.height * 0.20
        x: -parent.width * 0.35
        y: parent.height * 0.28
        rotation: -7
        opacity: 0.05
        antialiasing: true
        gradient: Gradient {
            GradientStop { position: 0.0;  color: "transparent" }
            GradientStop { position: 0.35; color: "#ffffff" }
            GradientStop { position: 0.65; color: "#ffffff" }
            GradientStop { position: 1.0;  color: "transparent" }
        }
    }

    // Decorative wave ribbon 2
    Rectangle {
        width: parent.width * 2.1
        height: parent.height * 0.14
        x: -parent.width * 0.20
        y: parent.height * 0.37
        rotation: -4.5
        opacity: 0.03
        antialiasing: true
        gradient: Gradient {
            GradientStop { position: 0.0;  color: "transparent" }
            GradientStop { position: 0.35; color: menuPage.menuPresets[menuPage._menuPresetIdx].accent }
            GradientStop { position: 0.65; color: menuPage.menuPresets[menuPage._menuPresetIdx].accent }
            GradientStop { position: 1.0;  color: "transparent" }
        }
    }

    // Horizontal separator at category bar level
    Rectangle {
        x: menuPage._catX - Math.round(width * 0.015)
        y: menuPage._catY
        width: parent.width - x
        height: 1
        color: "#12ffffff"
        opacity: (menuPage.reorderMode || menuPage.raLoginMode || menuPage.bgSettingsMode || menuPage.clockSettingsMode || menuPage.uiSettingsMode || menuPage.languageSettingsMode || menuPage.logsMode || menuPage.fileBrowserMode) ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    // TOUCH GESTURE HANDLER

    MouseArea {
        id: touchGesture
        anchors.fill: parent
        z: 10
        enabled: !menuPage.reorderMode && !menuPage.raLoginMode && !menuPage.bgSettingsMode && !menuPage.clockSettingsMode && !menuPage.uiSettingsMode && !menuPage.languageSettingsMode && !menuPage.logsMode && !menuPage.fileBrowserMode
        preventStealing: true

        property real _sx: 0
        property real _sy: 0

        onPressed: { _sx = mouseX; _sy = mouseY; }
        onReleased: {
            var dx = mouseX - _sx;
            var dy = mouseY - _sy;
            var adx = Math.abs(dx);
            var ady = Math.abs(dy);
            var minSwipe = menuPage.width * 0.05;

            if (adx < minSwipe && ady < minSwipe) {
                // TAP — hit-test category icons
                var tapX = _sx, tapY = _sy;
                for (var ci = 0; ci < menuPage.menuCategories.length; ci++) {
                    var catDist = ci - menuPage.currentCategoryIndex;
                    var catSz = (ci === menuPage.currentCategoryIndex) ? menuPage._iconSelSz : menuPage._iconSz;
                    var catIconX = menuPage._catX + catDist * menuPage._iconSpacing - catSz * 0.5;
                    if (catDist > 0) catIconX += menuPage._iconSelSz * 1.8;
                    var catIconY = menuPage._catY - catSz * 0.5;
                    if (tapX >= catIconX && tapX <= catIconX + catSz &&
                        tapY >= catIconY && tapY <= catIconY + catSz) {
                        menuPage.currentCategoryIndex = ci;
                        menuPage.currentSubItemIndex = 0;
                        var hitCat = menuPage.menuCategories[ci];
                        if (hitCat.subItems.length > 0) {
                            menuPage.inSubItems = true;
                        } else {
                            menuPage.inSubItems = false;
                            menuPage.selectCurrentItem();
                        }
                        return;
                    }
                }

                // TAP — hit-test sub-items
                var curCatTap = menuPage.menuCategories[menuPage.currentCategoryIndex];
                if (curCatTap && curCatTap.subItems.length > 0) {
                    var gap = Math.round(menuPage.height * 0.024);
                    for (var si = 0; si < curCatTap.subItems.length; si++) {
                        var subDist = si - menuPage.currentSubItemIndex;
                        var subIsSel = menuPage.inSubItems && menuPage.currentSubItemIndex === si;
                        var subH = subIsSel ? menuPage._subSelH : menuPage._subH;
                        var subY;
                        if (!menuPage.inSubItems) {
                            subY = menuPage._subStartY + si * menuPage._subH;
                        } else if (subDist < 0) {
                            var aboveAnchor = menuPage._catY - menuPage._iconSelSz * 1.0;
                            subY = aboveAnchor + (subDist + 1) * menuPage._subH - gap;
                        } else if (subDist === 0) {
                            subY = menuPage._subStartY;
                        } else {
                            subY = menuPage._subStartY + menuPage._subSelH + gap + (subDist - 1) * menuPage._subH;
                        }
                        var subX = menuPage._catX;
                        var subW = menuPage.width * 0.52;
                        if (tapX >= subX && tapX <= subX + subW &&
                            tapY >= subY && tapY <= subY + subH) {
                            menuPage.inSubItems = true;
                            menuPage.currentSubItemIndex = si;
                            menuPage.selectCurrentItem();
                            return;
                        }
                    }
                }

                // Tap on empty area
                if (menuPage.inSubItems) {
                    menuPage.inSubItems = false;
                    menuPage.currentSubItemIndex = 0;
                } else {
                    menuPage.close();
                }
                return;
            }

            var curCat;
            if (adx > ady) {
                // Horizontal swipe
                if (dx > 0) {
                    if (menuPage.currentCategoryIndex < menuPage.menuCategories.length - 1) {
                        menuPage.currentCategoryIndex++;
                        menuPage.currentSubItemIndex = 0;
                        curCat = menuPage.menuCategories[menuPage.currentCategoryIndex];
                        if (menuPage.inSubItems && (!curCat || curCat.subItems.length === 0))
                            menuPage.inSubItems = false;
                    }
                } else {
                    if (menuPage.currentCategoryIndex > 0) {
                        menuPage.currentCategoryIndex--;
                        menuPage.currentSubItemIndex = 0;
                        curCat = menuPage.menuCategories[menuPage.currentCategoryIndex];
                        if (menuPage.inSubItems && (!curCat || curCat.subItems.length === 0))
                            menuPage.inSubItems = false;
                    }
                }
            } else {
                // Vertical swipe
                if (dy > 0) {
                    if (!menuPage.inSubItems) {
                        curCat = menuPage.menuCategories[menuPage.currentCategoryIndex];
                        if (curCat && curCat.subItems.length > 0) {
                            menuPage.inSubItems = true;
                            menuPage.currentSubItemIndex = 0;
                        }
                    } else {
                        var subLen = menuPage.menuCategories[menuPage.currentCategoryIndex].subItems.length;
                        if (menuPage.currentSubItemIndex < subLen - 1)
                            menuPage.currentSubItemIndex++;
                    }
                } else {
                    if (menuPage.inSubItems) {
                        if (menuPage.currentSubItemIndex > 0) {
                            menuPage.currentSubItemIndex--;
                        } else {
                            menuPage.inSubItems = false;
                            menuPage.currentSubItemIndex = 0;
                        }
                    }
                }
            }
        }
    }

    // CATEGORY LABEL (top-left)

    Text {
        id: categoryLabel
        x: menuPage._catX
        y: Math.round(menuPage.height * 0.028)
        text: menuCategories[currentCategoryIndex].title
        font.pixelSize: Math.max(18, Math.round(menuPage.height * 0.034))
        font.weight: Font.DemiBold
        color: "#c8daea"
        opacity: (menuPage.reorderMode || menuPage.raLoginMode || menuPage.bgSettingsMode || menuPage.clockSettingsMode || menuPage.uiSettingsMode || menuPage.languageSettingsMode || menuPage.logsMode || menuPage.fileBrowserMode) ? 0 : 0.90
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
        Behavior on text { SequentialAnimation {
            NumberAnimation { target: categoryLabel; property: "opacity"; to: 0; duration: 120 }
            PropertyAction { target: categoryLabel; property: "text" }
            NumberAnimation { target: categoryLabel; property: "opacity"; to: 0.90; duration: 280; easing.type: Easing.OutQuad }
        }}
    }

    // Version info (bottom-left)
    Text {
        x: Math.round(menuPage.width * 0.02)
        y: menuPage.height - Math.round(menuPage.height * 0.05)
        text: "AcquaFlow v0.6.0"
        font.pixelSize: Math.max(10, Math.round(menuPage.height * 0.016))
        color: "#506070"
        opacity: (menuPage.reorderMode || menuPage.raLoginMode || menuPage.bgSettingsMode || menuPage.clockSettingsMode || menuPage.uiSettingsMode || menuPage.languageSettingsMode || menuPage.logsMode || menuPage.fileBrowserMode) ? 0 : 0.6
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    // HORIZONTAL CATEGORY ICONS

    Item {
        id: categoryBar
        x: ((menuPage.reorderMode || menuPage.raLoginMode || menuPage.bgSettingsMode || menuPage.clockSettingsMode || menuPage.uiSettingsMode || menuPage.languageSettingsMode || menuPage.logsMode || menuPage.fileBrowserMode) ? -menuPage.width * 0.06 : 0) + menuPage._menuSlide
        y: 0; width: parent.width; height: parent.height
        z: 1
        opacity: (menuPage.reorderMode || menuPage.raLoginMode || menuPage.bgSettingsMode || menuPage.clockSettingsMode || menuPage.uiSettingsMode || menuPage.languageSettingsMode || menuPage.logsMode || menuPage.fileBrowserMode) ? 0 : 1

        Behavior on x       { NumberAnimation { duration: 420; easing.type: Easing.OutQuad } }
        Behavior on opacity { NumberAnimation { duration: 360; easing.type: Easing.OutQuad } }

        Repeater {
            model: menuPage.menuCategories

            delegate: Item {
                id: catDel
                property int idx: index
                property bool isSel: menuPage.currentCategoryIndex === index
                property real dist: index - menuPage.currentCategoryIndex
                property real sz: isSel ? menuPage._iconSelSz : menuPage._iconSz

                x: {
                    var baseX = menuPage._catX + dist * menuPage._iconSpacing - sz * 0.5;
                    if (dist > 0) baseX += menuPage._iconSelSz * 1.8;
                    return baseX;
                }
                y: menuPage._catY - sz * 0.5
                width: sz
                height: sz
                z: isSel ? 2 : 1
                opacity: isSel ? 1.0 : Math.max(0.12, 1.0 - Math.abs(dist) * 0.22)

                Behavior on x       { NumberAnimation { duration: 360; easing.type: Easing.OutQuad } }
                Behavior on y       { NumberAnimation { duration: 340; easing.type: Easing.OutQuad } }
                Behavior on width   { NumberAnimation { duration: 380; easing.type: Easing.OutBack } }
                Behavior on height  { NumberAnimation { duration: 380; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

                // Outer glow behind selected category
                Rectangle {
                    id: catGlow
                    visible: catDel.isSel
                    anchors.centerIn: parent
                    width: parent.width * 1.50
                    height: width
                    radius: width * 0.5
                    color: "transparent"
                    border.color: catDel.isSel ? "#18ffffff" : "transparent"
                    border.width: Math.round(menuPage.height * 0.003)
                    opacity: catDel.isSel ? 1.0 : 0

                    Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutQuad } }
                }

                // Soft radial glow
                Rectangle {
                    visible: catDel.isSel
                    anchors.centerIn: parent
                    width: parent.width * 1.80
                    height: width
                    radius: width * 0.5
                    color: "#08b0d0ff"
                    opacity: catDel.isSel ? 1.0 : 0
                    Behavior on opacity { NumberAnimation { duration: 400 } }
                }

                // Icon circle
                Rectangle {
                    anchors.fill: parent
                    radius: width * 0.5
                    color: catDel.isSel ? "#dce8f4" : "transparent"
                    border.color: catDel.isSel ? "transparent" : "#20ffffff"
                    border.width: catDel.isSel ? 0 : Math.max(1, Math.round(menuPage.height * 0.0016))

                    Behavior on color        { ColorAnimation { duration: 340; easing.type: Easing.OutQuad } }
                    Behavior on border.color  { ColorAnimation { duration: 340 } }

                    // Canvas icon drawn consistently for all categories
                    Canvas {
                        id: iconCanvas
                        anchors.centerIn: parent
                        width: Math.round(parent.width * 0.48)
                        height: width
                        property color iconColor: catDel.isSel ? "#162c48" : "#8aa0b8"
                        property string catId: modelData.id

                        onIconColorChanged: requestPaint()
                        Component.onCompleted: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var w = width;
                            var h = height;
                            var cx = w / 2;
                            var cy = h / 2;
                            var lw = Math.max(1.5, w * 0.08);
                            ctx.lineWidth = lw;
                            ctx.strokeStyle = iconColor;
                            ctx.fillStyle = iconColor;
                            ctx.lineCap = "round";
                            ctx.lineJoin = "round";

                            if (catId === "platforms") {
                                // Diamond (rotated square)
                                var s = w * 0.38;
                                ctx.beginPath();
                                ctx.moveTo(cx, cy - s);
                                ctx.lineTo(cx + s, cy);
                                ctx.lineTo(cx, cy + s);
                                ctx.lineTo(cx - s, cy);
                                ctx.closePath();
                                ctx.fill();
                            } else if (catId === "ra") {
                                // 5-point star
                                var outerR = w * 0.42;
                                var innerR = outerR * 0.40;
                                ctx.beginPath();
                                for (var i = 0; i < 10; i++) {
                                    var r = (i % 2 === 0) ? outerR : innerR;
                                    var angle = -Math.PI / 2 + i * Math.PI / 5;
                                    var px = cx + r * Math.cos(angle);
                                    var py = cy + r * Math.sin(angle);
                                    if (i === 0) ctx.moveTo(px, py);
                                    else ctx.lineTo(px, py);
                                }
                                ctx.closePath();
                                ctx.fill();
                            } else if (catId === "settings") {
                                // Gear: outer ring with teeth + inner circle
                                var outerR2 = w * 0.40;
                                var innerR2 = outerR2 * 0.70;
                                var teeth = 8;
                                var toothH = outerR2 * 0.28;
                                ctx.beginPath();
                                for (var t = 0; t < teeth; t++) {
                                    var a1 = (t / teeth) * Math.PI * 2 - Math.PI / 2;
                                    var a2 = ((t + 0.35) / teeth) * Math.PI * 2 - Math.PI / 2;
                                    var a3 = ((t + 0.65) / teeth) * Math.PI * 2 - Math.PI / 2;
                                    var a4 = ((t + 1) / teeth) * Math.PI * 2 - Math.PI / 2;
                                    if (t === 0) ctx.moveTo(cx + (outerR2 + toothH) * Math.cos(a1), cy + (outerR2 + toothH) * Math.sin(a1));
                                    ctx.lineTo(cx + (outerR2 + toothH) * Math.cos(a2), cy + (outerR2 + toothH) * Math.sin(a2));
                                    ctx.lineTo(cx + outerR2 * Math.cos(a3), cy + outerR2 * Math.sin(a3));
                                    ctx.lineTo(cx + outerR2 * Math.cos(a4), cy + outerR2 * Math.sin(a4));
                                    ctx.lineTo(cx + (outerR2 + toothH) * Math.cos(a4), cy + (outerR2 + toothH) * Math.sin(a4));
                                }
                                ctx.closePath();
                                ctx.fill();
                                // Inner hole
                                ctx.globalCompositeOperation = "destination-out";
                                ctx.beginPath();
                                ctx.arc(cx, cy, innerR2, 0, Math.PI * 2);
                                ctx.fill();
                                ctx.globalCompositeOperation = "source-over";
                            } else if (catId === "about") {
                                // Info: circle with "i" inside
                                ctx.beginPath();
                                ctx.arc(cx, cy, w * 0.40, 0, Math.PI * 2);
                                ctx.stroke();
                                // Dot
                                ctx.beginPath();
                                ctx.arc(cx, cy - h * 0.16, lw * 0.8, 0, Math.PI * 2);
                                ctx.fill();
                                // Line
                                ctx.beginPath();
                                ctx.moveTo(cx, cy - h * 0.04);
                                ctx.lineTo(cx, cy + h * 0.22);
                                ctx.stroke();
                            } else if (catId === "exit") {
                                // X cross
                                var s2 = w * 0.28;
                                ctx.beginPath();
                                ctx.moveTo(cx - s2, cy - s2);
                                ctx.lineTo(cx + s2, cy + s2);
                                ctx.stroke();
                                ctx.beginPath();
                                ctx.moveTo(cx + s2, cy - s2);
                                ctx.lineTo(cx - s2, cy + s2);
                                ctx.stroke();
                            }
                        }
                    }
                }
            }
        }
    }

    // VERTICAL SUB-ITEMS LIST

    Item {
        id: subItemsArea
        x: ((menuPage.reorderMode || menuPage.raLoginMode || menuPage.bgSettingsMode || menuPage.clockSettingsMode || menuPage.uiSettingsMode || menuPage.languageSettingsMode || menuPage.logsMode || menuPage.fileBrowserMode) ? -menuPage.width * 0.06 : 0) + menuPage._menuSlide
        y: 0; width: parent.width; height: parent.height
        clip: true
        z: 2

        Behavior on x { NumberAnimation { duration: 420; easing.type: Easing.OutQuad } }

        // Show dimmed when browsing categories, bright when focused (hidden in reorder/login mode)
        opacity: {
            if (menuPage.reorderMode || menuPage.raLoginMode || menuPage.bgSettingsMode || menuPage.clockSettingsMode || menuPage.uiSettingsMode || menuPage.languageSettingsMode || menuPage.logsMode || menuPage.fileBrowserMode) return 0.0;
            var cat = menuPage.menuCategories[menuPage.currentCategoryIndex];
            if (!cat || cat.subItems.length === 0) return 0.0;
            return menuPage.inSubItems ? 1.0 : 0.38;
        }
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutQuad } }

        // Empty platforms message
        Text {
            visible: {
                var cat = menuPage.menuCategories[menuPage.currentCategoryIndex];
                return cat.id === "platforms" && cat.subItems.length === 0;
            }
            x: menuPage._catX
            y: menuPage._subStartY
            text: T.t("no_platforms", menuPage.lang)
            color: "#506880"
            font.pixelSize: menuPage._fItem
        }

        Repeater {
            model: menuPage.menuCategories[menuPage.currentCategoryIndex].subItems

            delegate: Item {
                id: subDel
                property int subIdx: index
                property bool isSel: menuPage.inSubItems && menuPage.currentSubItemIndex === index
                property real dist: index - menuPage.currentSubItemIndex

                x: menuPage._catX
                y: {
                    var base = menuPage._subStartY;
                    if (!menuPage.inSubItems) {
                        return base + index * menuPage._subH;
                    }
                    var gap = Math.round(menuPage.height * 0.024);
                    if (dist < 0) {
                        // Items above: stack upward from above the category icon
                        var aboveAnchor = menuPage._catY - menuPage._iconSelSz * 1.0;
                        // dist is negative, so (dist + 1) positions them upward from the anchor
                        return aboveAnchor + (dist + 1) * menuPage._subH - gap;
                    } else if (dist === 0) {
                        return base;
                    } else {
                        return base + menuPage._subSelH + gap + (dist - 1) * menuPage._subH;
                    }
                }
                width: parent.width * 0.52
                height: subDel.isSel ? menuPage._subSelH : menuPage._subH
                opacity: {
                    if (!menuPage.inSubItems) return 0.65;
                    var d = Math.abs(dist);
                    return d === 0 ? 1.0 : Math.max(0.0, 1.0 - d * 0.18);
                }

                Behavior on y       { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                Behavior on opacity { NumberAnimation { duration: 180 } }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Math.round(menuPage.height * 0.012)

                    // Sub-item icon
                    Rectangle {
                        property real sz: subDel.isSel ? Math.round(menuPage.height * 0.048) : Math.round(menuPage.height * 0.030)
                        width: sz; height: sz
                        radius: Math.round(sz * 0.22)
                        color: subDel.isSel ? "#20ffffff" : "#08ffffff"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "\u25B8"
                            font.pixelSize: Math.round(parent.width * 0.48)
                            color: subDel.isSel ? "#e0eeff" : "#5878a0"
                        }
                    }

                    // Title + subtitle
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Math.round(menuPage.height * 0.003)

                        Text {
                            text: modelData.title
                            font.pixelSize: subDel.isSel ? menuPage._fItemSel : menuPage._fItem
                            font.bold: subDel.isSel
                            color: subDel.isSel ? "#ffffff" : "#8098b0"
                        }

                        Text {
                            visible: subDel.isSel && modelData.subtitle !== undefined && modelData.subtitle !== ""
                            text: modelData.subtitle || ""
                            font.pixelSize: menuPage._fSub
                            color: "#6090c0"
                        }
                    }
                }

                // BoxBack status indicator (checkmark / X)
                Canvas {
                    id: bbStatusCanvas
                    property bool isPlatform: modelData.id !== undefined && modelData.id.indexOf("platform_select_") === 0
                    property string shortName: isPlatform ? modelData.id.replace("platform_select_", "").toLowerCase() : ""
                    property bool hasBoxback: isPlatform && (api.memory.get("boxback_path_" + shortName) || "") !== ""
                    visible: isPlatform && menuPage.menuCategories[menuPage.currentCategoryIndex].id === "platforms"
                    property real sz: subDel.isSel ? Math.round(menuPage.height * 0.026) : Math.round(menuPage.height * 0.018)
                    width: sz; height: sz
                    anchors.right: parent.right
                    anchors.rightMargin: Math.round(parent.width * 0.04)
                    anchors.verticalCenter: parent.verticalCenter
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.lineWidth = Math.max(1.5, sz * 0.18);
                        ctx.lineCap = "round";
                        ctx.lineJoin = "round";
                        if (hasBoxback) {
                            // Checkmark
                            ctx.strokeStyle = "#60d080";
                            ctx.beginPath();
                            ctx.moveTo(sz * 0.15, sz * 0.55);
                            ctx.lineTo(sz * 0.40, sz * 0.80);
                            ctx.lineTo(sz * 0.85, sz * 0.20);
                            ctx.stroke();
                        } else {
                            // X mark
                            ctx.strokeStyle = "#c05050";
                            ctx.beginPath();
                            ctx.moveTo(sz * 0.20, sz * 0.20);
                            ctx.lineTo(sz * 0.80, sz * 0.80);
                            ctx.stroke();
                            ctx.beginPath();
                            ctx.moveTo(sz * 0.80, sz * 0.20);
                            ctx.lineTo(sz * 0.20, sz * 0.80);
                            ctx.stroke();
                        }
                    }
                    onSzChanged: requestPaint()
                    onHasBoxbackChanged: requestPaint()
                }
            }
        }
    }

    // INLINE REORDER PANEL

    PlatformReorderPanel {
        id: inlineReorderPanel
        anchors.fill: parent
        z: 3
        collections: menuPage.collections
        gcGameCount: menuPage.gcGameCount
        lang: menuPage.lang

        onClosed: {
            menuPage.reorderMode = false;
            menuPage.forceActiveFocus();
        }

        onOrderSaved: {
            menuPage.platformOrderChanged(orderArray, lpVisible, raVis, favVis);
        }
    }

    // INLINE RA LOGIN PANEL

    RALoginPanel {
        id: inlineLoginPanel
        anchors.fill: parent
        z: 3
        lang: menuPage.lang

        onClosed: {
            menuPage.raLoginMode = false;
            menuPage.forceActiveFocus();
        }
    }

    // INLINE BG SETTINGS PANEL

    BackgroundSettingsPanel {
        id: inlineBgPanel
        anchors.fill: parent
        z: 3
        lang: menuPage.lang

        onClosed: {
            menuPage.bgSettingsMode = false;
            menuPage.forceActiveFocus();
        }

        onSettingsChanged: {
            menuPage.refreshMenuGradient();
            menuPage.bgSettingsApplied(useArtwork, useVideo, bgSource, customPath, blurIntensity);
        }
    }

    // INLINE CLOCK SETTINGS PANEL

    ClockSettingsPanel {
        id: inlineClockPanel
        anchors.fill: parent
        z: 3
        lang: menuPage.lang

        onClosed: {
            menuPage.clockSettingsMode = false;
            menuPage.forceActiveFocus();
        }

        onSettingsChanged: {
            menuPage.clockSettingsApplied(use24h, fontIndex, colorIndex);
        }
    }

    // INLINE UI SETTINGS PANEL

    UISettingsPanel {
        id: inlineUiPanel
        anchors.fill: parent
        z: 3
        lang: menuPage.lang

        onClosed: {
            menuPage.uiSettingsMode = false;
            menuPage.forceActiveFocus();
        }

        onSettingsChanged: {
            menuPage.uiSettingsApplied(platformBarAutoHide, showLogoOutline, showBattery, showWifi, screenSizeMode);
        }
    }

    // INLINE LANGUAGE SETTINGS PANEL

    LanguageSettingsPanel {
        id: inlineLangPanel
        anchors.fill: parent
        z: 3

        onClosed: {
            menuPage.languageSettingsMode = false;
            menuPage.forceActiveFocus();
        }

        onSettingsChanged: {
            menuPage.languageSettingsApplied(lang);
        }
    }

    // INLINE LOGS PANEL

    LogsPanel {
        id: inlineLogsPanel
        anchors.fill: parent
        z: 3

        onClosed: {
            menuPage.logsMode = false;
            menuPage.forceActiveFocus();
        }
    }

    // FILE BROWSER (back covers)

    FileBrowser {
        id: menuFileBrowser
        anchors.fill: parent
        z: 5
        visible: false
        folderMode: true
        lang: menuPage.lang

        onFolderSelected: {
            api.memory.set("boxback_path_" + menuPage._fbPlatformShortName, folderPath);
            console.log("[MenuPage] BoxBack path for " + menuPage._fbPlatformShortName + " = " + folderPath);
            menuPage.boxbackPathChanged();
            menuPage._needsRestart = true;
            menuPage.fileBrowserMode = false;
            menuFileBrowser.close();
            menuPage.forceActiveFocus();
            menuPage.updatePlatformSubItems();
        }

        onCancelled: {
            menuPage.fileBrowserMode = false;
            menuFileBrowser.close();
            menuPage.forceActiveFocus();
        }
    }

    // NAVIGATION LEGEND

    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.round(menuPage.height * 0.025)
        anchors.right: parent.right
        anchors.rightMargin: Math.round(menuPage.width * 0.025)
        font.pixelSize: Math.max(11, Math.round(menuPage.height * 0.016))
        color: "#ffffff"
        opacity: (menuPage.reorderMode || menuPage.raLoginMode || menuPage.bgSettingsMode || menuPage.clockSettingsMode || menuPage.uiSettingsMode || menuPage.languageSettingsMode || menuPage.logsMode || menuPage.fileBrowserMode) ? 0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 300 } }
        text: {
            var cat = menuPage.menuCategories[menuPage.currentCategoryIndex];
            if (!menuPage.inSubItems)
                return T.t("hint_cat_nav", menuPage.lang);
            if (cat.id === "platforms" && menuPage.currentSubItemIndex > 0)
                return T.t("hint_plat_nav", menuPage.lang);
            return T.t("hint_sub_nav", menuPage.lang);
        }
    }

    // Restart notice (shown after selecting a boxback folder)
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.round(menuPage.height * 0.055)
        anchors.right: parent.right
        anchors.rightMargin: Math.round(menuPage.width * 0.025)
        font.pixelSize: Math.max(11, Math.round(menuPage.height * 0.016))
        font.bold: true
        color: "#e04040"
        opacity: menuPage._needsRestart && !(menuPage.reorderMode || menuPage.raLoginMode || menuPage.bgSettingsMode || menuPage.clockSettingsMode || menuPage.uiSettingsMode || menuPage.languageSettingsMode || menuPage.logsMode || menuPage.fileBrowserMode) ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }
        text: T.t("hint_restart", menuPage.lang)
    }

    // KEYBOARD NAVIGATION

    Keys.onPressed: {
        if (menuPage.reorderMode || menuPage.raLoginMode || menuPage.bgSettingsMode || menuPage.clockSettingsMode || menuPage.logsMode) { event.accepted = false; return; }

        // Forward to file browser when active
        if (menuPage.fileBrowserMode) {
            menuFileBrowser.handleKey(event);
            event.accepted = true;
            return;
        }

        event.accepted = true;

        // Gamepad button codes (Android confirmed)
        var isAccept = (event.key === Qt.Key_Return || event.key === Qt.Key_Enter ||
                        event.key === 1048576);  // Gamepad A
        var isBack   = (event.key === Qt.Key_Escape || event.key === Qt.Key_Back ||
                        event.key === Qt.Key_Backspace || event.key === 1048577);  // Gamepad B
        var isUp     = (event.key === Qt.Key_Up);
        var isDown   = (event.key === Qt.Key_Down);
        var isLeft   = (event.key === Qt.Key_Left);
        var isRight  = (event.key === Qt.Key_Right);
        var isX      = (event.key === 1048578);  // Gamepad X

        if (menuPage.inSubItems) {
            var subItems = menuPage.menuCategories[menuPage.currentCategoryIndex].subItems;

            if (isUp) {
                if (menuPage.currentSubItemIndex > 0) {
                    menuPage.currentSubItemIndex--;
                } else {
                    // Top of list: back to category bar
                    menuPage.inSubItems = false;
                    menuPage.currentSubItemIndex = 0;
                }
            } else if (isDown) {
                if (menuPage.currentSubItemIndex < subItems.length - 1) {
                    menuPage.currentSubItemIndex++;
                }
            } else if (isLeft) {
                if (menuPage.currentCategoryIndex > 0) {
                    menuPage.currentCategoryIndex--;
                    menuPage.currentSubItemIndex = 0;
                    var catL = menuPage.menuCategories[menuPage.currentCategoryIndex];
                    if (catL.subItems.length === 0) menuPage.inSubItems = false;
                }
            } else if (isRight) {
                if (menuPage.currentCategoryIndex < menuPage.menuCategories.length - 1) {
                    menuPage.currentCategoryIndex++;
                    menuPage.currentSubItemIndex = 0;
                    var catR = menuPage.menuCategories[menuPage.currentCategoryIndex];
                    if (catR.subItems.length === 0) menuPage.inSubItems = false;
                }
            } else if (isAccept) {
                // A on platform items opens back cover file browser
                var curCat2 = menuPage.menuCategories[menuPage.currentCategoryIndex];
                if (curCat2.id === "platforms" && menuPage.currentSubItemIndex > 0) {
                    var subItem2 = curCat2.subItems[menuPage.currentSubItemIndex];
                    if (subItem2 && subItem2.id.indexOf("platform_select_") === 0) {
                        var shortName2 = subItem2.id.replace("platform_select_", "").toLowerCase();
                        menuPage._fbPlatformShortName = shortName2;
                        menuPage.fileBrowserMode = true;
                        var existing2 = api.memory.get("boxback_path_" + shortName2) || "";
                        menuFileBrowser.open(existing2);
                        return;
                    }
                }
                menuPage.selectCurrentItem();
            } else if (isBack) {
                menuPage.inSubItems = false;
                menuPage.currentSubItemIndex = 0;
            } else {
                event.accepted = false;
            }

        } else {
            // Category bar navigation
            if (isLeft) {
                if (menuPage.currentCategoryIndex > 0) {
                    menuPage.currentCategoryIndex--;
                } else {
                    menuPage.currentCategoryIndex = menuPage.menuCategories.length - 1;
                }
                menuPage.currentSubItemIndex = 0;
            } else if (isRight) {
                if (menuPage.currentCategoryIndex < menuPage.menuCategories.length - 1) {
                    menuPage.currentCategoryIndex++;
                } else {
                    menuPage.currentCategoryIndex = 0;
                }
                menuPage.currentSubItemIndex = 0;
            } else if (isDown || isAccept) {
                var cat = menuPage.menuCategories[menuPage.currentCategoryIndex];
                if (cat.subItems.length > 0) {
                    menuPage.inSubItems = true;
                    menuPage.currentSubItemIndex = 0;
                } else {
                    menuPage.selectCurrentItem();
                }
            } else if (isBack) {
                menuPage.close();
            } else {
                event.accepted = false;
            }
        }
    }

    // ANIMATIONS

    // Slide+fade entrance property
    property real _menuSlide: 0

    ParallelAnimation {
        id: openAnim
        NumberAnimation {
            target: menuPage; property: "opacity"
            from: 0; to: 1; duration: 480
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: menuPage; property: "_menuSlide"
            from: -menuPage.width * 0.025; to: 0; duration: 520
            easing.type: Easing.OutQuad
        }
        onFinished: menuPage.isOpen = true
    }

    ParallelAnimation {
        id: closeAnim
        NumberAnimation {
            target: menuPage; property: "opacity"
            from: 1; to: 0; duration: 280
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: menuPage; property: "_menuSlide"
            from: 0; to: menuPage.width * 0.015; duration: 280
            easing.type: Easing.InQuad
        }
        onFinished: {
            menuPage.visible = false;
            menuPage.isOpen = false;
            menuPage._menuSlide = 0;
            menuPage.menuClosed();
        }
    }

    // FUNCTIONS

    function open() {
        if (visible) return;
        refreshMenuGradient();
        visible = true;
        opacity = 0;
        isOpen = true;
        currentCategoryIndex = 0;
        currentSubItemIndex = 0;
        inSubItems = false;
        updatePlatformSubItems();
        forceActiveFocus();
        openAnim.start();
    }

    function close() {
        if (closeAnim.running || !visible) return;
        closeAnim.start();
    }

    function selectCurrentItem() {
        var cat = menuCategories[currentCategoryIndex];
        var itemId = "";

        if (cat.subItems.length > 0 && inSubItems) {
            itemId = cat.subItems[currentSubItemIndex].id;
        } else {
            itemId = cat.id;
        }

        // Block "Coming Soon" items
        if (itemId === "theme_settings" || itemId === "text_settings" ||
            itemId === "controls_settings" || itemId === "audio_settings") {
            return;
        }

        if (itemId === "platform_reorder") {
            reorderMode = true;
            inlineReorderPanel.openPanel();
            return;
        } else if (itemId === "background_settings") {
            bgSettingsMode = true;
            inlineBgPanel.openPanel();
            return;
        } else if (itemId === "clock_settings") {
            clockSettingsMode = true;
            inlineClockPanel.openPanel();
            return;
        } else if (itemId === "ui_settings") {
            uiSettingsMode = true;
            inlineUiPanel.openPanel();
            return;
        } else if (itemId === "language_settings") {
            languageSettingsMode = true;
            inlineLangPanel.openPanel();
            return;
        } else if (itemId === "logs") {
            logsMode = true;
            inlineLogsPanel.openPanel();
            return;
        } else if (itemId === "ra_login") {
            raLoginMode = true;
            inlineLoginPanel.openPanel();
            return;
        } else if (itemId.indexOf("platform_select_") === 0) {
            // Noop for now (future feature)
            return;
        } else if (itemId === "exit") {
            close();
        } else {
            menuItemSelected(itemId);
        }
    }

    function updatePlatformSubItems() {
        if (!collections) return;

        var platformCategory = null;
        for (var i = 0; i < menuCategories.length; i++) {
            if (menuCategories[i].id === "platforms") {
                platformCategory = menuCategories[i];
                break;
            }
        }
        if (!platformCategory) return;

        var newSubItems = [];
        // Fixed first item: reorder platforms
        newSubItems.push({
            id: "platform_reorder",
            title: T.t("reorder_platforms", menuPage.lang),
            subtitle: T.t("reorder_platforms_sub", menuPage.lang)
        });
        for (var j = 0; j < collections.count; j++) {
            var collection = collections.get(j);
            if (collection) {
                var gameCount = (collection.games && collection.games.count !== undefined) ? collection.games.count : -1;
                if (gameCount > 0) {
                    var bbPath = api.memory.get("boxback_path_" + collection.shortName.toLowerCase());
                    var bbInfo = (bbPath && bbPath !== "") ? "  \u00b7  \u2713 Back covers" : "";
                    newSubItems.push({
                        id: "platform_select_" + collection.shortName,
                        title: collection.name,
                        subtitle: gameCount + T.t("games_suffix", menuPage.lang) + bbInfo
                    });
                }
            }
        }
        platformCategory.subItems = newSubItems;
        // Force QML to re-evaluate bindings on menuCategories
        var tmp = menuCategories;
        menuCategories = [];
        menuCategories = tmp;
    }

    Component.onCompleted: { refreshMenuGradient(); updatePlatformSubItems(); }

    Connections {
        target: menuPage
        function onCollectionsChanged() {
            updatePlatformSubItems();
        }
    }
}
