#!/bin/sh
#
# create index for LAS files in subdir las/
#
# Usage: sh create_lasindex.sh LASFILE <rebuild>
# Batch: find /home/laser/rawdata/als/ -wholename "*/las/*.la[sz]" -exec sh /home/laser/rawdata/maintenance/scripts/als/create_lasindex.sh {} \; &
# Batch: find /home/laser/rawdata/als/ -wholename "*/las/*.la[sz]" -exec sh /home/laser/rawdata/maintenance/scripts/als/create_lasindex.sh {} rebuild \; &
#

#
# handle logging
#
LOG=/home/laser/rawdata/maintenance/scripts/als/logs/times_lasindex.csv
if [ ! -f "$LOG" ]; then
    echo "file;task;real;user;sys" > $LOG
fi

#
# make sure that LAS file is present
#
if [ -z "$1" ]; then 
    echo "Usage: sh create_lasindex.sh LASFILE <rebuild>"
    exit
else
    if [ ! -f "$1" ]; then
        echo "$1 is not a valid LAS file"
        exit
    fi
fi

#
# run lasindex on file
#
LAS=$1
LAX=`echo $LAS | sed s/\.[^\.]*$/.lax/`

if [ -f "$LAX" ]; then
    if test "$2" = "rebuild"; then
        echo "rebuilding lasindex for $LAS ..."
        /usr/bin/time -f "$LAS;lasindex;%E;%U;%S" lasindex -i $LAS 2>>$LOG
    else
        echo "skipping recreation of existing lasindex for $LAS ..."
        continue
    fi
else
    echo "creating lasindex for $LAS ..."
    /usr/bin/time -f "$LAS;lasindex;%E;%U;%S" lasindex -i $LAS 2>>$LOG
fi

#
# clean up debug messages of lasindex
#
# before complete 100000 -20
# after minimum_points 100000
# next largest interval gap is 1008
# after maximum_intervals 7860
# largest interval gap increased to 1770

grep -v 'before\|after\|next\|largest' $LOG > $LOG.tmp
mv $LOG.tmp $LOG

