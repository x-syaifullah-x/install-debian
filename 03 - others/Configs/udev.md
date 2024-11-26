# UDEV
#
#
### ADB USB RULES
```sh
cat << EOF > /etc/udev/rules.d/adb_usb.rules
ACTION=="add|remove" SUBSYSTEM=="usb", RUN+="/usr/bin/sh /usr/bin/adb_usb_rules.sh $env{DEVPATH}"
EOF

cat << EOF > /usr/sbin/adb_usb_rules.sh
#!/bin/sh
_PATH="/sys$1"
_DATA="$(ls -A $_PATH)"
_RULES_NAME="$(echo "$_PATH" | md5sum | cut -f1 -d" ").rules"
if [ -z "$_DATA" ]; then
  _RULES_FILE=/etc/udev/rules.d/$_RULES_NAME
  if [ -f $_RULES_FILE ]; then
    rm -rf $_RULES_FILE
    udevadm control --reload-rules
    udevadm trigger --subsystem-match $_PATH
  fi
else
  _CONFIGURATION="$(cat $_PATH/configuration)"
  case "$_CONFIGURATION" in
    *adb*)
      for i in $(ls -A $_PATH); do
        case "$i" in
          idProduct)
            ID_PRODUCT=$(cat $_PATH/$i)
            ;;
          idVendor)
            ID_VENDOR=$(cat $_PATH/$i)
            ;;
        esac
      done
      echo "SUBSYSTEM==\"usb\", ATTR{idVendor}==\"$ID_VENDOR\", ATTR{idProduct}==\"$ID_PRODUCT\", MODE=\"0666\", GROUP=\"plugdev\"" > /etc/udev/rules.d/$_RULES_NAME
      udevadm control --reload-rules
      udevadm trigger --subsystem-match $_PATH
    ;;
  esac
fi
EOF
```