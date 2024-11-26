# SETUP BOOTLOADER
#
#
### MOUNT, OVERLAY SYSTEM AND RUNNING AS CHROOT
```bash
IS_ERROR=0
ROOTFS_DIR=/mnt/zram-0 && [ ! -d $ROOTFS_DIR ] && echo "No rootfs" && IS_ERROR=1

BIND_DIRS="dev dev/pts proc sys"
for BIND_DIR in $BIND_DIRS; do
  SOURCE_DIR="/$BIND_DIR"
  TARGET_DIR="$ROOTFS_DIR/$BIND_DIR"
  [ ! -d "$TARGET_DIR" ] && echo "Not exists $TARGET_DIR"
  sudo umount -v $TARGET_DIR
  sudo mount -v --bind $SOURCE_DIR $TARGET_DIR || exit $?
done
OVERLAY_DIRS="etc opt srv usr var"
OVERLAY_STORAGE="/run/rootfs_overlay" && [ -d "$OVERLAY_STORAGE" ] && sudo rm -rfv $OVERLAY_STORAGE
for OVERLAY_DIR in $OVERLAY_DIRS; do
  if [ -d "$ROOTFS_DIR/$OVERLAY_DIR" ]; then
    lower_dir=$ROOTFS_DIR/$OVERLAY_DIR
    upper_dir=$OVERLAY_STORAGE/upperdir/$OVERLAY_DIR
    work_dir=$OVERLAY_STORAGE/workdir/$OVERLAY_DIR
    sudo mkdir -pv $upper_dir $work_dir
    target_dir=$ROOTFS_DIR/$OVERLAY_DIR
    sudo umount $target_dir
    sudo mount -v -t overlay overlay -o lowerdir=$lower_dir,upperdir=$upper_dir,workdir=$work_dir $target_dir
  else
    echo "Not exists $ROOTFS_DIR/$OVERLAY_DIR"
    IS_ERROR=1
  fi
done
for i in $OVERLAY_DIRS; do
 mount | grep "overlay on $ROOTFS_DIR/$i"
done
[ ! $IS_ERROR -eq 0 ] && exit $?

TMPFS_DIRS="home media mnt root run tmp"
for TMPFS_DIR in $TMPFS_DIRS; do
  TARGET_DIR="$ROOTFS_DIR/$TMPFS_DIR"
  if [ -d "$TARGET_DIR" ]; then
    sudo umount $TARGET_DIR
    sudo mount -v -t tmpfs tmpfs $TARGET_DIR
  else
    echo "Not exists $TARGET_DIR"
    IS_ERROR=1
  fi
done
[ ! $IS_ERROR -eq 0 ] && exit $?

sudo chroot $ROOTFS_DIR
```
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
- **Update initrd**
    ```bash
    update-initramfs -v -d -c -k all
    ```
- **Exit Chroot**
    ```bash
    exit
    ```