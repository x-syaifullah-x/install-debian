# COSTUME INITRD
#
#
### ENVIRONMENT
```sh
MY_INITRD_DIR=/mnt/my-initrd
```

### UNPACK INITRD
```sh
sudo unmkinitramfs /boot/initrd.img-$(uname -r) $MY_INITRD_DIR
```
### ADDED FILE CPIO TO INITRD
```sh
sudo find etc usr var | sudo cpio -o -H newc | sudo tee $MY_INITRD_DIR/rootfs.cpio 2>&1 >/dev/null
```
### REPACK INITRD WITH LZ4 COMPRESS
```sh
sudo find . | sudo cpio -o -H newc | sudo lz4 -9 -l | sudo tee ../resutl.img 2>&1 >/dev/null
```
### MAKE AS SYSTEM
- **Environment**
    ```sh
    ROOTFS_DIR=/mnt/ram-0
    ```
- **Mount Disk**
    ```sh
    sudo moun /dev/abcD $ROOTFS_DIR
    ```
- **Setup Directory System**
    ```sh
    sudo mkdir -pv $ROOTFS_DIR/{boot,dev,etc,home,media,mnt,opt,proc,root,run,srv,sys,tmp,usr/{bin,lib,lib64,sbin},var}
    sudo ln -fsv /usr/bin $ROOTFS_DIR/bin 
    sudo ln -fsv /usr/sbin $ROOTFS_DIR/sbin
    sudo ln -fsv /usr/sbin $ROOTFS_DIR/sbin
    sudo ln -fsv /usr/lib $ROOTFS_DIR/lib
    sudo ln -fsv /usr/lib64 $ROOTFS_DIR/lib64
    ```
- **Setup Directory Boot**
    ```sh
    sudo cp -frv vmlinuz-$(uname -r) $ROOTFS_DIR/boot/vmlinuz-$(uname -r)
    sudo cp -frv your_initrd $ROOTFS_DIR/boot/initrd.img-$(uname -r)
    ```
-**Setup Grub CFG**
    ```sh
    ```