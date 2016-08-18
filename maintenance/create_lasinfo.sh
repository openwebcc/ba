#!/bin/sh
#
# extract metadata from lasfiles with lasinfo
# force rebuilding by passing "rebuild" as commandline argument
#
# Usage: sh create_lasinfo.sh {rebuild}
#

SCRIPTDIR=/home/laser/rawdata/maintenance/scripts/als

REBUILD=""
if test "$1" = "rebuild"; then
    REBUILD=rebuild
fi

find /home/laser/rawdata/als/c4austria -maxdepth 3 -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/engabreen -maxdepth 3 -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/hef -maxdepth 3 -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/island -maxdepth 3 -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/montafon -maxdepth 3 -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/musicals -maxdepth 3 -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/schmirntal -maxdepth 3 -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/vinschgau -maxdepth 3 -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/vogis -maxdepth 3 -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/tls/schmirntal -maxdepth 3 -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
