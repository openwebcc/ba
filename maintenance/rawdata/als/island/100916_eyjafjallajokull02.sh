#!/bin/bash
#
# Eyjafjallajökull, 16.9.2010
#

BASE=/home/rawdata/als/island/100916_eyjafjallajokull02

# convert ASCII rawdata to LAS
cd $BASE/raw/str/all
for GZ in `ls *.all.gz`
do
    TMP=`echo $BASE/raw/$GZ | sed s/.all.gz/.all/`
    LAS=`echo $BASE/las/$GZ | sed s/.all.gz/.las/`

    echo "creating $LAS ..."

    # unpack and remove leading 27 from x-coordinates
    gunzip -c $GZ | awk '{gsub(/^27/,"",$2); print}' > $TMP

    # convert to LAS
    txt2las -i $TMP \
            -o $LAS \
            -parse txyzirn \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 32627 \
            -set_file_creation 259 2010 \
            #-set_system_identifier "ALTM 1225"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    rm -f $TMP
done

# copy cleaned trajectories
cd $BASE/raw/str/bet
for BET in `ls *.bet`
do
    echo "creating $BASE/bet/$BET ..."
    cat $BET | awk '{gsub(/^27/,"",$2); print}' > $BASE/bet/$BET
done
