# SETUP TMPFILES
#
#
### REMOVE DIR AUTO CREATE
```sh
dirs=$(cat /lib/tmpfiles.d/*.conf | grep "L " | awk '{print $2}')
for dir in $dirs; do rm -rfv $dir; done
```