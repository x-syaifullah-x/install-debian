# TEST SPEED DISK WITH DD

### CLEAR BUFFER
```
sudo sync && sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
```
### TEST WRITE
```bash
dd if=/dev/zero of=abcd bs=1M count=1024 conv=fdatasync
```
### CLEAR BUFFER
```
sudo sync && sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
```
### TEST READ
```bash
dd if=abcd of=/dev/null bs=1M count=1024
```