# SETUP ANDROID USB RULES

### CHECK USB ANDROID
    
- **Running Command**

    ```bash
    sudo dmesg -w
    ```

    - **Connect your android via USB**

    - **See Output dmesg**

    - **Example Output**
        ```text
        [ 6611.677224] usb 2-2: new high-speed USB device number 8 using xhci_hcd
        [ 6611.828378] usb 2-2: New USB device found, idVendor=2717, idProduct=ff48, bcdDevice= 4.09
        [ 6611.828392] usb 2-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
        [ 6611.828397] usb 2-2: Product: MI 8
        [ 6611.828400] usb 2-2: Manufacturer: Xiaomi
        [ 6611.828403] usb 2-2: SerialNumber: dfcb63b5
        ```

### CREATE FILE ANDROID USB RULES
```bash
cat << "EOF" > /etc/udev/rules.d/android.usb.rules
# ANDROID MI-8 START
### usb tethering and transfer photos (PTP)
SUBSYSTEM=="usb", ATTR{idVendor}=="2717", ATTR{idProduct}=="ff88", MODE="0666", GROUP="plugdev"

### file transfer
SUBSYSTEM=="usb", ATTR{idVendor}=="2717", ATTR{idProduct}=="ff48", MODE="0666", GROUP="plugdev"

### no data transfer
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4ee7", MODE="0666", GROUP="plugdev"
# ANDROID MI-8 END
EOF
```