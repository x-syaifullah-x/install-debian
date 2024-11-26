# BACKUP | SPLIT | RESTORE

### Backup 

- **bz2**
    ```bash
    sudo tar cvjSf backup.tar.bz2 *
    ```

- **xz**
    ```bash
    sudo tar cfJv backup.tar.xz *
    ```

### SPLIT

- **Backup**

    - **bz2**
        ```bash
        gzip -c backup.tar.bz2 | split -b 50000000 --numeric-suffixes=0 --suffix-length=1 - backup.tar.bz2.0
        ```

    - **xz**
        ```bash
        gzip -c backup.tar.xz | split -b 50000000 --numeric-suffixes=0 --suffix-length=1 - backup.tar.xz.0
        ```

- **Restore**

    - **bz2**
        ```bash
        cat backup.tar.bz2.* | zcat > backup.tar.bz2
        ```

    - **xz**
        ```bash
        cat backup.tar.xz.* | zcat > backup.tar.xz
        ```

### RESTORE

- **bz2**
    ```bash
    tar -xf backup.tar.bz2 -C destination
    ```

- **xz**
    ```bash
    tar xvf backup.tar.xz -C destination
    ```