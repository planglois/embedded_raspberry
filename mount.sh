#!/bin/sh

IS_MOUNTED=`mountpoint mnt -q; echo $?`

if [ $# != 1 ]
then
  echo "provide an image as argument."
  exit
fi

if [ $IS_MOUNTED = 0 ]
then
  echo "'mnt' already is a mountpoint, unmounting 'mnt'."
  sudo umount mnt
fi

sudo mount -t ext3 -o loop $1 mnt
