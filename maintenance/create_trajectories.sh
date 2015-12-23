#!/bin/sh
#
# get original and generalized trajectories for each LAS file from overall trajectory file(s)
# force rebuilding by passing "rebuild" as commandline argument
#
# Usage: sh rebuild_trajectories.sh {rebuild}
#

REBUILD=""
if test "$1" = "rebuild"; then
    REBUILD=`echo "--rebuild"`
fi

find /home/laser/rawdata/als/c4austria -maxdepth 1 -mindepth 1 -type d -exec python /home/klaus/private/ba/tools/get_trajectories.py --mindist 100 --subdir {} $REBUILD \;
find /home/laser/rawdata/als/engabreen -maxdepth 1 -mindepth 1 -type d -exec python /home/klaus/private/ba/tools/get_trajectories.py --mindist 100 --subdir {} $REBUILD \;
find /home/laser/rawdata/als/hef -maxdepth 1 -mindepth 1 -type d -exec python /home/klaus/private/ba/tools/get_trajectories.py --mindist 100 --subdir {} $REBUILD \;
find /home/laser/rawdata/als/montafon -maxdepth 1 -mindepth 1 -type d -exec python /home/klaus/private/ba/tools/get_trajectories.py --mindist 100 --subdir {} $REBUILD \;
find /home/laser/rawdata/als/musicals -maxdepth 1 -mindepth 1 -type d -exec python /home/klaus/private/ba/tools/get_trajectories.py --mindist 100 --subdir {} $REBUILD \;
find /home/laser/rawdata/als/schmirntal -maxdepth 1 -mindepth 1 -type d -exec python /home/klaus/private/ba/tools/get_trajectories.py --mindist 100 --subdir {} $REBUILD \;
find /home/laser/rawdata/als/vinschgau -maxdepth 1 -mindepth 1 -type d -exec python /home/klaus/private/ba/tools/get_trajectories.py --mindist 100 --subdir {} $REBUILD \;
find /home/laser/rawdata/als/vogis -maxdepth 1 -mindepth 1 -type d -exec python /home/klaus/private/ba/tools/get_trajectories.py --mindist 100 --subdir {} $REBUILD \;
