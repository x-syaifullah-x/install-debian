# EXTRACT AND REPACK SFS IMG

### Install Tools
```bash
sudo apt install --no-install-suggests --no-install-recommends squashfs-tools
```

### Extract
```bash
unsquashfs original.sfs
```

### Repack
```bash
mksquashfs squashfs-root modified.sfs
```