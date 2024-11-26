### ROOTFS DEBIAN ARM64 B860H
#
#
### BASE SYSTEM

### INIT SYSTEM

- **Install Packages**
    ```sh
    apt install --no-install-suggests --no-install-recommends init kmod systemd-timesyncd udev
    ```

- **Setup FSTAB**
    ```sh
    cat << EOF | tee /etc/fstab
    LABEL=ROOTFS / ext4 defaults,noatime,errors=remount-ro,commit=1800 0 0
    EOF
    ```

- **Disable Systemd**
    ```sh
    systemctl disable apt-daily-upgrade.timer apt-daily.timer dpkg-db-backup.timer fstrim.timer remote-fs.target systemd-pstore.service
    ```

- **Mask Systemd**
    ```sh
    services=(
        getty-static.service
        kmod-static-nodes.service
        modprobe@dm_mod.service
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
- **Sysctl Conf**
    ```sh
    cat << EOF | tee /etc/sysctl.d/proc.sys.conf
    kernel.printk = 0 4 1 7
    EOF
    ```

- **Update Size Runtime Directory Size**
    ```sh
    sed -i 's/^#\?RuntimeDirectorySize=.*/RuntimeDirectorySize=100%/' /etc/systemd/logind.conf
    ```

- **Disable Journald**
    ```sh
    sed -i 's/^#\?Storage=.*/Storage=none/' /etc/systemd/journald.conf
    ```

### SETUP HOSTNAME
```sh
cat << EOF | tee /etc/hostname
s905x
EOF
```

### UPDATE HOSTS
```sh
cat << EOF | tee /etc/hosts
127.0.0.1   localhost $(cat /etc/hostname)
::1         ip6-localhost ip6-loopback
fe00::0     ip6-localnet
ff00::0     ip6-mcastprefix
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF
```

### SETUP HOTSPOT

- **Install Packages**
    ```sh
    apt install --no-install-suggests --no-install-recommends hostapd dnsmasq wpasupplicant iptables dbus
    ```

- **Link Machine-ID**
    ```sh
    ln -sfv /etc/machine-id /var/lib/dbus/machine-id
    ```

- **Setup ENV**
    ```sh
    _interface=wlan0
    _getway=192.168.0.1
    ```

- **Setup HOSTAPD**
    ```sh
    sed -i 's/^#\?DAEMON_CONF=.*/DAEMON_CONF=\"\/etc\/hostapd\/hostapd.conf\"/' /etc/default/hostapd
    cat << EOF | tee /etc/hostapd/hostapd.conf
    interface=$_interface
    driver=nl80211
    ssid=Wi-Fi
    # HW MODE
    #   a : 5GHz
    #   b : 2.4GHz
    hw_mode=g
    channel=1
    wmm_enabled=0
    macaddr_acl=0
    auth_algs=1
    # IGNORE BROADCASE SSID
    #   0: visible
    #   1: hidden
    ignore_broadcast_ssid=0
    wpa=2
    wpa_passphrase=3172041902920013
    wpa_key_mgmt=WPA-PSK
    rsn_pairwise=TKIP CCMP
    ctrl_interface=/var/run/hostapd
    ctrl_interface_group=0
    EOF
    ```

- **Setup DNSMASQ**
    ```sh
    cat << EOF | tee /etc/dnsmasq.d/${_interface}.conf
    interface=$_interface
    dhcp-range=net:$_interface,${_getway}00,${_getway}99,255.255.255.0,infinite
    dhcp-option=${_interface},3,$_getway
    dhcp-option=${_interface},6,$_getway
    host-record=$(cat /etc/hostname),$_getway
    EOF
    ```

- **Add HOTSPOT SERVICE**
    ```sh
    _service_name=hotspot.service
    cat << EOF | tee /etc/systemd/system/$_service_name
    [Unit]
    Description=Create Hotspot
    After=network.target

    [Service]
    Type=oneshot
    Environment="INTERFACE=$_interface"
    Environment="GETWAY=$_getway"
    Environment="INET=wlan1"
    ExecStart=/bin/sh -c "ip link set \$INTERFACE up && ip addr add \${GETWAY}/24 dev \$INTERFACE || true"
    ExecStart=/bin/sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
    ExecStart=/bin/sh -c "/sbin/iptables -t nat -A POSTROUTING -o \$INET -j MASQUERADE"
    ExecStart=/bin/sh -c "/sbin/iptables -A FORWARD -i \$INET -o \$INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT"
    ExecStart=/bin/sh -c "/sbin/iptables -A FORWARD -i \$INTERFACE -o \$INET -j ACCEPT"

    [Install]
    WantedBy=multi-user.target
    EOF
    systemctl enable $_service_name 
    ```

### SETUP SSH SERVER
```sh
apt install --no-install-suggests --no-install-recommends openssh-server
mkdir --mode=0700 --parents ~/.ssh
touch ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
```