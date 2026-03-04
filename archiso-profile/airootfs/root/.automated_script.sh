#!/usr/bin/env bash
# edpearOS archiso customize_airootfs script
# This runs inside the chroot during ISO build
scriptdir="$(dirname "$(readlink -f "$0")")"

# Run the main setup
/usr/local/bin/edpear-setup
