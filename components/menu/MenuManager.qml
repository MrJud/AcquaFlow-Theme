import QtQuick 2.15
import ".."

Item {
    id: menuManager

    property bool menuOpen: false
    property alias menuPage: menuPageInstance
    property var collections: null
    property int gcGameCount: 0
    property string lang: "it"

    signal themeNavigationEnabled(bool enabled)
    signal menuRequested()
    signal raHubRequested()
    signal platformSelected(string platformShortName)
    signal platformOrderChanged(var orderArray, bool lpVisible, bool raVis, bool favVis)
    signal bgSettingsApplied(bool useArtwork, bool useVideo, string bgSource, string customPath, int blurIntensity)
    signal clockSettingsApplied(bool use24h, int fontIndex, int colorIndex)
    signal uiSettingsApplied(bool platformBarAutoHide, bool showLogoOutline, bool showBattery, bool showWifi, string screenSizeMode)
    signal languageSettingsApplied(string lang)
    signal boxbackPathChanged()

    MenuPage {
        id: menuPageInstance
        anchors.fill: parent
        z: 1
        collections: menuManager.collections
        gcGameCount: menuManager.gcGameCount
        lang: menuManager.lang

        onMenuItemSelected: {
            switch(itemId) {
                case "ra_login":
                    // Handled inline by MenuPage's RALoginPanel
                    break
                case "theme_settings":
                    break
                case "system_settings":
                    break
                case "version_info":
                    break
                case "credits":
                    break
                case "ra_view":
                    menuManager.raHubRequested()
                    menuManager.closeMenu()
                    break
            }
        }

        onMenuClosed: {
            menuManager.menuOpen = false
            menuManager.themeNavigationEnabled(true)
            menuManager.parent.forceActiveFocus()
        }

        onPlatformOrderChanged: {
            menuManager.platformOrderChanged(orderArray, lpVisible, raVis, favVis)
        }

        onBgSettingsApplied: {
            menuManager.bgSettingsApplied(useArtwork, useVideo, bgSource, customPath, blurIntensity)
        }

        onClockSettingsApplied: {
            menuManager.clockSettingsApplied(use24h, fontIndex, colorIndex)
        }

        onUiSettingsApplied: {
            menuManager.uiSettingsApplied(platformBarAutoHide, showLogoOutline, showBattery, showWifi, screenSizeMode)
        }

        onLanguageSettingsApplied: {
            menuManager.languageSettingsApplied(lang)
        }

        onBoxbackPathChanged: {
            menuManager.boxbackPathChanged()
        }

        Connections {
            target: menuPageInstance
            function onPlatformSelected(platformShortName) {
                menuManager.platformSelected(platformShortName)
                menuManager.closeMenu()
            }
        }
    }

    function openMenu() {
        if (!menuOpen) {
            menuOpen = true
            themeNavigationEnabled(false)
            menuPageInstance.open()
        }
    }

    function closeMenu() {
        if (menuOpen) {
            menuPageInstance.close()
        }
    }

    function toggleMenu() {
        if (menuOpen) {
            closeMenu()
        } else {
            openMenu()
        }
    }
}
