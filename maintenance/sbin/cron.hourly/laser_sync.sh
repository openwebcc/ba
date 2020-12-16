#!/bin/sh
#
# sync temporary data from downloadarea to laser drive
#

SOURCE=$1
TARGET=`echo $1 | sed "s#/home/institut/rawdata#/mnt/netappa/Laser/data#g"`
TARGET=`echo $TARGET | sed -r "s/[0-9]+$//g"`

cp -vruL $SOURCE $TARGET
