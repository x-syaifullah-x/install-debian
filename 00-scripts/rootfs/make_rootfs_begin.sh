#!/bin/bash

export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin

ROOTFS_DIR="${1:-rootfs}"
INCLUDE_APT=1
EXCLUDE_MAN=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --without-apt)
      INCLUDE_APT=
      ;;
    --without-man)
      EXCLUDE_MAN=1
      ;;
  esac
  shift
done

function download_package {
  local packages=$(echo "$@" | tr ' ' '\n' | sort)
  for package in $packages; do
      printf "Downloading $package...\n"
      apt-get download $package &>/dev/null
  done
}

function extract_package {
  local packages=$(echo "$@" | tr ' ' '\n' | sort)
  for package in $packages; do
      printf "Extracting $package...\n"
      dpkg -x ${package}_*.deb $ROOTFS_DIR
  done
}

function install_package {
  for package in $@; do
    dpkg --admindir=$ROOTFS_DIR/var/lib/dpkg --root=$ROOTFS_DIR --force-depends --ignore-depends=libc6,usr-is-merged,openssl-provider-legacy -i ${package}_*.deb
  done
}