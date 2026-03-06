import QtQuick 2.15
import ".."
import "../config/Translations.js" as T

Item {
    id: themeLoader
    anchors.fill: parent
    z: 9999
    focus: true

    opacity: active ? 1.0 : 0.0
    visible: opacity > 0

    // Bindable properties for consumers (theme.qml)
    readonly property bool active: isLoading || waitingForUserInput

    // Properties pubbliche
    property string lang: "it"
    property var apiRef: null
    property bool detectGameReload: true

    property bool themeInitialized: false
    property bool isLoading: true
    property bool waitingForUserInput: false
    property bool userHasInteracted: false

    // Reload detection
    property int _lastCollectionCount: -1
    property string _lastCollectionHash: ""
    property bool _isDataReloading: false

    property int themeImageWidth: 300
    property int themeImageHeight: 80
    property real themeImageScale: 2.0

    // Segnali
    signal loadingComplete()
    signal loadingFailed(string error)
    signal userContinued()

    Component.onCompleted: {
        themeInitialized = true
        isLoading = false
        waitingForUserInput = true
        themeLoader.forceActiveFocus()
    }

    onVisibleChanged: {
        if (visible && isLoading && !waitingForUserInput) {
            _finishLoading()
        }
    }

    Item {
        id: staticImagesContainer
        anchors.fill: parent
        z: 1
        visible: waitingForUserInput

        Image {
            id: loaderImage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -120
            source: "../../assets/images/Loader.png"
            width: 120
            height: 120
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: true
        }

        Image {
            id: themeImage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "../../assets/images/loadingscreen/Acquaflowtheme.png"
            width: themeImageWidth * themeImageScale
            height: themeImageHeight * themeImageScale
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: true
        }
    }

    Rectangle {
        id: loaderBackground
        anchors.fill: parent
        color: "#20000000"  // Single RGBA value
        visible: parent.opacity > 0

        Column {
            id: textColumn
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 180
            spacing: 20
            opacity: waitingForUserInput ? 1.0 : 0.0
            visible: opacity > 0

            SequentialAnimation {
                id: textBreathingAnimation
                running: waitingForUserInput && themeLoader.visible
                loops: Animation.Infinite

                PropertyAnimation {
                    target: textColumn; property: "opacity"
                    from: 1.0; to: 0.4; duration: 1000
                }
                PropertyAnimation {
                    target: textColumn; property: "opacity"
                    from: 0.4; to: 1.0; duration: 1000
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Text {
                    text: T.t("loader_press", themeLoader.lang)
                    font.pixelSize: 28
                    color: "#4A9EFF"
                    style: Text.Outline; styleColor: "#000000"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: "transparent"
                    border.color: "#4A9EFF"; border.width: 2
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: "A"; font.pixelSize: 24; font.bold: true
                        color: "#4A9EFF"; anchors.centerIn: parent
                    }
                }

                Text {
                    text: T.t("loader_to_continue", themeLoader.lang)
                    font.pixelSize: 28
                    color: "#4A9EFF"
                    style: Text.Outline; styleColor: "#000000"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: T.t("loader_tap", themeLoader.lang)
                font.pixelSize: 20
                color: "#cccccc"; opacity: 0.8
                style: Text.Outline; styleColor: "#000000"
            }
        }

        // Touch input
        MouseArea {
            anchors.fill: parent
            enabled: waitingForUserInput
            onClicked: handleUserInput()
        }
    }

    // INPUT HANDLING

    Keys.onPressed: function(event) {
        if (waitingForUserInput) {
            handleUserInput()
            event.accepted = true
        }
    }

    Timer {
        id: focusTimer
        interval: 500
        repeat: true
        running: waitingForUserInput && !themeLoader.activeFocus
        onTriggered: {
            if (waitingForUserInput && !themeLoader.activeFocus) {
                themeLoader.forceActiveFocus()
            }
        }
    }

    function handleUserInput() {
        if (!waitingForUserInput) return

        // Smooth breathing animation fade-out
        textBreathingAnimation.stop()
        textColumn.opacity = 1.0

        waitingForUserInput = false
        userHasInteracted = true
        userContinued()
    }

    // GAME DATA RELOAD MONITORING

    Timer {
        id: gameReloadMonitor
        interval: 2000
        repeat: true
        running: detectGameReload && apiRef !== null && !isLoading
        onTriggered: {
            if (_checkForGameReload()) {
                _startReloading()
            }
        }
    }

    Timer {
        id: safetyTimer
        interval: 8000
        repeat: false
        onTriggered: {
            if (isLoading) {
                console.warn("ThemeLoader: Timeout caricamento (8s)")
                loadingFailed("Timeout caricamento (8 secondi)")
                _finishLoading()
            }
        }
    }

    // Funzioni interne

    function _startReloading() {
        if (themeInitialized && !_isDataReloading) return
        isLoading = true
        safetyTimer.start()
    }

    function _finishLoading() {
        themeInitialized = true
        _isDataReloading = false
        safetyTimer.stop()
        isLoading = false
        waitingForUserInput = true
        loadingComplete()
    }

    function _checkForGameReload() {
        if (!apiRef || !detectGameReload) return false

        var currentCount = apiRef.collections ? apiRef.collections.count : 0
        var currentHash = _generateCollectionHash()

        if (_lastCollectionCount === -1) {
            _lastCollectionCount = currentCount
            _lastCollectionHash = currentHash
            return false
        }

        if (currentCount !== _lastCollectionCount || currentHash !== _lastCollectionHash) {
            _lastCollectionCount = currentCount
            _lastCollectionHash = currentHash
            _isDataReloading = true
            return true
        }
        return false
    }

    function _generateCollectionHash() {
        if (!apiRef || !apiRef.collections) return ""
        var hash = ""
        var limit = Math.min(3, apiRef.collections.count)
        for (var i = 0; i < limit; i++) {
            var c = apiRef.collections.get(i)
            if (c) hash += c.shortName + "_" + (c.games ? c.games.count : 0) + "|"
        }
        return hash
    }
}
