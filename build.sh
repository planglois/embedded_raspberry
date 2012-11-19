#!/bin/sh

if [ ! -e "$HOME/embedded_raspberry/install/bin/ct-ng" ]
then
  echo "You need to run setup.sh first"
  exit
fi

export PATH="$PATH:$HOME/embedded_raspberry/install/bin"

cd build

cp ../config/ct-ng/rpi-eglibc.conf .config

ct-ng menuconfig
ct-ng build

ln -sv $HOME/embedded_raspberry/build/.build/tarballs $HOME/embedded_raspberry/tarballs
ln -sv $HOME/embedded_raspberry/toolchains/arm-rpi-linux-gnueabi/arm-rpi-linux-gnueabi/sys-root/ 
$HOME/embedded_raspberry/rootfs
