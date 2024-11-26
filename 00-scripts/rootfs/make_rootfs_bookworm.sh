#!/bin/bash

CURRENT_DIR="/$(realpath --relative-to=/ $(dirname $0))"

. $CURRENT_DIR/make_rootfs_begin.sh $@

base_pacakages=(
  gcc-12-base
  libgcc-s1
  libacl1
  libpcre2-8-0
  libselinux1
  libattr1
  libgmp10
  libc6
  sed
  libcap2
  libzstd1
  zlib1g
  debianutils
  libbz2-1.0
  liblzma5
  libmd0
  libgpg-error0
  libgcrypt20
  liblz4-1
  libsystemd0
  coreutils
  tar
  diffutils
  libcrypt1
  usr-is-merged
  dpkg
	perl-base
	init-system-helpers
  dash
  libtinfo6
  mawk
  libdebconfclient0
  base-passwd
  base-files
  bash
  grep
  bash-completion
  libc-bin
  ncurses-base
)

if [ $INCLUDE_APT ]; then
  apt_packages=(
    findutils
    libstdc++6
    libseccomp2
    libunistring2
    libtasn1-6
    libffi8
    libp11-kit0
    libnettle8
    libidn2-0
    libhogweed6
    libgnutls30
    debian-archive-keyring
    libudev1
    libxxhash0
    libapt-pkg6.0
    gpgv
    debconf
    libaudit-common
    libcap-ng0
    libaudit1
    libpam0g
    libsemanage-common
    libsepol2
    libsemanage2
    libpam-modules-bin
    libdb5.3
    libpam-modules
    passwd
    adduser
    apt
    apt-utils
  )
fi

packages=("${base_pacakages[@]}" "${apt_packages[@]}")
download_package ${packages[@]}
extract_package ${packages[@]}

# USR MERGED BEGIN
cp -rnp $ROOTFS_DIR/lib $ROOTFS_DIR/usr && rm -rf $ROOTFS_DIR/lib && ln -sf usr/lib $ROOTFS_DIR
cp -rnp $ROOTFS_DIR/lib64 $ROOTFS_DIR/usr && rm -rf $ROOTFS_DIR/lib64 && ln -sf usr/lib64 $ROOTFS_DIR
cp -rnp $ROOTFS_DIR/bin $ROOTFS_DIR/usr && rm -rf $ROOTFS_DIR/bin && ln -sf usr/bin $ROOTFS_DIR
cp -rnp $ROOTFS_DIR/sbin $ROOTFS_DIR/usr && rm -rf $ROOTFS_DIR/sbin && ln -sf usr/sbin $ROOTFS_DIR
# USR MERGED END

download_package "util-linux" &>/dev/null
dpkg -x util-linux_*.deb util-linux
# Fix for reinstall all package no getopt
cp -rfp util-linux/usr/bin/getopt $ROOTFS_DIR/bin
rm -rf util-linux

install_package ${base_pacakages[@]}

[ $INCLUDE_APT ] && install_package ${apt_packages[@]} && tee $ROOTFS_DIR/etc/apt/sources.list << EOF
deb http://deb.debian.org/debian                bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian                bookworm-backports main contrib non-free non-free-firmware
deb http://deb.debian.org/debian                bookworm-updates main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security  bookworm-security main contrib non-free non-free-firmware
EOF

. $CURRENT_DIR/make_rootfs_end.sh