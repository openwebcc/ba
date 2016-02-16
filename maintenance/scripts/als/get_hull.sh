#!/bin/sh
#
# get WKT boundaries of LAS files in subdir las/
#
# Usage: sh get_hull.sh FILENAME [thin m] <rebuild>
# Batch: find /home/laser/rawdata/als/ -wholename "*/las/*.la[sz]" -exec sh /home/laser/rawdata/maintenance/scripts/als/get_hull.sh {} 10 \; &
# Batch: find /home/laser/rawdata/als/ -wholename "*/las/*.la[sz]" -exec sh /home/laser/rawdata/maintenance/scripts/als/get_hull.sh {} 10 rebuild \; &
#

#
# handle logging
#
CSV=/home/laser/rawdata/maintenance/scripts/als/logs/get_hull.csv
if [ ! -f "$CSV" ]; then
    echo "file;task;real;user;sys" > $CSV
fi

#
# make sure that input file exists
#
if [ -z "$1" ]; then 
    echo "Usage: sh get_hull.sh FILENAME [thin m] <rebuild>"
    exit
else
    if [ ! -f "$1" ]; then
        echo "$1 does not exist"
        exit
    fi
fi

#
# create simplified WKT geometry of boundary and write it to .hull.wkt file in parent metadata directory
#
LASPATH=$1
LASNAME=`basename $LASPATH`
METADIR=`dirname $LASPATH | sed s/las$/meta/`
THIN=$2

if [ -f "$METADIR/$LASNAME.hull.wkt" ]; then
    if test "$3" = "rebuild"; then
        echo "rebuilding $METADIR/$LASNAME.hull.wkt ..."
        /usr/bin/time -f "$LASPATH;lasprecision_thin$THIN;%E;%U;%S" /usr/bin/wine /usr/local/src/LAStools/bin/lasprecision.exe -i $LASPATH -o /tmp/$LASNAME -rescale 1 1 1 -thin_with_grid $THIN >>$CSV 2>&1
        /usr/bin/time -f "$LASPATH;lasboundary_wkt10;%E;%U;%S" /usr/bin/wine /usr/local/src/LAStools/bin/lasboundary.exe -i /tmp/$LASNAME -owkt -o $METADIR/$LASNAME.hull.wkt >>$CSV 2>&1
        rm -f /tmp/$LASNAME
    else
        echo "ignoring $METADIR/$LASNAME.hull.wkt ..."
    fi
else
    echo "creating $METADIR/$LASNAME.hull.wkt ..."
    /usr/bin/time -f "$LASPATH;lasprecision_thin$THIN;%E;%U;%S" /usr/bin/wine /usr/local/src/LAStools/bin/lasprecision.exe -i $LASPATH -o /tmp/$LASNAME -rescale 1 1 1 -thin_with_grid $THIN >>$CSV 2>&1
    /usr/bin/time -f "$LASPATH;lasboundary_wkt10;%E;%U;%S" /usr/bin/wine /usr/local/src/LAStools/bin/lasboundary.exe -i /tmp/$LASNAME -o $METADIR/$LASNAME.hull.wkt >>$CSV 2>&1
    rm -f /tmp/$LASNAME
fi

#
# clean up logfile - remove license and X server warnings
#
grep "file;\|lasprecision\|lasboundary" $CSV > $CSV.tmp
mv $CSV.tmp $CSV
