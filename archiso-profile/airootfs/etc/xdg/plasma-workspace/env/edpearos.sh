#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# /etc/xdg/plasma-workspace/env/edpearos.sh
# Runs BEFORE Plasma starts — sets dark GTK theme env vars
# so every app opened is already dark, no flash of light theme
# ═══════════════════════════════════════════════════════════════

# Force GTK apps to use dark theme
export GTK_THEME="Breeze:dark"
export GTK2_RC_FILES="/usr/share/themes/Breeze/gtk-2.0/gtkrc"

# Qt platform theme
export QT_QPA_PLATFORMTHEME="kde"
export QT_STYLE_OVERRIDE="kvantum"

# Cursor
export XCURSOR_THEME="breeze_cursors"
export XCURSOR_SIZE=24

# XDG
export XDG_CURRENT_DESKTOP="KDE"
export DESKTOP_SESSION="plasma"
