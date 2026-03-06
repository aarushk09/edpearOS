#!/usr/bin/env bash
# edpearOS archiso profile definition
# shellcheck disable=SC2034

iso_name="edpearOS"
iso_label="EDPEAROS_$(date +%Y%m)"
iso_publisher="edpearOS <https://github.com/aarushk09/edpearOS>"
iso_application="edpearOS — The Modern Student Desktop"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=(
  'bios.syslinux.mbr'
  'bios.syslinux.eltorito'
  'uefi-ia32.grub.esp'
  'uefi-x64.grub.esp'
  'uefi-ia32.grub.eltorito'
  'uefi-x64.grub.eltorito'
)
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/sudoers.d/10-liveuser"]="0:0:440"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/usr/local/bin/edpear-welcome"]="0:0:755"
  ["/usr/local/bin/edpear-focus"]="0:0:755"
  ["/usr/local/bin/edpear-setup"]="0:0:755"
  ["/usr/share/edpearos/apply-theme.sh"]="0:0:755"
  ["/etc/xdg/plasma-workspace/env/edpearos.sh"]="0:0:755"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/home/liveuser"]="1000:1000:750"
)
