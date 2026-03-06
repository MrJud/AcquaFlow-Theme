import QtQuick 2.15
import ".."

Item {
    id: navigationManager

    enum NavigationLevel {
        Carousel,
        TopBar
    }

    property int currentLevel: NavigationManager.NavigationLevel.Carousel
    property int topBarIndex: 0

    readonly property bool atCarousel: currentLevel === NavigationManager.NavigationLevel.Carousel
    readonly property bool atTopBar:   currentLevel === NavigationManager.NavigationLevel.TopBar

    // Configuration pulsanti TopBar
    // Ordine visivo: 0=RA, 1=Customizer, 2=ViewSwitcher, 3=Search, 4=Favourite, 5=Menu
    property int topBarButtonCount: 6

    // Guardie di sicurezza
    property bool navigationEnabled: true
    property bool coverSelected: false

    // Segnali
    signal levelChanged(int newLevel)
    signal topBarFocusChanged(int newIndex)
    signal topBarButtonActivated(int buttonIndex)

    // Navigation: Carousel → TopBar
    function navigateToTopBar() {
        if (!navigationEnabled || coverSelected) return
        if (currentLevel !== NavigationManager.NavigationLevel.Carousel) return
        if (topBarButtonCount <= 0) return

        currentLevel = NavigationManager.NavigationLevel.TopBar
        topBarIndex = 1
        levelChanged(currentLevel)
        topBarFocusChanged(topBarIndex)
    }

    // Navigation: TopBar → Carousel
    function navigateToCarousel() {
        if (!navigationEnabled) return
        if (currentLevel !== NavigationManager.NavigationLevel.TopBar) return

        currentLevel = NavigationManager.NavigationLevel.Carousel
        topBarIndex = 0
        levelChanged(currentLevel)
    }

    function navigateLeft() {
        if (!_canNavigateTopBar()) return
        topBarIndex = (topBarIndex - 1 + topBarButtonCount) % topBarButtonCount
        topBarFocusChanged(topBarIndex)
    }

    function navigateRight() {
        if (!_canNavigateTopBar()) return
        topBarIndex = (topBarIndex + 1) % topBarButtonCount
        topBarFocusChanged(topBarIndex)
    }

    function navigateToIndex(index) {
        if (!_canNavigateTopBar()) return
        if (index < 0 || index >= topBarButtonCount) return
        topBarIndex = index
        topBarFocusChanged(topBarIndex)
    }

    function activateCurrentButton() {
        if (!_canNavigateTopBar()) return
        topBarButtonActivated(topBarIndex)
    }

    function reset() {
        var wasTopBar = atTopBar
        currentLevel = NavigationManager.NavigationLevel.Carousel
        topBarIndex = 0
        levelChanged(currentLevel)
    }

    onCoverSelectedChanged: {
        if (coverSelected && atTopBar) {
            navigateToCarousel()
        }
    }

    function _canNavigateTopBar() {
        return navigationEnabled &&
               !coverSelected &&
               currentLevel === NavigationManager.NavigationLevel.TopBar &&
               topBarButtonCount > 0
    }

    Component.onCompleted: {
        console.log("NavigationManager: Initialized at Carousel level with", topBarButtonCount, "buttons")
    }
}
