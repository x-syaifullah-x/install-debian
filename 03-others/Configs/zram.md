# ZRAM
#
#
### ADDED ZRAM CONF MODULES-LOAD.D
```sh
cat << "EOF" > /etc/modules-load.d/zram.conf
zram
EOF
```
### ADDED ZRAM CONF MODPROBE.D
```sh
cat << "EOF" > /etc/modprobe.d/zram.conf
options zram num_devices=1
EOF
```
### ADDED ZRAM RULES RULES.D
```sh
cat << "EOF" > /etc/udev/rules.d/zram.rules
KERNEL=="zram0", SUBSYSTEM=="block", ACTION=="add", ATTR{initstate}=="0", ATTR{comp_algorithm}="lz4", ATTR{disksize}="15830M", RUN="/sbin/mkswap -U clear /dev/zram0", TAG+="systemd"
EOF
```
### ADDED CONFIG VM SWAPPINESS
```sh
cat << "EOF" > /etc/sysctl.d/vm-swappiness.conf
#
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables.
# See sysctl.conf (5) for information.
#
vm.swappiness=1
EOF
```
### ENBALE ZRAM AS SWAP
- **Please Use One**

    - **With FSTAB**
        ```sh
        cat << "EOF" >> /etc/fstab
        # ZRAM
        /dev/zram0  none    swap    defaults,pri=100    0   0
        EOF
        ```

    - **With Command**
        ```sh
        swapon /dev/zram0
        ```