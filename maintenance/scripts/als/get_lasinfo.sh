#!/bin/sh
#
# get info of LAS files in subdir las/
#
# Usage: sh get_lasinfo.sh LASFILE <rebuild>
# Batch: find /home/laser/rawdata/als/ -wholename "*/las/*.la[sz]" -exec sh /home/laser/rawdata/maintenance/scripts/als/get_lasinfo.sh {} \; &
# Batch: find /home/laser/rawdata/als/ -wholename "*/las/*.la[sz]" -exec sh /home/laser/rawdata/maintenance/scripts/als/get_lasinfo.sh {} rebuild \; &
#

#
# handle logging
#
CSV=/home/laser/rawdata/maintenance/scripts/als/logs/get_lasinfo.csv
if [ ! -f "$CSV" ]; then
    echo "file;task;real;user;sys" > $CSV
fi

#
# make sure that LAS file is present
#
if [ -z "$1" ]; then 
    echo "Usage: sh get_lasinfo.sh LASFILE <rebuild>"
    exit
else
    if [ ! -f "$1" ]; then
        echo "$1 does not exist"
        exit
    fi
fi

#
# get LAS info and write it to .info.txt file in parent metadata directory
#
LASPATH=$1
LASNAME=`basename $LASPATH`
METADIR=`dirname $LASPATH | sed s/las$/meta/`

if [ -f "$METADIR/$LASNAME.info.txt" ]; then
    if test "$2" = "rebuild"; then
        echo "rebuilding $METADIR/$LASNAME.info.txt ..."
        /usr/bin/time -f "$LASPATH;lasinfo;%E;%U;%S" lasinfo -quiet -i $LASPATH -o $METADIR/$LASNAME.info.txt -compute_density -repair 2>>$CSV
    else
        echo "ignoring $METADIR/$LASNAME.info.txt ..."
    fi
else
    echo "creating $METADIR/$LASNAME.info.txt ..."
    /usr/bin/time -f "$LASPATH;lasinfo;%E;%U;%S" lasinfo -quiet -i $LASPATH -o $METADIR/$LASNAME.info.txt -compute_density -repair 2>>$CSV
fi

