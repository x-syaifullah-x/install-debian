# SETUP ROOTFS

### [Download BaseSystem](https://github.com/x-syaifullah-x/install-debian/releases)

### EXTRACT ROOTFS
```sh
ROOTFS_DIR=rootfs
tar xvf rootfs_amd64.tar.xz -C $ROOTFS_DIR
```

### RUNNING AS CHROOT
```sh
sudo 00-scripts/run_chroot.sh $ROOTFS_DIR
```
- **INSTALL SYSTEMD**
    ```sh
    apt install --no-install-recommends --no-install-suggests systemd util-linux
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
            dev-hugepages.mount
            dev-mqueue.mount
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
            remote-fs-pre.target
            remote-fs.target
            swap.target
            sys-fs-fuse-connections.mount
            sys-kernel-config.mount
            sys-kernel-debug.mount
            sys-kernel-tracing.mount
            systemd-ask-password-console.path
            systemd-ask-password-wall.path
            systemd-binfmt.service
            systemd-firstboot.service
            systemd-journald-audit.socket
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
- **INSTALL LOGIN**
    ```sh
    apt install --no-install-suggests --no-install-recommends login
    ```
- **INSTALL DBUS**
    ```sh
    apt install --no-install-recommends --no-install-suggests libpam-systemd
    ```
    - **MAKE LINK MACHINE ID**
        ```sh
        ln -sfv ../../../etc/machine-id /var/lib/dbus/machine-id
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
        useradd $_USER_NAME --shell /usr/bin/bash --home-dir /home/${_USER_NAME} --create-home
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
        u ${_USER_NAME} $id:$id - $home_dir /usr/bin/bash
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
        ln -fsv ../usr/share/zoneinfo/Asia/Jakarta /etc/localtime
        ```
    - **USE BIOS TIME**
        ```sh
        tee /etc/adjtime << EOF
        0.0 0 0
        0
        LOCAL
        EOF
        ```
- **SETUP HOSTNAME**
    ```sh
    tee /etc/hostname << EOF
    x-host
    EOF
    ```
- **SETUP HOSTS**
    ```sh
    tee /etc/hosts << EOF
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