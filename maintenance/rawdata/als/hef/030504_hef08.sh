#!/bin/bash
#
# Hintereisferner, 04.05.2003
#

BASE=/home/laser/rawdata/als/hef/030504_hef08

# unpack ASCII rawdata and convert it to LAS
cd $BASE/raw/kach/all
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
            -parse xyzi \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 25832 \
            -set_file_creation 124 2003 \
            -set_system_identifier "ALTM 2050"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    rm -f $TMP
done
