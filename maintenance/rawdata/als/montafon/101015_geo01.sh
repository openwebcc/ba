#!/bin/bash
#
# Montafon 13.10.2010, 14.10.2010, 15.10.2010
#

BASE=/home/rawdata/als/montafon/101015_geo01

cd $BASE/raw/str/ala
for GZ in `ls *.all.gz`
do
    TMP=`echo $BASE/raw/$GZ | sed s/.all.gz/.all/`
    LAS=`echo $BASE/las/$GZ | sed s/.all.gz/.las/`

    echo "creating $LAS ..."

    # unpack
    gunzip -c $GZ > $TMP

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

# set day of year and year
cd $BASE/las
find . -name "*101013*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 288 2010 \;
find . -name "*101014*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 289 2010 \;
find . -name "*101015*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 290 2010 \;

# copy trajectories
cp -av $BASE/raw/str/bet/*.bet $BASE/bet/
