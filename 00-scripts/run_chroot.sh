#!/bin/bash

export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export DEBIAN_FRONTEND="teletype"

ROOTFS_DIR="${1:-rootfs}"

__clean_up() {
    for dir in $(mount | grep "$ROOTFS_DIR/" | awk '{print $3}'); do
        mount | grep -q "on $dir type" && umount -v --lazy --recursive $dir
    done

    dpkg --admindir=$ROOTFS_DIR/var/lib/dpkg --root=$ROOTFS_DIR --instdir=$ROOTFS_DIR --clear-avail
    
    [ -f $ROOTFS_DIR/etc/.pwd.lock ]                && rm -rfv $ROOTFS_DIR/etc/.pwd.lock
    [ -f $ROOTFS_DIR/etc/passwd- ]                  && rm -rfv $ROOTFS_DIR/etc/passwd-
    [ -f $ROOTFS_DIR/etc/group- ]                   && rm -rfv $ROOTFS_DIR/etc/group-
    [ -f $ROOTFS_DIR/etc/shadow- ]                  && rm -rfv $ROOTFS_DIR/etc/shadow-
    [ -f $ROOTFS_DIR/etc/gshadow- ]                 && rm -rfv $ROOTFS_DIR/etc/gshadow-
    [ -f $ROOTFS_DIR/var/lib/dpkg/diversions-old ]  && rm -rfv $ROOTFS_DIR/var/lib/dpkg/diversions-old
    [ -f $ROOTFS_DIR/var/lib/dpkg/status-old ]      && rm -rfv $ROOTFS_DIR/var/lib/dpkg/status-old
    [ -f $ROOTFS_DIR/etc/resolv.conf ]              && rm -rfv $ROOTFS_DIR/etc/resolv.conf
}

trap __clean_up SIGINT

mount -v udev   -t devtmpfs  $ROOTFS_DIR/dev             -o defaults,size=0                                             || exit $?
mount -v devpts -t devpts    $ROOTFS_DIR/dev/pts         -o defaults                                                    || exit $?
mount -v tmpfs  -t tmpfs     $ROOTFS_DIR/media           -o defaults,size=100%,nr_inodes=0,mode=0775                    || exit $?
mount -v tmpfs  -t tmpfs     $ROOTFS_DIR/mnt             -o defaults,size=100%,nr_inodes=0,mode=0775                    || exit $?
mount -v proc   -t proc      $ROOTFS_DIR/proc            -o defaults                                                    || exit $?
mount -v tmpfs  -t tmpfs     $ROOTFS_DIR/root            -o defaults,size=100%,nr_inodes=0,mode=0700                    || exit $?
mount -v tmpfs  -t tmpfs     $ROOTFS_DIR/run             -o defaults,size=100%,nr_inodes=0,mode=0775                    || exit $?
mount -v tmpfs  -t tmpfs     $ROOTFS_DIR/run/lock        -o defaults,size=100%,nr_inodes=0,nosuid,nodev,noexec --mkdir  || exit $?
mount -v sysfs  -t sysfs     $ROOTFS_DIR/sys             -o defaults || exit $?
mount -v tmpfs  -t tmpfs     $ROOTFS_DIR/tmp             -o defaults,size=100%,nr_inodes=0,mode=1777,nosuid,nodev       || exit $?
mount -v tmpfs  -t tmpfs     $ROOTFS_DIR/var/cache       -o defaults,size=100%,nr_inodes=0,mode=0755 || exit $?
mkdir -pv $ROOTFS_DIR/var/lib/apt
mount -v tmpfs  -t tmpfs     $ROOTFS_DIR/var/lib/apt     -o defaults,size=100%,nr_inodes=0,mode=0755 || exit $?
mount -v tmpfs  -t tmpfs     $ROOTFS_DIR/var/log         -o defaults,size=100%,nr_inodes=0,mode=0755 || exit $?
touch $ROOTFS_DIR/etc/resolv.conf
mount -v -B /etc/resolv.conf $ROOTFS_DIR/etc/resolv.conf || exit $?

chroot $ROOTFS_DIR /bin/bash

__clean_up