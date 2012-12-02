#!/bin/sh

echo -e "\033[1m\033[32m====> \033[34mchecking crosstool-ng...\033[0m"

if [ ! `which ct-ng 2> /dev/null; echo #?` ]
then
  echo "you need to have crosstool-ng installed on your system."
  usage
  exit
fi

echo -e "\033[1m\033[32m====> \033[34msetting up project...\033[0m"

mkdir -p build rootfs tarballs toolchains images mnt archives
