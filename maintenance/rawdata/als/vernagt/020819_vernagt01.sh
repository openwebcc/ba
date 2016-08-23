#!/bin/bash
#
# Vernagtferner, 19.8.2002
#

BASE=/home/laser/rawdata/als/vernagt/020819_vernagt01

# convert ASCII rawdata to LAS
cd $BASE/raw/str/all
for GZ in `ls *.all.gz`
do
    TMP=`echo $BASE/raw/$GZ | sed s/.all.gz/.all/`
    LAS=`echo $BASE/las/$GZ | sed s/.all.gz/.las/`

    echo "creating $LAS ..."

    # unpack and remove leading 32 from x-coordinates
    gunzip -c $GZ | awk '{gsub(/^32/,"",$1); print}' > $TMP

    # convert to LAS
    txt2las -i $TMP \
            -o $LAS \
            -parse xyz \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 25832 \
            -set_file_creation 231 2002 \
            #-set_system_identifier "ALTM 1225"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    rm -f $TMP
done
