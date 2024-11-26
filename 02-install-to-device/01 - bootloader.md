# SETUP BOOTLOADER
#
#
### SETUP RAID
- **Setup configuration**
    ```bash
    cat << EOF > /etc/mdadm/mdadm.conf
    HOMEHOST <system>
    MAILADDR root
    $(mdadm --detail --scan /dev/md0)
    EOF
    ```

### SETUP INITRAMFS CONF
- **Update Config**
    ```bash
    cat << EOF > /etc/initramfs-tools/initramfs.conf
    MODULES=most
    BUSYBOX=n
    KEYMAP=n
    COMPRESS=lz4
    COMPRESSLEVEL=0
    DEVICE=
    NFSROOT=auto
    RUNSIZE=100%
    FSTYPE=auto
    EOF
    ```

#### SET SIZE DIRECTORY DEV
- **Default**
    ```bash
    mount -t devtmpfs -o nosuid,mode=0755 udev /dev
    ```
- **Replace**
    ```bash
    sed -i -e 's/mount -t devtmpfs -o nosuid,mode=0755/mount -t devtmpfs -o nosuid,mode=0755,size=0/' /usr/share/initramfs-tools/init
    ```

### ADDED IO-SCHEDULER.RULES
- **Create Rules**
    ```bash
    cat << EOF > /etc/udev/rules.d/io-scheduler.rules
    ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*|nvme[0-9]n[0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
    EOF
    ```
- **Check**
    ```bash
    # Check :
    #   cat /sys/block/sdX/queue/scheduler
    #   cat /sys/block/nvme*/queue/scheduler
    #
    # (/sys/block/sdX/queue/rotationall == 0) is SSD
    ```

### SETUP GRUB
- **Mount EFI Partitions**
    ```bash
    mount -v --label EFI /boot/efi --mkdir
    ```
- **ENV Bootloader ID**
```bash
BOOTLOADER_ID=Debian
```

- **Remove Directory EFI**
    ```bash
    rm -rfv "/boot/efi/EFI/$BOOTLOADER_ID"
    ```

- **Remove Directory GRUB**
    ```bash
    rm -rfv /boot/grub/*
    ```

- **Install GRUB-EFI-AMD64**
    ```bash
    apt install grub-efi-amd64
    ```

- **Setup File /etc/default/grub**
    ```bash
    cat << EOF > /etc/default/grub
    GRUB_DEFAULT=0
    GRUB_TIMEOUT=5
    GRUB_DISTRIBUTOR="Debian Boot Manager"
    GRUB_CMDLINE_LINUX_DEFAULT="quiet modprobe.blacklist=dm_mod,uas,usb_storage,at24,b43,bcma,brcmsmac,efi_pstore,iTCO_wdt,r8169,uvcvideo mitigations=off acpi_enforce_resources=no reboot=pci acpi_osi=Linux nmi_watchdog=0 systemd.gpt_auto=0 lsm= fsck.mode=skip"
    GRUB_CMDLINE_LINUX=""
    GRUB_DISABLE_OS_PROBER=false
    GRUB_GFXMODE=$(cat /sys/class/drm/*/modes | head -1)
    GRUB_DISABLE_LINUX_UUID=true
    GRUB_DISABLE_RECOVERY="true"
    GRUB_DISABLE_SUBMENU=y
    GRUB_BACKGROUND=/boot/theme/background.png
    GRUB_THEME=/boot/theme/theme.txt
    EOF
    ```

    - **Setup Grub Theme**

        - **[Download Theme](https://github.com/x-syaifullah-x/install-linux/blob/master/Others/z-Files/boot/theme.tar.gz)**

        - **COPY DIRECTORY THEME TO BOOT**
            ```bash
            cp -rfv theme /boot
            ```

        - **Config Theme**
            ```bash
            cat << EOF >> /etc/default/grub
            GRUB_BACKGROUND=/boot/theme/background.png
            GRUB_THEME=/boot/theme/theme.txt
            EOF
            ```

- **Fix MDADM Rm Not Found On Booting**
    ```bash
    cat << EOF > /usr/share/initramfs-tools/scripts/local-bottom/mdadm
    #! /bin/sh
    [ -f /run/count.mdadm.initrd ] && rm -f /run/count.mdadm.initrd
    exit 0
    EOF
    ```

- **Install Needed For Iinitrd**
    ```bash
    apt install amd64-microcode firmware-realtek intel-microcode lz4 f2fs-tools
    ```

- **Update grub.cfg**
    ```bash
    update-grub
    ```
    - **Without Grub Menu**
        ```bash
        cat << EOF > /boot/grub/grub.cfg
        terminal_output gfxterm
        background_image -m normal $prefix/bg.png
        set default=0
        set gfxpayload=keep
        set pager=1
        set timeout=0
        menuentry '' {
            linux /boot/vmlinuz-6.13-amd64 quiet modprobe.blacklist=dm_mod,uas,usb_storage,at24,b43,bcma,brcmsmac,efi_pstore,iTCO_wdt,r8169,uvcvideo mitigations=off acpi_enforce_resources=no reboot=pci acpi_osi=Linux nmi_watchdog=0 systemd.gpt_auto=0 lsm= fsck.mode=skip
            initrd /boot/initrd.img-6.13-amd64
        }
        EOF
        ```
### GRUB INSTALL
- **Create EFI**
    ```bash
    grub-install --verbose --no-nvram --recheck --compress=no --bootloader-id "$BOOTLOADER_ID"
    ```

- **Change Config Grub EFI**
    ```bash
    cat << "EOF" > /boot/efi/EFI/$BOOTLOADER_ID/grub.cfg
    set root=(md/0)
    set prefix=($root)'/boot/grub'
    configfile $prefix/grub.cfg
    EOF
    ```

- **Exit Chroot**
```bash
exit
```
### CREATE BOOTLOADER
```sh
modprobe --verbose efivarfs
mount --verbose -t efivarfs efivarfs /sys/firmware/efi/efivars
efibootmgr --verbose --create --disk /dev/sda --part 4 --label "Debian Boot Manager" --loader "/EFI/$BOOTLOADER_ID/shimx64.efi"
```
### UMOUNT OVERLAY SYSTEM
```sh
for dir in $(mount | grep "$ROOTFS_DIR/" | awk '{print $3}'); do
    mount | grep -q "on $dir type" && sudo umount -v --recursive $dir
done
```
