#!/bin/bash

if [ $EXCLUDE_MAN ]; then
  X_DPKG_1=$ROOTFS_DIR/etc/dpkg/dpkg.cfg.d/x-dpkg_1
  tee $X_DPKG_1 << EOF
force-unsafe-io
path-exclude=/usr/share/doc/*
path-exclude=/usr/share/doc-base/*
path-exclude=/usr/share/man/*
path-exclude=/usr/share/info/*
path-exclude=/usr/share/lintian/*
path-exclude=/usr/share/locale/*
path-include=/usr/share/locale/en*
EOF
  for _paths in $(sed -n 's|path-[a-z]*=\(/[^/]*\(/[^/]*\)*\)/.*|\1|p' $X_DPKG_1 | uniq); do
      for _path in $(ls -A "$_paths"); do
          rm -rfv "${ROOTFS_DIR}$_paths/$_path"
      done
  done

  X_DPKG_2=$ROOTFS_DIR/etc/dpkg/dpkg.cfg.d/x-dpkg_2
tee $X_DPKG_2 << EOF
path-exclude=/sbin/*.bfs
path-exclude=/sbin/*.cramfs
path-exclude=/sbin/*.minix
EOF
  sed 's/path-exclude=//g' $X_DPKG_2 | while read path; do
    for expanded_path in $path; do
      if [ -e "$expanded_path" ]; then
        rm -rfv "${ROOTFS_DIR}$expanded_path"
      fi
    done
  done
  cat "$X_DPKG_1" "$X_DPKG_2" | tee $ROOTFS_DIR/etc/dpkg/dpkg.cfg.d/x-dpkg
  rm -rfv "$X_DPKG_1" "$X_DPKG_2"
  rm -rfv $ROOTFS_DIR/etc/alternatives/*.gz
fi

### CLEAN DIRS
for dir in dev root run var/cache var/lib/apt var/log; do
  if [ -f "$ROOTFS_DIR/$dir" ]; then
    rm -rfv $ROOTFS_DIR/$dir || exit $?
    continue
  fi
  for i in $(ls -A ${ROOTFS_DIR}/${dir} 2>/dev/null); do
    rm -rfv "$ROOTFS_DIR/$dir/$i" || exit $?
  done
done

tee $ROOTFS_DIR/etc/bash.bashrc << "EOF"
PS1='\u@\h:\w\$ '

if ! shopt -oq posix; then
  . /usr/share/bash-completion/bash_completion
fi
EOF

tee $ROOTFS_DIR/etc/default/locale << EOF
LANG=C.UTF-8
LANGUAGE=C.UTF-8
LC_ADDRESS=C.UTF-8
LC_ALL=C.UTF-8
LC_COLLATE=C.UTF-8
LC_CTYPE=C.UTF-8
LC_IDENTIFICATION=C.UTF-8
LC_MEASUREMENT=C.UTF-8
LC_MESSAGES=C.UTF-8
LC_MONETARY=C.UTF-8
LC_NAME=C.UTF-8
LC_NUMERIC=C.UTF-8
LC_PAPER=C.UTF-8
LC_TELEPHONE=C.UTF-8
LC_TIME=C.UTF-8
EOF

tee $ROOTFS_DIR/etc/default/keyboard << EOF
XKBLAYOUT=us
EOF

tee $ROOTFS_DIR/etc/vconsole.conf << EOF
KEYMAP=us
EOF

RUN_CHROOT="$CURRENT_DIR/run_chroot.sh"
chmod +x $RUN_CHROOT
$RUN_CHROOT $ROOTFS_DIR << "EOF_CHROOT"
if [ -x /bin/apt ]; then
  apt update
  packages=$(dpkg --get-selections | grep -v deinstall | mawk '{print $1}')
  apt install --no-install-recommends --no-install-suggests --reinstall $packages -y
fi
EOF_CHROOT

echo
echo "Total Package: $(dpkg --root=$ROOTFS_DIR --instdir=$ROOTFS_DIR --get-selections | grep -v deinstall | awk '{print $1}' | wc -l)"