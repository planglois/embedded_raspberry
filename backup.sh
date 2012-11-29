#!/bin/sh

DATE=`date +%d-%m-%Y@%H-%M-%S`
ARCHIVE=rfs-$DATE.tar.gz
echo "backing up to archive/$ARCHIVE."
sudo tar czf archives/$ARCHIVE rootfs
