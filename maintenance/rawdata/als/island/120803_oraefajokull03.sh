#!/bin/bash
#
# Öræfajökull, 13.7.2012, 2.8.2012, 3.8.2011, 12.9.2012
#

BASE=/home/laser/rawdata/als/island/120803_oraefajokull03

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
find . -name "*120713*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 195 2012 \;
find . -name "*120802*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 215 2012 \;
find . -name "*120803*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 216 2012 \;
find . -name "*120912*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 256 2012 \;

# copy cleaned trajectories
cd $BASE/raw/str/bet
for BET in `ls *.bet`
do
    echo "creating $BASE/bet/$BET ..."
    cat $BET | awk '{gsub(/^28/,"",$2); print}' > $BASE/bet/$BET
done
