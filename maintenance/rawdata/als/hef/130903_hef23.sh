#!/bin/bash
#
# Hintereisferner, 03.09.2013
#

BASE=/home/rawdata/als/hef/130903_hef23

# unpack ASCII rawdata and convert it to LAS
cd $BASE/raw/str/ala
for GZ in `ls *.all.gz`
do
    TMP=`echo $BASE/raw/$GZ | sed s/.all.gz/.ala/`
    LAS=`echo $BASE/las/$GZ | sed s/.all.gz/.las/`

    echo "creating $LAS ..."

    # unpack and remove leading 32 from x-coordinates
    gunzip -c $GZ | awk '{gsub(/^32/,"",$2); print}' > $TMP

    # convert to LAS
    txt2las -i $TMP \
            -o $LAS \
            -parse txyzirn \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 25832 \
            -set_system_identifier "ALTM Gemini"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    rm -f $TMP
done

# set day in year and year for LAS files
cd $BASE/las
find . -name "*130903*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 246 2013 \;
find . -name "*130904*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 247 2013 \;

# copy cleaned trajectories
cd $BASE/raw/str/bet
for BET in `ls *.bet`
do
    echo "creating $BASE/bet/$BET ..."
    cat $BET | awk '{gsub(/^32/,"",$2); print}' > $BASE/bet/$BET
done
