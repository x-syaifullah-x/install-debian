# SETUP FSTAB
#
#
### SETUP FILE FSTAB
```sh
cat << EOF > /etc/fstab
# <FILE SYSTEM>                                 <MOUNT POINT>       <TYPE>        <OPTIONS>                                                                              <DUMP>   <PASS>

# SYSTEM ROOT EXT4
UUID=00000000-0000-0000-0000-000000000001	     /   ext4    defaults,noatime,errors=remount-ro,commit=1800,barrier=0                                          0        0

# SYSTEM ROOT EXT4 RAID
/dev/md0                                         /   ext4    defaults,noatime,errors=remount-ro,commit=1800,barrier=0                                          0        0

# SYSTEM ROOT F2FS
UUID=00000000-0000-0000-0000-000000000001        /   f2fs    defaults,noatime,gc_merge,fastboot                                                                0        0

# SYSTEM ROOT F2FS RAID
/dev/md0                                         /   f2fs    defaults,noatime,gc_merge,fastboot                                                                0        0

# RAMFS AND TMPFS
tmpfs                                            /dev/shm            tmpfs         defaults,noatime,size=100%,nr_inodes=0,mode=1777,nosuid,nodev               0        0
none                                             /media              tmpfs         defaults,noatime,size=100%,nr_inodes=0,mode=0755                            0        0
none                                             /mnt                tmpfs         defaults,noatime,size=100%,nr_inodes=0,mode=0755                            0        0
none                                             /root               ramfs         defaults,noatime,size=100%,nr_inodes=0,mode=0700                            0        0
tmpfs                                            /run/lock           tmpfs         defaults,noatime,size=100%,nr_inodes=0,mode=1777,nosuid,nodev,noexec        0        0
none                                             /tmp                ramfs         defaults,noatime,size=100%,nr_inodes=0,mode=1777,nosuid,nodev               0        0
none                                             /var/backups        tmpfs         defaults,noatime,size=100%,nr_inodes=0,mode=0755                            0        0
none                                             /var/cache          tmpfs         defaults,noatime,size=100%,nr_inodes=0,mode=0755                            0        0
none                                             /var/lib/apt        tmpfs         defaults,noatime,size=100%,nr_inodes=0,mode=0755                            0        0
none                                             /var/log            tmpfs         defaults,noatime,size=100%,nr_inodes=0,mode=0755                            0        0
EOF
```