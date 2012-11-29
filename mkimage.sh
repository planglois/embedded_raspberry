#!/bin/sh

ERROR="ERROR:"

usage()
{
  echo "/-----------------------------------------\\"
  echo "| usage: ./mkimage.sh <output image file> |"
  echo "\\-----------------------------------------/"
}

if [ $0 != "./mkimage.sh" ]
then
  echo "$ERROR you need to run this script from it's current location."
  usage
  exit
fi

if [ $# != 1 ]
then
  echo "$ERROR: you need to provide an output image file name."
  usage
  exit
fi

if [ -f $1 ]
then
  echo "$ERROR the file $1 already exists."
  usage
  exit
fi

if [ ! -d rootfs ]
then
  echo "$ERROR could not find 'rootfs' directory in '$PWD'."
  usage
  exit
fi

if [ ! -d mnt ]
then
  mkdir mnt
fi

BLKSIZE=512

du rootfs -s -B $BLKSIZE > size.tmp
read SIZE DIR < size.tmp
rm size.tmp

echo "=> creating empty image of size $SIZE x $BLKSIZE..."
dd if=/dev/zero of=$1 bs=$BLKSIZE count=$SIZE

echo "=> installing ext3 filesystem..."
yes | sudo mke2fs -t ext3 $1

echo "=> mounting new empty image."
./mount.sh $1

echo "=> copying and backing up root file system content..."
./backup.sh > /dev/null
sudo cp -pr rootfs/* mnt
sync

echo "=> unmounting image."
sudo umount mnt

echo "done."
