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

find /home/laser/rawdata/als/c4austria -maxdepth 2 -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/engabreen -maxdepth 2 -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/hef -maxdepth 2 -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/island -maxdepth 2 -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/montafon -maxdepth 2 -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/musicals -maxdepth 2 -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/schmirntal -maxdepth 2 -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/vinschgau -maxdepth 2 -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
find /home/laser/rawdata/als/vogis -maxdepth 2 -type d -name bet -exec python $SCRIPTDIR/get_trajectories.py --mindist 100 --trajdir {} $REBUILD \;
