<#
.SYNOPSIS
    edpearOS — Windows Build and Flash Script

.DESCRIPTION
    Builds the edpearOS ISO using WSL2 (Arch Linux) and optionally flashes
    it to a USB drive using Rufus.

.NOTES
    Run as Administrator.
    Prerequisites:
      - WSL2 installed (wsl --install)
      - An Arch Linux WSL distro (see README for setup)
      - Internet connection

.EXAMPLE
    .\build_and_flash.ps1                    # Build + Flash
    .\build_and_flash.ps1 -SkipFlash         # Build only
    .\build_and_flash.ps1 -SkipBuild         # Flash existing ISO
    .\build_and_flash.ps1 -CleanBuild        # Clean rebuild
#>

Param (
    [switch]$SkipBuild,
    [switch]$SkipFlash,
    [switch]$CleanBuild
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ── Administrator check ──
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "This script should be run as Administrator."
    Write-Host "Right-click PowerShell → 'Run as Administrator' and try again."
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  edpearOS Build & Flash (Windows)     " -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan

# ── Check WSL ──
$wslCheck = wsl -l -q 2>$null
if (-not $wslCheck) {
    Write-Error "WSL is not installed. Run: wsl --install"
    exit
}

# Check for Arch WSL specifically
# NOTE: wsl -l outputs UTF-16LE with hidden null bytes — strip them before matching
$wslRaw = (wsl -l -q 2>$null) -join "`n"
$wslClean = $wslRaw -replace '\x00', ''
$distroName = ($wslClean -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "Arch" } | Select-Object -First 1)

if (-not $distroName) {
    Write-Host ""
    Write-Warning "No Arch Linux WSL distribution found!"
    Write-Host ""
    Write-Host "edpearOS requires an Arch Linux WSL instance to build." -ForegroundColor Yellow
    Write-Host "Install one with these steps:" -ForegroundColor Yellow
    Write-Host "  1. Download ArchWSL from: https://github.com/yuk7/ArchWSL/releases"
    Write-Host "  2. Extract and run Arch.exe to install"
    Write-Host "  3. Inside Arch WSL, run: pacman -Syu archiso"
    Write-Host "  4. Re-run this script"
    Write-Host ""
    Write-Host "Alternatively, you can use any WSL distro with archiso installed." -ForegroundColor DarkGray
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host "  Using WSL distro: $distroName" -ForegroundColor Green

# ── Build ISO via WSL ──
if (-not $SkipBuild) {
    Write-Host "`n[1/2] Building edpearOS via WSL..." -ForegroundColor Green

    # Convert Windows path to WSL path
    $Drive = $ScriptDir.Substring(0, 1).ToLower()
    $Path = $ScriptDir.Substring(2).Replace('\', '/')
    $WslPath = "/mnt/$Drive$Path"

    $CleanArg = if ($CleanBuild) { " --clean" } else { "" }
    $wslCmd = "cd '$WslPath' && find . -type f -name '*.sh' -exec dos2unix {} + 2>/dev/null; bash ./scripts/build-iso.sh$CleanArg"

    Write-Host "  Executing in WSL: $wslCmd" -ForegroundColor DarkGray
    
    try {
        wsl -d $distroName --user root -e bash -c "$wslCmd"
    }
    catch {
        Write-Error "WSL build failed. Check the output above for errors."
        exit
    }
}
else {
    Write-Host "`n[1/2] Skipping build (-SkipBuild)." -ForegroundColor DarkGray
}

# ── Find the built ISO ──
$OutDir = Join-Path $ScriptDir "out"
$IsoFile = Get-ChildItem -Path $OutDir -Filter "edpearOS*.iso" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $IsoFile) {
    Write-Error "No edpearOS ISO found in $OutDir. Build may have failed."
    exit
}

$IsoPath = $IsoFile.FullName
Write-Host "`nISO: $IsoPath" -ForegroundColor Green
Write-Host "Size: $([math]::Round($IsoFile.Length / 1GB, 2)) GB"

# ── Flash via Rufus ──
if (-not $SkipFlash) {
    Write-Host "`n[2/2] Preparing Rufus for USB flash..." -ForegroundColor Green
    
    $RufusUrl = "https://github.com/pbatard/rufus/releases/download/v4.6/rufus-4.6p.exe"
    $RufusDir = Join-Path $OutDir "tools"
    $RufusPath = Join-Path $RufusDir "rufus.exe"

    if (-not (Test-Path $RufusPath)) {
        New-Item -ItemType Directory -Force -Path $RufusDir | Out-Null
        Write-Host "  Downloading Rufus..."
        Invoke-WebRequest -Uri $RufusUrl -OutFile $RufusPath
    }

    Write-Host ""
    Write-Host "  Launching Rufus with your ISO..." -ForegroundColor Yellow
    Write-Host "  1. Select your USB drive" -ForegroundColor Yellow
    Write-Host "  2. ISO should be pre-selected" -ForegroundColor Yellow
    Write-Host "  3. Use 'DD Image' mode (not ISO mode) for Arch ISOs" -ForegroundColor Yellow
    Write-Host "  4. Click START" -ForegroundColor Yellow
    Write-Host ""
    
    # Launch Rufus (portable, auto-selects ISO if possible)
    Start-Process -FilePath $RufusPath -ArgumentList "-i `"$IsoPath`""
    
    Write-Host "Rufus launched. Waiting for you to finish flashing..."
}
else {
    Write-Host "`n[2/2] Skipping flash (-SkipFlash)." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Done! Boot from USB to try edpearOS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
