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

find /home/laser/rawdata/als/c4austria -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/engabreen -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/hef -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/montafon -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/musicals -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/schmirntal -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/vinschgau -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/als/vogis -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
find /home/laser/rawdata/tls/schmirntal -wholename "*/las/*.la[sz]" -exec /bin/sh $SCRIPTDIR/get_lasinfo.sh {} $REBUILD \;
