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

# ── Apply color scheme ──
if command -v plasma-apply-colorscheme &>/dev/null; then
    plasma-apply-colorscheme EdpearOSTokyo 2>/dev/null || true
    echo "[edpearOS] Color scheme applied"
fi

# ── Apply Plasma theme (breeze-dark) ──
if command -v plasma-apply-desktoptheme &>/dev/null; then
    plasma-apply-desktoptheme breeze-dark 2>/dev/null || true
    echo "[edpearOS] Desktop theme applied"
fi

# ── Apply look-and-feel ──
if command -v plasma-apply-lookandfeel &>/dev/null; then
    plasma-apply-lookandfeel -a org.edpearos.desktop 2>/dev/null || true
    echo "[edpearOS] Look-and-feel applied"
fi

# ── Apply wallpaper ──
if command -v plasma-apply-wallpaperimage &>/dev/null; then
    if [ -f /usr/share/edpearos/wallpapers/default.png ]; then
        plasma-apply-wallpaperimage /usr/share/edpearos/wallpapers/default.png 2>/dev/null || true
        echo "[edpearOS] Wallpaper applied"
    fi
fi

# ── Apply cursor theme ──
if command -v plasma-apply-cursortheme &>/dev/null; then
    plasma-apply-cursortheme breeze_cursors 2>/dev/null || true
fi

# ── Set icon theme via kwriteconfig ──
if command -v kwriteconfig6 &>/dev/null; then
    kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark
    echo "[edpearOS] Icon theme set to Papirus-Dark"
elif command -v kwriteconfig5 &>/dev/null; then
    kwriteconfig5 --file kdeglobals --group Icons --key Theme Papirus-Dark
fi

# ── Set Konsole defaults ──
if command -v kwriteconfig6 &>/dev/null; then
    kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile edpearos.profile
fi

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
