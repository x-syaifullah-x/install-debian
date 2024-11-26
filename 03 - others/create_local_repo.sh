#! /bin/bash

# REQUIRED ROOT ACCESS
if [ $(id --user) != 0 ]; then
  echo "Please running script as root"
  exit 0
fi

WORKING_DIR="/$(realpath --relative-to=/ $(dirname $0))"
REPO_NAME="deb"

DEB_DIR="$WORKING_DIR/$REPO_NAME"
[ ! -d $DEB_DIR ] && mkdir -pv $DEB_DIR

OVERAIDE_FILE="$DEB_DIR/overaidefie"
[ ! -f $OVERAIDE_FILE ] && touch $OVERAIDE_FILE

PACKAGES_FILE="$DEB_DIR/Packages"
[ ! -f $$PACKAGES_FILE ] && touch $PACKAGES_FILE

# DOWNLOAD NEW PACKAGE IF EXIST
packages=''
for name in $(cd $DEB_DIR && ls -A *.deb); do
  name_short=$(echo "$name" | sed "s/\(_.*\)\.deb//")
  packages="$packages $name_short"
done
echo "Update ..."
err="$(DEBIAN_FRONTEND="noninteractive" apt-get update -y 2>&1 1>/dev/null)"
if [[ ! -z "$err" ]]; then
  echo $err
  exit 1
fi

echo "Downloads ..."
err="$(DEBIAN_FRONTEND="noninteractive" cd $DEB_DIR && apt-get download $packages -y 2>&1 1>/dev/null)"
if [[ ! -z "$err" ]]; then
  echo $err
  exit 1
fi
###

# REMOVE OLD VERSIONS
name_full=''
name_short=''
for name in $(ls -A $DEB_DIR/*.deb); do
  name_short_new=$(echo "$name" | sed "s/\(_.*\)\.deb/.deb/")
  if [ "$name_short" == "$name_short_new" ]; then
    rm -rfv $name_full
  fi
    name_full=$name
    name_short=$name_short_new
done
###

if [ ! -x "$(command -v dpkg-scanpackages)" ]; then
  echo "Install dpkg-scanpackages ..."
  err="$(sudo DEBIAN_FRONTEND="noninteractive" apt-get install --no-install-suggests --no-install-recommends dpkg-dev -y 2>&1 1>/dev/null)"
  if [[ ! -z "$err" ]]; then
    echo $err
    exit 1
  fi
fi

cd $WORKING_DIR && dpkg-scanpackages -e $OVERAIDE_FILE $REPO_NAME > $PACKAGES_FILE

# GENERATE SOURCES LIST
cat << EOF > $WORKING_DIR/sources.list
deb [trusted=yes] file:$WORKING_DIR ./$REPO_NAME/
EOF
