# TIME SYNCHRONIZATION

- **Install systemd timesyncd**

    ```bash
    apt install --no-install-suggests --no-install-recommends systemd-timesyncd
    ```

- **Synchronized System Clock**
    ```bash
    timedatectl set-local-rtc 0
    timedatectl set-ntp true
    ```