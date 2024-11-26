# SYSCTL CONF
#
#
### PROC SYS CONF
```sh
mkdir -pv /etc/sysctl.d
tee /etc/sysctl.d/proc.sys.conf << EOF
kernel.printk               = 0 4 1 7
#vm.dirty_ratio             = 1
#vm.dirty_background_ratio  = 1
vm.page-cluster             = 0
vm.swappiness               = 1
#vm.vfs_cache_pressure      = 500
vm.watermark_boost_factor   = 0
vm.watermark_scale_factor   = 50
EOF
```