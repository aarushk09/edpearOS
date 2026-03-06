#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# edpearOS — ISO Build Script
# Builds the edpearOS live ISO using archiso (mkarchiso)
#
# Usage: sudo ./scripts/build-iso.sh [--clean]
#
# Prerequisites:
#   - Arch Linux host (or Arch-based distro)
#   - archiso package installed: pacman -S archiso
#   - ~15GB free disk space
#   - Internet connection (for package downloads)
#
# Output: out/edpearOS-YYYY.MM.DD-x86_64.iso
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROFILE_DIR="${REPO_ROOT}/archiso-profile"
WORK_DIR="${REPO_ROOT}/work"
OUT_DIR="${REPO_ROOT}/out"
CLEAN_BUILD=0

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --clean) CLEAN_BUILD=1 ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
  shift
done

# ── Checks ──
if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: This script must be run as root (sudo)"
  exit 1
fi

if ! command -v mkarchiso &>/dev/null; then
  echo "ERROR: archiso is not installed."
  echo "Install with: pacman -S archiso"
  exit 1
fi

echo "═══════════════════════════════════════════"
echo "  edpearOS — ISO Build"
echo "═══════════════════════════════════════════"
echo "Profile: $PROFILE_DIR"
echo "Work:    $WORK_DIR"
echo "Output:  $OUT_DIR"
echo ""

# ── Clean previous build ──
if [ "$CLEAN_BUILD" -eq 1 ]; then
  echo "==> Cleaning previous build..."
  rm -rf "$WORK_DIR" "$OUT_DIR"
fi

mkdir -p "$OUT_DIR"

# ── Setup Chaotic-AUR (needed for obsidian, calamares, etc.) ──
echo "==> Setting up Chaotic-AUR repository..."
if ! pacman -Qq chaotic-keyring &>/dev/null 2>&1; then
  echo "  Installing Chaotic-AUR keyring..."
  pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com || true
  pacman-key --lsign-key 3056513887B78AEB || true
  pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' || true
  pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' || true
fi

# Ensure chaotic-aur mirrorlist exists for the profile's pacman.conf
if [ ! -f /etc/pacman.d/chaotic-mirrorlist ]; then
  echo "[chaotic-aur]" >> /etc/pacman.conf
  echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
  mkdir -p /etc/pacman.d
  echo 'Server = https://cdn-mirror.chaotic.cx/chaotic-aur/$repo/$arch' > /etc/pacman.d/chaotic-mirrorlist
fi

# Update pacman databases
pacman -Sy

# ── Generate wallpaper (bake directly into airootfs) ──
echo "==> Generating Tokyo Night wallpaper..."
WALLPAPER_DIR="${PROFILE_DIR}/airootfs/usr/share/edpearos/wallpapers"
mkdir -p "$WALLPAPER_DIR"
if [ ! -f "$WALLPAPER_DIR/default.png" ]; then
  if command -v python3 &>/dev/null; then
    echo "  Using Python generator..."
    python3 "${SCRIPT_DIR}/generate-wallpaper.py" "$WALLPAPER_DIR/default.png" 1920 1080
  elif command -v convert &>/dev/null; then
    echo "  Using ImageMagick fallback..."
    convert -size 1920x1080 \
      'gradient:#1a1b26-#24283b' \
      "$WALLPAPER_DIR/default.png"
  else
    echo "  WARNING: No generator available — theme will use default KDE wallpaper"
  fi
else
  echo "  Wallpaper already exists, skipping"
fi

# ── Generate Calamares branding logo if not present ──
BRAND_DIR="${PROFILE_DIR}/airootfs/etc/calamares/branding/edpearos"
mkdir -p "$BRAND_DIR"
if [ ! -f "$BRAND_DIR/logo.png" ]; then
  echo "  Generating placeholder logo..."
  if command -v convert &>/dev/null; then
    convert -size 256x256 xc:'#1a1b26' \
      -fill '#7aa2f7' -font 'DejaVu-Sans-Bold' -pointsize 120 \
      -gravity center -annotate 0 'eP' \
      -fill '#bb9af7' -draw 'circle 128,128 128,20' \
      -fill '#1a1b26' -font 'DejaVu-Sans-Bold' -pointsize 100 \
      -gravity center -annotate 0 'eP' \
      "$BRAND_DIR/logo.png"
  fi
fi
if [ ! -f "$BRAND_DIR/welcome.png" ]; then
  cp "$BRAND_DIR/logo.png" "$BRAND_DIR/welcome.png" 2>/dev/null || true
fi

# ── Create systemd service symlinks ──
# (Needed because Windows/NTFS can't store Unix symlinks in the git repo)
echo "==> Creating systemd service enable symlinks..."
mkdir -p "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants"
mkdir -p "$PROFILE_DIR/airootfs/etc/systemd/system/timers.target.wants"
mkdir -p "$PROFILE_DIR/airootfs/etc/systemd/system/sockets.target.wants"
mkdir -p "$PROFILE_DIR/airootfs/etc/systemd/system/sysinit.target.wants"
mkdir -p "$PROFILE_DIR/airootfs/etc/systemd/system-generators"

# -- Disable GPT auto-generator (interferes with live boot) --
ln -sf /dev/null \
  "$PROFILE_DIR/airootfs/etc/systemd/system-generators/systemd-gpt-auto-generator"

# -- SDDM display manager --
ln -sf /usr/lib/systemd/system/sddm.service \
  "$PROFILE_DIR/airootfs/etc/systemd/system/display-manager.service"

# -- NetworkManager --
ln -sf /usr/lib/systemd/system/NetworkManager.service \
  "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service"

# -- Bluetooth --
ln -sf /usr/lib/systemd/system/bluetooth.service \
  "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/bluetooth.service"

# -- Pacman keyring init --
ln -sf /etc/systemd/system/pacman-init.service \
  "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/pacman-init.service"

# -- IWD (wireless) --
ln -sf /usr/lib/systemd/system/iwd.service \
  "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/iwd.service"

# -- Time sync --
ln -sf /usr/lib/systemd/system/systemd-timesyncd.service \
  "$PROFILE_DIR/airootfs/etc/systemd/system/sysinit.target.wants/systemd-timesyncd.service"

# -- Periodic TRIM for SSDs --
ln -sf /usr/lib/systemd/system/fstrim.timer \
  "$PROFILE_DIR/airootfs/etc/systemd/system/timers.target.wants/fstrim.timer"

# ── Create liveuser home directory from skel ──
echo "==> Setting up liveuser home directory..."
mkdir -p "$PROFILE_DIR/airootfs/home/liveuser"
cp -rT "$PROFILE_DIR/airootfs/etc/skel" "$PROFILE_DIR/airootfs/home/liveuser"

# ── Refresh edpearos-desktop theme (optional, fetch latest) ──
echo "==> Checking edpearos-desktop theme..."
DESKTOP_REPO="https://github.com/aarushk09/edpearos-desktop.git"
DESKTOP_TMP="/tmp/edpearos-desktop"
if command -v git &>/dev/null; then
  if git clone --depth 1 "$DESKTOP_REPO" "$DESKTOP_TMP" 2>/dev/null; then
    echo "  Refreshing theme files from edpearos-desktop repo..."
    # Color scheme
    cp -f "$DESKTOP_TMP/color-schemes/"*.colors \
      "$PROFILE_DIR/airootfs/usr/share/color-schemes/" 2>/dev/null || true
    # Look-and-feel package
    cp -rf "$DESKTOP_TMP/look-and-feel/org.edpearos.desktop" \
      "$PROFILE_DIR/airootfs/usr/share/plasma/look-and-feel/" 2>/dev/null || true
    # SDDM theme
    cp -rf "$DESKTOP_TMP/sddm/edpearos/"* \
      "$PROFILE_DIR/airootfs/usr/share/sddm/themes/edpearos/" 2>/dev/null || true
    # Konsole profile + colorscheme
    cp -f "$DESKTOP_TMP/konsole/"* \
      "$PROFILE_DIR/airootfs/usr/share/konsole/" 2>/dev/null || true
    # Icon
    cp -f "$DESKTOP_TMP/icons/edpearos.svg" \
      "$PROFILE_DIR/airootfs/usr/share/icons/hicolor/scalable/apps/" 2>/dev/null || true
    # Apply script
    cp -f "$DESKTOP_TMP/scripts/apply-theme.sh" \
      "$PROFILE_DIR/airootfs/usr/share/edpearos/apply-theme.sh" 2>/dev/null || true
    # GTK settings
    for ver in gtk-3.0 gtk-4.0; do
      [ -f "$DESKTOP_TMP/$ver/settings.ini" ] && \
        cp -f "$DESKTOP_TMP/$ver/settings.ini" \
          "$PROFILE_DIR/airootfs/etc/skel/.config/$ver/settings.ini" 2>/dev/null || true
    done
    rm -rf "$DESKTOP_TMP"
    echo "  Theme files refreshed from upstream"
  else
    echo "  Using bundled theme files (git clone failed, offline build)"
  fi
fi

# ── Strip Windows CRLF line endings from all profile text files ──
# (Files synced from NTFS can retain \r, which breaks bash scripts in the chroot)
echo "==> Stripping CRLF line endings from airootfs..."
find "$PROFILE_DIR" -type f \
  \( -name "*.sh" -o -name "*.preset" -o -name "*.conf" -o -name "*.service" \
     -o -name "*.desktop" -o -name "*.ini" -o -name "*.cfg" -o -name "*.py" \
     -o -name "*.txt" -o -name "*.json" -o -name "*.lua" -o -name "*.rules" \
     -o -name "control" -o -name "profiledef.sh" \) \
  -exec sed -i 's/\r//' {} +
echo "    Done."

# ── Build ISO ──
echo ""
echo "==> Building edpearOS ISO with mkarchiso..."
echo "    This will download packages and may take 15-30 minutes."
echo ""

yes | mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"

# ── Rename output ISO ──
ISO_FILE=$(find "$OUT_DIR" -name "edpearOS-*.iso" -type f | head -1)
if [ -z "$ISO_FILE" ]; then
  echo "ERROR: No ISO file produced!"
  exit 1
fi

# ── Generate checksum ──
echo ""
echo "==> Generating checksum..."
cd "$OUT_DIR"
sha256sum "$(basename "$ISO_FILE")" > "$(basename "$ISO_FILE").sha256"

echo ""
echo "═══════════════════════════════════════════"
echo "  edpearOS ISO Build Complete!"
echo "═══════════════════════════════════════════"
echo "ISO:      $ISO_FILE"
echo "SHA256:   $(cat "$(basename "$ISO_FILE").sha256")"
echo "Size:     $(du -h "$ISO_FILE" | cut -f1)"
echo ""
echo "Flash to USB:"
echo "  sudo dd if=$ISO_FILE of=/dev/sdX bs=4M status=progress oflag=sync"
echo "  Or use Rufus (Windows) / Ventoy / Balena Etcher"
