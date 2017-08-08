#!/bin/bash
#
# get WKT boundaries of LAS files in subdir las/ from bounding box in corresponding meta/*.info.txt files
#
# Usage: /bin/bash get_hull_bbox.sh FILENAME <rebuild>
# Batch: find /home/rawdata/als/vogis -wholename "*/las/*.la[sz]" -exec /bin/bash /home/institut/rawdata/maintenance/scripts/als/get_hull_bbox.sh {} \; &
# Batch: find /home/rawdata/als/vogis -wholename "*/las/*.la[sz]" -exec /bin/bash /home/institut/rawdata/maintenance/scripts/als/get_hull_bbox.sh {} rebuild \; &
#

#
# make sure that input file exists
#
if [ -z "$1" ]; then 
    echo "Usage: /bin/bash get_hull_bbox.sh FILENAME <rebuild>"
    exit
else
    if [ ! -f "$1" ]; then
        echo "$1 does not exist"
        exit
    fi
fi

#
# create WKT geometry of boundary from bounding box and write it to .hull.wkt file in the metadata directory
#
LASPATH=$1
LASNAME=`basename $LASPATH`
METADIR=`dirname $LASPATH | sed s/las$/meta/`

# bail out if no .info.txt is present
if [ ! -f "$METADIR/$LASNAME.info.txt" ]; then
    echo "$METADIR/$LASNAME.info.txt does not exist. Please build it before you run this script"
    exit
fi

# split up lines with min/max X/Y to columns and create WKT polygon
MIN=( `cat $METADIR/$LASNAME.info.txt | grep "min x y z"` )
MAX=( `cat $METADIR/$LASNAME.info.txt | grep "max x y z"` )

# POLYGON ((minx miny, minx maxy, maxx maxy, maxx miny, minx miny))
WKT="POLYGON ((${MIN[4]} ${MIN[5]}, ${MIN[4]} ${MAX[5]}, ${MAX[4]} ${MAX[5]}, ${MAX[4]} ${MIN[5]}, ${MIN[4]} ${MIN[5]}))"

# write WKT polygon
if [ -f "$METADIR/$LASNAME.hull.wkt" ]; then
    if test "$2" = "rebuild"; then
        echo "rebuilding $METADIR/$LASNAME.hull.wkt ..."
        echo $WKT > "$METADIR/$LASNAME.hull.wkt"
    else
        echo "ignoring $METADIR/$LASNAME.hull.wkt ..."
    fi
else
    echo "creating $METADIR/$LASNAME.hull.wkt ..."
    echo $WKT > "$METADIR/$LASNAME.hull.wkt"
fi
