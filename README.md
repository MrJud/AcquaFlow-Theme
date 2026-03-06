# AcquaFlow Theme

**Alpha Build v0.6.0** — A theme for [Pegasus Frontend](https://pegasus-frontend.org/)

---

## Overview

AcquaFlow is a custom Pegasus frontend theme primarily inspired by **WiiFlow** — a Wii homebrew launcher known for its animated 3D cover carousel. The theme centres around a full 3D cover-flow browser where game art is rendered as physical box covers with depth, rotation and perspective. The menu system takes its structural cues from the XMB (PlayStation 3) interface with a horizontal category bar and vertical sub-item panels.

The theme features a dark, glass-like aesthetic with fluid animations and targets 1080p as its base resolution, scaling dynamically to other resolutions.

---

## Features

- **WiiFlow-inspired 3D carousel** — animated cover-flow with physical box depth, rotation and perspective rendering
- **XMB-style menu** — horizontal category bar with vertical sub-item drill-down (menu only)
- **Multiple view modes** — carousel variants, grid view, and more
- **RetroAchievements integration** — login, progress tracking and achievement hub
- **Per-platform carousel customization** — adjust cover scale, spread, offset and center size live with a slider panel
- **Dynamic backgrounds** — artwork-based, video, solid colour or custom image
- **Platform reorder panel** — drag-and-drop platform order, toggle Last Played / Favourites visibility and swap order
- **Settings menu** — UI options, clock display, language (IT / EN), background and more
- **Box-back covers** — optional secondary cover art displayed on the back face of carousel covers
- **Responsive scaling** — all UI elements scale with screen resolution via ``ScreenMetrics``
- **Animated toolbar** — quick-access buttons (RA, Settings, View Mode, Search, Favourites, Menu) with zoom-in labels

---

## Requirements

- [Pegasus Frontend](https://pegasus-frontend.org/) — alpha16 or later
- Game collections configured in Pegasus with artwork (box covers recommended)
- A gamepad or keyboard for navigation

---

## Installation

Download or clone this repository, then copy the `AcquaFlow-Theme` folder into the Pegasus themes directory for your platform:

| Platform | Themes directory |
|----------|-----------------|
| **Windows** | `C:\Users\<username>\AppData\Local\pegasus-frontend\themes\` |
| **Linux** | `~/.config/pegasus-frontend/themes/` |
| **Linux (Flatpak)** | `~/.var/app/org.pegasus_frontend.Pegasus/config/pegasus-frontend/themes/` |
| **macOS** | `~/Library/Preferences/pegasus-frontend/themes/` |
| **Android** | `<storage>/Android/data/org.pegasus_frontend.android/files/pegasus-frontend/themes/` |

If the `themes` directory does not exist, create it manually.

Once copied, launch Pegasus, open **Settings → Themes** and select **AcquaFlow**.

### Android notes

On Android, `<storage>` is typically the root of your internal storage or SD card. You can use a file manager app to navigate to the path above and paste the theme folder there. Some Android versions may require granting Pegasus storage permissions in system settings.

---

## Navigation

| Input | Action |
|-------|--------|
| D-Pad Left / Right | Navigate categories |
| D-Pad Up / Down | Navigate sub-items / move in lists |
| A (Accept) | Confirm / enter |
| B (Back) | Go back / close panel |
| Y | Context action (swap, secondary action) |
| X | Context action (filter, tertiary action) |
| Start / Menu button | Open theme menu |
| Select / Search button | Open search |

---

## Supported Platforms

Side-cover art is included for:
``3DS`` · ``GBA`` · ``GBC`` · ``GameCube`` · ``N64`` · ``NDS`` · ``PS1`` · ``PS2`` · ``PSP`` · ``PS Vita`` · ``SNES`` · ``Switch`` · ``Wii`` · ``Windows``

Additional platform sprites are planned for future updates.

---

## Known Issues

See the **Logs** section inside the theme menu (About → Logs) for the current list of known issues and planned work.

---

## Credits

Created by **MrJud** — design, development & animations.

Built with Qt/QML 5.15 on top of the Pegasus Frontend framework.

---

## License

This theme is provided as-is for personal use. Redistribution or modification for public release requires attribution.