#!/bin/sh

######################################################################################################################################################
# function declaration
######################################################################################################################################################

usage()
{
  echo "/----------------------------------------------\\"
  echo "| usage: ./mkimage.sh <output image file> [-v] |"
  echo "\\----------------------------------------------/"
}

message()
{
  echo -e "\033[1m\033[32m====> \033[34m$1\033[0m"
}

getdirsize()
{
  echo `du $1 -s -B $BLK_SIZE | grep -o "[0-9]\+"`
}

getfilesize()
{
  echo `ls -s --block-size=$BLK_SIZE $1 | grep -o "[0-9]\+"`
}

######################################################################################################################################################
# initial checkings
######################################################################################################################################################

if [ $UID != 0 ]
then
  echo "you need to be root to run this script."
  usage
  exit
fi

if [ $# != 1 ]
then
  if [ $# = 2 ]
  then
    if [ $2 = "-v" ]
    then
      export VERBOSE="yes"
    else
      usage
      exit
    fi
  else
    usage
    exit
  fi
else
  export VERBOSE="no"
fi

if [ $0 != "./mkimage.sh" ]
then
  echo "you need to run this script from it's current location."
  usage
  exit
fi

export NEEDED_PROGRAMS="bc mkfs.vfat mkfs.ext2";

for PROG in $NEEDED_PROGRAMS
do
  export PROG=$PROG
  if [ ! `which $PROG 2> /dev/null; echo #?` ]
  then
    echo "you need $PROG installed in your system and present in PATH."
    usage
    exit
  fi
done

######################################################################################################################################################
# variables initialization
######################################################################################################################################################

if [ $VERBOSE = "yes" ]
then
  export REDIRECT=`tty`
else
  export REDIRECT="/dev/null"
fi

export RFS_DIR="rootfs"
export MNT_DIR="mnt"
export IMAGE_TOOL_DIR="tools/mkimage"
export FIRWARE_DIR="firmware/boot"
export FIRWARE="$FIRWARE_DIR/COPYING.linux  \
                $FIRWARE_DIR/LICENCE.broadcom \
                $FIRWARE_DIR/bootcode.bin \
                $FIRWARE_DIR/fixup.dat \
                $FIRWARE_DIR/fixup_cd.dat \
                $FIRWARE_DIR/start.elf  \
                $FIRWARE_DIR/start_cd.elf"
export LINUX_KERNEL="linux/arch/arm/boot/Image"
export CONFIG_DIR="config/linux/boot"

export BLK_SIZE=512

export IMG=$1
export LOOP
export OFFSET=4096


export RFS_SIZE=`getdirsize $RFS_DIR`
export FIRWARE_SIZE=0

for FILE in $FIRWARE
do
  SIZE=`getfilesize $FILE`
  FIRWARE_SIZE=`echo "$FIRWARE_SIZE + $SIZE" | bc`
done

BROADCOM_KERNEL_SIZE=`getfilesize $FIRWARE_DIR/kernel.img`
BROADCOM__CUTDOWN_KERNEL_SIZE=`getfilesize $FIRWARE_DIR/kernel_cutdown.img`
BROADCOM__EMERGENCY_KERNEL_SIZE=`getfilesize $FIRWARE_DIR/kernel_emergency.img`

if [ -f $LINUX_KERNEL ]
then
  
  CURRENT_DIR=$PWD
  cd $IMAGE_TOOL_DIR
  ./imagetool-uncompressed.py $CURRENT_DIR/$LINUX_KERNEL
  cd $CURRENT_DIR
  export LINUX_KERNEL=$IMAGE_TOOL_DIR/kernel.img
  HOMEMADE_KERNEL_SIZE=`getfilesize $LINUX_KERNEL`
  export KERNEL_SIZE=`echo "$HOMEMADE_KERNEL_SIZE + $BROADCOM_KERNEL_SIZE + $BROADCOM__CUTDOWN_KERNEL_SIZE + $BROADCOM__EMERGENCY_KERNEL_SIZE" | bc`
else
  export KERNEL_SIZE=`echo "$BROADCOM_KERNEL_SIZE + $BROADCOM__CUTDOWN_KERNEL_SIZE + $BROADCOM__EMERGENCY_KERNEL_SIZE" | bc`
fi

export CONFIG_SIZE=`getdirsize config/linux/boot`
export BOOT_SIZE=`echo "$CONFIG_SIZE + $FIRWARE_SIZE + $KERNEL_SIZE + $OFFSET" | bc`

export FULL_SIZE=`echo "$RFS_SIZE + $BOOT_SIZE + $OFFSET" | bc`

export HEADS=255
export SECTORS=63
export CYLINDERS=`echo "$FULL_SIZE/($HEADS*$SECTORS)" | bc`

######################################################################################################################################################
# creating and empty image and associating it to a loop device
######################################################################################################################################################

message "creating an emty `echo "($BLK_SIZE * $FULL_SIZE)/1000000" | bc` megabytes image"

dd if=/dev/zero of=$IMG bs=$BLK_SIZE count=$FULL_SIZE > $REDIRECT 2>&1
LOOP_IMG=`losetup -f --show $IMG`
LOOP+=" $LOOP_IMG"

message "image associated to '$LOOP_IMG'"

######################################################################################################################################################
# setting up disk
######################################################################################################################################################

message "creating partition table with $CYLINDERS cylinders, $HEADS heads and $SECTORS sectors"
echo w | fdisk -H $HEADS -C $CYLINDERS -S $SECTORS $LOOP_IMG > $REDIRECT 2>&1

message "probing fdisk for the first sector available"
export PART_BOOT_START=`
  {
    echo n
    echo p
    echo 1 
  } | fdisk -H $HEADS -C $CYLINDERS -S $SECTORS $LOOP_IMG | grep -o "default [0-9][0-9]\+" | grep -o "[0-9]\+"
`

export PART_BOOT_START_B=`echo "$BLK_SIZE * $PART_BOOT_START" | bc`
export PART_BOOT_END=`echo "$BOOT_SIZE + $PART_BOOT_START" | bc`

message "creating first partition from sector $PART_BOOT_START to sector $PART_BOOT_END, which will later contain the bootloader and the linux kernel"
{
  echo n
  echo p
  echo 1
  echo $PART_BOOT_START
  echo $PART_BOOT_END
  echo w
} | fdisk -H $HEADS -C $CYLINDERS -S $SECTORS $LOOP_IMG > $REDIRECT 2>&1

message "setting up flags for the first partition"
{
  echo t
  echo 
  echo c
  echo w
} | fdisk -H $HEADS -C $CYLINDERS -S $SECTORS $LOOP_IMG > $REDIRECT 2>&1

message "probing fdisk for the next and the last sectors available"
{
  echo n
  echo p
  echo 2
  echo
} | fdisk -H $HEADS -C $CYLINDERS -S $SECTORS $LOOP_IMG | grep -o "default [0-9][0-9]\+" | grep -o "[0-9]\+" > default.tmp 2> $REDIRECT

read PART_RFS_START < default.tmp
cat default.tmp | tail -n 1 > default_rfs.tmp
read PART_RFS_END < default_rfs.tmp
rm default.tmp default_rfs.tmp

export PART_RFS_START=echo $PART_RFS_START_END | head -n 1
export PART_RFS_START_B=`echo "$BLK_SIZE * $PART_RFS_START" | bc`
export PART_RFS_END=$PART_RFS_END

message "creating second partition from sector $PART_RFS_START to sector $PART_RFS_END, which will contain the root file system"
{
  echo n
  echo p
  echo 2
  echo $PART_RFS_START
  echo $PART_RFS_END
  echo w
} | fdisk -H $HEADS -C $CYLINDERS -S $SECTORS $LOOP_IMG > $REDIRECT 2>&1

######################################################################################################################################################
# setting up file systems and installing the files on the partitions
######################################################################################################################################################

LOOP_IMG_BOOT=`losetup -f --show -o $PART_BOOT_START_B $IMG`
LOOP+=" $LOOP_IMG_BOOT"

LOOP_IMG_RFS=`losetup -f --show -o $PART_RFS_START_B $IMG`
LOOP+=" $LOOP_IMG_RFS"

message "associated loop devices '$LOOP_IMG_BOOT' and '$LOOP_IMG_RFS' to each partition"

message "setting up file systems in FAT16 and ext2"

mkfs.vfat -F 16 $LOOP_IMG_BOOT > $REDIRECT 2>&1

fsck.vfat $LOOP_IMG_BOOT > $REDIRECT 2>&1

mkfs.ext2 $LOOP_IMG_RFS > $REDIRECT 2>&1

fsck.ext2 $LOOP_IMG_RFS > $REDIRECT 2>&1

if [ ! `mountpoint $MNT_DIR -q; echo $?` ]
then
  umount $MNT_DIR
fi

message "mounting boot partition"

mount -t vfat $LOOP_IMG_BOOT $MNT_DIR

message "copying firware, linux kernel and its configuration"

for FILE in $FIRWARE
do
  cp $FILE $MNT_DIR
done

cp $FIRWARE_DIR/kernel.img $MNT_DIR/bc_kernel.img
cp $FIRWARE_DIR/kernel_cutdown.img $MNT_DIR/bc_kernel_cutdown.img
cp $FIRWARE_DIR/kernel_emergency.img $MNT_DIR/bc_kernel_emergency.img

if [ -f $LINUX_KERNEL ]
then
  cp $LINUX_KERNEL $MNT_DIR
else
  mv $MNT_DIR/{bc_,}kernel.img
fi

cat $CONFIG_DIR/cmdline.txt | tee $MNT_DIR/cmdline.txt > $REDIRECT 2>&1
cat $CONFIG_DIR/config.txt | tee $MNT_DIR/config.txt > $REDIRECT 2>&1

sync
umount $MNT_DIR

message "mounting root partition"
mount -t ext2 $LOOP_IMG_RFS $MNT_DIR
message "populating file system"
cp -r -a $RFS_DIR/* $MNT_DIR
sync
umount $MNT_DIR

######################################################################################################################################################
# final clearup
######################################################################################################################################################

message "releasing loop devices '$LOOP'"

losetup -d $LOOP
