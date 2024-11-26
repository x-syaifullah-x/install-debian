### ROOTFS DEBIAN ARM64
#
#
### BASE SYSTEM
[Download Base System](https://github.com/x-syaifullah-x/install-debian/releases/download/bookworm-arm64/rootfs_arm64.tar.xz)

[Init](https://github.com/x-syaifullah-x/install-debian/blob/master/README.md)

### INIT SYSTEM
- **Install Packages**
    ```sh
    apt install --no-install-suggests --no-install-recommends systemd-timesyncd
    ```

### SETUP FSTAB
- **EXT4**
    ```sh
    cat << EOF | tee /etc/fstab
    LABEL=ROOTFS / ext4 defaults,noatime,errors=remount-ro,commit=1800 0 0
    EOF
    ```
- **F2FS**
    ```sh
    cat << EOF | tee /etc/fstab
    /dev/mmcblk1p2 / f2fs defaults,noatime,gc_merge,fastboot 0 0
    EOF
    ```

### SYSCTL CONFIG
```sh
cat << EOF | tee /etc/sysctl.d/proc.sys.conf
kernel.printk = 0 4 1 7
EOF
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
    apt install --no-install-suggests --no-install-recommends hostapd wpasupplicant dbus
    ```
- **Link Machine-ID**
    ```sh
    ln -sfv /etc/machine-id /var/lib/dbus/machine-id
    ```
- **Setup ENV**
    ```sh
    _interface=wlan0
    _getway=192.168.1.1
    ```
- **Setup HOSTAPD**
    ```sh
    sed -i 's/^#\?DAEMON_CONF=.*/DAEMON_CONF=\"\/etc\/hostapd\/hostapd.conf\"/' /etc/default/hostapd
    cat << EOF | tee /etc/hostapd/hostapd.conf
    interface=$_interface
    driver=nl80211
    ieee80211n=1
    ht_capab=[HT40+][SHORT-GI-20][SHORT-GI-40]
    ssid=$(cat /etc/hostname)
    # HW MODE
    #   a : 5GHz
    #   b : 2.4GHz
    hw_mode=g
    channel=6
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
    ap_isolate=0
    EOF
    ```
- **Setup Network**
    ```sh
    ### ETH0 | LAN
    cat << EOF | tee /etc/systemd/network/20-eth0.network
    [Match]
    Name=eth0
    [Network]
    Address=192.168.0.1/24
    DHCPServer=yes
    IPMasquerade=yes
    [DHCPServer]
    PoolOffset=2
    PoolSize=9
    DNS=192.168.0.1
    DNS=8.8.8.8
    EOF

    ### WLAN0 | HOTSPOT
    cat << EOF | tee /etc/systemd/network/20-wlan0.network
    [Match]
    Name=wlan0
    [Network]
    Address=192.168.1.1/24
    DHCPServer=yes
    IPMasquerade=yes
    [DHCPServer]
    PoolOffset=2
    PoolSize=9
    DNS=192.168.1.1
    DNS=8.8.8.8
    EOF

    ### WLAN1 | INTERNET
    cat << EOF | tee /etc/systemd/network/20-wlan1.network
    [Match]
    Name=wlan1
    [Network]
    DHCP=yes
    #Address=192.168.44.21/24
    #Gateway=192.168.44.1
    #DNS=192.168.44.1
    #DNS=118.98.115.70
    #DNS=118.98.115.77
    EOF
    ```
- **Add HOTSPOT SERVICE**
    ```sh
    _service_name=hotspot.service
    cat << EOF | tee /etc/systemd/system/$_service_name
    [Unit]
    Description=Restart Systemd Networkd
    After=network.target

    [Service]
    Type=oneshot
    ExecStart=/bin/sh -c "systemctl restart systemd-networkd --now"

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