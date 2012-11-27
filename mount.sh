#!/bin/sh

if [ $# != 1 ]
then
  echo "provide an image as argument."
  exit
fi;


sudo mount -t ext3 -o loop $1 rootfs
