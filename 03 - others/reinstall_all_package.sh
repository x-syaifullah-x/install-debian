[ $(id --user) != 0 ] && echo "Please running script as root." && exit
package_name=$(dpkg --get-selections | grep -v deinstall | awk '{print $1}')
apt install --reinstall $package_name -y
