#!/bin/sh
#
# get original and generalized trajectories for each lasfiles from overall trajectory file(s)
# force rebuilding by passing "rebuild" as commandline argument
#
# Usage: sh create_trajectories.sh {rebuild}
#

SCRIPTDIR=/home/laser/rawdata/maintenance/scripts/als

REBUILD=""
if test "$1" = "rebuild"; then
    REBUILD=`echo "--rebuild"`
fi

find /home/laser/rawdata/als/c4austria -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/engabreen -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/hef -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/montafon -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/musicals -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/schmirntal -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/vinschgau -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/vogis -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
