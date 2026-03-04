# edpearOS — The Modern Student Desktop

An Arch Linux distribution built for academic productivity. Pre-configured with a student-focused workflow, focus mode, and everything you need to succeed in school.

## Features

- **Dual Desktop**: KDE Plasma (familiar) + Hyprland (tiling power-user mode) — choose at login
- **Focus Mode**: One-click toggle that silences notifications, blocks distracting websites, and enables a blue light filter
- **Student Stack**: Pre-installed Obsidian, Zotero, LibreOffice, VS Code, Firefox, LaTeX
- **Welcome App**: "What are you studying today?" — launches the right workspace for your subject
- **Smart Shortcuts**: `Super+N` = Notes, `Super+C` = Calculator, `Super+F` = Focus Mode, etc.
- **Calamares Installer**: Graphical installer with a "Student Setup" page to choose your major and install relevant tools
- **Blue Light Filter**: Active by default in the evenings for late-night study sessions
- **Timeshift Snapshots**: Automatic system backups so you never lose your setup
- **Tokyo Night Theme**: High-contrast dark theme optimized for reading

## Screenshots

*Coming soon — build the ISO and try it!*

## System Requirements

| Component | Minimum       | Recommended   |
|-----------|---------------|---------------|
| CPU       | 2-core 64-bit | 4-core 64-bit |
| RAM       | 4 GB          | 8 GB          |
| Storage   | 20 GB         | 50 GB         |
| Boot      | UEFI or BIOS  | UEFI          |

## Quick Start

### Download (Releases)

Download the latest ISO from [GitHub Releases](https://github.com/aarushk09/edpearOS/releases), flash to USB, and boot.

### Windows Build (Recommended for Development)

Prerequisites:
- Windows 10/11 with Administrator privileges
- [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) with [ArchWSL](https://github.com/yuk7/ArchWSL)
- Inside ArchWSL: `pacman -Syu archiso`

```powershell
# Run PowerShell as Administrator
.\build_and_flash.ps1
```

Flags:
- `-SkipFlash` — Build ISO only, don't launch Rufus
- `-SkipBuild` — Use existing ISO, just flash
- `-CleanBuild` — Wipe work directory and rebuild from scratch

### Linux Build (Native Arch)

Prerequisites:
- Arch Linux host (or Arch-based distro like EndeavourOS)
- `archiso` package: `sudo pacman -S archiso`
- ~15GB free disk space

```bash
sudo ./scripts/build-iso.sh
```

The ISO will be in `out/edpearOS-YYYY.MM.DD-x86_64.iso`.

### Flash to USB

**Windows**: Use [Rufus](https://rufus.ie) in DD Image mode  
**Linux**: `sudo dd if=out/edpearOS-*.iso of=/dev/sdX bs=4M status=progress oflag=sync`  
**Cross-platform**: [Ventoy](https://ventoy.net) (just copy the ISO to the Ventoy USB)

## Repository Structure

```
edpearOS/
├── .github/workflows/          # GitHub Actions CI (auto-builds ISO)
│   └── build-iso.yml
├── archiso-profile/            # The archiso profile (heart of the distro)
│   ├── profiledef.sh           # Archiso profile definition
│   ├── packages.x86_64         # All packages to include
│   ├── pacman.conf             # Pacman config (with Chaotic-AUR)
│   ├── airootfs/               # Root filesystem overlay
│   │   ├── etc/
│   │   │   ├── skel/           # User template (themes, configs, shortcuts)
│   │   │   ├── calamares/      # Calamares installer configuration
│   │   │   ├── edpearos/       # Focus mode blocklist, config
│   │   │   └── sddm.conf.d/   # Display manager config
│   │   └── usr/
│   │       ├── local/bin/      # edpear-focus, edpear-welcome, edpear-setup
│   │       └── share/          # Desktop entries, wallpapers, sessions
│   ├── grub/                   # GRUB bootloader config
│   ├── syslinux/               # Syslinux bootloader config (BIOS)
│   └── efiboot/                # EFI boot config
├── scripts/
│   └── build-iso.sh            # Main build script
├── build_and_flash.ps1         # Windows build + Rufus flash
├── LICENSE                     # MIT License
└── README.md
```

## Customization

### Adding/Removing Packages

Edit `archiso-profile/packages.x86_64`. One package per line. Use `pacman -Ss <name>` to search for packages.

### Changing the Desktop Theme

KDE Plasma config lives in `archiso-profile/airootfs/etc/skel/.config/`. Modify `kdeglobals`, `kwinrc`, `plasma-org.kde.plasma.desktop-appletsrc`, etc.

Hyprland config: `archiso-profile/airootfs/etc/skel/.config/hypr/hyprland.conf`

### Customizing the Focus Mode Blocklist

Edit `archiso-profile/airootfs/etc/edpearos/focus-blocklist.txt`. One domain per line.

### Changing the Wallpaper

Replace `archiso-profile/airootfs/usr/share/edpearos/wallpapers/default.png` with your image (1920x1080 recommended).

### Branding the Installer

Edit `archiso-profile/airootfs/etc/calamares/branding/edpearos/branding.desc` for names, colors, and URLs. Replace `logo.png` and `welcome.png`.

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super + N` | Open Obsidian (Notes) |
| `Super + C` | Open Calculator |
| `Super + T` | Open Terminal |
| `Super + E` | Open File Manager |
| `Super + F` | Toggle Focus Mode |
| `Super + B` | Open Firefox (Browser) |
| `Super + W` | Study Workspace Launcher |
| `Super + Space` | App Launcher |
| `Super + Q` | Close Window (Hyprland) |
| `Super + 1-5` | Switch Workspace |

## How It Works

1. **archiso** ([official Arch tool](https://wiki.archlinux.org/title/Archiso)) builds a bootable live ISO from the profile
2. The `airootfs/` directory is overlaid onto the root filesystem — everything in there becomes part of the live system
3. `/etc/skel/` is the template for every new user's home directory — this is where the "rice" lives
4. **Calamares** provides a graphical installer that copies the live system to disk
5. On first boot, the **Welcome App** runs and asks what you're studying, launching the right tools
6. **Focus Mode** uses `/etc/hosts` blocking + KDE/Hyprland DND to eliminate distractions

## CI/CD

Every push to `main` triggers a GitHub Actions build that:
1. Spins up an Arch Linux container
2. Installs archiso and dependencies
3. Runs `mkarchiso` to build the ISO
4. Uploads the ISO as a build artifact

Tagging a release (`git tag v2026.1 && git push --tags`) creates a GitHub Release with the ISO attached.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Test: `sudo ./scripts/build-iso.sh --clean`
5. Push and open a Pull Request

## License

MIT License — see [LICENSE](LICENSE) for details.

## Credits

Built with:
- [Arch Linux](https://archlinux.org)
- [archiso](https://wiki.archlinux.org/title/Archiso)
- [Calamares](https://calamares.io)
- [KDE Plasma](https://kde.org/plasma-desktop/)
- [Hyprland](https://hyprland.org)
- [Chaotic-AUR](https://aur.chaotic.cx)
