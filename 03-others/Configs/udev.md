# UDEV RULES
#
#
### IO_SCHEDULER
```sh
tee /etc/udev/rules.d/io-scheduler.rules << "EOF"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
EOF
```

### MD_LEVEL
```sh
tee /etc/udev/rules.d/md-level.rules << "EOF"
ACTION=="add|change", KERNEL=="md[0-9]*", PROGRAM="/usr/bin/cat /sys/class/block/%k/md/level", ENV{MD_LEVEL}="$result"
EOF
```

### ADB
```sh
tee /etc/udev/rules.d/adb.rules << "EOF"
ACTION=="add|change", SUBSYSTEM=="usb", ENV{ID_SERIAL_SHORT}=="dfcb63b5", MODE="0666", GROUP="plugdev"
EOF
```