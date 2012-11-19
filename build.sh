#!/bin/sh

if [ ! -e "$HOME/embedded_raspberry/install/bin/ct-ng" ]
then
  echo "You need to run setup.sh first"
  exit
fi

export PATH="$PATH:$HOME/embedded_raspberry/install/bin"

cd build

cp ../config/ct-ng/rpi-eglibc.conf .config

ct-ng build
