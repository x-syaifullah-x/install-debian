#!/bin/bash

CURRENT_DIR="/$(realpath --relative-to=/ $(dirname $0))"

. $CURRENT_DIR/make_rootfs_begin.sh $@

base_pacakages=(
  gcc-14-base
  libgcc-s1
  libacl1
  libpcre2-8-0
  libselinux1
  libattr1
  libgmp10
  libc6
  libcap2
  libzstd1
  zlib1g
  libssl3t64
  openssl-provider-legacy
  sed
  debianutils
  libbz2-1.0
  liblzma5
  libmd0
  libsystemd0
  coreutils
  tar
  diffutils
  libcrypt1
  perl-base
  init-system-helpers
  dpkg
  dash
  libtinfo6
  mawk
  libdebconfclient0
  base-passwd
  base-files
  bash
  bash-completion
  libc-bin
  grep
  ncurses-base
)

if [ $INCLUDE_APT ]; then
  apt_packages=(
    libnettle8t64
    libhogweed6t64
    sqv
    libxxhash0
    liblz4-1
    findutils
    libstdc++6
    libudev1
    libxxhash0
    libapt-pkg7.0
    debian-archive-keyring
    libseccomp2
    apt
    libdb5.3t64
    apt-utils
  )
fi

packages=("${base_pacakages[@]}" "${apt_packages[@]}")
download_package ${packages[@]}
extract_package ${packages[@]}

install_package ${base_pacakages[@]}

[ $INCLUDE_APT ] && install_package ${apt_packages[@]} && tee $ROOTFS_DIR/etc/apt/sources.list << EOF
deb http://deb.debian.org/debian               trixie           main contrib non-free non-free-firmware
deb http://deb.debian.org/debian               trixie-backports main contrib non-free non-free-firmware
deb http://deb.debian.org/debian               trixie-updates   main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security  main contrib non-free non-free-firmware
EOF

. $CURRENT_DIR/make_rootfs_end.sh