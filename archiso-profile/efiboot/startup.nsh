# edpearOS EFI shell startup script
@echo -off
echo "edpearOS Live ISO"
echo "Booting via EFI shell..."

# Try to find and boot the GRUB EFI binary
fs0:
\EFI\BOOT\BOOTX64.EFI
