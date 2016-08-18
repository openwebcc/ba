#!/bin/bash
#
# Hofsjökull, 13.10.2013, 14.10.2013
#

BASE=/home/laser/rawdata/als/island/131013_hofsjokull01

# convert ASCII rawdata to LAS
cd $BASE/raw/str/all
for GZ in `ls *.all.gz`
do
    TMP=`echo $BASE/raw/$GZ | sed s/.all.gz/.all/`
    LAS=`echo $BASE/las/$GZ | sed s/.all.gz/.las/`

    echo "creating $LAS ..."

    # unpack and remove leading 28 from x-coordinates
    gunzip -c $GZ | awk '{gsub(/^28/,"",$2); print}' > $TMP

    # convert to LAS
    txt2las -i $TMP \
            -o $LAS \
            -parse txyzirn \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 32628 \
            -set_system_identifier "ALTM 3100"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    rm -f $TMP
done

# set day of year and year
cd $BASE/las
find . -name "*131013*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 286 2013 \;
find . -name "*131014*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 287 2013 \;

# copy cleaned trajectories
cd $BASE/raw/str/bet
for BET in `ls *.bet`
do
    echo "creating $BASE/bet/$BET ..."
    cat $BET | awk '{gsub(/^28/,"",$2); print}' > $BASE/bet/$BET
done
