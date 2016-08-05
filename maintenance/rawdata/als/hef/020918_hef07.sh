#!/bin/bash
#
# Hintereisferner, 18.09.2002
#

BASE=/home/laser/rawdata/als/hef/020918_hef07

# unpack ASCII rawdata and convert it to LAS
cd $BASE/raw/str/all
for GZ in `ls *.all.gz`
do
    TMP=`echo $BASE/raw/$GZ | sed s/.all.gz/.all/`
    LAS=`echo $BASE/las/$GZ | sed s/.all.gz/.las/`

    echo "creating $LAS ..."

    # unpack and remove leading 32 from x-coordinates
    gunzip -c $GZ | awk '{gsub(/^32/,"",$2); print}' > $TMP

    # convert to LAS
    txt2las -i $TMP  \
            -o $LAS  \
            -parse txyzirn  \
            -reoffset 0 0 0  \
            -rescale 0.01 0.01 0.01  \
            -epsg 25832  \
            -set_file_creation 261 2002 \
            -set_system_identifier "ALTM 3033"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    rm -f $TMP
done

# copy cleaned trajectories (filter coords with 32N from mixed .bet file containing 33N as well)
cd $BASE/raw/str/bet
for BET in `ls *.bet`
do
    echo "creating $BASE/bet/$BET ..."
    head -1 $BET > $BASE/bet/$BET
    cat $BET | grep '^ *[0-9]*\.[0-9]* * 32' | awk '{gsub(/^32/,"",$2); print}' >> $BASE/bet/$BET
done

