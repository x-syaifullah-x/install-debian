# SETUP PIPEWIRE
#
#
### INSTALL WIREPLUMBER
```sh
apt install --no-install-suggests --no-install-recommends wireplumber
```
### INSTALL PIPEWIRE-PULSE
```sh
apt install --no-install-suggests --no-install-recommends pipewire-pulse
```
### INSTALL PIPEWIRE-ALSA
```sh
apt install --no-install-suggests --no-install-recommends pipewire-alsa
```
### INSTALL PIPEWIRE-JACK
```sh
apt install --no-install-suggests --no-install-recommends libspa-0.2-jack pipewire-jack
```
- **Setup Configuration**
  ```sh
  ln -sf /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d  && ldconfig
  ```
- **Test Pipewire Jack**
  - **Install jack-tools**
    ```sh
    apt install --no-install-suggests --no-install-recommends jack-tools
    ```
  - **Running jack_simple_client**
    ```sh
    jack_simple_client
    ```
---
### INSTALL PIPEWIRE-BLUETOOTH
```sh
apt install --no-install-suggests --no-install-recommends libspa-0.2-bluetooth
```
### INSTALL RTKIT
```sh
apt install --no-install-suggests --no-install-recommends rtkit
```
### INSTALL XDG-DESKTOP-PORTAL
```sh
apt install --no-install-suggests --no-install-recommends xdg-desktop-portal
```