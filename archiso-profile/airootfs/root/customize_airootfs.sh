#!/usr/bin/env bash
# customization hook - runs in arch-chroot after package install
# NOTE: /proc /sys not mounted here. Use sed for shadow edits, not passwd.
set -u

echo "==> [edpearOS] customize_airootfs: starting..."

# liveuser home
echo "==> Setting up liveuser home..."
if id liveuser >/dev/null 2>&1; then
    mkdir -p /home/liveuser
    if [ -z "" ]; then
        cp -rT /etc/skel /home/liveuser 2>/dev/null || true
    fi
    chown -R liveuser:liveuser /home/liveuser
    chmod 750 /home/liveuser
fi

# liveuser groups
echo "==> Setting liveuser group memberships..."
for grp in wheel video audio storage optical network lp scanner sys rfkill input; do
    groupadd -f "" 2>/dev/null || true
    usermod -aG "" liveuser 2>/dev/null || true
done

# Remove passwords via direct shadow edit (no /proc needed)
echo "==> Removing passwords via /etc/shadow..."
if [ -f /etc/shadow ]; then
    sed -i 's|^liveuser:[^:]*:|liveuser::|' /etc/shadow
    sed -i 's|^root:[^:]*:|root::|'        /etc/shadow
    echo "==> shadow updated"
fi

# Session cleanup: keep only plasma.desktop
echo "==> Cleaning up session desktop files..."
find /usr/share/wayland-sessions -name '*.desktop' ! -name 'plasma.desktop' -delete 2>/dev/null || true
rm -f /usr/share/xsessions/*.desktop 2>/dev/null || true
echo "==> Remaining wayland-sessions:"
ls /usr/share/wayland-sessions/ 2>/dev/null || true

# Auto-detect plasma session name if renamed
if [ ! -f /usr/share/wayland-sessions/plasma.desktop ]; then
    found=
    if [ -n "" ]; then
        sname=
        sed -i "s/^Session=.*/Session=/" /etc/sddm.conf.d/edpearos.conf 2>/dev/null || true
        echo "==> SDDM session auto-set to: "
    fi
fi

# Enable systemd services via symlinks (no running systemd needed)
echo "==> Enabling systemd services..."
_enable() {
    local svc="" target=""
    local wants_dir="/etc/systemd/system/.wants"
    local unit; unit=
    if [ -n "" ]; then
        mkdir -p ""
        ln -sf "" "/" 2>/dev/null || true
        echo "  enabled:  -> "
    fi
}
_enable sddm.service          graphical.target
_enable NetworkManager.service
_enable bluetooth.service
_enable avahi-daemon.service

# Sudoers NOPASSWD for wheel
if [ -f /etc/sudoers ]; then
    grep -q 'NOPASSWD' /etc/sudoers || echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
fi

echo "==> [edpearOS] customize_airootfs: done."
