#!/bin/bash
# edpearOS Student Setup — Post-install script for Calamares
# Called by the student-setup module after the user picks their major.
# Reads the selected profile from /tmp/edpearos-student-profile
set -e

PROFILE_FILE="/tmp/edpearos-student-profile"
TARGET_DIR="$1"  # Calamares passes the install target

if [ ! -f "$PROFILE_FILE" ]; then
    echo "[student-setup] No profile selected, skipping extra packages."
    exit 0
fi

PROFILE=$(cat "$PROFILE_FILE")
echo "[student-setup] Installing packages for profile: $PROFILE"

case "$PROFILE" in
    STEM)
        EXTRA_PKGS="texlive-basic texlive-latexrecommended python-numpy python-matplotlib python-scipy octave"
        ;;
    Writing)
        EXTRA_PKGS="texlive-latexrecommended texlive-humanities"
        ;;
    Art)
        EXTRA_PKGS="gimp inkscape krita blender"
        ;;
    Programming)
        EXTRA_PKGS="docker python-pandas python-scikit-learn rust go"
        ;;
    *)
        EXTRA_PKGS=""
        ;;
esac

if [ -n "$EXTRA_PKGS" ]; then
    if [ -n "$TARGET_DIR" ] && [ -d "$TARGET_DIR" ]; then
        arch-chroot "$TARGET_DIR" pacman -S --noconfirm --needed $EXTRA_PKGS 2>&1 || true
    else
        pacman -S --noconfirm --needed $EXTRA_PKGS 2>&1 || true
    fi
fi

echo "[student-setup] Profile '$PROFILE' packages installed."
