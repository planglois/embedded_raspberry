#!/bin/sh
echo "checking crosstool-ng..."

ct-ng version

if [ ! $? ]
then
  echo "you need to have crosstool-ng installed on your system."
  exit
fi

echo "setting up project..."

mkdir -p build rootfs tarballs toolchains images mnt
