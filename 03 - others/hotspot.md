# SETUP HOTSPOT
#
#
### INSTALL PACKAGES
```sh
apt install --no-install-suggests --no-install-recommends hostapd dnsmasq iptables wpasupplicant
```
### HOSTAPD CONFIG
```sh
cat << EOF | tee /etc/hostapd/hostapd.conf 
interface=wlan0
driver=nl80211
ssid=Wi-Fi
hw_mode=g
channel=1
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=1
wpa_passphrase=3172041902920013
wpa_key_mgmt=WPA-PSK
rsn_pairwise=TKIP CCMP
EOF
```
### HOSTAPD CONF ENABLE
```SH
cat << EOF >> /etc/default/hostapd

DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF
```

### DNSMASQ CONFIG
```sh
cat << EOF >> /etc/dnsmasq.d/wlan0.conf 
interface=wlan0
dhcp-range=net:wlan0,192.168.0.100,192.168.0.150,255.255.255.0,24h
dhcp-option=wlan0,3,192.168.0.1
dhcp-option=wlan0,6,8.8.8.8,8.8.4.4
EOF
```

### SERVICE WLAN0 UP
```sh
cat << EOF >> /etc/systemd/system/wlan0.up.service 
[Unit]
Description=wlan0 up
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c "ip link set wlan0 up && ip addr add 192.168.0.1/24 dev wlan0"

[Install]
WantedBy=multi-user.target
EOF
```

### SERVICE WLAN0 UP ENABLE
```sh
systemctl enable wlan0.up.service
```

### CONNECT TO WIFI
```sh
S_FILE=connect.wifi
cat << EOF >> $S_FILE
#!/bin/sh

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -o wlan1 -j MASQUERADE
iptables -A FORWARD -i wlan1 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o wlan1 -j ACCEPT
_cfg='network={
	ssid="adibah.Net WiFi-"
	key_mgmt=NONE
}'
echo "$_cfg" | sudo wpa_supplicant -i wlan1 -c /dev/stdin -B
dhclient -v wlan1
EOF
chmod +x $S_FILE
```