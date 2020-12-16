#!/bin/sh
#
# sync temporary data from download area to laser drive
#

SOURCE=$1
SUBDIR=`echo $1 | sed "s#/home/institut/rawdata#/mnt/netappa/Laser/data#g"`
TARGET=`echo $SUBDIR | sed -r "s/[0-9]+$//g"`

echo "creating $SUBDIR ..."
cp -ruL $SOURCE $TARGET
find $SUBDIR -type f -printf "%f (%kK)\n"
echo
