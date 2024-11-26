# ~/.bash_aliasess

#alias libreoffice='libreoffice7.3 -env:UserInstallation=file:////tmp/libreoffice'

### VNCSERVER START
# alias vncserver_for_mi_8_start="vncserver :0 -name xxx@Lonovo-B490 -geometry 710x820 -dpi 105"
# alias vncserver_for_mi_8_stop="vncserver -kill :0"
### VNCSERVER END

### APT_PURGE BEGIN
alias apt_purge="sudo apt purge $(dpkg -l | awk '/^rc/ { print $2 }')"
### APT_PURGE end

### BATTERY_STATE BEGIN
alias battery_stat="upower              -i /org/freedesktop/UPower/devices/battery_BAT0"
alias battery_stat_watch="watch upower  -i /org/freedesktop/UPower/devices/battery_BAT0"
### BATTERY_STATE END

### POWER PROFILE BEGIN
# function _power_profile() {
#   _profile=(powersave schedutil performance)
#   _input="$1"
#   if [ "$_input" = "" ]; then
#     echo "Required args :"
#     echo ""
#     echo "    0: ${_profile[0]}"
#     echo "    1: ${_profile[1]}"
#     echo "    2: ${_profile[2]}"
#     unset _profile
#     unset _input
#     return 0
#   fi
#   _index=0
#   while true; do
#     _path=/sys/devices/system/cpu/cpu${_index}/cpufreq/scaling_governor
#     if [ ! -f "$_path" ]; then
#       break
#     fi
#     _result=$(echo "${_profile["${_input}"]}" | tee $_path)
#     echo "CPU $_index: $_result"
#     unset _result
#     unset _path
#     _index=$((_index + 1))
#   done
#   unset _index
#   unset _input
#   unset _profile
# }
# alias power_profile_powersave='sudo bash -c "$(declare -f _power_profile); _power_profile 0"'
# alias power_profile_schedutil='sudo bash -c "$(declare -f _power_profile); _power_profile 1"'
# alias power_profile_performance='sudo bash -c "$(declare -f _power_profile); _power_profile 2"'
### POWER PROFILE END

### SET ONLINE CPU BEGIN
# function _set_online_cpu() {
#   _ARG_1=$(expr ${1:-0} - 1)
#   _INDEX=0
#   for i in /sys/devices/system/cpu/cpu*/online; do
#     if [ $_INDEX -lt $_ARG_1 ]; then
#       echo 1 | sudo tee $i 2>/dev/null
#     else
#       echo 0 | sudo tee $i 2>/dev/null
#     fi
#     _INDEX=$(expr $_INDEX + 1)
#   done
#   unset _INDEX
#   unset _ARG_1
# }
# alias set_online_cpu="_set_online_cpu $@"
### SET ONLINE CPU END

alias cpu_MHz_watch="watch -d -n1 'grep MHz /proc/cpuinfo'"

### TEMPERATURE BEGIN
alias temperature="cat              /sys/class/thermal/thermal_zone*/temp"
alias temperature_watch="watch cat  /sys/class/thermal/thermal_zone*/temp"
### TEMPERATURE END

### ANDROID AVD BEGIN
# --device = $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager list | grep tv
# alias create_avd="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd --name test --package "system-images;android-35;google_apis;x86_64" --device "pixel_4" --skin "pixel_4" --sdcard /dev/null --force"
# with gpu nvidia = -gpu swiftshader_indirect
# alias run_avd="QT_QPA_PLATFORM=xcb $ANDROID_HOME/emulator/emulator @test -metrics-collection -log-nofilter -nocache -no-boot-anim -no-snapstorage -no-snapshot -no-snapshot-load -no-snapshot-save -accel on -lowram -gpu host -data ~/.cache/avd/data.img -cache ~/.cache/avd/cache.img -datadir ~/.cache/avd -qemu -cpu host,kvm=on -smp $(nproc) -m $(expr 1024 \* 1)"
# alias run_avd_api_level_less_then_26="QT_QPA_PLATFORM=xcb $ANDROID_HOME/emulator/emulator @test_0 -metrics-collection -log-nofilter -nocache -no-boot-anim -no-snapstorage -no-snapshot -no-snapshot-load -no-snapshot-save -accel on -lowram -gpu host -memory $((1024*3)) -cores $(nproc)"
### ANDROID AVD END

alias clear_ram="sudo 'sync && echo 3 > /proc/sys/vm/drop_caches'"

### WAYDROID BEGIN
alias waydroid_adb_connect="$ANDROID_HOME/platform-tools/adb connect 192.168.240.112"
# alias waydroid_multi_windows="waydroid prop set persist.waydroid.multi_windows $@"
### WAYDROID END

# FOR FIX BLUEZ BEGIN
# function _rfkill_hci0() {
#   for i in /sys/class/rfkill/rfkill*; do
#     RFKILL_NAME=`cat $i/name`
#     if [ $RFKILL_NAME == "hci0" ]; then
#       echo 0 | sudo tee $i/soft &>/dev/null
#     fi
#   done
#   unset i
#   unset RFKILL_NAME
# }
# alias rfkill_hci0="_rfkill_hci0 $@"
# FOR FIX BLUEZ END

### CHROMIUM BEGIN
#LIBVA_MESSAGING_LEVEL=2 LIBVA_TRACE=libva GTK_A11Y=none chromium --ignore-gpu-blocklist --disable-features=UseChromeOSDirectVideoDecoder --use-cmd-decoder=validating --enable-logging=stderr --loglevel=0 --vmodule=vaapi_wrapper=4,vaapi_video_decode_accelerator=4 --enable-hardware-overlays --force-dark-mode --enable-features=VaapiIgnoreDriverChecks,WebUIDarkMode
# SITE TEST LIBVA: https://test-videos.co.uk/bigbuckbunny/mp4-h264
### CHROMIUM END

### GNOME DYNAMIC WORKSPACE BEGIN
#alias dynamic_workspaces_enable="gsettings set org.gnome.mutter dynamic-workspaces true"
#alias dynamic_workspaces_disable="gsettings set org.gnome.mutter dynamic-workspaces false"
### GNOME DYNAMIC WORKSPACE END