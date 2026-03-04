# edpearOS — Build Instructions

## Overview

edpearOS uses **archiso** to build a bootable Arch Linux ISO. The entire distro is defined by the `archiso-profile/` directory — there's no need to manually install packages or configure the system.

## Build Methods

### Method 1: Windows via WSL (Easiest)

This is the recommended method if you're on Windows.

#### Prerequisites

1. **Install WSL2**: Open PowerShell as Admin and run `wsl --install`
2. **Install ArchWSL**: Download from [yuk7/ArchWSL](https://github.com/yuk7/ArchWSL/releases), extract, run `Arch.exe`
3. **Set up ArchWSL**:
   ```bash
   # Inside Arch WSL:
   pacman-key --init
   pacman-key --populate archlinux
   pacman -Syu
   pacman -S archiso dos2unix base-devel
   ```

#### Build

```powershell
# PowerShell as Administrator
cd C:\Users\<you>\research\edpearOS
.\build_and_flash.ps1
```

The script:
1. Converts line endings (Windows → Unix)
2. Runs `mkarchiso` inside WSL
3. Downloads and launches Rufus to flash the ISO to USB

### Method 2: Native Arch Linux

```bash
# Install archiso
sudo pacman -S archiso

# Clone the repo
git clone https://github.com/aarushk09/edpearOS.git
cd edpearOS

# Build (takes 15-30 min depending on internet speed)
sudo ./scripts/build-iso.sh

# Output: out/edpearOS-YYYY.MM.DD-x86_64.iso
```

### Method 3: GitHub Actions (Fully Automated)

Every push to `main` triggers an automated build. You can also manually trigger it:

1. Go to the [Actions tab](https://github.com/aarushk09/edpearOS/actions)
2. Click "Build edpearOS ISO"
3. Click "Run workflow"
4. Download the ISO from the build artifacts

To create a release:
```bash
git tag v2026.1
git push --tags
```

This builds the ISO and creates a GitHub Release with the ISO attached.

## Flashing the ISO

### Rufus (Windows)
1. Download [Rufus](https://rufus.ie)
2. Select your USB drive
3. Select the edpearOS ISO
4. **Important**: Choose "DD Image" mode (not ISO mode)
5. Click START

### dd (Linux)
```bash
sudo dd if=out/edpearOS-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
sync
```

### Ventoy (Cross-platform)
1. Install [Ventoy](https://ventoy.net) on a USB drive
2. Copy the edpearOS ISO file to the Ventoy USB
3. Boot from USB → select edpearOS from the Ventoy menu

## Testing in a VM

### QEMU (Linux)
```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -cpu host \
  -smp 4 \
  -bios /usr/share/ovmf/OVMF.fd \
  -cdrom out/edpearOS-*.iso \
  -boot d
```

### VirtualBox
1. Create a new VM (Type: Arch Linux, 64-bit)
2. RAM: 4 GB minimum
3. Enable EFI: Settings → System → Enable EFI
4. Storage → Controller: IDE → Add edpearOS ISO
5. Start the VM

## Troubleshooting

### Build fails with "package not found"
- The Chaotic-AUR repo may be down. Try again later.
- Some packages (obsidian, zotero) require Chaotic-AUR. The build script sets this up automatically.

### ISO is too large
- Edit `archiso-profile/packages.x86_64` and remove packages you don't need.
- Large packages: `libreoffice-fresh` (~300MB), `texlive-*` (~200MB), `code` (~300MB).

### WSL build fails
- Make sure you're using Arch Linux WSL, not Ubuntu.
- Run `dos2unix` on all shell scripts: `find . -name '*.sh' -exec dos2unix {} +`
- Ensure enough disk space: WSL needs ~15GB free in the VHDX.

### Calamares doesn't start
- Calamares requires root: run `sudo calamares` or use the desktop shortcut.
- Check `/var/log/Calamares/session.log` for errors.

### Focus mode doesn't block websites
- Website blocking requires root. It uses `pkexec` to modify `/etc/hosts`.
- You can edit the blocklist at `/etc/edpearos/focus-blocklist.txt` or `~/.config/edpearos/focus-blocklist.txt`.
