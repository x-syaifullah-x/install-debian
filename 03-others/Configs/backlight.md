# BACKLIGHT
#
#
### INTEL BACKLIGHT
```sh
tee /var/lib/systemd/backlight/pci-0000\:00\:02.0\:backlight\:intel_backlight << EOF
1000
EOF
```

### INTEL BACKLIGHT WITH TMPFILES
```sh
tee /etc/tmpfiles.d/default_backlight.conf << EOF
d /var/lib/systemd/backlight                                                0755    root    root    -
f /var/lib/systemd/backlight/pci-0000\:00\:02.0\:backlight\:intel_backlight 0755    root    root
w /var/lib/systemd/backlight/pci-0000\:00\:02.0\:backlight\:intel_backlight -       -       -       -	1000
EOF
```

### INTEL BACKLIGHT SOURCECODE
```sh
nano drivers/gpu/drm/i915/display/intel_backlight.c
```
- **CTRL+W**
    - intel_pwm_setup_backlight(
- **Replace**
    - panel->backlight.level = intel_pwm_get_backlight(connector, pipe); -> panel->backlight.level = 1000 + 40;