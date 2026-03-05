#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# apply-theme.sh — Apply the edpearOS theme to the current user session
# Called automatically on first login via autostart
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

MARKER="$HOME/.config/edpearos/.theme-applied"

# Skip if already applied (unless --force)
if [ -f "$MARKER" ] && [ "${1:-}" != "--force" ]; then
    exit 0
fi

echo "[edpearOS] Applying desktop theme..."

# Detect kwriteconfig version
KWC="kwriteconfig6"
command -v kwriteconfig6 &>/dev/null || KWC="kwriteconfig5"
QDBUS="qdbus6"
command -v qdbus6 &>/dev/null || QDBUS="qdbus"

# ── Pre-write all config files before applying ──
mkdir -p "$HOME/.config"

# Color scheme
$KWC --file kdeglobals --group General --key ColorScheme EdpearOSTokyo
# Icons
$KWC --file kdeglobals --group Icons --key Theme Papirus-Dark
# Plasma look-and-feel
$KWC --file kdeglobals --group KDE --key LookAndFeelPackage org.edpearos.desktop
# Kvantum widget style
$KWC --file kdeglobals --group KDE --key widgetStyle kvantum
# Desktop theme  
$KWC --file plasmarc --group Theme --key name breeze-dark
# KWin decoration
$KWC --file kwinrc --group "org.kde.kdecoration2" --key library org.kde.breeze
$KWC --file kwinrc --group "org.kde.kdecoration2" --key theme Breeze
# Splash
$KWC --file ksplashrc --group KSplash --key Theme org.edpearos.desktop
$KWC --file ksplashrc --group KSplash --key Engine none
# Konsole default profile
$KWC --file konsolerc --group "Desktop Entry" --key DefaultProfile edpearos.profile
# Kvantum
mkdir -p "$HOME/.config/Kvantum"
echo -e '[General]\ntheme=KvArcDark' > "$HOME/.config/Kvantum/kvantum.kvconfig"

# ── Apply via plasma-apply-* tools ──
if command -v plasma-apply-colorscheme &>/dev/null; then
    plasma-apply-colorscheme EdpearOSTokyo 2>/dev/null || true
    echo "[edpearOS] Color scheme applied"
fi

if command -v plasma-apply-desktoptheme &>/dev/null; then
    plasma-apply-desktoptheme breeze-dark 2>/dev/null || true
fi

if command -v plasma-apply-lookandfeel &>/dev/null; then
    plasma-apply-lookandfeel -a org.edpearos.desktop 2>/dev/null || true
    echo "[edpearOS] Look-and-feel applied"
fi

if command -v plasma-apply-wallpaperimage &>/dev/null; then
    if [ -f /usr/share/edpearos/wallpapers/default.png ]; then
        plasma-apply-wallpaperimage /usr/share/edpearos/wallpapers/default.png 2>/dev/null || true
        echo "[edpearOS] Wallpaper applied"
    fi
fi

if command -v plasma-apply-cursortheme &>/dev/null; then
    plasma-apply-cursortheme breeze_cursors 2>/dev/null || true
fi

# ── Reload KWin for immediate decoration effect ──
$QDBUS org.kde.KWin /KWin reconfigure 2>/dev/null || true

# ── GTK dark theme ──
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
for ver in 3.0 4.0; do
    if [ -f "/etc/skel/.config/gtk-$ver/settings.ini" ]; then
        cp -n "/etc/skel/.config/gtk-$ver/settings.ini" "$HOME/.config/gtk-$ver/settings.ini"
    fi
done

# ── Mark as applied ──
mkdir -p "$(dirname "$MARKER")"
date > "$MARKER"

echo "[edpearOS] Theme applied successfully!"
