#alias libreoffice='libreoffice7.3 -env:UserInstallation=file:////tmp/libreoffice'

### VNCSERVER START
# alias vncserver_for_mi_8_start="vncserver :0 -name xxx@Lonovo-B490 -geometry 710x820 -dpi 105"
# alias vncserver_for_mi_8_stop="vncserver -kill :0"
### VNCSERVER END

### APT START
alias apt_purge="sudo apt purge $(dpkg -l | awk '/^rc/ { print $2 }')"
### APT AND

### BATTERY STATE START
alias battery_stat="upower              -i /org/freedesktop/UPower/devices/battery_BAT0"
alias battery_stat_watch="watch upower  -i /org/freedesktop/UPower/devices/battery_BAT0"
### BATTERY STATE END

### POWER PROFILE START
function _power_profile(){
  echo ""
  _profile=(powersave schedutil performance)
  _input="$1"
  if [ "$_input" = "" ]; then
    echo "Required args :"
    echo ""
    echo "    0: ${_profile[0]}"
    echo "    1: ${_profile[1]}"
    echo "    2: ${_profile[2]}"
    unset _profile
    unset _input
    exit 0
  fi
  _index=0
  while true; do
    _path=/sys/devices/system/cpu/cpu${_index}/cpufreq/scaling_governor
    if [ ! -f "$_path" ]; then
      break
    fi
    _result=$(echo "${_profile["${_input}"]}" | tee $_path)
    echo "CPU $_index: $_result"
    unset _result
    unset _path
    _index=$((_index + 1))
  done
  unset _index
  unset _input
  unset _profile
}
alias power_profile_powersave='sudo bash -c "$(declare -f _power_profile); _power_profile 0"'
alias power_profile_schedutil='sudo bash -c "$(declare -f _power_profile); _power_profile 1"'
alias power_profile_performance='sudo bash -c "$(declare -f _power_profile); _power_profile 2"'
### POWER PROFILE END

### SET ONLINE CPU START
function _set_online_cpu() {
  _ARG_1=$(expr ${1:-0} - 1)
  _INDEX=0
  for i in /sys/devices/system/cpu/cpu*/online; do
    if [ $_INDEX -lt $_ARG_1 ]; then
      echo 1 | sudo tee $i 2>/dev/null
    else
      echo 0 | sudo tee $i 2>/dev/null
    fi
    _INDEX=$(expr $_INDEX + 1)
  done
  unset _INDEX
  unset _ARG_1
}
alias set_online_cpu="_set_online_cpu $@"
### SET ONLINE CPU END

alias cpu_MHz_watch="watch -d -n1 'grep MHz /proc/cpuinfo'"

alias temperature="cat              /sys/class/thermal/thermal_zone*/temp"
alias temperature_watch="watch cat  /sys/class/thermal/thermal_zone*/temp"

# alias clear_zsh="printf '\033c'"

#alias tmux_clear='clear && tmux clear'

# --device = $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager list | grep tv
# alias create_avd="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd --name test --package "system-images;android-35;google_apis;x86_64" --device "pixel_4" --skin "pixel_4" --sdcard /dev/null --force"
# with gpu nvidia = -gpu swiftshader_indirect
# alias run_avd="QT_QPA_PLATFORM=xcb $ANDROID_HOME/emulator/emulator @test -metrics-collection -log-nofilter -nocache -no-boot-anim -no-snapstorage -no-snapshot -no-snapshot-load -no-snapshot-save -accel on -lowram -gpu host -data ~/.cache/avd/data.img -cache ~/.cache/avd/cache.img -datadir ~/.cache/avd -qemu -cpu host,kvm=on -smp $(nproc) -m $(expr 1024 \* 1)"
# alias run_avd_api_level_less_then_26="QT_QPA_PLATFORM=xcb $ANDROID_HOME/emulator/emulator @test_0 -metrics-collection -log-nofilter -nocache -no-boot-anim -no-snapstorage -no-snapshot -no-snapshot-load -no-snapshot-save -accel on -lowram -gpu host -memory $((1024*3)) -cores $(nproc)"
### ENABLE SKIA
#su
#setprop debug.hwui.renderer skiagl
#stop
#start
#
###

#alias adb="$ANDROID_HOME/platform-tools/adb"
#alias fastboot="sudo ${ANDROID_HOME}/platform-tools/fastboot"

alias clear_ram="sudo sync && sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null"

### WAYDROID START
alias waydroid_adb_connect="adb connect 192.168.240.112"
alias waydroid_multi_windows="waydroid prop set persist.waydroid.multi_windows $@"
### WAYDROID END

### CREATE RAM EXT4 START
function _create_ram_ext4() {
  [ -x /usr/sbin/mkfs.ext4 ] || {
    echo "mkfs.ext4 command not found"
    return 127
  }
  [ $(id --user) != 0 ] && exit
  size='$(free -k | grep Mem | awk '{print $2}')'
  modprobe -r brd --verbose
  modprobe brd rd_nr=1 rd_size=$size --verbose
  unset size
  ram_path="/dev/ram0"
  ram_label=$(echo "$ram_path" | sed "s/\/dev\/ram/ram\-/g")
  mkfs.ext4 -v -m 0 -O ^has_journal -L $ram_label $ram_path -F
  tune2fs $ram_path -o discard,journal_data_writeback,nobarrier
  e2fsck $ram_path -f && e2fsck $ram_path -F
  unset ram_path
  unset ram_label
}
alias create_ram_ext4="sudo bash -c '$(declare -f _create_ram_ext4); _create_ram_ext4 $@'"
### CREATE RAM EXT4 END

### CREATE RAM F2FS START
function _create_ram_f2fs() {
  [ -x /usr/sbin/mkfs.f2fs ] || {
    echo "mkfs.f2fs command not found"
    return 127
  }
  [ $(id --user) != 0 ] && exit
  size='$(free -k | grep Mem | awk '{print $2}')'
  modprobe -r brd --verbose
  modprobe brd rd_nr=1 rd_size=$size --verbose
  unset size
  ram_path="/dev/ram0"
  ram_label=$(echo "$ram_path" | sed "s/\/dev\/ram/ram\-/g")
  mkfs.f2fs -l $ram_label $ram_path -f
  unset ram_path
  unset ram_label
}
alias create_ram_f2fs="sudo bash -c '$(declare -f _create_ram_f2fs); _create_ram_f2fs $@'"
### CREATE RAM F2FS END

### CREATE ZRAM EXT4 START
function _create_zram_ext4() {
  [ -x /usr/sbin/mkfs.ext4 ] || {
    echo "mkfs.ext4 command not found"
    return 127
  }
  [ $(id --user) != 0 ] && exit
  size='$(free -b | grep Mem | awk '{print $2}')'
  modprobe zram --verbose
  zram_path=$(zramctl --find --algorithm lz4 --size $size)
  unset size
  zram_label=$(echo $zram_path | sed "s/\/dev\/zram/zram\-/g")
  mkfs.ext4 -v -m 0 -O ^has_journal -L $zram_label $zram_path -F
  tune2fs $zram_path -o discard,journal_data_writeback,nobarrier
  e2fsck $zram_path -f && e2fsck $zram_path -F
  unset zram_path
  unset zram_label
}
alias create_zram_ext4="sudo bash -c '$(declare -f _create_zram_ext4); _create_zram_ext4 $@'"
### CREATE ZRAM EXT4 END

### CREATE ZRAM F2FS START
function _create_zram_f2fs() {
  [ -x /usr/sbin/mkfs.f2fs ] || {
    echo "mkfs.f2fs command not found"
    return 127
  }
  [ $(id --user) != 0 ] && exit
  size='$(free -b | grep Mem | awk '{print $2}')'
  modprobe zram --verbose
  zram_path=$(zramctl --find --algorithm lz4 --size $size)
  unset size
  zram_label=$(echo $zram_path | sed "s/\/dev\/zram/zram\-/g")
  mkfs.f2fs -l $zram_label $zram_path -f
  unset zram_path
  unset zram_label
}
alias create_zram_f2fs="sudo bash -c '$(declare -f _create_zram_f2fs); _create_zram_f2fs $@'"
### CREATE ZRAM F2FS END

### CREATE ZRAM SWAP START
function _create_zram_swap() {
  [ $(id --user) != 0 ] && exit
  size='$(free -b | grep Mem | awk '{print $2}')'
  modprobe zram --verbose
  zram_path=$(zramctl --find --algorithm lz4 --size $size)
  unset size
  zram_label=$(echo $zram_path | sed "s/\/dev\/zram/zram\-/g")
  mkswap $zram_path --label $zram_label
  swapon $zram_path -p 100 -v
  unset zram_path
  unset zram_label
  sysctl -w vm.swappiness=1
  sysctl -p
}
alias create_zram_swap="sudo bash -c '$(declare -f _create_zram_swap); _create_zram_swap $@'"
### CREATE ZRAM SWAP END

# FOR FIX BLUEZ START
function _rfkill_hci0() {
  for i in /sys/class/rfkill/rfkill*; do
    RFKILL_NAME=`cat $i/name`
    if [ $RFKILL_NAME == "hci0" ]; then
      echo 0 | sudo tee $i/soft &>/dev/null
    fi
  done
  unset i
  unset RFKILL_NAME
}
alias rfkill_hci0="_rfkill_hci0 $@"
# FOR FIX BLUEZ END

# test va driver: https://test-videos.co.uk/bigbuckbunny/mp4-h264
alias chromium="chromium --gtk-version=4 --start-maximized --enable-native-gpu-memory-buffers --enable-zero-copy --enable-features=ConversionMeasurement,WebGPUService,VaapiVideoDecoder,VaapiVideoEncoder,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE --ozone-platform-hint=auto --enable-parallel-downloading --enable-gpu-rasterization"
#LIBVA_MESSAGING_LEVEL=2 LIBVA_TRACE=libva GTK_A11Y=none chromium --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds --disable-features=UseChromeOSDirectVideoDecoder --use-cmd-decoder=validating --enable-logging=stderr --loglevel=0 --enable-logging=stderr --vmodule=vaapi_wrapper=4,vaapi_video_decode_accelerator=4 --enable-hardware-overlays --force-dark-mode --enable-features=WebGPU,UseOzonePlatform,VaapiIgnoreDriverChecks,WebUIDarkMode,

alias dynamic_workspaces_enable="gsettings set org.gnome.mutter dynamic-workspaces true"
alias dynamic_workspaces_disable="gsettings set org.gnome.mutter dynamic-workspaces false"