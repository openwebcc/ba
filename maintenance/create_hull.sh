#!/bin/sh
#
# create simplified concave hulls for LAS files
# force rebuilding by passing "rebuild" as commandline argument
#
# Usage: sh rebuild_hull.sh {rebuild}
#

REBUILD=""
if test "$1" = "rebuild"; then
    REBUILD=rebuild
fi

find /home/laser/rawdata/als/ -wholename "*/las/*.la[sz]" -exec sh /home/klaus/private/ba/tools/get_hull.sh {} 10 rebuild \; &

find /home/laser/rawdata/als/c4austria -wholename "*/las/*.la[sz]" -exec /bin/sh /home/klaus/private/ba/tools/get_hull.sh {} 10 $REBUILD \;
find /home/laser/rawdata/als/engabreen -wholename "*/las/*.la[sz]" -exec /bin/sh /home/klaus/private/ba/tools/get_hull.sh {} 10 $REBUILD \;
find /home/laser/rawdata/als/hef -wholename "*/las/*.la[sz]" -exec /bin/sh /home/klaus/private/ba/tools/get_hull.sh {} 10 $REBUILD \;
find /home/laser/rawdata/als/montafon -wholename "*/las/*.la[sz]" -exec /bin/sh /home/klaus/private/ba/tools/get_hull.sh {} 10 $REBUILD \;
find /home/laser/rawdata/als/musicals -wholename "*/las/*.la[sz]" -exec /bin/sh /home/klaus/private/ba/tools/get_hull.sh {} 10 $REBUILD \;
find /home/laser/rawdata/als/schmirntal -wholename "*/las/*.la[sz]" -exec /bin/sh /home/klaus/private/ba/tools/get_hull.sh {} 10 $REBUILD \;
find /home/laser/rawdata/als/vinschgau -wholename "*/las/*.la[sz]" -exec /bin/sh /home/klaus/private/ba/tools/get_hull.sh {} 10 $REBUILD \;
find /home/laser/rawdata/als/vogis -wholename "*/las/*.la[sz]" -exec /bin/sh /home/klaus/private/ba/tools/get_hull.sh {} 10 $REBUILD \;
find /home/laser/rawdata/tls/schmirntal -wholename "*/las/*.la[sz]" -exec /bin/sh /home/klaus/private/ba/tools/get_hull.sh {} 10 $REBUILD \;
