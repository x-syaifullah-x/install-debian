# INSTALL DEBIAN MINIMAL
#
#
### [Download BaseSystem](https://github.com/x-syaifullah-x/install-debian/releases)

### SETUP ENV
```sh
ROOTFS_DIR=rootfs
```

### EXTRACT BASE SYSTEM
```sh
tar xvf rootfs_amd64.tar.xz -C $ROOTFS_DIR
```

### MOUNT
```sh
mount -v udev     -t devtmpfs          $ROOTFS_DIR/dev             -o defaults,size=0
mount -v devpts   -t devpts            $ROOTFS_DIR/dev/pts         -o defaults
mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/media           -o defaults,size=100%,nr_inodes=0,mode=0775
mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/mnt             -o defaults,size=100%,nr_inodes=0,mode=0775
mount -v proc     -t proc              $ROOTFS_DIR/proc            -o defaults
mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/root            -o defaults,size=100%,nr_inodes=0,mode=0700
mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/run             -o defaults,size=100%,nr_inodes=0,mode=0775
mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/run/lock        -o defaults,size=100%,nr_inodes=0,nosuid,nodev,noexec --mkdir
mount -v sysfs    -t sysfs             $ROOTFS_DIR/sys             -o defaults
mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/tmp             -o defaults,size=100%,nr_inodes=0,mode=1777,nosuid,nodev
mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/var/cache       -o defaults,size=100%,nr_inodes=0,mode=0755
mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/var/lib/apt     -o defaults,size=100%,nr_inodes=0,mode=0755
mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/var/log         -o defaults,size=100%,nr_inodes=0,mode=0755
mount -v          -B /etc/resolv.conf  $ROOTFS_DIR/etc/resolv.conf
```

### RUNNING CHROOT
```sh
chroot $ROOTFS_DIR
```
- **ENV**
    ```sh
    export DEBIAN_FRONTEND=teletype
    ```

- **SETUP DPKG CONF**
    ```sh
    X_DPKG_1=/etc/dpkg/dpkg.cfg.d/x-dpkg_1
    tee $X_DPKG_1 << EOF
    force-unsafe-io
    path-exclude=/usr/share/doc/*
    path-exclude=/usr/share/doc-base/*
    path-exclude=/usr/share/man/*
    path-exclude=/usr/share/info/*
    path-exclude=/usr/share/lintian/*
    path-exclude=/usr/share/locale/*
    path-include=/usr/share/locale/en*
    EOF
    for _paths in $(sed -n 's|path-[a-z]*=\(/[^/]*\(/[^/]*\)*\)/.*|\1|p' $X_DPKG_1 | uniq); do
        for _path in $(ls -A "$_paths"); do
            rm -rfv "$_paths/$_path"
        done
    done

    X_DPKG_2=/etc/dpkg/dpkg.cfg.d/x-dpkg_2
    tee $X_DPKG_2 << EOF
    path-exclude=/sbin/*.bfs
    path-exclude=/sbin/*.cramfs
    path-exclude=/sbin/*.minix
    EOF
    sed 's/path-exclude=//g' $X_DPKG_2 | while read path; do
        for expanded_path in $path; do
            if [ -e "$expanded_path" ]; then
                rm -rfv "$expanded_path"
            fi
        done
    done
    cat "$X_DPKG_1" "$X_DPKG_2" | tee /etc/dpkg/dpkg.cfg.d/x-dpkg
    rm -rfv "$X_DPKG_1" "$X_DPKG_2"
    ```

- **REINSTALL PACAKAGES**
    ```sh
    apt update
    packages=$(dpkg --get-selections | grep -v deinstall | awk '{print $1}')
    # 84 Package
    apt-get install --no-install-recommends --no-install-suggests --reinstall $packages
    ```
- **INSTALL SYSTEMD**
    ```sh
    apt install --no-install-recommends --no-install-suggests systemd
    ```
    - **Default Systemd Active**
        1. apt-daily-upgrade.timer
        1. apt-daily.timer
        1. dpkg-db-backup.timer
        1. fstrim.timer
        1. getty@.service
        1. remote-fs.target
        1. systemd-pstore.service
    - **Disable Systemd Active**
        ```sh
        systemctl disable apt-daily-upgrade.timer apt-daily.timer dpkg-db-backup.timer fstrim.timer remote-fs.target systemd-pstore.service
        ```
    - **Mask Systemd Service**
        ```bash
        services=(
            cryptsetup.target
            first-boot-complete.target
            getty-static.service
            integritysetup.target
            kmod-static-nodes.service
            modprobe@dm_mod.service
            modprobe@drm.service
            modprobe@fuse.service
            modprobe@loop.service
            proc-sys-fs-binfmt_misc.automount
            proc-sys-fs-binfmt_misc.mount
            swap.target
            sys-fs-fuse-connections.mount
            sys-kernel-config.mount
            sys-kernel-debug.mount
            sys-kernel-tracing.mount
            systemd-ask-password-console.path
            systemd-ask-password-wall.path
            systemd-binfmt.service
            systemd-firstboot.service
            systemd-machine-id-commit.service
            systemd-modules-load.service
            systemd-random-seed.service
            systemd-remount-fs.service
            systemd-repart.service
            systemd-rfkill.service
            systemd-rfkill.socket
            systemd-sysusers.service
            systemd-tmpfiles-clean.service
            systemd-tmpfiles-clean.timer
            systemd-tmpfiles-setup-dev.service
            veritysetup.target
        )
        for service in ${services[@]}; do
            systemctl mask $service
        done
        ```
    - **Systemd Logind**
        - **Disable TTY[2-6]**
            - **Set**
                ```sh
                sed -i 's/^#\?NAutoVTs=.*/NAutoVTs=0/' /etc/systemd/logind.conf
                sed -i 's/^#\?ReserveVT=.*/ReserveVT=0/' /etc/systemd/logind.conf
                ```
            - **Restore**
                ```sh
                sed -i 's/^#\?NAutoVTs=.*/#NAutoVTs=6/' /etc/systemd/logind.conf
                sed -i 's/^#\?ReserveVT=.*/#ReserveVT=6/' /etc/systemd/logind.conf
                ```
        - **RuntimeDirectorySize**
            - **Set**
                ```sh
                sed -i 's/^#\?RuntimeDirectorySize=.*/RuntimeDirectorySize=100%/' /etc/systemd/logind.conf
                ```
            - **Restore**
                ```sh
                sed -i 's/^#\?RuntimeDirectorySize=.*/#RuntimeDirectorySize=10%/' /etc/systemd/logind.conf
                ```
    - **Disable Journald**
        - **Set**
            ```sh
            sed -i 's/^#\?Storage=.*/Storage=none/' /etc/systemd/journald.conf
            ```
        - **Restore**
            ```sh
            sed -i 's/^#\?Storage=.*/#Storage=auto/' /etc/systemd/journald.conf
            ```
    - **Systemd Network**
        ```sh
        tee /etc/systemd/network/20-en.network << EOF
        [Match]
        Name=*en*
        [Network]
        DHCP=yes
        EOF
        tee /etc/systemd/network/20-wl.network << EOF
        [Match]
        Name=*wl*
        [Network]
        DHCP=yes
        EOF
        ```
- **INSTALL KMOD(modprobe), UDEV(udevadm)**
    ```sh
    apt install --no-install-recommends --no-install-suggests kmod udev
    ```
- **INSTALL LINUX IMAGE**
    ```sh
    apt install --no-install-recommends --no-install-suggests linux-image-6.12.12+bpo-amd64
    ```
    - **INIRAMFS CONF**
        ```sh
        sed -i 's/^#\?BUSYBOX=.*/BUSYBOX=n/' /etc/initramfs-tools/initramfs.conf
        sed -i 's/^#\?COMPRESS=.*/COMPRESS=gzip/' /etc/initramfs-tools/initramfs.conf
        sed -i 's/^#\?COMPRESSLEVEL=.*/COMPRESSLEVEL=1/' /etc/initramfs-tools/initramfs.conf
        ```
    - **UPDATE_INITRAMFS CONF**
        ```sh 
        sed -i 's/update_initramfs=yes/update_initramfs=no/' /etc/initramfs-tools/update-initramfs.conf
        ```
    - **REMOVE OLD KERNERL**
        ```sh 
        rm -rfv /initrd.img.old /vmlinuz.old
        ```
- **SYSCTL CONF**
    ```sh
    mkdir -pv /etc/sysctl.d
    tee /etc/sysctl.d/proc.sys.conf << EOF
    kernel.printk               = 0 4 1 7
    #vm.dirty_ratio             = 1
    #vm.dirty_background_ratio  = 1
    vm.page-cluster             = 0
    vm.swappiness               = 1
    #vm.vfs_cache_pressure      = 500
    vm.watermark_boost_factor   = 0
    vm.watermark_scale_factor   = 50
    EOF
    ```
- **BANNER**
    - **Default**
        ```sh
        Debian GNU/Linux 12 \n \l

        ```
    - **Local**
        ```sh
        tee /etc/issue << EOF
        \d \t on \l

        Name    : \n
        Os      : \s \m
        Kernel  : \r
        Version : \v
        EOF
        ```
    - **Remote**
        ```sh
        tee /etc/issue.net << EOF
        \d \t on \l

        Name    : \n
        Os      : \s \m
        Kernel  : \r
        Version : \v
        EOF
        ```
- **CREATE USER**
    - **ENV**
    ```sh
    _USER_NAME=xxx
    ```
    - ****
        ```sh
        useradd $_USER_NAME --shell /bin/bash --home-dir /home/${_USER_NAME} --create-home
        ```
        - **Clean User Directory**
            ```sh
            for i in $(ls -A /home/$_USER_NAME); do
                rm -rfv /home/$_USER_NAME/$i
            done
            ```
    - **Auto Create With systemd-sysusers.services**
        ```sh
        sysusers_d=/etc/sysusers.d
        home_dir=/home/${_USER_NAME}
        id=1000
        mkdir -pv $sysusers_d $home_dir
        chown -vR $id:$id $home_dir
        tee $sysusers_d/${_USER_NAME}.conf << EOF
        g ${_USER_NAME} $id - -
        u ${_USER_NAME} $id:$id - $home_dir /bin/bash
        EOF
        rm -rfv /etc/systemd/system/systemd-sysusers.service
        ```
- **SETUP PASSWORD**
    - **Login With Password**
        ```sh
        passwd $_USER_NAME
        ```
    - **Login Without Password**
        ```sh
        passwd -d $_USER_NAME
        ```
    - **Remove Password**
        ```sh
        passwd -dl $_USER_NAME
        ```
- **MAKE USER AUTO LOGIN**
    ```sh
    mkdir -pv /etc/systemd/system/getty@tty1.service.d
    tee /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
    [Service]
    ExecStart=
    ExecStart=-/sbin/agetty --autologin $_USER_NAME --skip-login --noclear - \$TERM
    Type=idle
    EOF
    ```
- **SETUP TIME**
    - **SETUP TIME ZONE**
        ```sh
        ln -fsv /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
        ```
    - **USE BIOS TIME**
        ```sh
        cat << EOF > /etc/adjtime 
        0.0 0 0
        0
        LOCAL
        EOF
        ```
- **INSTALL DBUS**
    ```sh
    apt install --no-install-recommends --no-install-suggests libpam-systemd
    ```
    - **MAKE LINK MACHINE ID**
        ```sh
        ln -sfv /etc/machine-id /var/lib/dbus/machine-id
        ```
- **SETUP HOSTNAME**
    ```sh
    cat << EOF > /etc/hostname
    x-host
    EOF
    ```
- **SETUP HOSTS**
    ```sh
    cat << EOF > /etc/hosts
    127.0.0.1   localhost $(cat /etc/hostname)
    ::1         ip6-localhost ip6-loopback
    fe00::0     ip6-localnet
    ff00::0     ip6-mcastprefix
    ff02::1     ip6-allnodes
    ff02::2     ip6-allrouters
    EOF
    ```
- **EXIT CHROOT**
    ```sh
    dpkg --clear-avail && exit
    ```
### UMOUNT
```sh
for dir in $(mount | grep "$ROOTFS_DIR/" | awk '{print $3}'); do
    mount | grep -q "on $dir type" && umount -v --recursive $dir
done
```
### CLEAN FILE NOT USE
```sh
[ -f $ROOTFS_DIR/etc/.pwd.lock ]                && rm -rfv $ROOTFS_DIR/etc/.pwd.lock
[ -f $ROOTFS_DIR/etc/group- ]                   && rm -rfv $ROOTFS_DIR/etc/group-
[ -f $ROOTFS_DIR/etc/gshadow- ]                 && rm -rfv $ROOTFS_DIR/etc/gshadow-
[ -f $ROOTFS_DIR/etc/hostname ]                 && rm -rfv $ROOTFS_DIR/etc/hostname
[ -f $ROOTFS_DIR/etc/passwd- ]                  && rm -rfv $ROOTFS_DIR/etc/passwd-
[ -f $ROOTFS_DIR/etc/resolv.conf ]              && tee $ROOTFS_DIR/etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
[ -f $ROOTFS_DIR/etc/shadow- ]                  && rm -rfv $ROOTFS_DIR/etc/shadow-
[ -f $ROOTFS_DIR/var/lib/dpkg/diversions-old ]  && rm -rfv $ROOTFS_DIR/var/lib/dpkg/diversions-old
[ -f $ROOTFS_DIR/var/lib/dpkg/status-old ]      && rm -rfv $ROOTFS_DIR/var/lib/dpkg/status-old
```