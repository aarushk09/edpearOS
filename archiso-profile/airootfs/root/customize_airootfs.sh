#!/usr/bin/env bash
# edpearOS customize_airootfs.sh
# Runs inside arch-chroot after package install.
# NOTE: /proc and /sys are NOT mounted. Use sed for shadow, symlinks for services.
set -u

echo "==> [edpearOS] customize_airootfs: starting..."

# ── liveuser home ──
echo "==> Setting up liveuser home..."
if id liveuser >/dev/null 2>&1; then
    mkdir -p /home/liveuser
    if [ -z "$(ls -A /home/liveuser 2>/dev/null)" ]; then
        cp -rT /etc/skel /home/liveuser 2>/dev/null || true
    fi
    chown -R liveuser:liveuser /home/liveuser
    chmod 750 /home/liveuser
fi

# ── Autologin group (SDDM requires this) ──
echo "==> Creating autologin group..."
groupadd -f autologin 2>/dev/null || true
usermod -aG autologin liveuser 2>/dev/null || true

# ── liveuser group memberships ──
echo "==> Setting liveuser group memberships..."
for grp in wheel video audio storage optical network lp scanner sys rfkill input; do
    groupadd -f "$grp" 2>/dev/null || true
    usermod -aG "$grp" liveuser 2>/dev/null || true
done
echo "==> liveuser groups: $(id liveuser 2>/dev/null || echo 'unknown')"

# ── Remove passwords via direct shadow edit (no /proc needed) ──
echo "==> Removing passwords via /etc/shadow..."
if [ -f /etc/shadow ]; then
    sed -i 's|^liveuser:[^:]*:|liveuser::|' /etc/shadow
    sed -i 's|^root:[^:]*:|root::|'        /etc/shadow
    echo "==> shadow updated"
fi

# ── Session cleanup: keep only plasma.desktop ──
echo "==> Cleaning up session desktop files..."
find /usr/share/wayland-sessions -name '*.desktop' ! -name 'plasma.desktop' -delete 2>/dev/null || true
rm -f /usr/share/xsessions/*.desktop 2>/dev/null || true
echo "==> Remaining wayland-sessions:"
ls /usr/share/wayland-sessions/ 2>/dev/null || true

# Auto-detect plasma session name if renamed
if [ ! -f /usr/share/wayland-sessions/plasma.desktop ]; then
    found="$(basename "$(ls /usr/share/wayland-sessions/*.desktop 2>/dev/null | head -1)" .desktop 2>/dev/null || true)"
    if [ -n "$found" ]; then
        sed -i "s/^Session=.*/Session=$found/" /etc/sddm.conf.d/edpearos.conf 2>/dev/null || true
        echo "==> SDDM session auto-set to: $found"
    fi
fi

# ── Enable systemd services via symlinks (no running systemd needed) ──
echo "==> Enabling systemd services..."
_enable() {
    local svc="$1"
    local target="${2:-multi-user.target}"
    local wants_dir="/etc/systemd/system/${target}.wants"
    local unit
    unit="$(find /usr/lib/systemd/system -maxdepth 1 -name "$svc" -print -quit 2>/dev/null)"
    if [ -n "$unit" ]; then
        mkdir -p "$wants_dir"
        ln -sf "$unit" "$wants_dir/$svc" 2>/dev/null || true
        echo "  enabled: $svc -> $wants_dir"
    else
        echo "  WARNING: unit file not found for $svc"
    fi
}
_enable sddm.service           graphical.target
_enable NetworkManager.service  multi-user.target
_enable bluetooth.service       multi-user.target
_enable avahi-daemon.service    multi-user.target

# ── Set graphical.target as default ──
ln -sf /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target 2>/dev/null || true
echo "==> default.target -> graphical.target"

# ── SDDM as the only display-manager (mask plasma-login-manager) ──
echo "==> Setting SDDM as the display manager..."
mkdir -p /etc/systemd/system
ln -sf /usr/lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service 2>/dev/null || true
# Mask plasmalogin so it cannot start (plasma-meta pulls it in)
if [ -f /usr/lib/systemd/system/plasmalogin.service ]; then
    ln -sf /dev/null /etc/systemd/system/plasmalogin.service 2>/dev/null || true
    echo "  masked plasmalogin.service"
fi
echo "  display-manager.service -> sddm.service"

# ── Verify SDDM config exists ──
echo "==> Verifying SDDM configuration..."
if [ -f /etc/sddm.conf.d/edpearos.conf ]; then
    echo "  SDDM config found:"
    cat /etc/sddm.conf.d/edpearos.conf
else
    echo "  WARNING: /etc/sddm.conf.d/edpearos.conf is MISSING!"
fi

# ── Verify SDDM theme exists ──
if [ -d /usr/share/sddm/themes/edpearos ]; then
    echo "  SDDM theme found: $(ls /usr/share/sddm/themes/edpearos/)"
else
    echo "  WARNING: /usr/share/sddm/themes/edpearos/ is MISSING!"
fi

# ── Sudoers NOPASSWD for wheel ──
if [ -f /etc/sudoers ]; then
    grep -q 'NOPASSWD' /etc/sudoers || echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
fi

echo "==> [edpearOS] customize_airootfs: done."
