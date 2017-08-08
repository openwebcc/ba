#!/bin/sh
#
# get filesize, last modified and number of points for each LAS/LAZ file
#

CSV=/home/institut/rawdata/maintenance/scripts/als/logs/list_las_files.csv
echo "path;bytes;lastmod;point_type;points" > $CSV

for LASPATH in `find /home/rawdata/ -wholename "*/las/*.la[sz]" | grep -v "/raw/"`
do
    # set LAS/LAZ name and meta directory
    LASNAME=`basename $LASPATH`
    METADIR=`dirname $LASPATH | sed s/las$/meta/`

    # preset points and point type
    POINTS=-
    PTYPE=-

    # get size and last modified date of file
    BYTES_LASTMOD=`stat --printf "%s;%y" $LASPATH`

    # get number of points from lasinfo output file if any
    if [ -f "$METADIR/$LASNAME.info.txt" ]; then
        # try to get "regular" number of points
        POINTS=`grep "^  number of point records:" $METADIR/$LASNAME.info.txt | awk '{print $5}'`
        if [ $POINTS -eq 0 ]; then
            # try to get "extended" number of points
            POINTS=`grep "^  extended number of point records:" $METADIR/$LASNAME.info.txt | awk '{print $6}'`
            if [ -z $POINTS ]; then
                echo "WARNING: no point count for $LASPATH"
            else
                PTYPE=extended
            fi
        else
            PTYPE=regular
        fi
    else
        echo "WARNING: $METADIR/$LASNAME.info.txt not found"
    fi

    # write attributes to CSV
    echo "$LASPATH;$BYTES_LASTMOD;$PTYPE;$POINTS" >> $CSV
done

echo
echo "created $CSV"
