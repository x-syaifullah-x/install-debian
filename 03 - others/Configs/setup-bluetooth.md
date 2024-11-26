# SETUP BLUETOOTH

### INSTALL LIBSPA-0.2-BLUETOOTH IF USE PIPEWIRE
```bash
sudo apt install --no-install-suggests --no-install-recommends libspa-0.2-bluetooth
```
---

### INSTALL BLUEZ
```bash
sudo apt install --no-install-suggests --no-install-recommends bluez
```
---

### STOP BLUETOOTH SERVICE
```bash
sudo systemctl stop bluetooth.service
```
---

### DISABLE HCI0
```bash
for i in /sys/class/rfkill/rfkill*; do
    RFKILL_NAME=`cat $i/name`
    if [ $RFKILL_NAME == "hci0" ]; then
        echo 0 | sudo tee $i/soft &>/dev/null
    fi
done
```
---

### START BLUETOOTH SERVICE
```bash
sudo systemctl start bluetooth.service
```
---

### TEST BLUETOOTH
```bash
bluetoothctl
```
```
power on
agent NoInputNoOutput # use if the device does not require a pin
scan on
pair $MAX_ADREESS
connect $MAX_ADREESS
```
---