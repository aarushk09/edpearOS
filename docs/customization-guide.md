# edpearOS — Customization Guide

## Package Management

### Adding Packages
Edit `archiso-profile/packages.x86_64` and add the package name (one per line).

Find packages: `pacman -Ss <search-term>` on any Arch system, or search [archlinux.org/packages](https://archlinux.org/packages/).

For AUR packages, they must be available in [Chaotic-AUR](https://aur.chaotic.cx/packages) since archiso can't build AUR packages during build time.

### Removing Packages
Delete or comment out the line in `packages.x86_64`.

## Desktop Customization

### KDE Plasma
All KDE config files live in `archiso-profile/airootfs/etc/skel/.config/`:
- `kdeglobals` — Global KDE settings (theme, colors, fonts)
- `kwinrc` — Window manager (Night Color, compositing, animations)
- `plasma-org.kde.plasma.desktop-appletsrc` — Panel layout, widgets, favorites
- `khotkeysrc` — Custom keyboard shortcuts

### Hyprland
- `archiso-profile/airootfs/etc/skel/.config/hypr/hyprland.conf` — Main config (keybinds, gaps, animations)
- `archiso-profile/airootfs/etc/skel/.config/waybar/config` — Status bar modules
- `archiso-profile/airootfs/etc/skel/.config/waybar/style.css` — Status bar theme
- `archiso-profile/airootfs/etc/skel/.config/wofi/` — App launcher config and theme
- `archiso-profile/airootfs/etc/skel/.config/dunst/dunstrc` — Notification daemon

### Wallpaper
Replace `archiso-profile/airootfs/usr/share/edpearos/wallpapers/default.png` with any image. 1920x1080 or higher recommended.

### Theme Colors (Tokyo Night)
The default theme uses Tokyo Night colors throughout:
- Background: `#1a1b26`
- Foreground: `#c0caf5`
- Accent: `#7aa2f7`
- Secondary: `#bb9af7`
- Success: `#9ece6a`
- Warning: `#e0af68`
- Error: `#f7768e`
- Muted: `#565f89`

Change these in the Waybar CSS, dunstrc, wofi CSS, Calamares branding, and hyprland.conf.

## Focus Mode

### Customizing the Blocklist
System default: `archiso-profile/airootfs/etc/edpearos/focus-blocklist.txt`

Users can override with `~/.config/edpearos/focus-blocklist.txt` (user override takes priority).

Format: one domain per line, `#` for comments.

### Adding Features to Focus Mode
Edit `archiso-profile/airootfs/usr/local/bin/edpear-focus` (bash script).

Current features:
- KDE Plasma Do Not Disturb
- Hyprland/dunst notification pause
- Website blocking via `/etc/hosts`
- KDE Night Color (blue light filter)

## Welcome App

The study workspace launcher is a Python/GTK4/Libadwaita app at `archiso-profile/airootfs/usr/local/bin/edpear-welcome`.

### Adding/Editing Workspaces
Edit the `WORKSPACES` dictionary in the Python file. Each workspace defines:
- `icon`: GTK icon name
- `subtitle`: Brief description
- `description`: What opens
- `apps`: List of commands to launch
- `packages_extra`: Additional packages for the Calamares student-setup module

## Calamares Installer

### Branding
`archiso-profile/airootfs/etc/calamares/branding/edpearos/`:
- `branding.desc` — Names, URLs, colors
- `show.qml` — Installation slideshow
- `logo.png` — Installer logo
- `welcome.png` — Welcome screen image

### Modules
`archiso-profile/airootfs/etc/calamares/modules/`:
- Each `.conf` file configures one step of the installer
- `student-setup.conf` — The custom student major selection page
- `student-setup-script.sh` — Installs major-specific packages post-install

### Adding a New Installer Step
1. Create a new `.conf` in the modules directory
2. Add the module name to the `sequence` in `settings.conf`

## Keyboard Shortcuts

### KDE Plasma
Edit `archiso-profile/airootfs/etc/skel/.config/khotkeysrc`. Follow the existing pattern for new shortcuts.

### Hyprland
Edit the key bindings section in `archiso-profile/airootfs/etc/skel/.config/hypr/hyprland.conf`. Format:
```
bind = $mainMod, KEY, exec, command
```
