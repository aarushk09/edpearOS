#!/bin/bash
# edpearOS — auto-start Plasma Wayland on tty1 (live ISO autologin)
# Sourced by bash on interactive login shells (getty autologin lands here)

[[ -f ~/.bashrc ]] && source ~/.bashrc

if [[ -z "$WAYLAND_DISPLAY" && -z "$DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
    export XDG_SESSION_TYPE=wayland
    export XDG_RUNTIME_DIR=/run/user/1000
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM=wayland
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 700 "$XDG_RUNTIME_DIR"
    # plasma-dbus-run-session-if-needed starts dbus when not run under a DM
    exec /usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland
fi
