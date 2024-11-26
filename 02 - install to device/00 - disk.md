# SETUP DISK
#
#
### CREATE RAID 0
- **ENV**
    ```bash
    X_DEV_DISK=/dev/mdX
    DEVICES=(/dev/sdxX /dev/sdxX)
    NUMBER_OF_DEVICES=${#DEVICES[@]}
    ```
- **Stop**
    ```bash
    sudo mdadm --verbose --stop $X_DEV_DISK
    ```
- **Create raid 0**
    ```bash
    sudo mdadm --verbose --create $X_DEV_DISK --homehost=raid --name=0 --level=0 --chunk=64 --raid-devices=$NUMBER_OF_DEVICES "${DEVICES[@]}"
    ```
- **Detail raid**
    ```bash
    sudo mdadm --detail $X_DEV_DISK
    ```
- **Update UUID**
    ```bash
    sudo mdadm --verbose --stop $X_DEV_DISK
    sudo mdadm -A $X_DEV_DISK --update=uuid --uuid=0123456789abcdef:fedcba9876543210 "${DEVICES[@]}"
    ```
### FORMAT EXT4
- **ENV**
    ```bash
    X_DEV_DISK=/dev/sdx
    ```
- **Format**
    ```bash
    sudo mkfs.ext4 $X_DEV_DISK -v -U 00000000-0000-0000-0000-000000000001 -L raid-0 -m 0 -O ^has_journal -F
    ```
- **Default Mount Options**
    ```bash
    sudo tune2fs $X_DEV_DISK -o discard,journal_data_writeback,nobarrier
    ```
- **Run fsck**
    ```bash
    sudo e2fsck $X_DEV_DISK && sudo e2fsck $X_DEV_DISK -f && sudo e2fsck $X_DEV_DISK -F
    ```
- **Check**
    ```bash
    sudo tune2fs -l $X_DEV_DISK
    ```