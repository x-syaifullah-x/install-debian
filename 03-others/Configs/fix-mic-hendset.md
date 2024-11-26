# FIX MIC HANDSET

### FIX

- **STOP SERVICE WIREPLUMBER**
    ```bash
    systemctl --user stop wireplumber.service
    ```

- **REMOVE MODULE SND HDA INTEL**
    ```bash
    sudo modprobe --verbose snd-hda-intel --remove
    ```

- **INSERT MODULE SND HDA INTEL**
    ```bash
    sudo modprobe --verbose snd-hda-intel model=dell-headset-multi
    ```

- **START SERVICE WIREPLUMBER**
    ```bash
    systemctl --user start wireplumber.service
    ```

- **SET MIC**
    ```bash
    pactl set-source-port alsa_input.pci-0000_00_1b.0.analog-stereo analog-input-mic
    ```

- **SET VOLUME**
    ```bash
    pactl set-source-volume alsa_input.pci-0000_00_1b.0.analog-stereo 45%
    ```

## RESTORE
- **STOP SERVICE WIREPLUMBER**
    ```bash
    systemctl --user stop wireplumber.service
    ```

- **REMOVE MODULE SND HDA INTEL**
    ```bash
    sudo modprobe --verbose snd-hda-intel --remove
    ```

- **INSERT MODULE SND HDA INTEL**
    ```bash
    sudo modprobe --verbose snd-hda-intel
    ```

- **START SERVICE WIREPLUMBER**
    ```bash
    systemctl --user start wireplumber.service
    ```

- **SET MIC**
    ```bash
    pactl set-source-port alsa_input.pci-0000_00_1b.0.analog-stereo analog-input-internal-mic
    ```

- **SET VOLUME**
    ```bash
    pactl set-source-volume alsa_input.pci-0000_00_1b.0.analog-stereo 60%
    ```