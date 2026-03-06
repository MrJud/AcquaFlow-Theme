import QtQuick 2.15
import "../../components/config/Translations.js" as T

// FileBrowser — Uses Pegasus.FolderListModel via Loader
// The model is used DIRECTLY as ListView model so that
// "name" and "isDir" roles work natively in delegates.
Item {
    id: browser
    visible: false
    opacity: 0

    property string selectedFile: ""
    property string currentFolder: ""
    property bool folderMode: false

    // Language
    property string lang: "it"

    property bool _ready: false
    property bool _fallbackMode: false
    property var _model: null

    signal fileSelected(string filePath)
    signal folderSelected(string folderPath)
    signal cancelled()

    // Layout
    readonly property real _fTitle: Math.max(14, Math.round(height * 0.025))
    readonly property real _fItem:  Math.max(12, Math.round(height * 0.020))
    readonly property real _fHint:  Math.max(10, Math.round(height * 0.015))
    readonly property real _rowH:   Math.round(height * 0.044)
    readonly property real _iconSz: Math.round(height * 0.028)

    // LOADER

    Loader {
        id: modelLoader
        active: false
        source: "FileBrowserModel.qml"
        onStatusChanged: {
            if (status === Loader.Ready && item) {
                console.log("[FileBrowser] Model OK, folder=" + item.folder);
                browser._model = item;
                browser._ready = true;
                browser._fallbackMode = false;
                browser.currentFolder = item.folder || "";
            } else if (status === Loader.Error) {
                console.warn("[FileBrowser] Model FAILED — fallback mode");
                browser._ready = false;
                browser._fallbackMode = true;
            }
        }
    }

    // BACKGROUND

    Rectangle { anchors.fill: parent; color: "#080c14"; opacity: 0.97 }

    // HEADER

    Item {
        id: hdr
        width: parent.width; height: Math.round(parent.height * 0.08)
        visible: !browser._fallbackMode

        Text {
            id: hdrTitle; x: Math.round(parent.width * 0.03)
            anchors.verticalCenter: parent.verticalCenter
            text: browser.folderMode ? T.t("fb_select_folder", browser.lang) : T.t("fb_browse", browser.lang)
            font.pixelSize: browser._fTitle; font.bold: true; color: "#c0d8f0"
        }
        Text {
            anchors.left: hdrTitle.right
            anchors.leftMargin: Math.round(parent.width * 0.01)
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Math.round(parent.width * 0.03)
            text: browser.currentFolder
            font.pixelSize: browser._fHint
            color: "#3a5a78"; elide: Text.ElideMiddle; horizontalAlignment: Text.AlignRight
        }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#14253a" }
    }

    // FILE LIST
    // Model is the Pegasus FolderListModel directly — roles "name" and "isDir"

    ListView {
        id: fileList
        anchors.top: hdr.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: Math.round(parent.width * 0.03)
        anchors.right: previewCol.left
        anchors.rightMargin: Math.round(parent.width * 0.015)
        anchors.bottom: hints.top
        anchors.bottomMargin: 4
        clip: true
        model: browser._model
        highlightMoveDuration: 80
        preferredHighlightBegin: height * 0.35
        preferredHighlightEnd: height * 0.65
        highlightRangeMode: ListView.ApplyRange
        visible: !browser._fallbackMode

        onCurrentIndexChanged: browser._updatePreview()

        delegate: Item {
            id: del
            width: fileList.width
            height: browser._rowH

            // Expose to parent for reading
            property string entryName: name
            property bool entryIsDir: isDir

            Rectangle {
                anchors.fill: parent; radius: 4
                color: del.ListView.isCurrentItem ? "#10ffffff" : "transparent"
                border.color: del.ListView.isCurrentItem ? "#1a3860" : "transparent"
                border.width: del.ListView.isCurrentItem ? 1 : 0
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Math.round(browser.width * 0.006)
                spacing: Math.round(browser.width * 0.006)

                Canvas {
                    width: browser._iconSz; height: browser._iconSz
                    anchors.verticalCenter: parent.verticalCenter
                    property bool d: isDir
                    property string n: name
                    onPaint: {
                        var ctx = getContext("2d"), w = width, h = height;
                        ctx.clearRect(0, 0, w, h);
                        if (n === "..") {
                            ctx.strokeStyle = "#6090b8"; ctx.lineWidth = 1.5;
                            ctx.beginPath();
                            ctx.moveTo(w*.5, h*.2); ctx.lineTo(w*.5, h*.8);
                            ctx.moveTo(w*.25, h*.45); ctx.lineTo(w*.5, h*.2);
                            ctx.lineTo(w*.75, h*.45); ctx.stroke();
                        } else if (d) {
                            ctx.strokeStyle = "#78a8d0"; ctx.lineWidth = 1.2;
                            ctx.beginPath();
                            ctx.moveTo(w*.05,h*.28); ctx.lineTo(w*.05,h*.82); ctx.lineTo(w*.95,h*.82);
                            ctx.lineTo(w*.95,h*.38); ctx.lineTo(w*.50,h*.38); ctx.lineTo(w*.42,h*.25);
                            ctx.lineTo(w*.05,h*.25); ctx.closePath(); ctx.stroke();
                        } else {
                            ctx.strokeStyle = "#5898c8"; ctx.lineWidth = 1.0;
                            ctx.strokeRect(w*.12,h*.12,w*.76,h*.76);
                            ctx.beginPath();
                            ctx.moveTo(w*.18,h*.72); ctx.lineTo(w*.42,h*.40); ctx.lineTo(w*.58,h*.55);
                            ctx.lineTo(w*.72,h*.35); ctx.lineTo(w*.82,h*.72); ctx.stroke();
                        }
                    }
                }

                Text {
                    text: name
                    font.pixelSize: browser._fItem
                    color: isDir ? "#90b0d0" : "#c0d8f0"
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    width: fileList.width * 0.72
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    fileList.currentIndex = index;
                    browser._activateCurrent();
                }
            }
        }
    }

    // PREVIEW

    Column {
        id: previewCol
        anchors.right: parent.right
        anchors.rightMargin: Math.round(parent.width * 0.03)
        anchors.top: hdr.bottom
        anchors.topMargin: Math.round(parent.height * 0.015)
        width: Math.round(parent.width * 0.22)
        spacing: Math.round(parent.height * 0.012)
        visible: !browser._fallbackMode

        Rectangle {
            width: parent.width; height: Math.round(browser.height * 0.28)
            radius: 6; color: "#08ffffff"
            border.color: pvImg.status === Image.Ready ? "#1a3a60" : "#0a1828"; border.width: 1

            Image {
                id: pvImg; anchors.fill: parent; anchors.margins: 3
                fillMode: Image.PreserveAspectFit; asynchronous: true; cache: false
                source: browser._pvSrc
            }
            Text {
                anchors.centerIn: parent
                visible: pvImg.source == "" || pvImg.status !== Image.Ready
                text: T.t("fb_preview", browser.lang); font.pixelSize: browser._fHint; color: "#253040"
            }
        }
    }

    property string _pvSrc: ""

    function _updatePreview() {
        var ci = fileList.currentItem;
        if (ci && !ci.entryIsDir && ci.entryName && ci.entryName !== "..") {
            _pvSrc = "file://" + currentFolder + "/" + ci.entryName;
        } else {
            _pvSrc = "";
        }
    }

    // FALLBACK

    Item {
        id: fallbackUI; anchors.fill: parent; visible: browser._fallbackMode

        property int scIdx: 0
        property var sc: [
            { label: T.t("fb_images", browser.lang),  path: "/storage/emulated/0/Pictures" },
            { label: "Download",  path: "/storage/emulated/0/Download" },
            { label: "DCIM",      path: "/storage/emulated/0/DCIM" },
            { label: T.t("fb_documents", browser.lang), path: "/storage/emulated/0/Documents" },
            { label: "Home",      path: "/storage/emulated/0" }
        ]

        Column {
            anchors.centerIn: parent
            spacing: Math.round(parent.height * 0.02)
            width: parent.width * 0.58

            Text {
                width: parent.width; text: T.t("fb_custom_bg", browser.lang)
                font.pixelSize: browser._fTitle; font.bold: true
                color: "#c0d8f0"; horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width
                text: "Inserisci percorso  ·  A conferma  ·  B annulla"
                font.pixelSize: browser._fHint; color: "#4a6a88"
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                width: parent.width; height: Math.round(browser.height * 0.048)
                Rectangle {
                    anchors.fill: parent; radius: 6; color: "#0cffffff"
                    border.color: fbInput.activeFocus ? "#3070a0" : "#1a3860"; border.width: 1
                }
                TextInput {
                    id: fbInput; anchors.fill: parent
                    anchors.margins: Math.round(browser.width * 0.008)
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: browser._fItem; color: "#c0d8f0"
                    selectionColor: "#2060a0"; selectedTextColor: "#fff"; clip: true
                    text: browser.selectedFile
                    onAccepted: { if (text !== "") browser.fileSelected(text); }
                }
                Text {
                    anchors.fill: parent; anchors.margins: Math.round(browser.width * 0.008)
                    verticalAlignment: Text.AlignVCenter; font.pixelSize: browser._fItem
                    color: "#304860"; text: "/storage/emulated/0/Pictures/wall.jpg"
                    visible: fbInput.text === "" && !fbInput.activeFocus
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Math.round(browser.width * 0.01)
                Repeater {
                    model: fallbackUI.sc
                    delegate: Rectangle {
                        width: scL.implicitWidth + Math.round(browser.width * 0.016)
                        height: Math.round(browser.height * 0.038); radius: 5
                        color: index === fallbackUI.scIdx ? "#183050" : "#0a1828"
                        border.color: index === fallbackUI.scIdx ? "#2a5a90" : "#14253a"
                        border.width: 1
                        Text {
                            id: scL; anchors.centerIn: parent; text: modelData.label
                            font.pixelSize: browser._fHint
                            font.bold: index === fallbackUI.scIdx
                            color: index === fallbackUI.scIdx ? "#b0d0f0" : "#506878"
                        }
                        MouseArea { anchors.fill: parent; onClicked: {
                            fallbackUI.scIdx = index;
                            fbInput.text = modelData.path + "/";
                            fbInput.forceActiveFocus();
                            fbInput.cursorPosition = fbInput.text.length;
                        }}
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Math.round(browser.width * 0.02)
                Rectangle {
                    width: Math.round(browser.width * 0.12)
                    height: Math.round(browser.height * 0.040)
                    radius: 6; color: "#1a3860"; border.color: "#2a5080"; border.width: 1
                    Text { anchors.centerIn: parent; text: T.t("fb_confirm", browser.lang)
                           font.pixelSize: browser._fHint; color: "#98c0e0" }
                    MouseArea { anchors.fill: parent
                        onClicked: { if (fbInput.text !== "") browser.fileSelected(fbInput.text); } }
                }
                Rectangle {
                    width: Math.round(browser.width * 0.12)
                    height: Math.round(browser.height * 0.040)
                    radius: 6; color: "#0a1828"; border.color: "#1a3050"; border.width: 1
                    Text { anchors.centerIn: parent; text: T.t("fb_cancel", browser.lang)
                           font.pixelSize: browser._fHint; color: "#506070" }
                    MouseArea { anchors.fill: parent; onClicked: browser.cancelled() }
                }
            }
        }
    }

    // HINTS

    Item {
        id: hints
        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
        height: Math.round(parent.height * 0.046)
        Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: "#14253a" }
        Text {
            anchors.centerIn: parent; font.pixelSize: browser._fHint; color: "#3a5a78"
            text: browser._fallbackMode
                ? T.t("fb_hint_fallback", browser.lang)
                : (browser.folderMode
                    ? T.t("fb_hint_folder", browser.lang)
                    : T.t("fb_hint_normal", browser.lang))
        }
    }

    // Warning text for folder mode
    Text {
        visible: browser.folderMode && !browser._fallbackMode
        anchors.bottom: hints.top
        anchors.bottomMargin: Math.round(browser.height * 0.01)
        anchors.right: parent.right
        anchors.rightMargin: Math.round(browser.width * 0.025)
        font.pixelSize: Math.max(10, Math.round(browser.height * 0.015))
        font.bold: true
        color: "#e04040"
        text: T.t("fb_image_warning", browser.lang)
    }

    // ANIMATIONS

    NumberAnimation {
        id: showAnim; target: browser; property: "opacity"
        from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic
    }
    NumberAnimation {
        id: hideAnim; target: browser; property: "opacity"
        from: 1; to: 0; duration: 180; easing.type: Easing.InCubic
        onFinished: { browser.visible = false; modelLoader.active = false; }
    }

    // PUBLIC API

    function open(startPath) {
        console.log("[FileBrowser] open(" + (startPath || "") + ")");
        selectedFile = startPath || "";
        _fallbackMode = false;
        _ready = false;
        _pvSrc = "";
        visible = true;
        showAnim.start();

        if (modelLoader.active && modelLoader.status === Loader.Ready && modelLoader.item) {
            _model = modelLoader.item;
            _ready = true;
            currentFolder = _model.folder || "";
            console.log("[FileBrowser] reusing model, folder=" + currentFolder + " cnt=" + _model.count);
        } else {
            modelLoader.active = false;
            modelLoader.active = true;
        }
    }

    function close() { hideAnim.start(); }

    // INTERNAL

    function _activateCurrent() {
        var ci = fileList.currentItem;
        if (!ci) return;

        var eName = ci.entryName;
        var eIsDir = ci.entryIsDir;

        console.log("[FileBrowser] activate: " + eName + " isDir=" + eIsDir);

        if (eIsDir) {
            _model.cd(eName);
            currentFolder = _model.folder || "";
            fileList.currentIndex = 0;
            console.log("[FileBrowser] now in: " + currentFolder + " count=" + fileList.count);
        } else if (!folderMode) {
            selectedFile = currentFolder + "/" + eName;
            console.log("[FileBrowser] selected: " + selectedFile);
            fileSelected(selectedFile);
        }
    }

    function _jumpToDir(dirName) {
        if (!_model) return;
        // Go to root
        for (var i = 0; i < 20; i++) {
            var b = _model.folder;
            _model.cd("..");
            if (_model.folder === b) break;
        }
        _model.cd(dirName);
        currentFolder = _model.folder || "";
        fileList.currentIndex = 0;
    }

    // KEYBOARD (called by parent)

    function handleKey(event) {
        var k = event.key;
        event.accepted = true;
        var kA = (k === Qt.Key_Return || k === Qt.Key_Enter || k === 1048576);
        var kB = (k === Qt.Key_Escape || k === Qt.Key_Back ||
                  k === Qt.Key_Backspace || k === 1048577);
        var kX = (k === 1048578);
        var kU = (k === Qt.Key_Up);
        var kD = (k === Qt.Key_Down);
        var kL = (k === Qt.Key_Left);
        var kR = (k === Qt.Key_Right);

        if (_fallbackMode) {
            if (kL && fallbackUI.scIdx > 0) {
                fallbackUI.scIdx--;
                fbInput.text = fallbackUI.sc[fallbackUI.scIdx].path + "/";
            } else if (kR && fallbackUI.scIdx < fallbackUI.sc.length - 1) {
                fallbackUI.scIdx++;
                fbInput.text = fallbackUI.sc[fallbackUI.scIdx].path + "/";
            } else if (kA && fbInput.text !== "") {
                fileSelected(fbInput.text);
            } else if (kB) {
                cancelled();
            }
            return;
        }

        // Browser mode
        var cnt = fileList.count;
        if (kU && fileList.currentIndex > 0) {
            fileList.currentIndex--;
        } else if (kD && fileList.currentIndex < cnt - 1) {
            fileList.currentIndex++;
        } else if (kA) {
            _activateCurrent();
        } else if (kX && folderMode && currentFolder) {
            folderSelected(currentFolder);
        } else if (kB) {
            // B: go up one level first, if at root then cancel
            if (_model) {
                var before = _model.folder;
                _model.cd("..");
                if (_model.folder !== before) {
                    currentFolder = _model.folder || "";
                    fileList.currentIndex = 0;
                    return;
                }
            }
            cancelled();
        }
    }
}
