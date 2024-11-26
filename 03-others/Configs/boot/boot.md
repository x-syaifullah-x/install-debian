# BOOT
#
#
### GRUB
```sh
cat << EOF > /boot/grub/grub.cfg
terminal_output gfxterm
background_image -m normal $prefix/bg.png
set default=0
set gfxpayload=keep
set pager=1
set timeout=0
menuentry '' {
        linux /boot/vmlinuz-6.13-amd64 quiet modprobe.blacklist=snd_hda_intel,xhci_pci,ehci_pci,kvm_intel,ipv6,uas,bcma,r8169,uvcvideo,dm_mod,uas,usb_storage,at24,b43,brcmsmac,efi_pstore,iTCO_wdt, pcie_aspm=force intel_iommu=igfx_off mitigations=off acpi_enforce_resources=no reboot=pci acpi_osi=Linux nmi_watchdog=0 systemd.gpt_auto=0 lsm= fsck.mode=skip
        initrd /boot/initrd.img-6.13-amd64
}
EOF
```