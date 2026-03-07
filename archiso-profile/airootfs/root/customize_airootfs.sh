#!/usr/bin/env bash
# edpearOS customize_airootfs.sh
# Runs inside arch-chroot after package install.
# NOTE: /proc and /sys are NOT mounted. Use sed for shadow, symlinks for services.
# Login strategy: getty autologin on tty1 → .bash_profile → startplasma-wayland
# SDDM is masked — no login screen.
set -u

echo "==> [edpearOS] customize_airootfs: starting..."

# ── Ensure liveuser exists in passwd ──
echo "==> Ensuring liveuser account exists..."
if ! id liveuser >/dev/null 2>&1; then
    echo "liveuser:x:1000:1000:Live User:/home/liveuser:/bin/bash" >> /etc/passwd
    echo "liveuser:x:1000:" >> /etc/group
    echo "  created liveuser in passwd/group"
fi

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

# ── Autologin group ──
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

# ── Ensure root and liveuser are in shadow with empty passwords ──
echo "==> Setting up /etc/shadow..."
if [ -f /etc/shadow ]; then
    # Add root if missing
    if ! grep -q '^root:' /etc/shadow; then
        echo 'root:::::::' >> /etc/shadow
        echo "  added root to shadow"
    fi
    # Add liveuser if missing
    if ! grep -q '^liveuser:' /etc/shadow; then
        echo 'liveuser:::::::' >> /etc/shadow
        echo "  added liveuser to shadow"
    fi
    # Clear passwords (set empty)
    sed -i 's|^liveuser:[^:]*:|liveuser::|' /etc/shadow
    sed -i 's|^root:[^:]*:|root::|'        /etc/shadow
    echo "==> shadow entries:"
    grep -E '^(root|liveuser):' /etc/shadow
fi

# ── Session cleanup: keep only plasma.desktop ──
echo "==> Cleaning up session desktop files..."
find /usr/share/wayland-sessions -name '*.desktop' ! -name 'plasma.desktop' -delete 2>/dev/null || true
rm -f /usr/share/xsessions/*.desktop 2>/dev/null || true
echo "==> Remaining wayland-sessions:"
ls /usr/share/wayland-sessions/ 2>/dev/null || true



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
_enable NetworkManager.service  multi-user.target
_enable bluetooth.service       multi-user.target
_enable avahi-daemon.service    multi-user.target

# ── Set graphical.target as default ──
ln -sf /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target 2>/dev/null || true
echo "==> default.target -> graphical.target"

# ── MASK sddm and plasmalogin — use getty autologin instead ──
# SDDM theme QML errors + autologin failures are bypassed this way.
echo "==> Masking SDDM and plasmalogin (using getty autologin)..."
mkdir -p /etc/systemd/system
ln -sf /dev/null /etc/systemd/system/sddm.service 2>/dev/null || true
ln -sf /dev/null /etc/systemd/system/plasmalogin.service 2>/dev/null || true
# Remove display-manager.service if it points to sddm
rm -f /etc/systemd/system/display-manager.service 2>/dev/null || true
# Also mask graphical.target wants/sddm
rm -f /etc/systemd/system/graphical.target.wants/sddm.service 2>/dev/null || true
echo "  sddm.service -> /dev/null (masked)"
echo "  plasmalogin.service -> /dev/null (masked)"

# ── Getty autologin for tty1 ──
echo "==> Setting up getty autologin for liveuser on tty1..."
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << 'AUTOLOGIN'
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \u' --noclear --autologin liveuser %I $TERM
Type=simple
AUTOLOGIN
echo "  getty@tty1 autologin configured"

# ── Ensure .bash_profile is in liveuser home ──
echo "==> Ensuring .bash_profile in liveuser home..."
if [ -f /etc/skel/.bash_profile ] && [ ! -f /home/liveuser/.bash_profile ]; then
    cp /etc/skel/.bash_profile /home/liveuser/.bash_profile
    chown liveuser:liveuser /home/liveuser/.bash_profile
    echo "  .bash_profile copied to /home/liveuser"
elif [ -f /home/liveuser/.bash_profile ]; then
    # Force overwrite from skel so it has the plasma start logic
    cp /etc/skel/.bash_profile /home/liveuser/.bash_profile
    chown liveuser:liveuser /home/liveuser/.bash_profile
    echo "  .bash_profile refreshed in /home/liveuser"
fi
echo "  .bash_profile content:"
cat /home/liveuser/.bash_profile 2>/dev/null || echo "  WARNING: not found!"

# ── Sudoers NOPASSWD for wheel ──
if [ -f /etc/sudoers ]; then
    grep -q 'NOPASSWD' /etc/sudoers || echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
fi

echo "==> [edpearOS] customize_airootfs: done."
