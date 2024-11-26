# DESKTOP ENVIRONMENT SWAY

### INSTALL SWAY
```bash
apt install --no-install-recommends --no-install-suggests sway
```

### INSTALL FOOT (TERMINAL)
```bash
apt install --no-install-recommends --no-install-suggests foot
```

### INSTALL XWAYLAND
```bash
apt install --no-install-recommends --no-install-suggests xwayland
```

### INSTALL WIREPLUMBER (SOUND)
```bash
apt install --no-install-recommends --no-install-suggests wireplumber
```

- **INSTALL DBUS USER SESSION**
	```bash
	apt install --no-install-recommends --no-install-suggests dbus-user-session
	```

- **INSTALL RTKIT**
	```bash
	apt install --no-install-recommends --no-install-suggests rtkit
	```

- **INSTALL XDG DESKTOP PORTAL**
	```bash
	apt install --no-install-recommends --no-install-suggests xdg-desktop-portal
	```

### SETUP TOUCHPAD

- **Copy Sway Config**
	```bash
	cp -rf /etc/sway/config /home/xxx/.config/sway/config
	```

- **Edit Sway Config**
	```bash
	editor /home/xxx/.config/sway/config
	```

- **Config**
	```
	input "2:7:SynPS/2_Synaptics_TouchPad" {
		dwt enabled
		tap enabled
		natural_scroll disabled
		scroll_method edge
		middle_emulation disabled
		accel_profile "flat"
		pointer_accel 0.5
		left_handed enabled
	}
	```

### RUNNING FROM TTY
- **With sway**
	```bash
	sway
	```

- **With dbus-run-session**
	```bash
	XDG_SESSION_TYPE=wayland dbus-run-session sway &>/dev/null
	```