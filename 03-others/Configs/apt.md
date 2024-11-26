# APT
#
#
### NO TRANSLATIONS
```sh
cat << EOF > /etc/apt/apt.conf.d/99no-translations
Acquire::Languages "none";
EOF
```

### SOURCE LIST
- **LOCAL**
    ```sh
    cat << EOF > /etc/apt/sources.list
    deb [trusted=yes] file:/home/xxx/.files/Repo/DEB bpo/
    deb [trusted=yes] file:/home/xxx/.files/Repo/DEB exp/
    deb [trusted=yes] file:/home/xxx/.files/Repo/DEB main/
    EOF
    ```