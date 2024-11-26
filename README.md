# INSTALL DEBIAN MINIMAL
#
#
### [Download Base System](https://github.com/x-syaifullah-x/install-debian/releases)
### EXTRACT BASE SYSTEM
```sh
sudo tar xvf rootfs_amd64.tar.xz
```
### SETUP ENV
```sh
ROOTFS_DIR=rootfs
```
### MOUNT
```sh
sudo mount -v udev     -t devtmpfs          $ROOTFS_DIR/dev             -o defaults,size=0
sudo mount -v devpts   -t devpts            $ROOTFS_DIR/dev/pts         -o defaults
sudo mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/media           -o defaults,size=100%,nr_inodes=0,mode=0775
sudo mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/mnt             -o defaults,size=100%,nr_inodes=0,mode=0775
sudo mount -v proc     -t proc              $ROOTFS_DIR/proc            -o defaults
sudo mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/root            -o defaults,size=100%,nr_inodes=0,mode=0700
sudo mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/run             -o defaults,size=100%,nr_inodes=0,mode=0775
sudo mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/run/lock        -o defaults,size=100%,nr_inodes=0,nosuid,nodev,noexec --mkdir
sudo mount -v sysfs    -t sysfs             $ROOTFS_DIR/sys             -o defaults
sudo mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/tmp             -o defaults,size=100%,nr_inodes=0,mode=1777,nosuid,nodev
sudo mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/var/cache       -o defaults,size=100%,nr_inodes=0,mode=0755
sudo mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/var/lib/apt     -o defaults,size=100%,nr_inodes=0,mode=0755
sudo mount -v tmpfs    -t tmpfs             $ROOTFS_DIR/var/log         -o defaults,size=100%,nr_inodes=0,mode=0755
sudo mount -v          -B /etc/resolv.conf  $ROOTFS_DIR/etc/resolv.conf
```
### RUNNING CHROOT
```sh
sudo chroot $ROOTFS_DIR
```
### INSTALL INIT
```sh
apt install --no-install-recommends --no-install-suggests init
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
- **Change Runtime Directory Size**
    - **Increase the value to 100%**
        ```sh
        sed -i 's/^#\?RuntimeDirectorySize=.*/RuntimeDirectorySize=100%/' /etc/systemd/logind.conf
        ```
    - **Restore**
        ```sh
        sed -i 's/^#\?RuntimeDirectorySize=.*/#RuntimeDirectorySize=10%/' /etc/systemd/logind.conf
        ```
- **Disable Storage Journald**
    - **Set**
        ```sh
        sed -i 's/^#\?Storage=.*/Storage=none/' /etc/systemd/journald.conf
        ```
    - **Restore**
        ```sh
        sed -i 's/^#\?Storage=.*/#Storage=auto/' /etc/systemd/journald.conf
        ```
### MASK SYSTEMD SERVICE
```bash
services=(
    getty-static.service
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
    systemd-binfmt.service
    systemd-modules-load.service
    systemd-random-seed.service
    systemd-rfkill.service
    systemd-rfkill.socket
    systemd-tmpfiles-clean.service
    systemd-tmpfiles-clean.timer
    systemd-tmpfiles-setup-dev.service
)
for service in ${services[@]}; do
  systemctl mask $service
done
```
### INSTALL KMOD(modprobe), UDEV(udevadm)
```sh
apt install --no-install-recommends --no-install-suggests kmod udev
```
### INSTALL LINUX IMAGE
```sh
apt install --no-install-recommends --no-install-suggests linux-image-6.11.10+bpo-amd64
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
### SYSCTL CONF
```sh
cat << EOF > /etc/sysctl.d/proc.sys.conf
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
### Banner
- **Default**
    ```sh
    Debian GNU/Linux 12 \n \l

    ```
- **Local**
    ```sh
    cat << EOF > /etc/issue
    \d \t on \l

    Name    : \n
    Os      : \s \m
    Kernel  : \r
    Version : \v

    EOF
    ```
- **Remote**
    ```sh
    cat << EOF > /etc/issue.net
    \d \t on \l

    Name    : \n
    Os      : \s \m
    Kernel  : \r
    Version : \v

    EOF
    ```
### SETUP TIME
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
### CREATE USER
```sh
_USER_NAME=xxx
useradd $_USER_NAME --shell /bin/bash --home-dir /home/${_USER_NAME} --create-home
```
- **Clean User Directory**
    ```sh
    for i in $(ls -A /home/$_USER_NAME); do
    rm -rfv /home/$_USER_NAME/$i
    done
    ```
### SETUP PASSWORD
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
### MAKE USER AUTO LOGIN
```sh
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat << EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $_USER_NAME --skip-login --noclear - \$TERM
Type=idle
EOF
```
### INSTALL DBUS
```sh
apt install --no-install-recommends --no-install-suggests dbus-user-session
```
- **MAKE LINK MACHINE ID**
    ```sh
    ln -sfv /etc/machine-id /var/lib/dbus/machine-id
    ```
### INSTALL SUDO
```sh
apt install --no-install-recommends --no-install-suggests sudo
```
- **SETUP SUDO FOR USER**
    ```sh
    usermod -aG sudo $USER_NAME
    ```
### INSTALL NETWORK PACAKGES
```sh
apt install --no-install-suggests --no-install-recommends isc-dhcp-client
```
### SETUP HOSTNAME
```sh
cat << EOF > /etc/hostname
x-host
EOF
```
### SETUP HOSTS
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
### EXIT CHROOT
```sh
dpkg --clear-avail
exit
```
### UMOUNT
```sh
for dir in $(mount | grep "$ROOTFS_DIR/" | awk '{print $3}'); do
    mount | grep -q "on $dir type" && sudo umount -v --recursive $dir
done
```
### CLEAN FILE NOT USE
```sh
[ -f $ROOTFS_DIR/etc/.pwd.lock ]                && sudo rm -rfv $ROOTFS_DIR/etc/.pwd.lock
[ -f $ROOTFS_DIR/etc/group- ]                   && sudo rm -rfv $ROOTFS_DIR/etc/group-
[ -f $ROOTFS_DIR/etc/gshadow- ]                 && sudo rm -rfv $ROOTFS_DIR/etc/gshadow-
[ -f $ROOTFS_DIR/etc/hostname ]                 && sudo rm -rfv $ROOTFS_DIR/etc/hostname
[ -f $ROOTFS_DIR/etc/passwd- ]                  && sudo rm -rfv $ROOTFS_DIR/etc/passwd-
[ -f $ROOTFS_DIR/etc/resolv.conf ]              && echo '' | sudo tee $ROOTFS_DIR/etc/resolv.conf
[ -f $ROOTFS_DIR/etc/shadow- ]                  && sudo rm -rfv $ROOTFS_DIR/etc/shadow-
[ -f $ROOTFS_DIR/var/lib/dpkg/diversions-old ]  && sudo rm -rfv $ROOTFS_DIR/var/lib/dpkg/diversions-old
[ -f $ROOTFS_DIR/var/lib/dpkg/status-old ]      && sudo rm -rfv $ROOTFS_DIR/var/lib/dpkg/status-old
```