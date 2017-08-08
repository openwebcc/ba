#!/bin/bash
#
# Öræfajökull, 9.8.2011, 26.8.2011, 27.8.2011
#

BASE=/home/rawdata/als/island/110809_oraefajokull02

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
            #-set_system_identifier "ALTM 1225"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    rm -f $TMP
done

# set day of year and year
cd $BASE/las
find . -name "*110809*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 221 2011 \;
find . -name "*110826*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 238 2011 \;
find . -name "*110827*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 239 2011 \;

# copy cleaned trajectories
cd $BASE/raw/str/bet
for BET in `ls *.bet`
do
    echo "creating $BASE/bet/$BET ..."
    cat $BET | awk '{gsub(/^28/,"",$2); print}' > $BASE/bet/$BET
done
