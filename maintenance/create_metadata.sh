#!/bin/sh
#
# (re)create metadata for a given campaign
# force rebuilding of existing metadata by passing "rebuild" as commandline argument
#
# Usage: sh /home/institut/rawdata/maintenance/create_metadata.sh CAMPAIGNDIR {rebuild}
# Batch: process all campaigns in a given project directory with:
#        find /home/rawdata/als/PROJECT/ -mindepth 1 -maxdepth 1 -type d -exec sh /home/institut/rawdata/maintenance/create_metadata.sh {} rebuild \;
#

SCRIPTDIR=/home/institut/rawdata/maintenance/scripts/als

if [ -z "$1" ]; then 
    echo "Usage: sh $0 CAMPAIGNDIR"
    exit
fi

BASE=$1

REBUILD=""
if test "$2" = "rebuild"; then
    REBUILD=rebuild
    REBUILD_ARG=`echo "--rebuild"`
fi

# extract metadata from lasfiles with lasinfo
find $BASE/las -name "*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;

# create simplified concave hulls for lasfiles
find $BASE/las -name "*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_hull.sh {} 10 $REBUILD \;

# get original and generalized trajectories for each lasfile from overall trajectory file(s)
python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir $BASE/bet $REBUILD_ARG
