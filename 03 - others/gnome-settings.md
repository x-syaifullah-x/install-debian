# GNOME SETTINGS
#
#
### BACKGROUND
- **Set**
    ```sh
    sudo apt install --no-install-suggests --no-install-recommends webp-pixbuf-loader
    gsettings set org.gnome.desktop.background picture-uri 'file:///home/xxx/.local/share/backgrounds/bg.webp'
    gsettings set org.gnome.desktop.background picture-uri-dark 'file:///home/xxx/.local/share/backgrounds/bg.webp'
    gsettings set org.gnome.desktop.background picture-options 'zoom'
    ```
- **Check**
    ```sh
    gsettings get org.gnome.desktop.background picture-uri
    gsettings get org.gnome.desktop.background picture-uri-dark
    gsettings get org.gnome.desktop.background picture-options
    ```
### FONT
- **Set**
    ```sh
    gsettings set org.gnome.desktop.interface document-font-name 'System-ui 9'
    gsettings set org.gnome.desktop.interface font-name 'System-ui Bold 9'
    gsettings set org.gnome.desktop.interface monospace-font-name 'Monospace 8'
    ```
- **Check**
    ```sh
    gsettings get org.gnome.desktop.interface document-font-name
    gsettings get org.gnome.desktop.interface font-name
    gsettings get org.gnome.desktop.interface monospace-font-name
    ```
### CLOCK
- **Set**
    ```sh
    gsettings set org.gnome.desktop.interface clock-format '12h'
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.interface clock-show-seconds true
    ```
- **Check**
    ```sh
    gsettings get org.gnome.desktop.interface clock-format
    gsettings get org.gnome.desktop.interface clock-show-date
    gsettings get org.gnome.desktop.interface clock-show-weekday
    gsettings get org.gnome.desktop.interface clock-show-seconds
    ```
### CENTER NEW WINDOWS
- **Set**
    ```sh
    gsettings set org.gnome.mutter center-new-windows true
    ```
- **Check**
    ```sh
    gsettings get org.gnome.mutter center-new-windows true
    ```
### DYNAMIC WORKSPACES
- **Set**
    ```sh
    gsettings set org.gnome.shell.overrides dynamic-workspaces false
    gsettings set org.gnome.mutter          dynamic-workspaces false
    ```
- **Check**
    ```sh
    gsettings get org.gnome.shell.overrides dynamic-workspaces
    gsettings get org.gnome.mutter          dynamic-workspaces
    ```
### NUM WORKSPACES
- **Set**
    ```sh
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
    ```
- **Check**
    ```sh
    gsettings get org.gnome.desktop.wm.preferences num-workspaces 1
    ```
### SCREENSAVER
- **Set**
    ```sh
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    ```
- **Check**
    ```sh
    gsettings get org.gnome.desktop.screensaver idle-activation-enabled
    gsettings get org.gnome.desktop.screensaver lock-enabled
    ```