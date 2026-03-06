#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# edpearOS — Chroot Customization Hook
# Runs inside the archiso chroot after all packages are installed.
# mkarchiso automatically executes this file at /root/customize_airootfs.sh
# ═══════════════════════════════════════════════════════════════
set -e -u

echo "==> [edpearOS] customize_airootfs: starting..."

# ── liveuser: home directory ──────────────────────────────────
echo "==> Setting up liveuser home..."
if id liveuser &>/dev/null; then
    mkdir -p /home/liveuser
    # Copy skeleton (dotfiles, config dirs)
    cp -rT /etc/skel /home/liveuser
    chown -R liveuser:liveuser /home/liveuser
    chmod 750 /home/liveuser
fi

# ── liveuser: group memberships ──────────────────────────────
echo "==> Setting liveuser group memberships..."
for grp in wheel video audio storage optical network lp scanner sys rfkill input; do
    groupadd -f "$grp" 2>/dev/null || true
    usermod -aG "$grp" liveuser 2>/dev/null || true
done

# ── liveuser: remove password (empty = autologin works) ──────
echo "==> Removing liveuser password..."
passwd -d liveuser

# ── Session cleanup: remove all but Plasma Wayland ───────────
# Packages (hyprland, plasma) install their own .desktop files.
# Remove everything except plasma.desktop (KDE Plasma 6 Wayland).
echo "==> Cleaning up session desktop files..."

# Wayland sessions: keep only plasma.desktop
find /usr/share/wayland-sessions -name '*.desktop' \
    ! -name 'plasma.desktop' -delete 2>/dev/null || true

# X11 sessions: remove all (we are Wayland-only)
rm -f /usr/share/xsessions/*.desktop 2>/dev/null || true

# Also clean any leftover Hyprland/UWSM wrappers
rm -f /usr/share/wayland-sessions/hyprland.desktop     2>/dev/null || true
rm -f /usr/share/wayland-sessions/hyprland-uwsm.desktop 2>/dev/null || true

echo "==> Remaining wayland-sessions:"
ls /usr/share/wayland-sessions/ 2>/dev/null

# ── Set correct Plasma session name in SDDM ──────────────────
# Verify plasma.desktop exists; if Plasma 6 uses a different name, patch conf.
if [ ! -f /usr/share/wayland-sessions/plasma.desktop ]; then
    # Fallback: find whatever Plasma session file exists
    PLASMA_SESSION=$(find /usr/share/wayland-sessions -iname '*plasma*' -name '*.desktop' | head -1)
    if [ -n "$PLASMA_SESSION" ]; then
        SESSION_NAME="$(basename "$PLASMA_SESSION" .desktop)"
        sed -i "s/^Session=.*/Session=${SESSION_NAME}/" /etc/sddm.conf.d/edpearos.conf
        echo "==> SDDM session set to: ${SESSION_NAME}"
    fi
fi

# ── Enable systemd services ───────────────────────────────────
echo "==> Enabling systemd services..."
systemctl enable sddm.service          2>/dev/null || true
systemctl enable NetworkManager.service 2>/dev/null || true
systemctl enable bluetooth.service     2>/dev/null || true
systemctl enable avahi-daemon.service  2>/dev/null || true

# ── Sudoers: ensure wheel has NOPASSWD ───────────────────────
if ! grep -q 'NOPASSWD' /etc/sudoers 2>/dev/null; then
    echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

echo "==> [edpearOS] customize_airootfs: done."
