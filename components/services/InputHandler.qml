import QtQuick 2.15
import ".."

FocusScope {
    id: controls
    focus: true
    enabled: true

    // Property to disable input when ThemeLoader is active
    property bool inputEnabled: true

    // Property to track if a cover is selected (affects X button behavior)
    property bool coverSelected: false

    // Property to track if GameCard is visible (affects X/Y button handling)
    property bool gameCardVisible: false

    // Property to track navigation level (for TopBar navigation)
    property bool isTopBarNavigation: false

    // Property to track if CarouselCustomizer panel is active (for slider navigation)
    property bool isCustomizerPanelActive: false

    // Property to track if SearchButton bar is open (freeze carousel input)
    property bool isSearchBarOpen: false

    property bool l1Pressed: false
    property bool r1Pressed: false
    property bool comboDetected: false  // Flag to prevent platform switching when combo is active

    // Combo detection timer - if both buttons pressed within this time = combo
    property int comboToleranceMs: 100  // 100ms tolerance window

    // Signals for CoverFlow navigation (horizontal)
    signal coverLeft()
    signal coverRight()

    // Signals for platform navigation (e.g., L1/R1)
    signal platformPrev()
    signal platformNext()

    // Signals for TopBar navigation (menu icons)
    signal topBarEnter()
    signal topBarExit()
    signal topBarNavigateLeft()
    signal topBarNavigateRight()
    signal topBarActivate()

    // Signals for CarouselCustomizer panel navigation
    signal customizerSliderUp()
    signal customizerSliderDown()
    signal customizerAdjustLeft()
    signal customizerAdjustRight()
    signal customizerClose()
    signal customizerReset()
    signal customizerResetCurrent()
    signal customizerConfirm()  // A button when focused on a customizer button

    // Generic navigation signals for other theme parts
    signal leftNav()
    signal rightNav()
    signal nextPage()
    signal prevPage()
    signal pageUp()
    signal pageDown()

    // Alphabetic jump signals (L2/R2)
    signal jumpNextLetter()
    signal jumpPrevLetter()

    // Selected mode cover scrolling signals (R1/L1 in selected mode)
    signal scrollNextCoverSelected()
    signal scrollPrevCoverSelected()

    // Specific action signals
    signal details()
    signal filter()

    // Cover selection signals
    signal selectCover()
    signal deselectCover()

    // View mode switch signal
    signal switchViewMode()

    // Open RA game detail signal (L1+R1 combo in selected mode)
    signal openRaGameDetail()

    // Info signal (for when cover is selected)
    signal showInfo()

    // Input repeat configuration
    property int inputRepeatInitialDelay: 280
    property int inputRepeatInterval: 280    // = initial delay → hold feels like sequential single presses

    // Platform switching repeat configuration (slower than cover navigation)
    property int platformSwitchInitialDelay: 400
    property int platformSwitchInterval: 300

    property real _axis: 0  // -1 for left, 1 for right, 0 for neutral

    property int _platformAxis: 0  // -1 for prev, 1 for next, 0 for neutral

    // L2/R2 analog trigger workaround:
    // On some devices/states, first press sends key=0, on others key=1048581/1048584 directly.
    // We handle L2/R2 ONLY on release. A single cooldown timer (800ms) blocks both
    // the duplicate release (~1ms) and phantom release (~735ms) that follow.
    property bool _l2Cooldown: false
    property bool _r2Cooldown: false
    Timer { id: _l2Reset; interval: 800; onTriggered: controls._l2Cooldown = false }
    Timer { id: _r2Reset; interval: 800; onTriggered: controls._r2Cooldown = false }

    property bool isRepeating: repeatHoldTimer.running && !repeatHoldTimer.isFirstTrigger
    // true as soon as any directional key is held (even the very first scroll)
    property bool isKeyHeld: repeatHoldTimer.running

    // Timer for continuous key repeat when a directional key is held down
    Timer {
        id: repeatHoldTimer
        property bool isFirstTrigger: true
        repeat: true
        running: false  // Don't auto-start, explicitly control

        interval: isFirstTrigger ? controls.inputRepeatInitialDelay : controls.inputRepeatInterval

        onTriggered: {
            if (isFirstTrigger) {
                isFirstTrigger = false;
            }
            // Only trigger if axis is still active
            if (controls._axis > 0) controls.coverRight();
            else if (controls._axis < 0) controls.coverLeft();
            else repeatHoldTimer.stop();  // Safety stop if axis is neutral
        }

        onRunningChanged: {
            // Reset first trigger flag when timer stops
            if (!running) {
                isFirstTrigger = true;
            }
        }
    }

    // Timer for platform switching repeat
    Timer {
        id: platformRepeatTimer
        property bool isFirstTrigger: true
        repeat: true
        running: false  // Don't auto-start, explicitly control

        interval: isFirstTrigger ? controls.platformSwitchInitialDelay : controls.platformSwitchInterval

        onTriggered: {
            if (isFirstTrigger) {
                isFirstTrigger = false;
            }
            // Only trigger if axis is still active AND combo not detected
            if (!controls.comboDetected) {
                if (controls._platformAxis > 0) controls.platformNext();
                else if (controls._platformAxis < 0) controls.platformPrev();
                else platformRepeatTimer.stop();  // Safety stop if axis is neutral
            }
        }

        onRunningChanged: {
            // Reset first trigger flag when timer stops
            if (!running) {
                isFirstTrigger = true;
            }
        }
    }

    // Timer for delayed platform switch to allow combo detection
    // If L1 is pressed, wait before triggering platformPrev — if R1 arrives within tolerance, it's a combo
    Timer {
        id: comboDetectionTimer
        interval: controls.comboToleranceMs
        repeat: false
        running: false

        property int pendingDirection: 0  // -1=prev, 1=next

        onTriggered: {
            // Combo window expired — execute the pending platform switch
            if (!controls.comboDetected && pendingDirection !== 0) {
                if (controls.coverSelected) {
                    if (pendingDirection < 0) controls.scrollPrevCoverSelected();
                    else controls.scrollNextCoverSelected();
                } else {
                    if (pendingDirection < 0) {
                        controls.platformPrev();
                        // Only start repeat if button is still held
                        if (controls.l1Pressed) {
                            controls._platformAxis = -1;
                            platformRepeatTimer.isFirstTrigger = true;
                            platformRepeatTimer.start();
                        } else {
                            controls._platformAxis = 0;
                        }
                    } else {
                        controls.platformNext();
                        // Only start repeat if button is still held
                        if (controls.r1Pressed) {
                            controls._platformAxis = 1;
                            platformRepeatTimer.isFirstTrigger = true;
                            platformRepeatTimer.start();
                        } else {
                            controls._platformAxis = 0;
                        }
                    }
                }
            }
            pendingDirection = 0;
        }
    }

    Keys.onPressed: (ev) => {
        // to propagate to parent (theme.qml Keys.onPressed).
        ev.accepted = false;

        if (!inputEnabled) return;

        if (isSearchBarOpen) return;

        switch (ev.key) {
        case Qt.Key_Left:
        case Qt.Key_A:
        case Qt.Key_GamepadDpadLeft:
        case Qt.Key_GamepadLeft:
        case 16777234:  // Android D-pad Left
            if (ev.isAutoRepeat) {
                // Some controllers (Windows/XInput) send RELEASE between each
                // auto-repeat PRESS, which resets _axis to 0 and stops our timer.
                // Restore axis and trigger immediate scroll; safe for Switch/Odin
                // where _axis and timer are still intact (becomes a no-op).
                _axis = -1;
                if (!repeatHoldTimer.running) {
                    repeatHoldTimer.isFirstTrigger = false;
                    coverLeft();
                    repeatHoldTimer.start();
                }
                ev.accepted = true;
                break;
            }
            if (gameCardVisible) {
                ev.accepted = false;
            } else if (isCustomizerPanelActive) {
                customizerAdjustLeft();
                ev.accepted = true;
            } else if (isTopBarNavigation) {
                topBarNavigateLeft();
                ev.accepted = true;
            } else {
                if (_axis !== -1) {
                    repeatHoldTimer.stop();
                    _axis = -1;
                    repeatHoldTimer.isFirstTrigger = true;
                    coverLeft();
                    repeatHoldTimer.start();
                }
                ev.accepted = true;
            }
            break;
        case Qt.Key_Right:
        case Qt.Key_D:
        case Qt.Key_GamepadDpadRight:
        case Qt.Key_GamepadRight:
        case 16777236:  // Android D-pad Right
            if (ev.isAutoRepeat) {
                // Some controllers (Windows/XInput) send RELEASE between each
                // auto-repeat PRESS, which resets _axis to 0 and stops our timer.
                // Restore axis and trigger immediate scroll; safe for Switch/Odin
                // where _axis and timer are still intact (becomes a no-op).
                _axis = 1;
                if (!repeatHoldTimer.running) {
                    repeatHoldTimer.isFirstTrigger = false;
                    coverRight();
                    repeatHoldTimer.start();
                }
                ev.accepted = true;
                break;
            }
            if (gameCardVisible) {
                ev.accepted = false;
            } else if (isCustomizerPanelActive) {
                customizerAdjustRight();
                ev.accepted = true;
            } else if (isTopBarNavigation) {
                topBarNavigateRight();
                ev.accepted = true;
            } else {
                if (_axis !== 1) {
                    repeatHoldTimer.stop();
                    _axis = 1;
                    repeatHoldTimer.isFirstTrigger = true;
                    coverRight();
                    repeatHoldTimer.start();
                }
                ev.accepted = true;
            }
            break;
        case Qt.Key_Up:
        case Qt.Key_W:
        case Qt.Key_GamepadDpadUp:
        case 16777235:  // Android D-pad Up
            if (gameCardVisible) {
                // Don't consume - let theme.qml handle for 3D rotation
                ev.accepted = false;
            } else if (isCustomizerPanelActive) {
                customizerSliderUp();
                ev.accepted = true;
            } else if (isTopBarNavigation) {
                // Already in TopBar, do nothing
                ev.accepted = true;
            } else if (coverSelected) {
                deselectCover();
                ev.accepted = true;
            } else {
                topBarEnter();
                ev.accepted = true;
            }
            break;
        case Qt.Key_Down:
        case Qt.Key_S:
        case Qt.Key_GamepadDpadDown:
        case 16777237:  // Android D-pad Down
            if (gameCardVisible) {
                // Don't consume - let theme.qml handle for 3D rotation
                ev.accepted = false;
            } else if (isCustomizerPanelActive) {
                customizerSliderDown();
                ev.accepted = true;
            } else if (coverSelected) {
                ev.accepted = true;
            } else if (isTopBarNavigation) {
                topBarExit();
                ev.accepted = true;
            } else {
                ev.accepted = true;
            }
            break;
        // Mappings for platform navigation (L1/R1, LB/RB, etc.)
        // When cover is selected, L1/R1 scroll through covers instead of platforms
        case Qt.Key_PageUp:
        case Qt.Key_Q:  // Keyboard LB/L1
            if (coverSelected) {
                console.log("InputHandler: Key L1/PrevPage (", ev.key, ") pressed in selected mode. Emitting scrollPrevCoverSelected().");
                scrollPrevCoverSelected();
            } else {
                console.log("InputHandler: Key L1/PrevPage (", ev.key, ") pressed. Emitting platformPrev().");
                if (_platformAxis === 0) {
                    platformRepeatTimer.stop();  // Stop any existing timer first
                    _platformAxis = -1;
                    platformRepeatTimer.isFirstTrigger = true;  // Reset for initial delay
                    platformPrev();  // Immediate trigger for the first action
                    platformRepeatTimer.start();  // Start repeat timer
                }
            }
            ev.accepted = true;
            break;
        case Qt.Key_PageDown:
        case Qt.Key_E:  // Keyboard RB/R1
            if (coverSelected) {
                console.log("InputHandler: Key R1/NextPage (", ev.key, ") pressed in selected mode. Emitting scrollNextCoverSelected().");
                scrollNextCoverSelected();
            } else {
                console.log("InputHandler: Key R1/NextPage (", ev.key, ") pressed. Emitting platformNext().");
                if (_platformAxis === 0) {
                    platformRepeatTimer.stop();  // Stop any existing timer first
                    _platformAxis = 1;
                    platformRepeatTimer.isFirstTrigger = true;
                    platformNext();  // Immediate trigger for the first action
                    platformRepeatTimer.start();
                }
            }
            ev.accepted = true;
            break;
        case 1048580:  // L1 button on Android (corrected mapping)
            l1Pressed = true;

            // Check if R1 is already pressed (instant combo detection)
            if (r1Pressed && !comboDetected) {
                comboDetected = true;
                comboDetectionTimer.stop();
                comboDetectionTimer.pendingDirection = 0;
                platformRepeatTimer.stop();
                _platformAxis = 0;
                if (coverSelected) {
                    openRaGameDetail();
                } else {
                    switchViewMode();
                }
                ev.accepted = true;
                break;
            }

            // Defer platform switch to allow combo detection window
            if (!comboDetected) {
                comboDetectionTimer.pendingDirection = -1;
                comboDetectionTimer.restart();
            }
            ev.accepted = true;
            break;
        case 1048583:  // R1 button on Android (corrected mapping)
            r1Pressed = true;

            // Check if L1 is already pressed (instant combo detection)
            if (l1Pressed && !comboDetected) {
                comboDetected = true;
                comboDetectionTimer.stop();
                comboDetectionTimer.pendingDirection = 0;
                platformRepeatTimer.stop();
                _platformAxis = 0;
                if (coverSelected) {
                    openRaGameDetail();
                } else {
                    switchViewMode();
                }
                ev.accepted = true;
                break;
            }

            // Defer platform switch to allow combo detection window
            if (!comboDetected) {
                comboDetectionTimer.pendingDirection = 1;
                comboDetectionTimer.restart();
            }
            ev.accepted = true;
            break;
        // L2/R2: on press, just consume — unless cover is selected (let theme.qml handle zoom).
        case 1048581:  // L2
            if (coverSelected) {
                ev.accepted = false;  // Let theme.qml handle zoom
            } else {
                ev.accepted = true;
            }
            break;
        case 1048584:  // R2
            if (coverSelected) {
                ev.accepted = false;  // Let theme.qml handle zoom
            } else {
                ev.accepted = true;
            }
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Space:  // Space as alternative A button
        case 16777220:  // Possible Gamepad A code
        case 16777222:  // Alternative Gamepad A code
        case 0x01000000:  // Another possible A code
        case 1048576:  // A button on Android gamepad (confirmed)
            console.log("InputHandler: Accept/Select button (", ev.key, ") pressed.");
            if (isTopBarNavigation) {
                // Activate current TopBar button
                console.log("InputHandler: A button in TopBar navigation - activating current button");
                topBarActivate();
            } else if (isCustomizerPanelActive) {
                // A button does nothing in customizer panel
                console.log("InputHandler: A button in Customizer panel - ignored");
            } else {
                // Select cover in Carousel mode
                selectCover();
            }
            ev.accepted = true;
            break;
        case Qt.Key_Select:  // Select button for view mode switching - handled by theme.qml
        case 1048582:        // L3 / Select on some controllers
        case 1048586:        // Select/Back button (0x10000a) on Windows/XInput controllers
            console.log("InputHandler: SELECT button detected (key:", ev.key, ") - NOT consuming, letting theme.qml handle it");
            ev.accepted = false;
            break;
        case Qt.Key_Escape:
        case Qt.Key_Backspace:  // Backspace as alternative B button
        case 16777221:  // Possible Gamepad B code
        case 16777223:  // Alternative Gamepad B code
        case 0x01000001:  // Another possible B code
        case 1048577:  // B button on Android gamepad (confirmed)
            console.log("InputHandler: Cancel/Back button (", ev.key, ") pressed.");
            if (isCustomizerPanelActive) {
                // Close and save customizer panel
                console.log("InputHandler: B button in Customizer panel - close and save");
                customizerClose();
                ev.accepted = true;
            } else if (isTopBarNavigation) {
                console.log("InputHandler: B button in TopBar - exit to carousel");
                topBarExit();
                ev.accepted = true;
            } else {
                // Normal deselect behavior
                deselectCover();
                ev.accepted = true;
            }
            break;
        case 1048578:  // X button on Android gamepad
            if (ev.isAutoRepeat) { ev.accepted = true; break; }  // Ignora auto-repeat
            // If customizer panel is active, use X to reset current slider
            if (isCustomizerPanelActive) {
                console.log("InputHandler: X button in Customizer panel - reset current slider");
                customizerResetCurrent();
                ev.accepted = true;
            } else {
                // Don't consume - let theme.qml handle for search button
                console.log("InputHandler: X button detected - NOT consuming, letting theme.qml handle it");
                ev.accepted = false;
            }
            break;
        case 1048579:
            if (ev.isAutoRepeat) { ev.accepted = true; break; }  // Ignora auto-repeat
            // If customizer panel is active, use Y for reset
            if (isCustomizerPanelActive) {
                console.log("InputHandler: Y button in Customizer panel - reset values");
                customizerReset();
                ev.accepted = true;
            } else {
                // Don't consume - let theme.qml handle for favourite toggle
                console.log("InputHandler: Y button detected - NOT consuming, letting theme.qml handle it");
                ev.accepted = false;
            }
            break;
        case Qt.Key_Menu:
            details();
            ev.accepted = true;
            break;
        case Qt.Key_F:
            filter();
            ev.accepted = true;
            break;
        }
    }

    Keys.onReleased: (ev) => {
        ev.accepted = false;

        // Stop cover navigation timer when releasing arrow keys
        if ((ev.key === Qt.Key_Left || ev.key === Qt.Key_A || ev.key === Qt.Key_GamepadDpadLeft || ev.key === Qt.Key_GamepadLeft || ev.key === 16777234) && _axis < 0) {
            repeatHoldTimer.stop();
            _axis = 0;
            repeatHoldTimer.isFirstTrigger = true;
            ev.accepted = true;
        }
        else if ((ev.key === Qt.Key_Right || ev.key === Qt.Key_D || ev.key === Qt.Key_GamepadDpadRight || ev.key === Qt.Key_GamepadRight || ev.key === 16777236) && _axis > 0) {
            repeatHoldTimer.stop();
            _axis = 0;
            repeatHoldTimer.isFirstTrigger = true;
            ev.accepted = true;
        }

        // Stop platform switching timer when releasing L1/R1
        if ((ev.key === Qt.Key_PageUp || ev.key === Qt.Key_Q || ev.key === 1048580) && _platformAxis < 0) {
            platformRepeatTimer.stop();
            _platformAxis = 0;
            platformRepeatTimer.isFirstTrigger = true;
            ev.accepted = true;
        }
        else if ((ev.key === Qt.Key_PageDown || ev.key === Qt.Key_E || ev.key === 1048583) && _platformAxis > 0) {
            platformRepeatTimer.stop();
            _platformAxis = 0;
            platformRepeatTimer.isFirstTrigger = true;
            ev.accepted = true;
        }

        // Reset L1/R1 combo tracking flags
        // On rapid taps (< comboToleranceMs), the release arrives before
        // comboDetectionTimer fires.  Instead of dropping the pending switch,
        // execute it immediately so every tap registers.
        if (ev.key === 1048580) {
            l1Pressed = false;
            if (!r1Pressed) {
                // Fire pending platform switch that was waiting for combo window
                if (!comboDetected && comboDetectionTimer.running && comboDetectionTimer.pendingDirection !== 0) {
                    var dir = comboDetectionTimer.pendingDirection;
                    comboDetectionTimer.stop();
                    comboDetectionTimer.pendingDirection = 0;
                    if (coverSelected) {
                        if (dir < 0) scrollPrevCoverSelected();
                        else scrollNextCoverSelected();
                    } else {
                        if (dir < 0) platformPrev();
                        else platformNext();
                    }
                    // Don't start repeat — button already released
                    _platformAxis = 0;
                } else {
                    comboDetectionTimer.stop();
                }
                comboDetected = false;
            }
            ev.accepted = true;
        }
        else if (ev.key === 1048583) {
            r1Pressed = false;
            if (!l1Pressed) {
                // Fire pending platform switch that was waiting for combo window
                if (!comboDetected && comboDetectionTimer.running && comboDetectionTimer.pendingDirection !== 0) {
                    var dir2 = comboDetectionTimer.pendingDirection;
                    comboDetectionTimer.stop();
                    comboDetectionTimer.pendingDirection = 0;
                    if (coverSelected) {
                        if (dir2 < 0) scrollPrevCoverSelected();
                        else scrollNextCoverSelected();
                    } else {
                        if (dir2 < 0) platformPrev();
                        else platformNext();
                    }
                    // Don't start repeat — button already released
                    _platformAxis = 0;
                } else {
                    comboDetectionTimer.stop();
                }
                comboDetected = false;
            }
            ev.accepted = true;
        }

        // L2/R2 — handle ONLY on release.
        // Cooldown (800ms) blocks duplicate release (~1ms) and phantom release (~735ms).
        // Skip alphabet jump when cover is selected (zoom is handled by theme.qml).
        if (ev.key === 1048581) {
            if (!_l2Cooldown && inputEnabled && !isSearchBarOpen && !coverSelected) {
                _l2Cooldown = true;
                _l2Reset.restart();
                jumpPrevLetter();
            }
            // When cover is selected, don't consume — let theme.qml handle zoom release
            if (coverSelected) ev.accepted = false;
        }
        else if (ev.key === 1048584) {
            if (!_r2Cooldown && inputEnabled && !isSearchBarOpen && !coverSelected) {
                _r2Cooldown = true;
                _r2Reset.restart();
                jumpNextLetter();
            }
            // When cover is selected, don't consume — let theme.qml handle zoom release
            if (coverSelected) ev.accepted = false;
        }
    }
}
