#!/bin/bash
#
# create project skeleton for als / tls projects
#

# check input
if [ -z "$1" ]; then 
    echo "Usage: sh $0 TYPE SUBDIR NAME"
    echo "no project type specified (als|tls)"
    exit

elif [ -z "$2" ]; then 
    echo "Usage: sh $0 TYPE SUBDIR NAME"
    echo "no project subdirectory specified (e.g. hef)"
    exit
elif [ -z "$3" ]; then 
    echo "Usage: sh $0 TYPE SUBDIR NAME"
    echo "no project name specified (e.g. YYMMDD_name)"
    exit
else
    # everything is fine
    PTYPE=$1
    PDIR=$2
    PNAME=$3
fi


# create skeleton
if test "$PTYPE" = "als"; then
    # create ALS-data skeleton
    echo "going als"
    for DIR in `echo "raw las bet doc meta"`
    do
        mkdir -pv /home/laser/rawdata/$PTYPE/$PDIR/$PNAME/$DIR
    done
    sh set_perms.sh /home/laser/rawdata/$PTYPE/$PDIR/$PNAME

elif test "$PTYPE" = "tls"; then
    # create TLS-data skeleton
    echo "going tls"
    for DIR in `echo "raw las reg doc meta"`
    do
        mkdir -pv /home/laser/rawdata/$PTYPE/$PDIR/$PNAME/$DIR
    done
    sh set_perms.sh /home/laser/rawdata/$PTYPE/$PDIR/$PNAME

else
    echo "'$PTYPE' is not a valid project type"
    echo "Usage: sh $0 TYPE SUBDIR NAME"
fi
