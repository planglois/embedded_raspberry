#!/bin/sh

mkdir -p install toolchains build

if [ ! -e "$HOME/embedded_raspberry/install/bin/ct-ng" ]
then
  echo "Installing crosstool-ng."
  cd $HOME/embedded_raspberry/tools/ct-ng
  ./configure --prefix="$HOME/embedded_raspberry/install"
  make
  make install
  make distclean
fi
