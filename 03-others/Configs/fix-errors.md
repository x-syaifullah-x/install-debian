# FIX ERROR

### W: Possible missing firmware /lib/firmware/rtl_nic/rtl8125b-2.fw for module r8169
```bash
apt install --no-install-suggests --no-install-recommends firmware-realtek
```

### Error platform regulatory.0: Direct firmware load for regulatory.db failed with error -2
#### FIX
```bash
apt install wireless-regdb
```
```
wireless-regdb
```
---

# FIX ERROR LIBBD_CRYPTO.SO2
#### failed to load module crypto: libbd_crypto.so.2: cannot open shared object file: No such file or directory
#### udisksd[457]: Failed to load the 'crypto' libblockdev plugin
##### Solution:
```
sudo apt install --no-install-suggests --no-install-recommends libblockdev-crypto2
```
---

# FIX ERROR LIBBD_MDRAID.SO2
#### udisksd[435]: failed to load module mdraid: libbd_mdraid.so.2: cannot open shared object file: No such file or directory
#### udisksd[435]: Failed to load the 'mdraid' libblockdev plugin
##### Solution:
```
cp -rf /files/usr/lib/x86_64-linux-gnu/libbd_mdraid.so.2 to /usr/lib/x86_64-linux-gnu
cp -rf /files/usr/lib/x86_64-linux-gnu/libbd_mdraid.so.2.0.0 to /usr/lib/x86_64-linux-gnu
cp -rf /files/usr/lib/x86_64-linux-gnu/libbytesize.so.1 to /usr/lib/x86_64-linux-gnu
cp -rf /files/usr/lib/x86_64-linux-gnu/libbytesize.so.1.0.0 to /usr/lib/x86_64-linux-gnu
```
or
```
sudo apt install --no-install-suggests --no-install-recommends libblockdev-mdraid2 libbytesize-common libbytesize1 mdadm
```
---

#### handle error couldn't access control socket: /run/user/1000/keyring/control: Tidak ada berkas atau direktori seperti itu
##### Solution : copy this to /etc/pam.d/login
```
session optional pam_gnome_keyring.so auto_start
auth optional pam_gnome_keyring.so
```
---
#### pipewire could not set nice level
##### Solution 
```
install rtkit to fix
```
---
#### Fix error [2263:2263:0807/213529.060837:ERROR:object_proxy.cc(590)] Failed to call method: org.freedesktop.portal.Settings.Read: object_path= /org/freedesktop/portal/desktop: org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.portal.Desktop was not provided by any .service files
```
sudo apt install xdg-desktop-portal-gtk --no-install-recommends --no-install-suggests
```
```
xdg-desktop-portal xdg-desktop-portal-gtk
```
---

### Support for cores revisions 0x17 and 0x18 disabled by module param allhwsupport=0. Try b43.allhwsupport=1
```
added kernel params modprobe.blacklist=b43
```