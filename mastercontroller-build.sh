#!/bin/bash

pkgs="git curl bzip2 zip xz-utils gnupg kpartx dosfstools"

dpkg-query -l $pkgs > /dev/null
if [ $? -ne 0 ]
then
    sudo apt-get update
    sudo apt-get install $pkgs
fi

if [ "$1" == "--update" ]
then
    ./update.sh
fi

# This is a workaround for https://github.com/debian-pi/raspbian-ua-netinst/issues/80.
if [ ! -f "packages/busybox-static_1.22.0-7_armhf.deb" ]
then
    rm -f packages/busybox-static*
    curl -o packages/busybox-static_1.22.0-7_armhf.deb https://archive.raspbian.org/raspbian/pool/main/b/busybox/busybox-static_1.20.0-7_armhf.deb
fi

./build.sh

# copy master controller custom configuration
cp post-install.txt installer-config.txt ./bootfs/

sudo ./buildroot.sh

img="raspbian-ua-netinst-`date +%Y%m%d`-git`git rev-parse --short @{0}`.img.xz"

echo ""
echo "------------------------------------------------------------------------"
echo ""
if [ -f "$img" ]
then
    echo "OK - The build process has succeeded!"
    echo "You can now dump your clean raspbian-ua-netinst image to a sdcard:"
    echo ""
    echo "$ xzcat \"$img\" > /dev/mmcblk0"
else
    echo "KO - The build process has failed!"
    echo "For some reason, \"$img\" file has not been created..."
fi
echo ""
echo "------------------------------------------------------------------------"
echo ""
