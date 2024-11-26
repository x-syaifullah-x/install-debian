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
- **SETUP KERNEL**
    - **Install Kernel**
        ```sh
        apt install --no-install-recommends --no-install-suggests linux-image-6.12.12+bpo-amd64
        ```

    - **Remove OLD Kernel**
        ```sh 
        rm -rfv /initrd.img.old /vmlinuz.old
        ```

    - **Update Initramfs Config**
        ```sh 
        sed -i 's/update_initramfs=yes/update_initramfs=no/' /etc/initramfs-tools/update-initramfs.conf
        ```

    - **Update Initramfs Config**
        ```sh
        sed -i 's/^#\?BUSYBOX=.*/BUSYBOX=n/' /etc/initramfs-tools/initramfs.conf
        sed -i 's/^#\?COMPRESS=.*/COMPRESS=gzip/' /etc/initramfs-tools/initramfs.conf
        sed -i 's/^#\?COMPRESSLEVEL=.*/COMPRESSLEVEL=1/' /etc/initramfs-tools/initramfs.conf
        ```

    - **Update Initramfs**
        ```sh
        update-initramfs -v -d -c -k all
        ```

- **SETUP SYSTEMD**
    - **Install Systemd**
        ```sh
        apt install --no-install-recommends --no-install-suggests systemd
        ```
    
    - **Disable Systemd Active**
        - **Default Systemd Active**
            1. apt-daily-upgrade.timer
            1. apt-daily.timer
            1. dpkg-db-backup.timer
            1. getty@.service
            1. remote-fs.target
            1. systemd-pstore.service
            ```sh
            systemctl disable apt-daily-upgrade.timer apt-daily.timer dpkg-db-backup.timer remote-fs.target systemd-pstore.service
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
    
    - **Config Logind**
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

        - **Update Runtime Directory Size**
            - **Set**
                ```sh
                sed -i 's/^#\?RuntimeDirectorySize=.*/RuntimeDirectorySize=100%/' /etc/systemd/logind.conf
                ```

            - **Restore**
                ```sh
                sed -i 's/^#\?RuntimeDirectorySize=.*/#RuntimeDirectorySize=10%/' /etc/systemd/logind.conf
                ```
    
    - **Config Journald**
        - **Disable Storage**
            - **Set**
                ```sh
                sed -i 's/^#\?Storage=.*/Storage=none/' /etc/systemd/journald.conf
                ```

            - **Restore**
                ```sh
                sed -i 's/^#\?Storage=.*/#Storage=auto/' /etc/systemd/journald.conf
                ```
    
    - **Config Network**
        - **ETHERNET**
            ```sh
            tee /etc/systemd/network/20-en.network << EOF
            [Match]
            Name=*en*
            [Network]
            DHCP=yes
            EOF
            ```

        - **WLAN**
            ```sh
            tee /etc/systemd/network/20-wl.network << EOF
            [Match]
            Name=*wl*
            [Network]
            DHCP=yes
            EOF
            ```

    - **Install KMOD(modprobe) & UDEV(udevadm) Required For Systemd**
        ```sh
        apt install --no-install-recommends --no-install-suggests kmod udev
        ```

        - **IO Scheduler**
            ```sh
            tee /etc/udev/rules.d/io-scheduler.rules << "EOF"
            ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
            EOF
            ```

        - **MD Level**
            ```sh
            tee /etc/udev/rules.d/md-level.rules << "EOF"
            ACTION=="add|change", KERNEL=="md[0-9]*", PROGRAM="/usr/bin/cat /sys/class/block/%k/md/level", ENV{MD_LEVEL}="$result"
            EOF
            ```

        - **ADB**
            ```sh
            tee /etc/udev/rules.d/adb.rules << "EOF"
            ACTION=="add|change", SUBSYSTEM=="usb", ENV{ID_SERIAL_SHORT}=="dfcb63b5", MODE="0666", GROUP="plugdev"
            EOF
            ```

- **SETUP TTY**
    - **Install Packages Required For TTY**
        ```bash
        packages=(
            login ### LOGIN
            libpam-systemd ### DBUS
            util-linux ### agetty, su, dll
        )
        apt install --no-install-suggests --no-install-recommends "${packages[@]}$"
        ```

    - **Make link Machine ID**
        ```sh
        ln -sfv ../../../etc/machine-id /var/lib/dbus/machine-id
        ```

    - **Update Banner**
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

- **SETUP USER**
    - **ENV**
        ```sh
        _USER_NAME=xxx
        _UID=1000
        _GID=1000
        ```

    - **Create User**
        - **With User Add**
            ```sh
            useradd $_USER_NAME --shell /usr/bin/bash --home-dir /home/${_USER_NAME} --create-home
            ```

            - **Clean User Directory**
                ```sh
                for i in $(ls -A /home/$_USER_NAME); do
                    rm -rfv /home/$_USER_NAME/$i
                done
                ```

        - **With Systemd Sysuses Service**
            ```sh
            sysusers_d=/etc/sysusers.d
            home_dir=/home/${_USER_NAME}
            mkdir -pv $sysusers_d $home_dir
            chown -vR $_UID:$_GID $home_dir
            tee $sysusers_d/${_USER_NAME}.conf << EOF
            g ${_USER_NAME} $_GID - -
            u ${_USER_NAME} $_UID:$_GID - $home_dir /usr/bin/bash
            EOF
            rm -rfv /etc/systemd/system/systemd-sysusers.service
            ```

    - **Create Password**
        - **With passwd**
            - **Install passwd**
                ```sh
                apt install --no-install-recommends --no-install-suggests passwd
                ```
            
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
        
        - **With shadow**
            - **Login With Password**
                ```sh
                editor /etc/shadow
                ```

                - **genreate password**
                    ```sh
                    openssl passwd -6
                    ```
                
                - **value**
                    ```txt
                    root:$y$j9T$gJlwbFLBM6g0yc.9ep1CK.$CJxzLB/CKOR9pwVjhHMjhXt00IRZd6CpX61Eh1SV3PA:20211::::::
                    ```

    - **User Auto Login**
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
    - **Timezone**
        -**Witl Link**
            ```sh
            ln -fsv ../usr/share/zoneinfo/Asia/Jakarta /etc/localtime
            ```

        -**Witl Copy**
            ```sh
            cp -rfv /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
            ```

    - **Bios Time**
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